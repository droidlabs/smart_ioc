class SmartIoC::BeanDependency
  attr_reader :bean, :ref, :package

  def initialize(bean:, ref:, package:)
    @bean = bean
    @ref = ref
    @package = package
  end

  def ref
    @ref || @bean
  end

  def ==(dependency)
    dependency.bean == @bean && dependency.package == @package
  end
end
