require 'pooka'
require 'pry'

yaml_path = File.join(Dir.mktmpdir('example'), 'config.yml')
pid_path  = File.join(Dir.mktmpdir('example'), 'example.pid')
File.write(yaml_path, <<YAML)
pid_path: #{ pid_path }
sleep_time: 5
other_opt:
  hash:
    key1: val1
    key2: val2
  list:
    - foo
    - bar
YAML

class Worker
  def run_before(configure, logger)
    logger.info "run before: #{ configure }"
  end

  def run(configure, logger)
    until @stop
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

pooka = Pooka::Master.new(Worker.new, config_file: yaml_path, verbose: false)
pooka.run(false)
