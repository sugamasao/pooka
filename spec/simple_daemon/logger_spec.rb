require 'spec_helper'

require 'tmpdir'
require 'logger'

describe SimpleDaemon::Logger do
  let(:create_log_path) { File.join(Dir.tmpdir, 'logger.log') }

  context '#open' do
    before do
      $stderr = File.open(File::NULL, 'w')
    end
    after do
      $stderr.close unless $stderr.closed?
      $stderr = STDERR
    end

    it 'Create Logger(STDERR)' do
      logger_manager = SimpleDaemon::Logger.new($stderr, 'info')
      logger_manager.open
      logger = logger_manager.instance_variable_get(:@logger)
      expect(logger.level).to eq ::Logger::INFO
      expect(logger.instance_variable_get(:@logdev).dev).to eq $stderr
      expect { logger_manager.close }.to_not raise_error
    end

    it 'Not Create Logger(fallback STDERR)' do
      logger_manager = SimpleDaemon::Logger.new(File.dirname(create_log_path), 'foo')
      logger_manager.open
      logger = logger_manager.instance_variable_get(:@logger)
      expect(logger.level).to eq ::Logger::DEBUG
      expect(logger.instance_variable_get(:@logdev).dev).to eq $stderr
      expect { logger_manager.close }.to_not raise_error
    end

    it 'Create Logger' do
      logger_manager = SimpleDaemon::Logger.new(create_log_path, 'INFO')
      logger_manager.open
      logger_manager.info 'hi'
      expect(File.readlines(create_log_path).last).to match /hi/
      expect(File.readlines(create_log_path).last).to match /INFO/
      expect { logger_manager.close }.to_not raise_error
    end
  end

  context '#reopen' do
    before do
      $stderr = File.open(File::NULL, 'w')

    end
    after do
      $stderr.close unless $stderr.closed?
      $stderr = STDERR
    end

    it 'Reopen Logger(STDERR -> FILE)' do
      logger_manager = SimpleDaemon::Logger.new($stderr, 'info')
      logger_manager.open
      logger_manager.reopen(create_log_path, 'WARN')
      logger = logger_manager.instance_variable_get(:@logger)
      expect(logger.level).to eq ::Logger::WARN
      expect(logger.instance_variable_get(:@logdev).dev.path).to eq create_log_path
      expect { logger_manager.close }.to_not raise_error
    end

    it 'Reopen Fail Logger(STDERR -> STDERR' do
      logger_manager = SimpleDaemon::Logger.new($stderr, 'info')
      logger_manager.open
      logger_manager.reopen(File.join(create_log_path, 'foo'), 'WARN')
      logger = logger_manager.instance_variable_get(:@logger)
      expect(logger.level).to eq ::Logger::INFO
      expect(logger.instance_variable_get(:@logdev).dev).to eq $stderr
      expect { logger_manager.close }.to_not raise_error
    end
  end
end
