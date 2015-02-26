require 'tmpdir'
require 'yaml'
require 'json'
require 'forwardable'

module Pooka
  # Configuration Error Class
  class ConfigurationError < StandardError; end

  # Pooka Configuration Class.
  class Configuration
    extend Forwardable

    def_delegators :@data, :[]

    attr_accessor :logger_path, :logger_level, :pid_path, :sleep_time

    # Configuration default settings
    # * logger_path - logger file path(for Logger class)
    # * logger_level - logger level(for Logger class)
    # * pid_path - Process ID Written path
    # * sleep_time - Master#run next turn wait time(sec)
    def initialize
      @data = {}
      @configure_filename = nil

      # default settings.
      @logger_path  = nil
      @logger_level = nil
      @pid_path     = File.join(Dir.mktmpdir('pooka'), 'pooka.pid')
      @sleep_time   = 60 # sec
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
        @data = load_file(@configure_filename)
        apply_configure(@data)
      rescue JSON::ParserError => e
        raise ConfigurationError, "Configuration JSON Format Error(#{ filename }) - #{ e.message }"
      rescue Psych::SyntaxError => e
        raise ConfigurationError, "Configuration YAML Format Error(#{ filename }) - #{ e.message }"
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
        when 'yml', 'yaml'
          YAML.load_file(filename)
        when 'json'
          JSON.parse(Fiel.read(filename))
        else
          YAML.load_file(filename)
      end
    end

    # apply read data
    # @param [Hash] data configure data
    def apply_configure(data)
      @logger_path  = data['logger_path']  || @logger_path
      @logger_level = data['logger_level'] || @logger_level
      @pid_path     = data['pid_path']     || @pid_path
      @sleep_time   = data['sleep_time']   || @sleep_time
    end
  end
end
