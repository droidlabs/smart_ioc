module SmartIoC
  # SmartIoC::Container is a beans store used for dependency injection
  class Container
    include SmartIoC::Args

    DEFAULT_CONTEXT = :default

    class << self
      def get_instance
        @container ||= SmartIoC::Container.allocate
      end

      def clear
        @container = nil
      end

      def get_bean(bean_name, package: nil, context: nil)
        get_instance.get_bean(bean_name, package: package, context: context)
      end
    end

    def initialize
      raise ArgumentError, "SmartIoC::Container should not be allocated. Use SmartIoC::Container.get_instance instead"
    end

    # @param klass [Class] bean class name
    # @return nil
    def unregister_bean(klass)
      bean_definitions_storage.delete_by_class(klass)
      clear_scopes
      nil
    end

    # @param bean_name [Symbol] bean name
    # @param klass [Class] bean class name
    # @param path [String] bean file absolute path
    # @param scope [Symbol] scope value
    # @param context [Symbol] bean context
    # @return [SmartIoC::BeanDefinition] bean definition
    def register_bean(bean_name:, klass:, context:, scope:, path:,
                      factory_method: nil, package_name: nil, instance: true)
      context ||= DEFAULT_CONTEXT

      check_arg(bean_name, :bean_name, Symbol)
      check_arg(context, :context, Symbol)
      check_arg(klass, :klass, Class)
      check_arg(path, :path, String)
      check_arg(factory_method, :factory_method, Symbol) if factory_method
      check_arg_any(instance, :instance, [TrueClass, FalseClass])

      scope ||= SmartIoC::Scopes::Singleton::VALUE

      allowed_scopes = [
        SmartIoC::Scopes::Prototype::VALUE,
        SmartIoC::Scopes::Singleton::VALUE,
        SmartIoC::Scopes::Request::VALUE
      ]

      if !allowed_scopes.include?(scope)
        raise ArgumentError, "bean scope should be one of #{allowed_scopes.inspect}"
      end

      package_name ||= SmartIoC::BeanLocations.get_bean_package(path)

      if !package_name
        raise ArgumentError, %Q(
          Package name should be given for bean :#{bean_name}.
          You should specify package name directly or run

          SmartIoC.find_package_beans(package_name, dir)

          to setup beans before you actually register them.
        )
      end

      bean_definition = SmartIoC::BeanDefinition.new(
        name:           bean_name,
        package:        package_name,
        path:           path,
        klass:          klass,
        instance:       instance,
        factory_method: factory_method,
        context:        context,
        scope:          scope
      )

      bean_definitions_storage.push(bean_definition)

      bean_definition
    end

    # Returns bean definition for specific class
    # @param klass [Class] class name
    # return [BeanDefinition]
    def get_bean_definition_by_class(klass)
      bean_definitions_storage.find_by_class(klass)
    end

    # Sets new load proc
    # for those who use active support dependency loader
    # one can use
    # SmartIoC.set_load_proc do |location|
    #    require_dependency(location)
    # end
    def set_load_proc(&proc)
      bean_factory.bean_file_loader.set_load_proc(&proc)
    end

    # Sets extra context for specific package
    # @param package_name [Symbol] package name
    # @param context [Symbol] context (ex: :test)
    def set_extra_context_for_package(package_name, context)
      extra_package_contexts.set_context(package_name, context)
      bean_definitions_storage.clear_dependencies
    end

    # @param bean_name [Symbol] bean name
    # @param optional package [Symbol] package name
    # @param optional context [Symbol] package context
    # @return bean instance from container
    def get_bean(bean_name, package: nil, context: nil)
      bean_factory.get_bean(bean_name, package: package, context: context)
    end

    def clear_scopes
      bean_factory.clear_scopes
    end

    def force_clear_scopes
      bean_factory.force_clear_scopes
      bean_factory.bean_file_loader.clear_locations
    end

    private

    def bean_factory
      @bean_factory ||= SmartIoC::BeanFactory.new(bean_definitions_storage, extra_package_contexts)
    end

    def extra_package_contexts
      @extra_package_contexts ||= SmartIoC::ExtraPackageContexts.new
    end

    def bean_definitions_storage
      @bean_definitions_storage ||= SmartIoC::BeanDefinitionsStorage.new
    end
  end
end
