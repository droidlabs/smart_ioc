class SmartIoC::BeanLocator
  include SmartIoC::Args

  BEAN_PATTERN = /bean\s+(:[a-zA-z0-9\-\_]+)/

  # @param package_name [Symbol] package name for bean (ex: :repository)
  # @param dir [String] absolute path for directory with bean definitions
  # @return nil
  def locate_beans(package_name, dir)
    check_arg(package_name, :package_name, Symbol)

    Dir.glob(File.join(dir, '**/*.rb')).each do |file_path|
      File.readlines(file_path).each do |line|
        match_data = line.match(BEAN_PATTERN)

        if match_data
          SmartIoC::BeanLocations.add_bean(
            package_name, match_data.captures.first.gsub(':', '').to_sym, file_path
          )
          break
        end
      end
    end

    nil
  end
end
