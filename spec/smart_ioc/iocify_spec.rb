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

  it 'reloads bean when file is reloaded' do
    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/utils')
    SmartIoC.find_package_beans(:users, dir_path)
    logger = SmartIoC.get_bean(:logger)
    initial_object_id = logger.object_id

    # reload file
    load(File.join(dir_path, 'logger.rb'))

    logger = SmartIoC.get_bean(:logger)
    final_object_id = logger.object_id

    expect(initial_object_id).not_to eq(final_object_id)
  end
end
