module SmartIoC::Errors
  class BeanNotFound < StandardError
    def initialize(bean_name)
      super("Unable to find bean :#{bean_name} in any packages")
    end
  end

  class AmbiguousBeanDefinition < StandardError
    attr_accessor :parent_bean_definition

    def initialize(bean_name, bean_definitions)
      @bean_name = bean_name
      @bean_definitions = bean_definitions
    end

    def message
      <<~EOS
        Unable to inject bean :#{@bean_name}#{@parent_bean_definition ? " into :#{@parent_bean_definition.name} (package: #{@parent_bean_definition.package})" : ""}.
        Several bean definitions with name :#{@bean_name} were found:

        #{@bean_definitions.map(&:inspect).join("\n\n")}
      EOS
    end
  end
end
