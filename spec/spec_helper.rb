require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simple_daemon'
require 'simple_daemon/configuration'
require 'simple_daemon/pid_manager'
require 'simple_daemon/logger_manager'

require 'pry'

RSpec.configure do |config|
#  config.raise_errors_for_deprecations!
end
