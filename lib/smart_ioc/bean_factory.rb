# Instantiates beans according to their scopes
class SmartIoC::BeanFactory
  include SmartIoC::Errors
  include SmartIoC::Args

  attr_reader :bean_file_loader

  def initialize(bean_definitions_storage, extra_package_contexts)
    @bean_definitions_storage = bean_definitions_storage
    @extra_package_contexts   = extra_package_contexts
    @bean_file_loader         = SmartIoC::BeanFileLoader.new
    @singleton_scope          = SmartIoC::Scopes::Singleton.new
    @prototype_scope          = SmartIoC::Scopes::Prototype.new
    @thread_scope             = SmartIoC::Scopes::Request.new
  end

  def clear_scopes
    all_scopes.each(&:clear)
  end

  def force_clear_scopes
    all_scopes.each(&:force_clear)
  end

  # Get bean from the container by it's name, package, context
  # @param bean_name [Symbol] bean name
  # @param package [Symbol] package name
  # @param context [Symbol] context
  # @return bean instance
  # @raise [ArgumentError] if bean is not found
  # @raise [ArgumentError] if ambiguous bean definition was found
  def get_bean(bean_name, package: nil, context: nil)
    check_arg(bean_name, :bean_name, Symbol)
    check_arg(package, :package, Symbol) if package
    check_arg(context, :context, Symbol) if context

    get_or_build_bean(bean_name, package, context)
  end

  private

  def get_or_build_bean(bean_name, package, context, history = Set.new)
    @bean_file_loader.require_bean(bean_name)

    context         = autodetect_context(bean_name, package, context)
    bean_definition = @bean_definitions_storage.find(bean_name, package, context)
    scope           = get_scope(bean_definition)
    scope_bean      = scope.get_bean(bean_definition.klass)
    is_recursive    = history.include?(bean_name)

    history << bean_name

    if scope_bean && scope_bean.loaded
      update_dependencies(scope_bean.bean, bean_definition)
      scope_bean.bean
    else
      if is_recursive
        raise LoadRecursion.new(bean_definition)
      end

      beans_cache = init_bean_definition_cache(bean_definition)

      autodetect_bean_definitions_for_dependencies(bean_definition)
      preload_beans(bean_definition, beans_cache[bean_definition])
      load_bean(bean_definition, beans_cache)
    end
  end

  def init_bean_definition_cache(bean_definition)
    {
      bean_definition => {
        scope_bean: nil,
        dependencies: {
        }
      }
    }
  end

  def update_dependencies(bean, bean_definition, updated_beans = {})
    bean_definition.dependencies.each do |dependency|
      bd = autodetect_bean_definition(
        dependency.ref, dependency.package, bean_definition.package
      )

      scope    = get_scope(bean_definition)
      dep_bean = updated_beans[bd]

      if !dep_bean && scope_bean = scope.get_bean(bd.klass)
        dep_bean = scope_bean.bean
      end

      if !dep_bean
        dep_bean = get_or_build_bean(bd.name, bd.package, bd.context)

        bean.instance_variable_set(:"@#{dependency.bean}", dep_bean)

        if !scope.is_a?(SmartIoC::Scopes::Prototype)
          updated_beans[bd] = dep_bean
        end
      else
        update_dependencies(dep_bean, bd, updated_beans)
      end
    end
  end

  def autodetect_context(bean_name, package, context)
    return context if context

    if package
      @extra_package_contexts.get_context(package)
    else
      bean_definition = autodetect_bean_definition(bean_name, package, nil)
      bean_definition.context
    end
  end

  def autodetect_bean_definitions_for_dependencies(bean_definition)
    bean_definition.dependencies.each do |dependency|
      next if dependency.bean_definition

      @bean_file_loader.require_bean(dependency.ref)

      dependency.bean_definition = autodetect_bean_definition(
        dependency.ref, dependency.package, bean_definition.package
      )

      autodetect_bean_definitions_for_dependencies(dependency.bean_definition)
    end
  end

  def autodetect_bean_definition(bean, package, parent_bean_package)
    if package
      bean_context = @extra_package_contexts.get_context(package)
      bds = @bean_definitions_storage.filter_by_with_drop_to_default_context(bean, package, bean_context)

      return bds.first if bds.size == 1
      raise ArgumentError, "bean :#{bean} is not found in package :#{package}"
    end

    if parent_bean_package
      bean_context = @extra_package_contexts.get_context(parent_bean_package)
      bds = @bean_definitions_storage.filter_by_with_drop_to_default_context(bean, parent_bean_package, bean_context)

      return bds.first if bds.size == 1
    end

    bds = @bean_definitions_storage.filter_by(bean)
    bds_by_package = bds.group_by(&:package)
    smart_bds = []

    bds_by_package.each do |package, bd_list|
      # try to find bean definition with package context
      bd = bd_list.detect {|bd| bd.context == @extra_package_contexts.get_context(bd.package)}
      smart_bds << bd if bd

      # last try: find for :default context
      if !bd
        bd = bd_list.detect {|bd| bd.context == SmartIoC::Container::DEFAULT_CONTEXT}
        smart_bds << bd if bd
      end
    end

    if smart_bds.size > 1
      raise ArgumentError, "Unable to autodetect bean :#{bean}.\nSeveral definitions were found.\n#{smart_bds.map(&:inspect).join("\n\n")}. Set package directly for injected dependency"
    end

    if smart_bds.size == 0
      raise ArgumentError, "Unable to find bean :#{bean} in any package."
    end

    return smart_bds.first
  end

  def preload_beans(bean_definition, beans_cache)
    scope = get_scope(bean_definition)

    if scope_bean = scope.get_bean(bean_definition.klass)
      beans_cache[:scope_bean] = scope_bean
    else
      preload_bean_instance(bean_definition, beans_cache)
    end

    bean_definition.dependencies.each do |dependency|
      bd = dependency.bean_definition

      next if beans_cache[:dependencies].has_key?(bd)

      dep_bean_cache = init_bean_definition_cache(bd)
      beans_cache[:dependencies].merge!(dep_bean_cache)
      preload_beans(bd, dep_bean_cache[bd])
    end
  end

  def preload_bean_instance(bean_definition, beans_cache)
    return if beans_cache[:scope_bean]

    scope = get_scope(bean_definition)
    scope_bean = scope.get_bean(bean_definition.klass)

    if scope_bean
      beans_cache[:scope_bean] = scope_bean
      return scope_bean
    end

    bean = if bean_definition.is_instance?
      bean_definition.klass.allocate
    else
      bean_definition.klass
    end

    scope_bean = SmartIoC::Scopes::Bean.new(bean, !bean_definition.has_factory_method?)

    scope.save_bean(bean_definition.klass, scope_bean)
    beans_cache[:scope_bean] = scope_bean

    scope_bean
  end

  def init_factory_bean(bean_definition, bd_opts)
    scope_bean = bd_opts[:scope_bean]

    if !scope_bean.loaded
      scope_bean.set_bean(scope_bean.bean.send(bean_definition.factory_method), true)
    end
  end

  def init_zero_dep_factory_beans(beans_cache)
    beans_cache.each do |bean_definition, bd_opts|
      if bean_definition.has_factory_method?
        has_factory_dependencies = !!bean_definition.dependencies.detect {|dep| dep.bean_definition.has_factory_method?}

        if bean_definition.dependencies.size == 0 || !has_factory_dependencies
          init_factory_bean(bean_definition, bd_opts)
        end
      end
      init_zero_dep_factory_beans(bd_opts[:dependencies]) if !bd_opts[:dependencies].empty?
    end
  end

  def collect_dependent_factory_beans(beans_cache, collection)
    beans_cache.each do |bean_definition, bd_opts|
      if bean_definition.has_factory_method? && bean_definition.dependencies.size > 0
        collection << bean_definition
      end
      collect_dependent_factory_beans(bd_opts[:dependencies], collection)
    end

    collection
  end

  def init_dependent_factory_beans(beans_cache)
    dependent_factory_beans = collect_dependent_factory_beans(beans_cache, [])

    dependent_factory_beans.each do |bean_definition|
      cross_refference_bd = get_cross_refference(dependent_factory_beans, bean_definition)

      if cross_refference_bd
        has_factory_dependencies = !!cross_refference_bd.dependencies.detect {|dep| dep.bean_definition.has_factory_method?}
        
        if has_factory_dependencies
          raise ArgumentError, "Factory method beans should not cross refference each other. Bean :#{bean_definition.name} cross refferences bean :#{cross_refference_bd.name}."
        end
      end
    end

    beans_cache.each do |bean_definition, bd_opts|
      if bean_definition.has_factory_method? && bean_definition.dependencies.size > 0
        inject_beans(bean_definition, bd_opts)
        init_factory_bean(bean_definition, bd_opts)
      end
      init_dependent_factory_beans(bd_opts[:dependencies])
    end
  end

  def load_bean(bean_definition, beans_cache)
    init_zero_dep_factory_beans(beans_cache)
    init_dependent_factory_beans(beans_cache)
    inject_beans(bean_definition, beans_cache[bean_definition])
    beans_cache[bean_definition][:scope_bean].bean
  end

  def inject_beans(bean_definition, beans_cache)
    bean = beans_cache[:scope_bean].bean
    bean_definition.dependencies.each do |dependency|
      bd = dependency.bean_definition
      dep_bean = beans_cache[:dependencies][bd][:scope_bean].bean
      bean.instance_variable_set(:"@#{dependency.bean}", dep_bean)
      inject_beans(bd, beans_cache[:dependencies][bd])
    end
  end

  def get_cross_refference(refer_bean_definitions, current_bean_definition, seen_bean_definitions = [])
    current_bean_definition.dependencies.each do |dependency|
      bd = dependency.bean_definition

      next if seen_bean_definitions.include?(bd)

      if refer_bean_definitions.include?(bd)
        return bd
      end

      if crbd = get_cross_refference(refer_bean_definitions, bd, seen_bean_definitions + [bd])
        return crbd
      end
    end

    nil
  end

  def all_scopes
    [@singleton_scope, @prototype_scope, @thread_scope]
  end

  def get_scope(bean_definition)
    case bean_definition.scope
    when SmartIoC::Scopes::Singleton::VALUE
      @singleton_scope
    when SmartIoC::Scopes::Prototype::VALUE
      @prototype_scope
    when SmartIoC::Scopes::Request::VALUE
      @thread_scope
    else
      raise ArgumentError, "bean definition for :#{bean_definition.name} has unsupported scope :#{bean_definition.scope}"
    end
  end
end
