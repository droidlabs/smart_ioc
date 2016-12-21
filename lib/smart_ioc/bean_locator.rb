class SmartIoC::BeanLocator
  BEAN_PATTERN = /bean\s+(:[a-zA-z0-9\-\_]+)/

  # @param package_name [Symbol] package name for bean (ex: :repository)
  # @param dir [String] absolute path for directory with bean definitions
  # @return nil
  def locate_beans(package_name, dir)
    SmartIoC::BeanLocations.clear

    if !package_name.is_a?(Symbol)
      raise ArgumentError, 'package name should be a symbol'
    end

    package_name = package_name

    Dir.glob(File.join(dir, '**/*.rb')).each do |file_path|
      source_str = File.read(file_path)

      beans = find_package_beans(source_str)

      beans.each do |bean_name|
        SmartIoC::BeanLocations.add_bean(package_name, bean_name, file_path)
      end
    end
    nil
  end

  private

  def find_package_beans(source_str)
    tokens = source_str.scan(BEAN_PATTERN)
    tokens.flatten.uniq.map {|token| token.gsub(':', '').to_sym}
  end
end
