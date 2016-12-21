class SmartIoC::InjectMetadata
  attr_reader :bean, :ref, :from

  def initialize(bean, ref, from)
    @bean = bean
    @ref = ref
    @from = from
  end

  def ref
    @ref || @bean
  end
end
