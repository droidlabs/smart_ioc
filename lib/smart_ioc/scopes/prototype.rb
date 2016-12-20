# Prototype scope instantiates new bean instance
# on each +get_bean+ call
class SmartIoC::Scopes::Prototype

  # Constructon
  # @param bean_factory bean factory
  def initialize(bean_factory)
    @bean_factory = bean_factory
  end

  # Get new bean instance
  # @param bean_metadata [BeanMetadata] bean metadata
  # @returns bean instance
  def get_bean(bean_metadata)
    @bean_factory.create_bean_and_save(bean_metadata, {})
  end

  # Delete bean from scope,
  # because Prototype scope doesn't store bean
  # then do nothing here
  #
  # @param bean_metadata [BeanMetadata] bean metadata
  def delete_bean(bean_metadata)
  end
end
