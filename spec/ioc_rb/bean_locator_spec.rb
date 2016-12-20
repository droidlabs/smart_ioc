require 'spec_helper'

describe SmartIoC::BeanLocator do
  before :all do
    locator = SmartIoC::BeanLocator.new
    locator.locate_beans('./example')
  end

  it { expect(SmartIoC::BeanLocations.get_bean_locations(:users_repository)).to match(/example\/users_repository.rb/)}
  it { expect(SmartIoC::BeanLocations.get_bean_locations(:users_creator)).to match(/example\/users_creator.rb/)}
end
