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

    class TestObject
    end

    class Factory
      include SmartIoC::Iocify
      bean :factory, factory_method: :build_bean, package: :bean_factory

      def build_bean
        TestObject.new
      end
    end
  end

  it 'returns same instance for singleton scope' do
    SmartIoC.set_extra_context_for_package(:bean_factory, :test)
    instance1 = SmartIoC.get_bean(:repo)
    instance2 = SmartIoC.get_bean(:repo)
    expect(instance1.object_id).to eq(instance2.object_id)
  end

  it 'returns same instance for factory method and singleton scope' do
    instance1_object_id = SmartIoC.get_bean(:factory).object_id
    instance2_object_id = SmartIoC.get_bean(:factory).object_id
    expect(instance1_object_id).to eq(instance2_object_id)
  end

  it 'returns proper bean for test context' do
    SmartIoC.set_extra_context_for_package(:bean_factory, :test)
    expect(SmartIoC.get_bean(:repo)).to be_a(TestRepo)
  end

  it 'returns proper bean for default context' do
    SmartIoC.set_extra_context_for_package(:bean_factory, :default)
    expect(SmartIoC.get_bean(:repo)).to be_a(Repo)
  end

  it 'returns proper bean for test context with fallback to default context' do
    SmartIoC.set_extra_context_for_package(:bean_factory, :test)
    expect(SmartIoC.get_bean(:dao)).to be_a(DAO)
  end

  it 'updates dependencies' do
    class SingletonBean
      include SmartIoC::Iocify
      bean :singleton_bean, scope: :singleton, package: :test

      inject :prototype_bean

      attr_reader :prototype_bean
    end

    class SecondSingletonBean
      include SmartIoC::Iocify
      bean :second_singleton_bean, scope: :singleton, package: :test
    end

    class PrototypeBean
      include SmartIoC::Iocify
      bean :prototype_bean, scope: :prototype, package: :test

      inject :second_singleton_bean

      attr_reader :second_singleton_bean
    end

    bean1 = SmartIoC.get_bean(:singleton_bean, package: :test)
    bean1_object_id = bean1.object_id
    prototype_bean1_object_id = bean1.prototype_bean.object_id
    second_singleton_bean1_object_id = bean1.prototype_bean.second_singleton_bean.object_id

    bean2 = SmartIoC.get_bean(:singleton_bean, package: :test)
    bean2_object_id = bean2.object_id
    prototype_bean2_object_id = bean2.prototype_bean.object_id
    second_singleton_bean2_object_id = bean2.prototype_bean.second_singleton_bean.object_id

    expect(bean1_object_id).to eq(bean2_object_id)
    expect(prototype_bean1_object_id).not_to eq(prototype_bean2_object_id)
    expect(second_singleton_bean1_object_id).to eq(second_singleton_bean2_object_id)
  end
end
