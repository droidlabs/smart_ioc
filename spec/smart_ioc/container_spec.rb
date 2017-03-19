require 'spec_helper'

describe SmartIoC::Container do
  it 'does not have initializer' do
    expect {
      SmartIoC::Container.new
    }.to raise_error(ArgumentError, "SmartIoC::Container should not be allocated. Use SmartIoC::Container.get_instance instead")
  end
end