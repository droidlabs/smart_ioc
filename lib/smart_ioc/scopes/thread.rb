# Threa scope instantiates new bean instance if it's not present in Thread.current
class SmartIoC::Scopes::Thread
  KEY = :__smart_ioc

  # @param bean_factory bean factory
  def initialize(bean_factory)
    @bean_factory = bean_factory
  end

  # Returns a bean from the +Thread.current+
  #
  # @param bean_metadata [BeanMetadata] bean metadata
  # @returns bean instance
  def get_bean(bean_metadata)
    Thread.current[KEY] ||= {}
    if bean = RequestStore.store[KEY][bean_metadata.name]
      bean
    else
      @bean_factory.create_bean_and_save(bean_metadata, RequestStore.store[KEY])
    end
  end

  # Delete bean from scope
  # @param bean_metadata [BeanMetadata] bean metadata
  def delete_bean(bean_metadata)
    RequestStore.store[KEY].delete(bean_metadata.name)
  end
end
