class SmartIoC::BeanDefinitionsStorage
  include SmartIoC::Errors

  def initialize
    @collection = Hash.new { |h, k| h[k] = [] }
  end

  def clear_dependencies
    @collection.values.flatten.each do |bd|
      bd.dependencies.each do |dependency|
        dependency.bean_definition = nil
      end
    end
  end

  # @param bean_definition [BeanDefinition]
  def push(bean_definition)
    bd_scope = @collection[bean_definition.name]

    existing_bd = bd_scope.detect { |bd| bd == bean_definition }

    if existing_bd
      bd_scope.reject! { |bd| bd == bean_definition }

      message = <<~EOF
        \nReplacing bean definition...
          - New bean details:
        #{bean_definition.inspect}
          - Existing bean details:
        #{existing_bd.inspect})

      EOF

      puts message
    end

    bd_scope.push(bean_definition)
  end

  def delete(bean_definition)
    bd_scope = @collection[bean_definition.name]

    bd_scope.delete_if { |bd| bd.klass.to_s == bean_definition.klass.to_s }

    nil
  end

  # Returns bean definition for specific class
  # @param bean_name [Symbol]
  # @param package [Symbol]
  # @param context [Symbol]
  # @return bean definition [BeanDefinition] or nil
  def find_bean(bean_name, package, context)
    @collection[bean_name].detect do |bd|
      bd.name == bean_name && bd.package == package && bd.context == context
    end
  end

  def filter_by(bean_name, package = nil, context = nil)
    bd_scope = @collection[bean_name]

    if package
      bd_scope = bd_scope.select { |bd| bd.package == package }
    end

    if context
      bd_scope = bean_definitions.select { |bd| bd.context == context }
    end

    bd_scope
  end

  # @bean_name [Symbol] bean name
  # @package [Symbol, nil] package name
  # @context [Symbol, nil] context
  # @package [Symbol, nil] parent_package name of parent package
  # @raises AmbiguousBeanDefinition if multiple bean definitions are found
  def find(bean_name, package = nil, context = nil, parent_package = nil)
    bds = filter_by_with_drop_to_default_context(bean_name, package, context)

    if bds.size > 1 && parent_package
      bean_definition = bds.detect do |bd|
        bd.package == parent_package
      end

      if bean_definition
        bds = [bean_definition]
      end
    end

    if bds.size > 1
      raise AmbiguousBeanDefinition.new(bean_name, bds)
    elsif bds.size == 0
      raise BeanNotFound.new(bean_name)
    end

    bds.first
  end

  # @bean_name [Symbol] bean name
  # @package [Symbol, nil] package name
  # @context [Symbol, nil] context
  def filter_by_with_drop_to_default_context(bean_name, package = nil, context = nil)
    bd_scope = @collection[bean_name]

    if package
      bd_scope = bd_scope.select { |bd| bd.package == package }
    end

    if context
      context_bean_definitions = bd_scope.select { |bd| bd.context == context }

      bd_scope = context_bean_definitions if context_bean_definitions.any?
    end

    bd_scope
  end
end
