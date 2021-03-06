require 'logger'
require 'forwardable'

module Pooka
  # Logger Management Class
  class Logger
    extend Forwardable

    def_delegators :@logger, :fatal, :error, :warn, :info, :debug

    # @overload initialize(path, level)
    #   @param [String] path Logger path
    #   @param [String] level Logging Level ('INFO', 'WARN' ...)
    # @overload initialize(path, level)
    #   @param [IO] path Logger IO Object
    #   @param [String] level Logging Level ('INFO', 'WARN' ...)
    def initialize(path, level)
      @path  = path || $stderr
      @level = level
      @use_stderr = @path == $stderr
    end

    # Logger open
    # if Logger open failed. using STDERR device
    def open
      @logger = ::Logger.new(@path)
    rescue => e
      @logger = ::Logger.new($stderr)
      @logger.warn "Logger File Create Failed(using STDERR device). [#{e.message}] path=[#{@path}] [#{@path.class}]"
    ensure
      @logger.level = find_logger_level(@level)
    end

    # Logger close
    def close
      @logger.close
    end

    # Logger reopen
    # @param [String] new_logfile_path nil is using now used file path
    # @param [String] new_level nil is using now used log level
    def reopen(new_logfile_path = nil, new_level = nil)
      new_logfile_path ||= @path
      old_logger = @logger
      old_use_stderr = @use_stderr
      begin
        @logger = ::Logger.new(new_logfile_path)
        @logger.level = find_logger_level(new_level || @level)

        @use_stderr = new_logfile_path == $stderr
        old_logger.close unless old_use_stderr
      rescue
        @logger = old_logger
        @logger.warn "Logger Reopen Failed. Use Old Logger. (New Logger File Path = #{ new_logfile_path || @path })"
      end
    end

    private

    # find logger level
    # @param [String] level Logger Level
    # @return [Fixnum] ::Logger::DEBUG .. ::Logger::WARN level
    def find_logger_level(level)
      ::Logger::Severity.constants.each do |logger_defined_level|
        if level.to_s.upcase == logger_defined_level.to_s.upcase
          return ::Logger.const_get logger_defined_level
        end
      end

      ::Logger::DEBUG # it's default.
    end
  end
end
