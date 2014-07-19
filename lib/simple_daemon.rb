require_relative 'simple_daemon/version'
require_relative 'simple_daemon/configuration'
require_relative 'simple_daemon/logger_manager'
require_relative 'simple_daemon/pid_manager'

require 'pry'

# namespace of SimpleDaemon
module SimpleDaemon
  # SimpleDaemon Main Class
  class Daemon
    attr_reader :configuration, :logger
    attr_accessor :onset_of_sleep, :runnable

    # using
    # daemon = SimpleDaemon.new
    # daemon.configure do |conf|
    #  conf.attr = 'val'
    # end
    def initialize(verbose = false)
      @configuration = Configuration.new
      @before_callback = []
      @after_callback = []
      @onset_of_sleep = true
      @runnable = true
      @verbose = verbose
      @reload_configuration = false
      @reload_logfile = false
    end

    # configuration params
    # * sleep_time ... sleep time(Fixnum)
    # * pid_path ... file path(String)
    # * logger_path ... file path(String)
    # * logger_level ... Logger Level(Fixnum)
    # * suspend_file ... suspend_file path(String)
    def configure
      yield configuration
    end

    def configure_load(filename)
      @configuration.load(filename)
    end

    # using
    # daemon.run(false) do |daemon|
    #   do_something
    # end
    def run(daemonize = true)
      begin
        Process.daemon if daemonize

        register_signal
        register_callback

        before_process

        loop do
          if @verbose
            @logger.debug "#{ self.class } - #{ VERSION }"
            @logger.debug "sleep?               - #{ sleep? }"
            @logger.debug "shutdown?            - #{ shutdown? }"
            @logger.debug "reload_configuration - #{ @reload_configuration }"
            @logger.debug "reload_logfile       - #{ @reload_logfile }"
            @logger.debug "pid path             - #{ @pid.path }"
          end

          yield self unless suspend?

          if shutdown?
            @logger.info 'Daemon will be Shutdown...' if @verbose
            break
          end

          if sleep?
            @logger.info "Daemon Sleep #{ configuration.sleep_time } sec." if @verbose
            sleeping(configuration.sleep_time)
          end

          @logger.reopen if @reload_logfile
        end

      rescue => e
        @logger.fatal "#{ e.message }/#{ e.class } -> #{ e.backtrace }"
      ensure
        after_process
      end
    end

    private

    # simple daemon setup
    # setup to callback
    def register_callback
      @before_callback << lambda do
        @logger = LoggerManager.new(@configuration.logger_path, @configuration.logger_level)
        @logger.open
        @pid = PIDManager.new(@configuration.pid_path, $PROCESS_ID)
        @pid.create
      end

      @after_callback << lambda do
        @pid.delete
        @logger.close
      end
    end

    def register_signal
      Signal.trap(:INT) do
        @runnable = false
      end

      Signal.trap(:TERM) do
        @runnable = false
      end

      Signal.trap(:HUP) do
        @reload_configuration = true
      end

      Signal.trap(:USR1) do
        @reload_logfile = true
      end
    end

    # @return [Boolean] true is shutdown
    def shutdown?
      !@runnable
    end

    # @return [Boolean] true is sleep
    def sleep?
      onset_of_sleep
    end

    # Suppression daemon.run block
    # @return [Boolean] true is exists suspend file
    def suspend?
      File.file?(@configuration.suspend_file.to_s)
    end

    # daemon start callback
    def before_process
      @before_callback.each do |callback|
        callback.call
      end
    end

    # daemon end callback
    def after_process
      @after_callback.reverse.each do |callback|
        callback.call
      end
    end

    # daemon sleep
    # @param [Fixnum] sec seep seconds
    def sleeping(sec)
      sec.to_i.times do
        sleep 1
      end
    end
  end
end
