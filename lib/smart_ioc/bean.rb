def bean(bean_name, &proc)
  raise ArgumentError, "name should be a Symbol" if !bean_name.is_a?(Symbol)
  raise ArgumentError, "proc should be provided" if !block_given?

  klass = Class.new do
    include SmartIoC::Iocify
  end

  klass.instance_variable_set(:@anonymous_bean, true)
  klass.instance_exec(&proc)

  file_path = caller[0].split(':').first
  package   = SmartIoC::BeanLocations.get_bean_package(file_path)

  klass.instance_exec do
    bean(
      bean_name,
      file_path:      file_path,
      scope:          instance_variable_get(:@scope) || nil,
      package:        instance_variable_get(:@package) || package,
      instance:       instance_variable_get(:@instance) || false,
      factory_method: instance_variable_get(:@factory_method) || nil,
      context:        instance_variable_get(:@context) || nil,
      after_init:     instance_variable_get(:@after_init) || nil
    )
  end

  (klass.instance_variable_get(:@injects) || []).each do |inject|
    klass.register_inject(inject[:bean_name], ref: inject[:ref], from: inject[:from])
  end

  klass
end