require 'spec_helper'

describe SmartIoC do
  before :all do
    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example')
    SmartIoC.find_package_beans(:my_package, dir_path)
    @container = SmartIoC::Container.get_instance
  end

  it '' do
    users_creator = @container.get_bean(:users_creator)
    users_creator.create('test@test.com')

    users_repository = @container.get_bean(:users_repository)
    expect(users_repository.get('test@test.com')).to be_a(User)
  end
end
