class SmartIoC::Scopes::Bean
  attr_reader :bean, :loaded

  def initialize(bean, loaded)
    @bean   = bean
    @loaded = loaded
  end

  def set_bean(bean, loaded)
    @bean   = bean
    @loaded = loaded
  end
end
