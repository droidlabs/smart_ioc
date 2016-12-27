# Instantiates beans according to their scopes
class SmartIoC::BeanFactory
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
    context ||= if package
      @extra_package_contexts.get_context(package)
    else
      bean_definition = autodetect_bean_definition(bean_name, package, nil)
      bean_definition.context
    end

    if !context.is_a?(Symbol)
      raise ArgumentError, 'context should be a Symbol'
    end

    @bean_file_loader.require_bean(bean_name)

    bds = @bean_definitions_storage.filter_by(bean_name, package, context)
    if bds.size > 1
      raise ArgumentError, "Unable to create bean :#{bean_name}.\nSeveral definitions were found.\n#{bds.map(&:inspect).join("\n\n")}"
    elsif bds.size == 0
      raise ArgumentError, "Unable to find bean :#{bean_name} in any packages"
    end

    bean_definition = bds.first
    dependency_cache = {}
    beans_cache = {}

    autodetect_bean_definitions_for_dependencies(bean_definition, dependency_cache)
    preload_beans(bean_definition, dependency_cache, beans_cache)
    load_bean(bean_definition, dependency_cache, beans_cache)
  end

  private

  def autodetect_bean_definitions_for_dependencies(bean_definition, dependency_cache)
    bean_definition.dependencies.each do |dependency|
      next if dependency_cache.has_key?(dependency)

      @bean_file_loader.require_bean(dependency.ref)

      bd = autodetect_bean_definition(
        dependency.ref, dependency.package, bean_definition.package
      )

      dependency_cache[dependency] = bd

      autodetect_bean_definitions_for_dependencies(bd, dependency_cache)
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

  def preload_beans(bean_definition, dependency_cache, beans_cache)
    preload_bean_instance(bean_definition, beans_cache)

    bean_definition.dependencies.each do |dependency|
      bd = dependency_cache[dependency]

      next if beans_cache.has_key?(bd)
      preload_beans(bd, dependency_cache, beans_cache)
    end
  end

  def preload_bean_instance(bean_definition, beans_cache)
    return beans_cache[bean_definition] if beans_cache.has_key?(bean_definition)

    scope = get_scope(bean_definition)
    bean = scope.get_bean(bean_definition.klass)

    if bean
      beans_cache[bean_definition] = bean
      return bean
    end

    bean = if bean_definition.is_instance?
      bean_definition.klass.allocate
    else
      bean_definition.klass
    end

    scope.save_bean(bean_definition.klass, bean)
    beans_cache[bean_definition] = bean

    bean
  end

  def load_bean(bean_definition, dependency_cache, beans_cache)
    # first let's setup beans with factory_methods
    zero_dep_bd_with_factory_methods = []
    bd_with_factory_methods = []

    beans_cache.each do |bean_definition, bean|
      if bean_definition.has_factory_method?
        if bean_definition.dependencies.size == 0
          zero_dep_bd_with_factory_methods << bean_definition
        else
          bd_with_factory_methods << bean_definition
        end
      end
    end

    bd_with_factory_methods.each do |bean_definition|
      if cross_refference_bd = get_cross_refference(bd_with_factory_methods, bean_definition, dependency_cache)
        raise ArgumentError, "Factory method beans should not cross refference each other. Bean :#{bean_definition.name} cross refferences bean :#{cross_refference_bd.name}."
      end
    end

    (zero_dep_bd_with_factory_methods + bd_with_factory_methods).each do |bean_definition|
      inject_beans(bean_definition, dependency_cache, beans_cache)
      bean = beans_cache[bean_definition]
      bean = bean.send(bean_definition.factory_method)
      beans_cache[bean_definition] = bean
    end

    inject_beans(bean_definition, dependency_cache, beans_cache)

    beans_cache[bean_definition]
  end

  def inject_beans(bean_definition, dependency_cache, beans_cache)
    bean = beans_cache[bean_definition]
    bean_definition.dependencies.each do |dependency|
      bd = dependency_cache[dependency]
      dep_bean = beans_cache[bd]
      bean.instance_variable_set(:"@#{dependency.bean}", dep_bean)
      inject_beans(bd, dependency_cache, beans_cache)
    end
  end

  def get_cross_refference(refer_bean_definitions, current_bean_definition, dependency_cache, seen_bean_definitions = [])
    current_bean_definition.dependencies.each do |dependency|
      bd = dependency_cache[dependency]

      next if seen_bean_definitions.include?(bd)

      if refer_bean_definitions.include?(bd)
        return bd
      end

      if crbd = get_cross_refference(refer_bean_definitions, bd, dependency_cache, seen_bean_definitions + [bd])
        return crbd
      end
    end

    nil
  end

  def set_bean_dependencies(bean, bean_definition, parent_bean_package)
    bean_definition.dependencies.each do |dependency|
      context = if dependency.package
        @extra_package_contexts.get_context(dependency.package)
      end

      dependent_bean = get_or_load_bean(dependency.ref, dependency.package, context, bean_definition.package)

      bean.instance_variable_set(:"@#{dependency.bean}", dependent_bean)
    end
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
