# Extend object with the bean injection mechanism
# Example of usage:
# class Bar
# end
#
# class Foo
#   inject :bar
#   or:
#   inject :some_bar, ref: bar
# end
#
# ioc_container[:foo].bar == ioc_container[:bar]
class Object

  class << self

    def inject(dependency_name, options = {})
      unless dependency_name.is_a?(Symbol)
        raise ArgumentError, "dependency name should be a symbol"
      end
      unless options.is_a?(Hash)
        raise ArgumentError, "second argument for inject method should be a Hash"
      end
      unless respond_to?(:_SmartIoC_injectable_attrs)
        class_attribute :_SmartIoC_injectable_attrs
        self._SmartIoC_injectable_attrs = { dependency_name => options.dup }
      else
        self._SmartIoC_injectable_attrs = self._SmartIoC_injectable_attrs.merge(dependency_name => options.dup)
      end
      attr_accessor dependency_name
    end

  end

end
