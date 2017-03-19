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

    @container = SmartIoC.container
  end

  it 'loads all beans' do
    SmartIoC.load_all_beans
  end

  it 'sets beans' do
    users_creator = @container.get_bean(:users_creator)
    users_creator.create(1, 'test@test.com')

    repository = @container.get_bean(:repository, package: :admins)

    expect(repository.get(1)).to be_a(User)
    expect(users_creator.send(:repository)).to be_a(AdminsRepository)
    expect(users_creator.send(:logger)).to be_a(LoggerFactory::SmartIoCLogger)
  end

  it 'sets beans with extra package context' do
    SmartIoC.set_extra_context_for_package(:admins, :test)
    SmartIoC.force_clear_scopes

    users_creator = @container.get_bean(:users_creator)
    users_creator.create(1, 'test@test.com')

    repository = @container.get_bean(:repository, package: :admins)

    expect(users_creator.send(:repository)).to eq(TestAdminsRepository)
    expect(repository.get(1)).to be_a(User)
    expect(users_creator.send(:logger)).to be_a(LoggerFactory::SmartIoCLogger)
  end
end
