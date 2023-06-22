require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'pry'

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.direnv/"
end

if ENV['CI']=='true'
  require 'codecov'

  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'smart_ioc'

RSpec.configure do |config|
end
