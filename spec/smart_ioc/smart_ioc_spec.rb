require 'spec_helper'

describe SmartIoC do
  before :all do
    SmartIoC.clear

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/users')
    SmartIoC.find_package_beans(:users, dir_path)

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/admins')
    SmartIoC.find_package_beans(:admins, dir_path)

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/utils')
    SmartIoC.find_package_beans(:utils, dir_path)

    @container = SmartIoC::Container.get_instance
  end

  it {
    users_creator = @container.get_bean(:users_creator)
    users_creator.create(1, 'test@test.com')

    repository = @container.get_bean(:repository, package: :admins)

    expect(repository.get(1)).to be_a(User)
    expect(users_creator.send(:repository)).to be_a(AdminsRepository)
    expect(users_creator.send(:logger)).to be_a(LoggerFactory::SmartIoCLogger)
  }
end
