class SmartIoC::BeanDefinition
  attr_reader :name, :package, :path, :klass, :scope, :instance, :factory_method,
              :context, :dependencies

  def initialize(name:, package:, path:, klass:, scope:, context:, instance:, factory_method:)
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
    @context        = context

    @dependencies = []
  end

  def add_dependency(bean_name:, ref: nil, package: nil)
    if !bean_name.is_a?(Symbol)
      raise ArgumentError, 'bean name should be a Symbol'
    end

    if ref && !ref.is_a?(Symbol)
      raise ArgumentError, 'ref name should be a Symbol'
    end

    if package && !package.is_a?(Symbol)
      raise ArgumentError, 'package/from should be a Symbol'
    end

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
    (bean_definition.klass == @klass) ||
      (
        bean_definition.name == @name &&
          bean_definition.package == @package &&
            bean_definition.scope == @scope
      )
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

  private

  def not_nil(value, name)
    if value.nil?
      raise ArgumentError, ":#{name} should not be blank"
    end
  end
end
