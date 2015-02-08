require 'tmpdir'
require 'yaml'
require 'forwardable'

module Pooka
  # Configuration Error Class
  class ConfigurationError < StandardError; end

  # Pooka Configuration Class.
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
      @pid_path     = File.join(Dir.mktmpdir('pooka'), 'pooka.pid')
      @suspend_file = nil
      @sleep_time   = 10 # sec
    end

    # settings load
    # @param [String] filename configuration path(Format is YAML)
    # @return [Hash] Load Data
    # @raise [ConfigurationError] File NotFound or File format Error
    def load(filename)
      unless File.file?(filename.to_s)
        raise ConfigurationError, "Configuration YAML File NotFound(#{ filename })"
      end

      @configure_filename = filename
      begin
        @data = YAML.load_file(@configure_filename)
        apply_configure(@data)
      rescue Psych::SyntaxError => e
        raise ConfigurationError, "Configuration YAML Format Error(#{ filename }) - #{ e.message }"
      end
    end

    # reload yaml data
    # @raise [ConfigurationError] File NotFound or File format Error
    def reload
      load(@configure_filename)
    end

    # Dump dat
    # @return [String] data
    def dump_configuration
      @data.to_s
    end

    # suspend file exists?
    # @return [Boolean] true is exits
    def suspend_file?
      File.file?(@suspend_file.to_s)
    end

    private

    # apply read data
    # @param [Hash] data configure data
    def apply_configure(data)
      @logger_path  = data['logger_path']  || @logger_path
      @logger_level = data['logger_level'] || @logger_level
      @pid_path     = data['pid_path']     || @pid_path
      @suspend_file = data['suspend_file'] || @suspend_file
      @sleep_time   = data['sleep_time']   || @sleep_time
    end

    def dup
    end
  end
end
