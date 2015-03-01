require 'thread'
require_relative 'pooka/version'
require_relative 'pooka/configuration'
require_relative 'pooka/logger'
require_relative 'pooka/pid'

# namespace of Pooka
module Pooka
  # Pooka Main Class
  class Master
    attr_reader :config, :logger

    # usage
    # daemon = Pooka.new(Worker)
    # daemon.configure_load '/path/to/configure.yml'
    # @param [Class] worker require `run` method
    # @param [Boolean] verbose true is master process verbose mode.
    def initialize(worker, verbose = false)
      @worker  = worker
      @verbose = verbose
      @config  = Configuration.new
    end

    # configuration file load.
    # file type in YAML or JSON(inference by extname)
    # @param [String/Pathname] filename
    # @return [void]
    def configure_load(filename)
      @config.load(filename)
    end

    # usage
    # daemon.run(false) do |daemon|
    #   do_something
    # end
    # @param [Boolean] daemonize true is daemonize
    # @return [void]
    def run(daemonize = true)
      begin
        Process.daemon if daemonize

        @logger = Pooka::Logger.new(@config.logger_path, @config.logger_level)
        @logger.open

        @pid = PID.new(@config.pid_path, $PROCESS_ID)
        @pid.create

        register_signal
        signal_handler = signal_handler_thread
        inspect_daemon_information

        @worker.run_before(@config, @logger) if @worker.respond_to?(:run_before)

        @worker.run(@config, @logger)
      rescue => e
        @logger.fatal "#{ e.message }/#{ e.class } -> #{ e.backtrace }"
      ensure
        signal_handler.exit if signal_handler.alive?
        @worker.run_after(@config, @logger) if @worker.respond_to?(:run_after)
        @pid.delete
        @logger.close
      end
    end

    private

    # signal handler set
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

    def signal_handler_thread
      Thread.new do
        until @stop do
          begin
            if @configuration_reload
              configuration_reload
              @configuration_reload = false
            end

            if @logger_reload
              @logger.reopen(@config.logger_path, @config.logger_level)
              @logger_reload = false
            end
          rescue => e
            @logger.fatal "Master Process Signal Handler Error. #{ e.message }/#{ e.class } -> #{ e.backtrace }"
          end

          sleep 1
        end
      end
    end

    # configuration reload
    def configuration_reload
      begin
        @logger.debug 'execute configuration reload.'
        @config.reload
      rescue Configuration::ConfigurationError => e
        @logger.warn "Configuration ReLoad Fail. #{ e.message }"
      else
        @logger.reopen(@config.logger_path, @config.logger_level)
        @pid.rename(@config.pid_path)
      end
    end

    # logging daemon information
    def inspect_daemon_information
      @logger.debug format('%-15s - %s', self.class, VERSION)
      @logger.debug format('%-15s - %s', 'pid path', @pid.path)
    end
  end
end
