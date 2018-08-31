class Config
  include SmartIoC::Iocify

  bean :config, factory_method: :get_config, after_init: :setup

  class TestConfig
    def setup
      # do nothing; only for testing purposes
    end

    def app_name
      'SmartIoC'
    end
  end

  def get_config
    TestConfig.new
  end
end
