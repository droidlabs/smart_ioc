module SmartIoC::ConstLoaders
  module Native
    def self.load_const(const_name)
      const_name.split('::').inject(Object) do |mod, const_part|
        mod.const_get(const_part)
      end
    end
  end
end
