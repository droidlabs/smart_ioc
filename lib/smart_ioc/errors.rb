module SmartIoC::Errors
  class BeanNotFound < StandardError
    def initialize(bean_name)
      super("Unable to find bean :#{bean_name} in any packages")
    end
  end

  class AmbiguousBeanDefinition < StandardError
    def initialize(bean_name, bean_definitions)
      super(%Q(
        Unable to create bean :#{bean_name}.
        Several definitions were found.
        #{bean_definitions.map(&:inspect).join("\n\n")}
      ))
    end
  end
end
