require_relative 'pooka/version'
require_relative 'pooka/configuration'
require_relative 'pooka/logger'
require_relative 'pooka/pid'

# namespace of Pooka
module Pooka
  # Pooka Main Class
  class Master
    attr_reader :config, :logger
    attr_accessor :onset_of_sleep, :runnable

    # using
    # daemon = Pooka.new
    # daemon.configure do |conf|
    #  conf.attr = 'val'
    # end
    def initialize(worker, verbose = false)
      @worker = worker
      @config = Configuration.new
      @verbose = verbose
    end

    def configure_load(filename)
      @config.load(filename)
    end

    # using
    # daemon.run(false) do |daemon|
    #   do_something
    # end
    def run(daemonize = true)
      begin
        Process.daemon if daemonize

        register_signal

        @logger = Pooka::Logger.new(@config.logger_path, @config.logger_level)
        @logger.open

        @pid = PID.new(@config.pid_path, $PROCESS_ID)
        @pid.create

        @worker.run_before(@config, @logger) if @worker.respond_to?(:run_before)

        if @configuration_reload
          @logger.debug 'execute configuration reload.'
          configuration_reload
          @configuration_reload = false
        end

        if @logger_reload
          @logger.reopen(@config.loger_path, @config.logger_level)
          @logger_reload = false
        end

        @worker.run(@config, @logger)
      rescue => e
        @logger.fatal "#{ e.message }/#{ e.class } -> #{ e.backtrace }"
      ensure
        @worker.run_after(@config, @logger) if @worker.respond_to?(:run_after)
        @pid.delete
        @logger.close
      end
    end

    private

    def register_signal
      Signal.trap(:INT) do
        @stop = true
        @worker.stop if @worker.respond_to?(:stop)
      end

      Signal.trap(:TERM) do
        @stop = true
        @worker.stop if @worker.respond_to?(:stop)
      end

      Signal.trap(:HUP) do
        @configuration_reload = true
        @worker.reload if @worker.respond_to?(:reload)
      end

      Signal.trap(:USR1) do
        @logger_reload = true
      end
    end


    # configuration reload
    def configuration_reload
      begin
        @config.reload
      rescue ConfigurationError => e
        @logger.warn "Configuration ReLoad Fail. #{ e.message }"
      else
        @logger.reopen(@config.logger_path, @config.logger_level)
        @pid.rename(@config.pid_path)
      end
    end

    # logging daemon information
    def inspect_daemon_information
      @logger.debug "#{ self.class } - #{ VERSION }"
      @logger.debug "stop                 - #{ @stop }"
      @logger.debug "configuration_reload - #{ @configuration_reload }"
      @logger.debug "logger_reload        - #{ @logger_reload }"
      @logger.debug "pid path             - #{ @pid.path }"
    end
  end
end
