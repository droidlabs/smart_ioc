class SmartIoC::BeanFileLoader
  def initialize
    @loaded_locations = {}
  end

  # @param bean_name [Symbol] bean name
  # return nil
  def require_bean(bean_name)
    locations = SmartIoC::BeanLocations.get_bean_locations(bean_name)

    # load *.rb file if extra bean location was added or it was not loaded yet
    location_count = locations.values.flatten.size

    if !@loaded_locations.has_key?(bean_name) || @loaded_locations[bean_name] != location_count
      locations.each do |package_name, locations|
        locations.each do |location|
          require location
        end
      end

      @loaded_locations[bean_name] = location_count
    end

    nil
  end
end
