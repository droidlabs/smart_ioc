# SmartIoC::BeanLocations is a storage for locations of package bean definitions.
# Storage structure:
# {
#   PACKAGE_NAME => { BEAN_SYM => BEAN_PATH}
# }
# Ex:
# {
#   repository: {
#     users_repository: ['/app/core/infrastructure/repository/users.rb'],
#     posts_repository: ['/app/core/infrastructure/repository/posts.rb']
#   }
# }
class SmartIoC::BeanLocations
  @data = {}

  class << self
    # @param package_name [Symbol] bean package name (ex: :repository)
    # @param bean [Symbol] bean name (ex: :users_repository)
    # @param bean_path [String] bean name (ex: :users_repository)
    # @return nil
    # @raise [ArgumentError] if bean previous bean definition with same name was found for package
    def add_bean(package_name, bean, bean_path)
      @data[package_name] ||= {}
      package_beans = @data[package_name]

      package_beans[bean] ||= []
      package_beans[bean].push(bean_path)

      nil
    end

    # @param bean [Symbol] bean name (ex: :users_repository)
    # @return Hash[Array[String]] hash of bean definitions from all packages
    def get_bean_locations(bean)
      locations = {}

      @data.each do |package, bean_locations|
        if bean_locations.has_key?(bean)
          locations[package] ||= []
          locations[package] += bean_locations[bean]
        end
      end

      locations
    end

    def load_all
      @data.each do |package, bean_locations|
        bean_locations.each do |bean, paths|
          paths.each do |path|
            load(path)
          end
        end
      end
    end

    def clear
      @data = {}
    end

    # @param path [String] absolute bean path
    # @return [nil or String] package name be absolute bean path
    def get_bean_package(path)
      @data.each do |package, bean_locations|
        if bean_locations.values.flatten.include?(path)
          return package
        end
      end

      nil
    end

    def get_all_bean_files
      @data
        .map { |_, bean_locations| bean_locations.values }
        .flatten
        .uniq
    end
  end
end
