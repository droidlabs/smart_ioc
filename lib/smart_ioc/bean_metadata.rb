# Stores bean specific data: bean class, name,
# scope and bean dependencies
class SmartIoC::BeanMetadata
  attr_reader :name, :bean_class, :scope, :instance, :factory_method, :attrs

  # Constructor
  # @param name [Symbol] bean name
  # @params options [Hash] includes bean class and scope
  # @params &block [Proc] bean dependencies, has the following structure:
  #   do |c|
  #     attr :some_dependency, ref: :dependency_name
  #     arg  :another_dependency, ref: :another_dependency_name
  #   end
  # here attr means setter injection, arg means constructon injects
  # +some_dependency+ is an attr_accessor defined in the bean class,
  # +ref+ specifies what dependency from container to use to set the attribute
  def initialize(name, options, &block)
    SmartIoC::ArgsValidator.has_key!(options, :class)

    @name           = name
    @bean_class     = options[:class]
    @scope          = options[:scope] || :singleton
    @instance       = options[:instance].nil? ? true : options[:instance]
    @factory_method = options[:factory_method]
    @attrs          = []

    fetch_attrs!(@bean_class)

    if block
      Dsl.new(@attrs).instance_exec(&block)
    end
  end

  def fetch_attrs!(klass)
    if klass.respond_to?(:_SmartIoC_injectable_attrs)
      klass._SmartIoC_injectable_attrs.each do |attr, options|
        options[:ref] ||= attr
        @attrs << SmartIoC::BeanMetadata::Attribute.new(attr, options)
      end
    end
  end

  def has_factory_method?
    !!@factory_method
  end

  class Attribute
    attr_reader :name, :ref

    def initialize(name, options)
      SmartIoC::ArgsValidator.has_key!(options, :ref)
      @name = name
      @ref  = options[:ref]
    end
  end

  class Dsl
    def initialize(attrs)
      @attrs = attrs
    end

    def attr(name, options)
      @attrs << SmartIoC::BeanMetadata::Attribute.new(name, options)
    end

    def arg(name, options)
      @args << SmartIoC::BeanMetadata::Attribute.new(name, options)
    end
  end
end
