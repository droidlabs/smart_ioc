require 'spec_helper'

describe SmartIoC::BeanFileLoader do
  before :all do
    SmartIoC.clear

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/admins')
    SmartIoC.find_package_beans(:admins, dir_path)

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/utils')
    SmartIoC.find_package_beans(:utils, dir_path)

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/users')
    SmartIoC.find_package_beans(:users, dir_path)

    @container = SmartIoC.container
  end

  it 'sets load proc' do
    $location_loaded = false

    @container.set_load_proc do |location|
      $location_loaded = true
      load(location)
    end

    @container.get_bean(:users_creator)
    expect($location_loaded).to eq(true)
  end

  it 'requires beans only once' do
    repository = @container.get_bean(:repository, package: :admins, context: :test)
    repository = @container.get_bean(:repository, package: :admins, context: :test)
    expect(repository.get(1)).to eq(nil)
  end
end
