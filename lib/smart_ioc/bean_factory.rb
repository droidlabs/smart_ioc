# Instantiates beans according to their scopes
class SmartIoC::BeanFactory
  def initialize(bean_definitions_storage, extra_package_contexts)
    @bean_definitions_storage = bean_definitions_storage
    @extra_package_contexts   = extra_package_contexts
    @singleton_scope          = SmartIoC::Scopes::Singleton.new
    @prototype_scope          = SmartIoC::Scopes::Prototype.new
    @thread_scope             = SmartIoC::Scopes::Request.new
    @bean_file_loader         = SmartIoC::BeanFileLoader.new
    @bean_definitions_cache   = {}
  end

  def clear_scopes
    all_scopes.each(&:clear)
  end

  def force_clear_scopes
    all_scopes.each(&:force_clear)
  end

  # Get bean from the container by it's name, package, context
  # @param name [Symbol] bean name
  # @param package [Symbol] package name
  # @param context [Symbol] context
  # @return bean instance
  # @raise [ArgumentError] if bean is not found
  # @raise [ArgumentError] if ambiguous bean definition was found
  def get_bean(name, package: nil, context: nil)
    get_or_load_bean(name, package, context)
  end

  private

  def get_or_load_bean(name, package, context, parent_bean_package = nil)
    context = if package
      @extra_package_contexts.get_context(package)
    else
      SmartIoC::Container::DEFAULT_CONTEXT
    end

    bean_definition = get_bean_definition(name, package, context, parent_bean_package)
    scope = get_scope(bean_definition)

    scope.get_bean(bean_definition.klass) || load_bean(bean_definition, scope, parent_bean_package)
  end

  # @param bean_name [Symbol]
  # @param [Symbol] bean name
  # @param [Symbol] bean name
  def get_bean_definition(bean_name, package_name, context_name, parent_bean_package)
    @bean_file_loader.require_bean(bean_name)

    bean_definitions = @bean_definitions_storage.find_all(bean_name, package_name, context_name)

    if package_name.nil? && !parent_bean_package.nil?
      filtered_bean_definitions = bean_definitions.select do |bd|
        bd.package == parent_bean_package
      end

      if filtered_bean_definitions.size > 0
        bean_definitions = filtered_bean_definitions
      end
    end

    if bean_definitions.size == 0
      raise ArgumentError,  "bean :#{bean_name} is not defined"
    elsif bean_definitions.size > 1
      raise ArgumentError, "several packages for bean :#{bean_name} were found (#{bean_definitions.inspect}). Please specify package directly"
    end

    bean_definitoin = bean_definitions.first

    bean_definitoin
  end

  def load_bean(bean_definition, scope, parent_bean_package = nil)
    bean = if bean_definition.is_instance?
      bean_definition.klass.allocate
    else
      bean_definition.klass
    end

    set_bean_dependencies(bean, bean_definition, parent_bean_package)

    if bean_definition.has_factory_method?
      bean = bean.send(bean_definition.factory_method)
    end

    scope.save_bean(bean_definition.klass, bean)

    bean
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

  def all_scopes
    [@singleton_scope, @prototype_scope, @thread_scope]
  end
end
