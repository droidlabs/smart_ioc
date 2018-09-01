class SmartIoC::BeanDefinition
  include SmartIoC::Args

  attr_reader :name, :package, :path, :klass, :scope, :instance, :factory_method,
              :context, :dependencies, :after_init

  def initialize(name:, package:, path:, klass:, scope:, context:, instance:, factory_method:, after_init:)
    not_nil(name, :name)
    not_nil(package, :package)
    not_nil(path, :path)
    not_nil(klass, :klass)
    not_nil(scope, :scope)
    not_nil(context, :context)
    not_nil(instance, :instance)

    @name           = name
    @package        = package
    @path           = path
    @klass          = klass
    @scope          = scope
    @instance       = instance
    @factory_method = factory_method
    @after_init     = after_init
    @context        = context

    @dependencies = []
  end

  def add_dependency(bean_name:, ref: nil, package: nil)
    check_arg(bean_name, :bean_name, Symbol)
    check_arg(ref, :ref, Symbol) if ref
    check_arg(package, :package, Symbol) if package

    @dependencies << SmartIoC::BeanDependency.new(
      bean:    bean_name,
      ref:     ref,
      package: package
    )
  end

  def is_instance?
    @instance
  end

  def has_factory_method?
    !@factory_method.nil?
  end

  def ==(bean_definition)
    bean_definition.klass == @klass
  end

  def singleton?
    SmartIoC::Scopes::Singleton::VALUE == @scope
  end

  def inspect
    str = []
    str << "class:          #{@klass}"
    str << "name:           :#{@name}"
    str << "package:        :#{@package}"
    str << "context:        :#{@context}"
    str << "path:           #{@path}"
    str << "instance:       #{@instance}"
    str << "factory_method: #{@factory_method}"
    str.join("\n")
  end
end
