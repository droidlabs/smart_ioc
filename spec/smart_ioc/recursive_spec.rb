require 'spec_helper'

describe SmartIoC::Container do
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

  it 'loads recursive beans' do
    users_creator = @container.get_bean(:users_creator)
    uc2 = users_creator.send(:repository).users_creator
    expect(users_creator).to eq(uc2)
  end
end
