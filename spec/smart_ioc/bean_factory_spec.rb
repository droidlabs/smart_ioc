require 'spec_helper'

describe SmartIoC::BeanFactory do
  before :all do
    SmartIoC.clear

    class Repo
      include SmartIoC::Iocify
      bean :repo, context: :default, package: :bean_factory
    end

    class TestRepo
      include SmartIoC::Iocify
      bean :repo, context: :test, package: :bean_factory
    end

    class DAO
      include SmartIoC::Iocify
      bean :dao, context: :default, package: :bean_factory
    end
  end

  it 'returns proper bean for test context' do
    SmartIoC::Container.get_instance.set_extra_context_for_package(:bean_factory, :test)
    expect(SmartIoC::Container.get_bean(:repo)).to be_a(TestRepo)
  end

  it 'returns proper bean for default context' do
    SmartIoC::Container.get_instance.set_extra_context_for_package(:bean_factory, :default)
    expect(SmartIoC::Container.get_bean(:repo)).to be_a(Repo)
  end

  it 'returns proper bean for test context with fallback to default context' do
    SmartIoC::Container.get_instance.set_extra_context_for_package(:bean_factory, :test)
    expect(SmartIoC::Container.get_bean(:dao)).to be_a(DAO)
  end
end
