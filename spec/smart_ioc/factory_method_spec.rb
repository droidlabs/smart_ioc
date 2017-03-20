require 'spec_helper'

describe 'Factory Method' do
  before :all do
    class TestService
      include SmartIoC::Iocify

      bean :test_service, package: :test

      inject :test_config

      attr_reader :test_config
    end

    class OtherService
      include SmartIoC::Iocify

      bean :other_service, package: :test

      inject :test_config

      attr_reader :test_config
    end

    class TestConfig
      include SmartIoC::Iocify

      bean :test_config, package: :test, factory_method: :build_config

      class Config
      end

      def build_config
        Config.new
      end
    end

    @test_service = SmartIoC.get_bean(:test_service)
    @other_service = SmartIoC.get_bean(:other_service)
  end

  it 'assigns bean with factory method' do
    expect(@test_service.test_config).to be_a(TestConfig::Config)
  end

  it 'assigns bean with factory method' do
    expect(@other_service.test_config).to be_a(TestConfig::Config)
  end
end