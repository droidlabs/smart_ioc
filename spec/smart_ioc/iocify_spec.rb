require 'spec_helper'

describe SmartIoC::Iocify do
  it 'raises if inject method was used without bean declaration' do
    expect {
      class MyTestClass
        include SmartIoC::Iocify

        inject :some_bean
      end
    }.to raise_error(ArgumentError, "MyTestClass is not registered as bean. Add `bean :bean_name` declaration")
  end
end