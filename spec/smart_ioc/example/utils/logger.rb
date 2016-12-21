class LoggerFactory
  include SmartIoC::Iocify

  class SmartIoCLogger
  end

  class SimpleLogger
  end

  bean :logger, factory_method: :get_logger

  inject :config

  def get_logger
    if config.app_name == 'SmartIoC'
      SmartIoCLogger.new
    else
      SimpleLogger.new
    end
  end
end
