# SmartIoc::BeanLocations is a storage for locations of package bean definitions.
# Storage structure:
# {
#   PACKAGE_NAME => { BEAN_SYM => BEAN_PATH}
# }
# Ex:
# {
#   repository: {
#     users_repository: '/app/core/infrastructure/repository/users.rb',
#     posts_repository: '/app/core/infrastructure/repository/posts.rb'
#   }
# }
class SmartIoc::BeanLocations
  class << self
    @data = {}

    # @param package_name [Symbol] bean package name (ex: :repository)
    # @param bean [Symbol] bean name (ex: :users_repository)
    # @param bean_path [String] bean name (ex: :users_repository)
    # @return nil
    # @raise [ArgumentError] if bean previous bean definition with same name was found for package
    def add_bean(package_name, bean, bean_path)
      @data[package_name] ||= {}
      package_beans = @data[package_name]

      if package_beans.has_key?(bean)
        raise ArgumentError, "bean :#{bean} was already defined in #{package_beans[bean]}"
      end

      package_beans[package_name][bean] = bean_path
      nil
    end

    # @param bean [Symbol] bean name (ex: :users_repository)
    # @return Array[String] list of bean definitions from all packages
    def get_bean_locations(bean)
      locations = []

      @data.each do |package, bean_locations|
        if bean_locations.has_key?(bean)
          locations << bean_locations[bean]
        end
      end

      locations
    end
  end
end
