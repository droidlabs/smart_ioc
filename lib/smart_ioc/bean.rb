def bean(bean_name, &proc)
  raise ArgumentError, "name should be a Symbol" if !bean_name.is_a?(Symbol)
  raise ArgumentError, "proc should be provided" if !block_given?

  klass = Class.new do
    include SmartIoC::Iocify
  end

  klass.instance_variable_set(:@anonymous_bean, true)
  klass.instance_exec(&proc)

  str       = SmartIoC::StringUtils
  file_path = caller[0].split(':').first
  package   = klass.instance_variable_get(:@package) || SmartIoC::BeanLocations.get_bean_package(file_path)
  context   = klass.instance_variable_get(:@context) || :default

  if package.nil?
    raise ArgumentError, "package is not defined for bean :#{bean_name}"
  end

  package_mod = str.camelize(package)
  context_mod = str.camelize(context || :default)

  class_name = str.camelize(bean_name)
  klass_name = "#{package_mod}::#{context_mod}::#{class_name}"

  eval(
    %Q(
      module #{package_mod}
        module #{context_mod}
          if constants.include?(:"#{class_name}")
            remove_const :"#{class_name}"
          end
        end
      end

      #{klass_name} = klass
    )
  )

  klass.instance_exec do
    bean(
      bean_name,
      file_path:      file_path,
      scope:          instance_variable_get(:@scope),
      package:        package,
      instance:       instance_variable_get(:@instance) || false,
      factory_method: instance_variable_get(:@factory_method),
      context:        context,
      after_init:     instance_variable_get(:@after_init),
    )
  end

  (klass.instance_variable_get(:@injects) || []).each do |inject|
    klass.register_inject(inject[:bean_name], ref: inject[:ref], from: inject[:from])
  end

  klass
end
