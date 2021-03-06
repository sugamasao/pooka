# Pooka

[![Build Status](https://travis-ci.org/sugamasao/pooka.svg?branch=master)](https://travis-ci.org/sugamasao/pooka)
[![Code Climate](https://codeclimate.com/github/sugamasao/pooka/badges/gpa.svg)](https://codeclimate.com/github/sugamasao/pooka)
[![Test Coverage](https://codeclimate.com/github/sugamasao/pooka/badges/coverage.svg)](https://codeclimate.com/github/sugamasao/pooka)
[![Inline docs](http://inch-ci.org/github/sugamasao/pooka.svg?branch=master)](http://inch-ci.org/github/sugamasao/pooka)

Pooka is Simple Daemon framework.

## Installation

Add this line to your application's Gemfile:

    gem 'pooka'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pooka

## Usage

### Simple Use

```ruby
require 'pooka'

class Worker
  def run_before(configure, logger)
    logger.info "run before: #{ configure }"
  end

  def run(configure, logger)
    until @stop do
      logger.info 'run worker'
      sleeping configure.sleep_time
    end
  end

  def run_after(configure, logger)
    logger.info "run after: #{ configure }"
  end

  # worker sleep
  # @param [Fixnum] sec seep seconds
  def sleeping(sec)
    sec.to_i.times do
      break if @stop
      sleep 1
    end
  end

  # callback for sigterm/int
  def stop
    @stop = true
  end

  # callback for sighup
  def reload
    @reload = true
  end
end

pooka = Pooka::Master.new(Worker.new)
pooka.run(false)
```

### using config file.

```ruby
pooka = Pooka::Master.new(Worker.new, config_file: yaml_path)
pooka.run(false)
```

worker use config value

```ruby
def run(configure, logger)
  puts configure['test']
end
```


TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/sugamasao/pooka/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
