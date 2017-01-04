# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_ioc/version'

Gem::Specification.new do |spec|
  spec.name          = "smart_ioc"
  spec.version       = SmartIoC::VERSION
  spec.authors       = ["Ruslan Gatiyatov"]
  spec.email         = ["ruslan@droidlabs.pro"]
  spec.description   = %q{Inversion of Control Container}
  spec.summary       = %q{Inversion of Control Container}
  spec.homepage      = "http://github.com/droidlabs/smart_ioc"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency "codecov"
end
