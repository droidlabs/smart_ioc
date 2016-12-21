class SmartIoC::ExtraPackageContexts
  def initialize
    @data = {}
  end

  # @param package_name [Symbol]
  # @param context [Symbol]
  def set_context(package_name, context)
    if !package_name.is_a?(Symbol)
      raise ArgumentError, "package name should be a Symbol"
    end

    if !context.is_a?(Symbol)
      raise ArgumentError, "context should be a Symbol"
    end

    @data[package_name] = context
  end

  def get_package_context(package_name)
    @data[package_name] || SmartIoC::Container::DEFAULT_CONTEXT
  end

  # @param package_name [Symbol]
  def clear_context(package_name)
    @data.delete(package_name)
    nil
  end
end
