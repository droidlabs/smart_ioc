class SmartIoC::BeanLocator
  BEAN_PATTERN = /bean\s+(:[a-zA-z0-9\-\_])/

  # @ dir [String] - source folder to find bean definitions
  def locate_beans(package_name, dir)
    Dir.glob(File.join(dir, '**/*.rb')).each do |file_path|
      source_str = File.read(file_path)

      beans = detect_beans(source_str)

      beans.each do |bean_sym|
        SmartIoC::BeanLocatios.add_bean_definition_path(package_name, bean_sym, file_path)
      end
    end
  end

  private

  def detect_beans(source_str)
    tokens = source_str.scan(BEAN_PATTERN)
    tokens.flatten.uniq.gsub(':', '').map(&:to_sym)
  end
end
