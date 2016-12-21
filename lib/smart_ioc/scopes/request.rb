# Request scope instantiates new bean instance if it's not present in Thread.current
class SmartIoC::Scopes::Request < SmartIoC::Scopes::Singleton
  VALUE = :request
  KEY   = :__SmartIoC

  # @param bean_factory bean factory
  def initialize
    clear
  end


  # @param klass [Class] bean class
  # @returns bean instance or nil if not stored
  def get_bean(klass)
    @beans[klass]
  end

  # @param klass [Class] bean class
  # @param bean [Any Object] bean object
  # @returns nil
  def save_bean(klass, bean)
    @beans[klass] = bean
    nil
  end

  def clear
    Thread.current[KEY] = {}
    @beans = Thread.current[KEY]
    nil
  end

  def force_clear
    clear
  end
end
