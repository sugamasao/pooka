require 'tmpdir'
require 'yaml'
require 'forwardable'

module SimpleDaemon
  # SimpleDaemon Configuration Class.
  class Configuration
    extend Forwardable

    def_delegators :@data, :[]

    attr_accessor :logger_path, :logger_level, :pid_path, :suspend_file, :sleep_time

    # Configuration default settings
    # * logger_path - logger file path(for Logger class)
    # * logger_level - logger level(for Logger class)
    # * pid_path - Process ID Written path
    # * suspend_file - Daemon pause file(lock file path)
    # * sleep_time - Daemon#run next turn wait time(sec)
    def initialize
      @data = {}
      @configure_filename = nil

      # default settings.
      @logger_path  = nil
      @logger_level = nil
      @pid_path     = File.join(Dir.mktmpdir('simple_daemon'), 'simple_daemon.pid')
      @suspend_file = nil
      @sleep_time   = 10 # sec
    end

    # @param [String] configure_filename configuration path(Format is YAML)
    # @return [Hash] Load Data
    def load(configure_filename)
      @configure_filename = configure_filename.to_s

      @data = YAML.load_file(@configure_filename)

      @logger_path  = @data['logger_path']  || @logger_path
      @logger_level = @data['logger_level'] || @logger_level
      @pid_path     = @data['pid_path']     || @pid_path
      @suspend_file = @data['suspend_file'] || @suspend_file
      @sleep_time   = @data['sleep_time']   || @sleep_time
    end

    def reload
    end

    def dump_configuration
      @data.to_s
    end

    private

    def dup
    end
  end
end
