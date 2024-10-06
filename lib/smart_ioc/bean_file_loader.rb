class SmartIoC::BeanFileLoader
  def initialize
    @loaded_locations = {}
    @load_proc        = Proc.new { |location| load(location) }
  end

  def set_load_proc(&block)
    raise ArgumentError, "block should be given" unless block_given?
    @load_proc = block
  end

  # @param bean_name [Symbol] bean name
  # return nil
  def require_bean(bean_name)
    locations = SmartIoC::BeanLocations.get_bean_locations(bean_name).values.flatten

    locations.each do |location|
      next if @loaded_locations.has_key?(location)
      @loaded_locations[location] = true
      @load_proc.call(location)
    end

    nil
  end

  def clear_locations
    @loaded_locations = {}
  end
end
