require 'smart_ioc/version'
require 'benchmark'

module SmartIoC
  autoload :Args,                   'smart_ioc/args'
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
  autoload :StringUtils,            'smart_ioc/string_utils'

  module Scopes
    autoload :Bean,      'smart_ioc/scopes/bean'
    autoload :Prototype, 'smart_ioc/scopes/prototype'
    autoload :Singleton, 'smart_ioc/scopes/singleton'
    autoload :Request,   'smart_ioc/scopes/request'
  end

  module Errors
    require 'smart_ioc/errors'
  end

  require 'smart_ioc/railtie' if defined?(Rails)

  class << self
    def is_benchmark_mode
      @benchmark_mode
    end

    # @param package_name [String or Symbol] package name for bean definitions
    # @param dir [String] absolute path with bean definitions
    # @return nil
    def find_package_beans(package_name, dir)
      time = Benchmark.realtime do
        bean_locator = SmartIoC::BeanLocator.new
        bean_locator.locate_beans(package_name.to_sym, dir)
      end

      time *= 1000

      if is_benchmark_mode
        puts "Search finished for '#{package_name}'. Time taken: #{"%.2f ms" % time}"
      end

      nil
    end

    def benchmark_mode(flag)
      @benchmark_mode = !!flag
    end

    # Load all beans (usually required for production env)
    def load_all_beans
      BeanLocations.all_bean_names.each do |bean|
        container.require_bean(bean)
      end
    end

    # Full clear of data (mostly for tests)
    def clear
      BeanLocations.clear
      Container.clear
    end

    def container
      Container.get_instance
    end

    extend Forwardable

    container_methods = [
      :register_bean,
      :set_extra_context_for_package,
      :get_bean,
      :clear_scopes,
      :force_clear_scopes,
      :set_load_proc,
      :get_bean_definition
    ]

    def_delegators :container, *container_methods
  end
end

require 'smart_ioc/bean'
