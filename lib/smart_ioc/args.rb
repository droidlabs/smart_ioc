module SmartIoC::Args
  def check_arg(value, name, klass)
    if !value.is_a?(klass)
      raise ArgumentError, ":#{name} should be a #{klass}"
    end
  end

  def check_arg_any(value, name, klasses)
    if !klasses.detect {|klass| value.is_a?(klass)}
      raise ArgumentError, ":#{name} should be any of #{klasses.inspect}"
    end
  end

  def not_nil(value, name)
    if value.nil?
      raise ArgumentError, ":#{name} should not be blank"
    end
  end
end