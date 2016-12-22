class Config
  include SmartIoC::Iocify

  bean :config, factory_method: :get_config

  class TestConfig
    def app_name
      'SmartIoC'
    end
  end

  def get_config
    TestConfig.new
  end
end
