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
    @semaphore                = Mutex.new
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
  # @param parent_bean_definition [SmartIoC::BeanDefinition] parent bean definition
  # @param context [Symbol] context
  # @return bean instance
  # @raise [ArgumentError] if bean is not found
  # @raise [ArgumentError] if ambiguous bean definition was found
  def get_bean(bean_name, package: nil, parent_bean_definition: nil, context: nil, parent_bean_name: nil)
    check_arg(bean_name, :bean_name, Symbol)
    check_arg(package, :package, Symbol) if package
    check_arg(parent_bean_definition, :parent_bean_definition, SmartIoC::BeanDefinition) if parent_bean_definition
    check_arg(context, :context, Symbol) if context

    @bean_file_loader.require_bean(bean_name)

    parent_package_name = parent_bean_definition ? parent_bean_definition.package : nil
    context = autodetect_context(bean_name, package, parent_package_name, context, parent_bean_name)
    bean_definition = @bean_definitions_storage.find(bean_name, package, context, parent_package_name)
    scope = get_scope(bean_definition)
    bean = scope.get_bean(bean_definition.klass)

    if !bean
      bean = init_bean(bean_definition)
    end

    scope.save_bean(bean_definition.klass, bean)
    bean
  rescue SmartIoC::Errors::AmbiguousBeanDefinition => e
    e.parent_bean_definition = parent_bean_definition
    raise e
  end

  private

  def init_bean(bean_definition)
    bean = if bean_definition.is_instance?
      bean_definition.klass.allocate
    else
      bean_definition.klass
    end

    if bean_definition.has_factory_method?
      bean = bean.send(bean_definition.factory_method)
    end

    if bean_definition.after_init
      bean.send(bean_definition.after_init)
    end

    bean
  end

  def autodetect_context(bean_name, package, parent_bean_package, context, parent_bean_name)
    return context if context

    if package
      @extra_package_contexts.get_context(package)
    else
      bean_definition = autodetect_bean_definition(bean_name, package, parent_bean_package, parent_bean_name)
      @extra_package_contexts.get_context(bean_definition.package)
    end
  end

  def autodetect_bean_definition(bean, package, parent_bean_package, parent_bean_name)
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
      raise ArgumentError.new(
%Q(Unable to autodetect bean :#{bean}#{parent_bean_name ? " for bean :#{parent_bean_name}" : ''}.
Several definitions were found:\n
#{smart_bds.map(&:inspect).join("\n\n")}.
Set package directly for injected dependency
)
      )
    end

    if smart_bds.size == 0
      raise ArgumentError, "Unable to find bean :#{bean} in any package."
    end

    return smart_bds.first
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
