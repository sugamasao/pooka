require 'simple_daemon'

daemon = SimpleDaemon::Daemon.new(true)

# config settings(direct setting)
daemon.configure do |config|
  config.logger_path = '/tmp/sample.log'
  config.sleep_time  = 3
end

yml_path = File.join(Dir.mktmpdir('example'), 'config.yml')
File.write(yml_path, <<YAML)
pid_path: /tmp/foo.pid
other_opt:
  hash:
    key1: val1
    key2: val2
  list:
    - foo
    - bar
YAML

# config settings(load file)
daemon.configure_load(yml_path)

loop_count = 0
daemon.run(false) do |d|
  d.logger.info 'stop signal to Ctrl-C or SIGTERM'
  d.logger.info 'daemon running...'
  d.logger.info d.configuration['pid_path']
  d.logger.info d.configuration['other_opt']['hash']['key1']
  d.logger.info d.configuration['other_opt']['list'][0]

  # 3 times loop before daemon shutdown
  loop_count += 1
  d.runnable = false if loop_count == 3
end
