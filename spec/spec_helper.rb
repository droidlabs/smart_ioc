require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'pry'

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.direnv/"
end

require 'smart_ioc'

RSpec.configure do |config|
end
