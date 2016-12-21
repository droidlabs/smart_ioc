class SmartIoC::BeanDefinitionsStorage
  def initialize
    @collection = []
  end

  # @param bean_definition [BeanDefinition]
  def push(bean_definition)
    existing_bd = @collection.detect do |bd|
      bd == bean_definition
    end

    if existing_bd
      raise ArgumentError, %Q(
        bean definition for bean :#{bean_definition.name}
        from package :#{bean_definition.package}
        with context :#{bean_definition.context}
        already defined. See details
        #{existing_bd.inspect}
      )
    end

    @collection.push(bean_definition)
  end

  # @param klass [Class] bean class
  # @return bean definition [BeanDefinition] or nil
  def find_by_class(klass)
    @collection.detect {|bd| bd.klass == klass}
  end

  # @bean_name [Symbol] bean name
  # @package [Symbol] package name
  # @context [Array[Symbol]] context
  def find_all(bean_name, package = nil, contexts = [])
    bean_definitions = @collection.select do |bd|
      bd.name == bean_name
    end

    if package
      bean_definitions = bean_definitions.select do |bd|
        bd.package == package
      end
    end

    if contexts
      bean_definitions = bean_definitions.select do |bd|
        bd.context == context
      end
    end

    bean_definitions
  end
end
