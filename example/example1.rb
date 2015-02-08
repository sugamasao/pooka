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
daemon = Pooka::Daemon.new(true)

# config settings(load file)
daemon.configure_load(yaml_path)

loop_count = 0
daemon.run(false) do |d|
  d.logger.info 'stop signal to Ctrl-C or SIGTERM'
  d.logger.info 'daemon running...'
  d.logger.info d.config['pid_path']
  d.logger.info d.config['other_opt']['hash']['key1']
  d.logger.info d.config['other_opt']['list'][0]

  # 3 times loop before daemon shutdown
  loop_count += 1
  d.runnable = false if loop_count == 3
end
