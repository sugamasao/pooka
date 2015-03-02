require 'spec_helper'
require 'tmpdir'
require 'pathname'

describe Pooka::Configuration do
  context 'fail configuration load' do
    let(:yaml_path) { File.join(Dir.mktmpdir('rspec'), 'config.yml') }
    let(:yaml_path_no_extname) { File.join(Dir.mktmpdir('rspec'), 'config') }
    let(:json_path) { File.join(Dir.mktmpdir('rspec'), 'config.json') }

    it 'file not found' do
      expect {
        Pooka::Configuration.new.load('/path/to/config')
      }.to raise_error Pooka::Configuration::ConfigurationFileNotFound
    end

    it 'yaml parse error' do
      expect {
        File.write(yaml_path, '%') # broken data
        Pooka::Configuration.new.load(yaml_path)
      }.to raise_error Pooka::Configuration::ConfigurationFileParseError
    end

    it 'yaml parse error(no extname fallback to yaml)' do
      expect {
        File.write(yaml_path_no_extname, '%') # broken data
        Pooka::Configuration.new.load(yaml_path_no_extname)
      }.to raise_error Pooka::Configuration::ConfigurationFileParseError
    end

    it 'json parse error' do
      expect {
        File.write(json_path, '') # broken data
        Pooka::Configuration.new.load(json_path)
      }.to raise_error Pooka::Configuration::ConfigurationFileParseError
    end
  end

  describe 'load configuration' do
    let(:yaml_path) { File.join(Dir.mktmpdir('rspec'), 'config.yml') }
    before do
      File.write(yaml_path, 'foo: bar')
    end
    subject { c = Pooka::Configuration.new; c.load(yaml_path); c }

    it 'get config value' do
      expect(subject['foo']).to eq 'bar'
    end

    context 'master process require data using default value' do
      it 'default sleep time' do
        expect(subject.sleep_time).to eq 60
      end

      it 'default pid path' do
        expect(subject.pid_path).to include 'pooka.pid'
      end

      it 'default logger path' do
        expect(subject.logger_path).to be_nil
      end

      it 'default logger level' do
        expect(subject.logger_level).to be_nil
      end
    end

    context '#to_s' do
      it 'data to_string' do
        expect(subject.to_s).to include({ 'foo' => 'bar' }.to_s)
      end
    end
  end

  describe 'config file pattern' do
    let(:yaml_path) { File.join(Dir.mktmpdir('rspec'), 'config.yml') }
    before do
      File.write(yaml_path, 'foo: bar')
    end

    it 'config file is nil' do
      expect {
        Pooka::Configuration.new.load(nil)
      }.to raise_error Pooka::Configuration::ConfigurationFileNotFound
    end

    it 'config file is Pathname' do
      c = Pooka::Configuration.new
      c.load(Pathname(yaml_path))
      expect(c['foo']).to eq 'bar'
    end
  end

  describe 'reload configuration' do
    let(:yaml_path) { File.join(Dir.mktmpdir('rspec'), 'config.yml') }
    before do
      File.write(yaml_path, 'foo: bar')
    end
    subject { c = Pooka::Configuration.new; c.load(yaml_path); c }

    it '#reload' do
      expect {
        File.write(yaml_path, 'foo: baz')
        subject.reload
      }.to change { subject['foo'] }.from('bar').to('baz')
    end
  end
end
