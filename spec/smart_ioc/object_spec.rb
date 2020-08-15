require 'spec_helper'

describe Object do
  before :all do
    SmartIoC.clear
  end

  describe '::inject' do
    before :all do
      class TestClass
        include SmartIoC::Iocify

        bean :test_class, package: :test, context: :test

        inject :config
        inject :logger, ref: :test_logger
      end

      @test_class = TestClass.allocate
    end

    it {expect(@test_class.private_methods.include?(:config)).to eq(true) }
    it {expect(@test_class.private_methods.include?(:logger)).to eq(true) }
  end

  describe '::bean' do
    before :all do
      class BeanClass
        include SmartIoC::Iocify

        bean :my_bean, scope: :request, package: :my_package, instance: false,
                       factory_method: :my_method, context: :test
      end

      @bean_definition = SmartIoC.get_bean_definition(:my_bean, :my_package, :test)
    end

    it { expect(@bean_definition.name).to eq(:my_bean) }
    it { expect(@bean_definition.package).to eq(:my_package) }
    it { expect(@bean_definition.path).to match(/object_spec.rb/) }
    it { expect(@bean_definition.klass).to eq(BeanClass) }
    it { expect(@bean_definition.scope).to eq(:request) }
    it { expect(@bean_definition.instance).to eq(false) }
    it { expect(@bean_definition.factory_method).to eq(:my_method) }
    it { expect(@bean_definition.context).to eq(:test) }
  end
end
