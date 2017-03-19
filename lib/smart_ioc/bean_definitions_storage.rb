class SmartIoC::BeanDefinitionsStorage
  include SmartIoC::Errors

  def initialize
    @collection = []
  end

  # @param bean_definition [BeanDefinition]
  def push(bean_definition)
    existing_bd = @collection.detect do |bd|
      bd == bean_definition
    end

    if existing_bd
      error_msg =
%Q(Not able to add bean to definitions storage.
Bean definition already exists.
New bean details:
  #{bean_definition.inspect}
Existing bean details:
  #{existing_bd.inspect})

      raise ArgumentError, error_msg
    end

    @collection.push(bean_definition)
  end

  # @param klass [Class] bean class
  # @return bean definition [BeanDefinition] or nil
  def find_by_class(klass)
    @collection.detect {|bd| bd.klass == klass}
  end

  def filter_by(bean_name, package = nil, context = nil)
    bean_definitions = @collection.select do |bd|
      bd.name == bean_name
    end

    if package
      bean_definitions = bean_definitions.select do |bd|
        bd.package == package
      end
    end

    if context
      bean_definitions = bean_definitions.select do |bd|
        bd.context == context
      end
    end

    bean_definitions
  end

  # @bean_name [Symbol] bean name
  # @package [Symbol, nil] package name
  # @context [Symbol, nil] context
  # @raises Errors::AmbiguousBeanDefinition if multiple bean definitions are found 
  def find(bean_name, package = nil, context = nil)
    bds = filter_by_with_drop_to_default_context(bean_name, package, context)

    if bds.size > 1
      raise Errors::AmbiguousBeanDefinition.new(bean_name, bds)
    elsif bds.size == 0
      raise Errors::BeanNotFound.new(bean_name)
    end

    bds.first
  end

  # @bean_name [Symbol] bean name
  # @package [Symbol, nil] package name
  # @context [Symbol, nil] context
  def filter_by_with_drop_to_default_context(bean_name, package = nil, context = nil)
    bean_definitions = @collection.select do |bd|
      bd.name == bean_name
    end

    if package
      bean_definitions = bean_definitions.select do |bd|
        bd.package == package
      end
    end

    if context
      context_bean_definitions = bean_definitions.select do |bd|
        bd.context == context
      end

      if !context_bean_definitions.empty?
        bean_definitions = context_bean_definitions
      end
    end

    bean_definitions
  end
end
