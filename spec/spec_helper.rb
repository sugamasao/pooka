require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pooka'
require 'pry'

class MyWorker
  def run(_, __)
    until @stop
      sleep 0.1
    end
  end

  def run_before(_, __)
  end

  def run_after(_, __)
  end

  def stop
    @stop = true
  end

  def reload
    @reload = true
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
