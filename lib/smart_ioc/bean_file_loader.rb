class SmartIoC::BeanFileLoader
  def initialize
    @loaded_locations = {}
  end

  # @param bean_name [Symbol] bean name
  # return nil
  def require_bean(bean_name)
    locations = SmartIoC::BeanLocations.get_bean_locations(bean_name).values.flatten

    locations.each do |location|
      next if @loaded_locations.has_key?(location)
      @loaded_locations[location] = true
      load location
    end

    nil
  end
end
