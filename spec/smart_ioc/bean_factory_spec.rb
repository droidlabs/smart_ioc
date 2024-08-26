require 'spec_helper'

describe SmartIoC::BeanFactory do
  before :all do
    SmartIoC.clear

    bean :repo do
      context :default
      package :bean_factory

      def call
        'default'
      end
    end

    bean :repo do
      context :test
      package :bean_factory

      inject :dao

      def call
        dao.call
        'test'
      end
    end

    bean :dao do
      context :default
      package :bean_factory
      
      def call
        'dao'
      end
    end

    class TestObject
    end

    bean :factory do
      factory_method :build_bean
      package        :bean_factory

      def build_bean
        TestObject.new
      end
    end
  end

  it 'returns benchmark time to load bean' do
    SmartIoC.benchmark_mode(true)

    SmartIoC.set_extra_context_for_package(:bean_factory, :test)
    SmartIoC.get_bean(:repo)

    SmartIoC.benchmark_mode(false)
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
    expect(SmartIoC.get_bean(:repo).call).to eq('test')
  end

  it 'returns proper bean for default context' do
    SmartIoC.set_extra_context_for_package(:bean_factory, :default)
    expect(SmartIoC.get_bean(:repo).call).to eq('default')
  end

  it 'returns proper bean for test context with fallback to default context' do
    SmartIoC.set_extra_context_for_package(:bean_factory, :test)
    expect(SmartIoC.get_bean(:dao).call).to eq('dao')
  end

  it 'updates dependencies' do
    class SingletonBean
      include SmartIoC::Iocify
      bean :singleton_bean, scope: :singleton, package: :test

      inject :prototype_bean

      public :prototype_bean
    end

    class SecondSingletonBean
      include SmartIoC::Iocify
      bean :second_singleton_bean, scope: :singleton, package: :test
    end

    class PrototypeBean
      include SmartIoC::Iocify
      bean :prototype_bean, scope: :prototype, package: :test

      inject :second_singleton_bean

      public :second_singleton_bean
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
    expect(prototype_bean1_object_id).to eq(prototype_bean2_object_id)
    expect(second_singleton_bean1_object_id).to eq(second_singleton_bean2_object_id)
  end

  describe 'prototype scope' do
    before :all do
      class PrototypeBean
        include SmartIoC::Iocify
        bean :prototype_bean, scope: :prototype, package: :prototype

        inject :prototype_service1
        inject :prototype_service2

        public :prototype_service1, :prototype_service2
      end

      class PrototypeService1
        include SmartIoC::Iocify
        bean :prototype_service1, scope: :prototype, package: :prototype

        inject :prototype_repo
        inject :singleton_repo

        public :prototype_repo, :singleton_repo
      end

      class PrototypeService2
        include SmartIoC::Iocify
        bean :prototype_service2, scope: :prototype, package: :prototype

        inject :prototype_repo
        inject :singleton_repo

        public :prototype_repo, :singleton_repo
      end

      class PrototypeRepo
        include SmartIoC::Iocify

        bean :prototype_repo, scope: :prototype, package: :prototype
      end

      class SingletonRepo
        include SmartIoC::Iocify

        bean :singleton_repo, scope: :singleton, package: :prototype
      end
    end

    it 'injects prototype beans with different object id' do
      prototype_bean = SmartIoC.get_bean(:prototype_bean, package: :prototype)
      repo1_object_id = prototype_bean.prototype_service1.prototype_repo.object_id
      repo2_object_id = prototype_bean.prototype_service2.prototype_repo.object_id

      expect(repo1_object_id).not_to eq(repo2_object_id)
    end

    it 'injects singleton beans with same object id' do
      prototype_bean = SmartIoC.get_bean(:prototype_bean, package: :prototype)
      repo1_object_id = prototype_bean.prototype_service1.singleton_repo.object_id
      repo2_object_id = prototype_bean.prototype_service2.singleton_repo.object_id

      expect(repo1_object_id).to eq(repo2_object_id)
    end
  end
end
