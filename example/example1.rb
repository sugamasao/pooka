require 'pooka'

yaml_path = File.join(Dir.mktmpdir('example'), 'config.yml')
pid_path  = File.join(Dir.mktmpdir('example'), 'example.pid')
File.write(yaml_path, <<YAML)
pid_path: #{ pid_path }
other_opt:
  hash:
    key1: val1
    key2: val2
  list:
    - foo
    - bar
YAML

# true is verbose

class MyWorker < Pooka::Worker
  def run(c, logger)
    until @stop do
      logger.info 'hi'
      sleeping(c.sleep_time)
    end
  end

  def stop
    @stop = true
  end
end

pooka = Pooka::Master.new(MyWorker.new, false)
pooka.configure_load yaml_path
pooka.run(false)
