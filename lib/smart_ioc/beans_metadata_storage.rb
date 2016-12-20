# Storage of bean metadatas
class SmartIoC::BeansMetadataStorage
  def initialize
    @bean_metadatas = {}
  end

  # Finds bean metadata in storage by it's name
  # @param name [Symbol] bean metadata name
  # @return bean metadata
  def by_name(name)
    @bean_metadatas[name]
  end

  # Saves a given +bean_metadata+ to the storage
  # @param bean_metadata [BeanMetadata] bean metadata for saving
  def put(bean_metadata)
    @bean_metadatas[bean_metadata.name] = bean_metadata
  end

  def bean_classes
    @bean_metadatas.values.map(&:bean_class)
  end
end
