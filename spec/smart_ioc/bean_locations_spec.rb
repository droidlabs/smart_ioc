require 'spec_helper'

describe SmartIoC::BeanLocations do
  before :all do
    SmartIoC.clear
  end

  it {
    path = '/app/test_path'
    SmartIoC::BeanLocations.add_bean(:test, :test_bean, path)

    expect(SmartIoC::BeanLocations.get_bean_by_path(path)).to eq(:test_bean)
  }
end
