require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pooka'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
