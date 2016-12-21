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
end
