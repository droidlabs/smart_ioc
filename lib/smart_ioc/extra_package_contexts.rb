class SmartIoC::ExtraPackageContexts
  include SmartIoC::Args

  def initialize
    @data = {}
  end

  # @param package_name [Symbol]
  # @param context [Symbol]
  def set_context(package_name, context)
    check_arg(package_name, :package_name, Symbol)
    check_arg(context, :context, Symbol)

    @data[package_name] = context
  end

  def package_context(package_name)
    @data[package_name]
  end

  def get_context(package_name)
    @data[package_name] || SmartIoC::Container::DEFAULT_CONTEXT
  end

  # @param package_name [Symbol]
  def clear_context(package_name)
    @data.delete(package_name)
    nil
  end
end
