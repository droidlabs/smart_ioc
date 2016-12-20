module SmartIoC::ConstLoaders
  module ActiveSupport
    def self.load_const(const_name)
      ::ActiveSupport::Inflector.constantize(const_name)
    end
  end
end
