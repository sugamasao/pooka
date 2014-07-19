require 'spec_helper'

require 'tmpdir'
require 'logger'

describe SimpleDaemon::LoggerManager do
  let(:create_log_path) { File.join(Dir.tmpdir, 'logger_manager.log') }

  context '#open' do
    before do
      $stderr = File.open(File::NULL, 'w')
    end
    after do
      $stderr.close unless $stderr.closed?
      $stderr = STDERR
    end

    it 'create Logger(STDERR)' do
      logger_manager = SimpleDaemon::LoggerManager.new($stderr, 'info')
      logger_manager.open
      logger = logger_manager.instance_variable_get(:@logger)
      expect(logger.level).to eq Logger::INFO
      expect(logger.instance_variable_get(:@logdev).dev).to eq $stderr
      expect{ logger_manager.close }.to_not raise_error
    end

    it 'not create Logger(fallback STDERR)' do
      logger_manager = SimpleDaemon::LoggerManager.new(File.dirname(create_log_path), 'foo')
      logger_manager.open
      logger = logger_manager.instance_variable_get(:@logger)
      expect(logger.level).to eq Logger::DEBUG
      expect(logger.instance_variable_get(:@logdev).dev).to eq $stderr
      expect{ logger_manager.close }.to_not raise_error
    end

    it 'create Logger' do
      logger_manager = SimpleDaemon::LoggerManager.new(create_log_path, 'INFO')
      logger_manager.open
      logger_manager.info 'hi'
      expect(File.readlines(create_log_path).last).to match /hi/
      expect(File.readlines(create_log_path).last).to match /INFO/
      expect{ logger_manager.close }.to_not raise_error
    end
  end
end
