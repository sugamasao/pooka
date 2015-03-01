require 'tmpdir'
require 'yaml'
require 'json'
require 'forwardable'

module Pooka
  # Pooka Configuration Class.
  class Configuration
    # @abstract abstract Configuration Error class
    class ConfigurationError < StandardError;end

    # Configuration file not found Error Class
    class ConfigurationFileNotFound < ConfigurationError; end

    # Configuration Parse Error Class
    class ConfigurationFileParseError < ConfigurationError; end
    
    extend Forwardable

    # default value
    DEFAULT_SLEEP_TIME = 60

    # default value
    DEFAULT_PID_PATH = File.join(Dir.mktmpdir('pooka'), 'pooka.pid')

    def_delegators :@data, :[]

    attr_accessor :logger_path, :logger_level, :pid_path, :sleep_time

    def initialize
      @data = {}

      # default value
      @pid_path   = DEFAULT_PID_PATH
      @sleep_time = DEFAULT_SLEEP_TIME
    end

    # settings load
    # @param [String/Pathname] filename configuration path(Format is YAML)
    # @return [Hash] Load Data
    # @raise [ConfigurationError] File NotFound or File format Error
    def load(filename)
      filename = filename.to_s # nil or Pathname to stringify
      unless File.file?(filename)
        raise ConfigurationFileNotFound, "Configuration File NotFound(#{ filename })"
      end

      @configure_filename = filename
      begin
        @data = load_file(@configure_filename)
        apply_pooka_configure(@data)
      rescue Psych::SyntaxError => e
        raise ConfigurationFileParseError, "Configuration YAML Format Error - #{ e.message }"
      rescue JSON::ParserError => e
        raise ConfigurationFileParseError, "Configuration JSON Format Error - #{ e.message }"
      end
    end

    # reload yaml data
    # @raise [ConfigurationError] File NotFound or File format Error
    def reload
      load(@configure_filename)
    end

    def to_s
      @data.to_s
    end

    private

    def load_file(filename)
      case File.extname(filename).downcase
        when '.yml', '.yaml'
          YAML.load_file(filename) || {}
        when '.json'
          JSON.parse(File.read(filename))
        else
          YAML.load_file(filename) || {}
      end
    end

    # apply master process require data
    # @param [Hash] data configure data
    def apply_pooka_configure(data)
      @logger_path  = data['logger_path']
      @logger_level = data['logger_level']
      @pid_path     = data['pid_path']   || @pid_path
      @sleep_time   = data['sleep_time'] || @sleep_time
    end
  end
end
