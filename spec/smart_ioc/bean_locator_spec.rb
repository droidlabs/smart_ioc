require 'spec_helper'

describe SmartIoC::BeanLocator do
  before :all do
    locator = SmartIoC::BeanLocator.new
    current_dir = File.expand_path(File.dirname(__FILE__))
    locator.locate_beans(:test, File.join(current_dir, './example'))
  end

  it {
    locations = SmartIoC::BeanLocations.get_bean_locations(:users_repository)

    expect(locations[:test].size).to eq(1)
    expect(locations[:test].first).to match(/example\/repository\/users_repository.rb/)
  }

  it {
    locations = SmartIoC::BeanLocations.get_bean_locations(:users_creator)

    expect(locations[:test].size).to eq(1)
    expect(locations[:test].first).to match(/example\/services\/users_creator.rb/)
  }
end
