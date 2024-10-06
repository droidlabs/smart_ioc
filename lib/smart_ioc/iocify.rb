# Extend Object with bean declaration and bean injection functionality
# Example of usage:
# class Bar
#   bean :bar
#
#   def call
#   end
# end
#
# class Foo
#   include SmartIoC::Iocify
#   bean :foo, scope: :prototype, instance: false, factory_method: :get_beans
#
#   inject :bar
#   inject :some_bar, ref: bar, from: :repository
#
#   def hello_world
#     some_bar.call
#     puts 'Hello world'
#   end
# end
#
# SmartIoC::Container.get_bean(:bar).hello_world
module SmartIoC::Iocify
  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def package(name)
      raise ArgumentError, "name should be a Symbol" if !name.is_a?(Symbol)
      @package = name
    end

    def context(name)
      raise ArgumentError, "name should be a Symbol" if !name.is_a?(Symbol)
      @context = name
    end

    def factory_method(name)
      raise ArgumentError, "name should be a Symbol" if !name.is_a?(Symbol)
      @factory_method = name
    end

    def scope(name)
      raise ArgumentError, "name should be a Symbol" if !name.is_a?(Symbol)
      @scope = name
    end

    def instance
      @instance = true
    end

    def after_init(name)
      raise ArgumentError, "name should be a Symbol" if !name.is_a?(Symbol)
      @after_init = name
    end

    # @param bean_name [Symbol] bean name
    # @param scope [Symbol] bean scope (defaults to :singleton)
    # @param package [nil or Symbol]
    # @param factory_method [nil or Symbol] factory method to get bean
    # @param instance [Boolean] instance based bean or class-based
    # @param context [Symbol] set bean context (ex: :test)
    # @param after_init [Symbol] name of bean method that will be called after bean initialization (ex: :test)
    # @return nil
    def bean(bean_name, scope: nil, package: nil, instance: true, factory_method: nil, context: nil, after_init: nil, file_path: nil)
      file_path ||= caller[0].split(':').first
      package ||= SmartIoC::BeanLocations.get_bean_package(file_path)
      context ||= SmartIoC::Container::DEFAULT_CONTEXT
      bean_definition = SmartIoC.find_bean_definition(bean_name, package, context)

      if bean_definition
        if bean_definition.path == file_path
          # seems that file with bean definition was reloaded
          # lets clear all scopes so we do not have
          container = SmartIoC::Container.get_instance
          container.unregister_bean(self)
          container.force_clear_scopes
        else
          raise ArgumentError, "bean with for class #{self.to_s} was already defined in #{bean_definition.path}"
        end
      end

      bean_definition = SmartIoC.register_bean(
        bean_name:      bean_name,
        klass:          self,
        scope:          scope,
        path:           file_path,
        package_name:   package,
        instance:       instance,
        factory_method: factory_method,
        context:        context,
        after_init:     after_init,
      )

      if bean_definition.is_instance?
        class_eval %Q(
          def initialize
            raise ArgumentError, "constructor based allocation is not allowed for beans. Use ioc container to allocate bean."
          end
        )
      end

      self.instance_variable_set(:@bean_definition, bean_definition)

      nil
    end

    def inject(bean_name, ref: nil, from: nil)
      if @anonymous_bean
        @injects ||= []
        @injects.push({bean_name: bean_name, ref: ref, from: from})
      else
        register_inject(bean_name, ref: ref, from: from)
      end
    end

    # @param bean_name [Symbol] injected bean name
    # @param ref [Symbol] refferece bean to be sef as bean_name
    # @param from [Symbol] package name
    # @return nil
    # @raise [ArgumentError] if bean_name is not a Symbol
    # @raise [ArgumentError] if ref provided and ref is not a Symbol
    # @raise [ArgumentError] if from provided and from is not a Symbol
    # @raise [ArgumentError] if bean with same name was injected before
    def register_inject(bean_name, ref: nil, from: nil)
      if !@bean_definition
        raise ArgumentError, "#{self.to_s} is not registered as bean. Add `bean :bean_name` declaration"
      end

      bd = @bean_definition

      bd.add_dependency(
        bean_name: bean_name,
        ref:       ref,
        package:   from
      )

      bean_method = Proc.new do
        bean = instance_variable_get(:"@#{bean_name}")
        return bean if bean

        klass = self.is_a?(Class) ? self : self.class

        bean = SmartIoC::Container.get_instance.get_bean(
          ref || bean_name,
          package: from,
          parent_bean_definition: bd,
          parent_bean_name: bd.name,
        )

        instance_variable_set(:"@#{bean_name}", bean)
      end

      if bd.is_instance?
        define_method bean_name, &bean_method
        private bean_name
      else
        define_singleton_method bean_name, &bean_method

        class_eval %Q(
          class << self
            private :#{bean_name}
          end
        )
      end

      nil
    end
  end
end
