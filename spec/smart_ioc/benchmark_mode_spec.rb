require 'spec_helper'

describe SmartIoC do
  it {
    SmartIoC.clear
    SmartIoC.benchmark_mode(true)

    dir_path = File.join(File.expand_path(File.dirname(__FILE__)), 'example/admins')
    SmartIoC.find_package_beans(:admins, dir_path)

    SmartIoC.benchmark_mode(false)
  }
end