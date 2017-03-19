require 'spec_helper'

describe SmartIoC::BeanFileLoader do
  before :all do
    SmartIoC.clear

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/admins')
    SmartIoC.find_package_beans(:admins, dir_path)

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/utils')
    SmartIoC.find_package_beans(:utils, dir_path)

    @container = SmartIoC.container
  end

  it 'requires beans only once' do
    repository = @container.get_bean(:repository, package: :admins, context: :test)
    repository = @container.get_bean(:repository, package: :admins, context: :test)
    expect(repository.get(1)).to eq(nil)
  end
end
