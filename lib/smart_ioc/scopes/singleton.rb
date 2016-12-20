# Singleton scope returns the same bean instance
# on each call
class SmartIoC::Scopes::Singleton

  # Constructon
  # @param bean_factory bean factory
  def initialize(bean_factory)
    @beans = {}
    @bean_factory = bean_factory
  end

  # Returns the same bean instance
  # on each call
  # @param bean_metadata [BeanMetadata] bean metadata
  # @returns bean instance
  def get_bean(bean_metadata)
    if bean = @beans[bean_metadata.name]
      bean
    else
      @bean_factory.create_bean_and_save(bean_metadata, @beans)
    end
  end

  # Delete bean from scope
  # @param bean_metadata [BeanMetadata] bean metadata
  def delete_bean(bean_metadata)
    @beans.delete(bean_metadata.name)
  end
end
