class Config
  include SmartIoC::Iocify

  bean :config

  def app_name
    'SmartIoC'
  end
end
