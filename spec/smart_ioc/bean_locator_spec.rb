require 'spec_helper'

describe SmartIoC::BeanLocator do
  before :all do
    SmartIoC.clear

    locator = SmartIoC::BeanLocator.new
    current_dir = File.expand_path(File.dirname(__FILE__))
    locator.locate_beans(:test, File.join(current_dir, 'example'))
  end

  it {
    locations = SmartIoC::BeanLocations.get_bean_locations(:repository)

    expect(locations[:test].size).to eq(2)
    expect(locations[:test][0]).to match(/example\/admins\/repository\/admins_repository.rb/)
    expect(locations[:test][1]).to match(/example\/users\/repository\/users_repository.rb/)
  }

  it {
    locations = SmartIoC::BeanLocations.get_bean_locations(:users_creator)

    expect(locations[:test].size).to eq(1)
    expect(locations[:test].first).to match(/example\/users\/services\/users_creator.rb/)
  }
end
