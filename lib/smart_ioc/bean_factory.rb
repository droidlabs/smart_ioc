require 'ioc_rb/scopes'
require 'ioc_rb/scopes/singleton_scope'
require 'ioc_rb/scopes/prototype_scope'
require 'ioc_rb/scopes/request_scope'

# Instantiates beans according to their scopes
class SmartIoC::BeanFactory
  attr_reader :const_loader

  # Constructor
  # @param beans_metadata_storage [BeansMetadataStorage] storage of bean metadatas
  def initialize(const_loader, beans_metadata_storage)
    @const_loader           = const_loader
    @beans_metadata_storage = beans_metadata_storage
    @singleton_scope        = SmartIoC::Scopes::SingletonScope.new(self)
    @prototype_scope        = SmartIoC::Scopes::PrototypeScope.new(self)
    @request_scope          = SmartIoC::Scopes::RequestScope.new(self)
  end

  # Get bean from the container by it's +name+.
  # According to the bean scope it will be newly created or returned already
  # instantiated bean
  # @param [Symbol] bean name
  # @return bean instance
  # @raise MissingBeanError if bean with the specified name is not found
  def get_bean(name)
    bean_metadata = @beans_metadata_storage.by_name(name)
    unless bean_metadata
      raise SmartIoC::Errors::MissingBeanError, "Bean with name :#{name} is not defined"
    end
    get_bean_with_metadata(bean_metadata)
  end

  # Get bean by the specified +bean metadata+
  # @param [BeanMetadata] bean metadata
  # @return bean instance
  def get_bean_with_metadata(bean_metadata)
    get_scope_by_metadata(bean_metadata).get_bean(bean_metadata)
  end

  # Create new bean instance according
  # to the specified +bean_metadata+
  # @param [BeanMetadata] bean metadata
  # @return bean instance
  # @raise MissingBeanError if some of bean dependencies are not found
  def create_bean_and_save(bean_metadata, beans_storage)
    if bean_metadata.bean_class.is_a?(Class)
      bean_class = bean_metadata.bean_class
    else
      bean_class = const_loader.load_const(bean_metadata.bean_class)
      bean_metadata.fetch_attrs!(bean_class)
    end
    bean = bean_metadata.instance ? bean_class.new : bean_class
    if bean_metadata.has_factory_method?
      set_bean_dependencies(bean, bean_metadata)
      bean = bean.send(bean_metadata.factory_method)
      beans_storage[bean_metadata.name] = bean
    else
      # put to container first to prevent circular dependencies
      beans_storage[bean_metadata.name] = bean
      set_bean_dependencies(bean, bean_metadata)
    end

    bean
  end

  # Delete bean from the container by it's +name+.
  # @param [Symbol] bean name
  # @raise MissingBeanError if bean with the specified name is not found
  def delete_bean(name)
    bean_metadata = @beans_metadata_storage.by_name(name)
    unless bean_metadata
      raise SmartIoC::Errors::MissingBeanError, "Bean with name :#{name} is not defined"
    end
    get_scope_by_metadata(bean_metadata).delete_bean(bean_metadata)
  end

  private

  def set_bean_dependencies(bean, bean_metadata)
    bean_metadata.attrs.each do |attr|
      bean_metadata = @beans_metadata_storage.by_name(attr.ref)
      unless bean_metadata
        raise SmartIoC::Errors::MissingBeanError, "Bean with name :#{attr.ref} is not defined, check #{bean.class}"
      end
      case bean_metadata.scope
      when :singleton
        bean.send("#{attr.name}=", get_bean(attr.ref))
      when :prototype
        bean.instance_variable_set(:@_ioc_rb_bean_factory, self)
        bean.define_singleton_method(attr.name) do
          @_ioc_rb_bean_factory.get_bean(attr.ref)
        end
      when :request
        bean.instance_variable_set(:@_ioc_rb_bean_factory, self)
        bean.define_singleton_method(attr.name) do
          @_ioc_rb_bean_factory.get_bean(attr.ref)
        end
      end
    end
  end

  def get_scope_by_metadata(bean_metadata)
    case bean_metadata.scope
    when :singleton
      @singleton_scope
    when :prototype
      @prototype_scope
    when :request
      @request_scope
    else
      raise SmartIoC::Errors::UnsupportedScopeError, "Bean with name :#{bean_metadata.name} has unsupported scope :#{bean_metadata.scope}"
    end
  end

end
