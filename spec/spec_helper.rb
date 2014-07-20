require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simple_daemon'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
