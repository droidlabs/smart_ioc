# Prototype scope instantiates new bean instance on each call
class SmartIoC::Scopes::Prototype
  VALUE = :prototype

  # Get new bean instance
  # @param bean_definition [BeanDefinition] bean definition
  # @returns nil
  def get_bean(bean_definition)
    # do nothing
  end

  # @param klass [Class] bean class
  # @param bean [Any Object] bean object
  # @returns nil
  def save_bean(klass, bean)
    # do nothing
  end

  def clear
    # do nothing
  end

  def force_clear
    # do nothing
  end
end
