require 'smart_ioc/version'

module SmartIoC
  autoload :BeanDefinition,         'smart_ioc/bean_definition'
  autoload :BeanDefinitionsStorage, 'smart_ioc/bean_definitions_storage'
  autoload :BeanDependency,         'smart_ioc/bean_dependency'
  autoload :BeanFactory,            'smart_ioc/bean_factory'
  autoload :BeanFileLoader,         'smart_ioc/bean_file_loader'
  autoload :BeanLocations,          'smart_ioc/bean_locations'
  autoload :BeanLocator,            'smart_ioc/bean_locator'
  autoload :Container,              'smart_ioc/container'
  autoload :ExtraPackageContexts,   'smart_ioc/extra_package_contexts'
  autoload :InjectMetadata,         'smart_ioc/inject_metadata'
  autoload :Iocify,                 'smart_ioc/iocify'
  autoload :Scopes,                 'smart_ioc/scopes'

  module Scopes
    autoload :Prototype, 'smart_ioc/scopes/prototype'
    autoload :Singleton, 'smart_ioc/scopes/singleton'
    autoload :Request,   'smart_ioc/scopes/request'
  end

  class << self
    # @param package_name [String or Symbol] package name for bean definitions
    # @param dir [String] absolute path with bean definitions
    # @return nil
    def find_package_beans(package_name, dir)
      bean_locator = SmartIoC::BeanLocator.new
      bean_locator.locate_beans(package_name.to_sym, dir)
      nil
    end

    # Load all beans (usually required for production env)
    def load_all_beans
      SmartIoC::BeanLocations.load_all
    end

    # Full clear of data (mostly for tests)
    def clear
      SmartIoC::BeanLocations.clear
      SmartIoC::Container.clear
    end
  end
end
