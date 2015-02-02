require 'spec_helper'
require 'tmpdir'

describe SimpleDaemon::PID do
  let(:pid_body) { '100' }
  subject(:pid) { SimpleDaemon::PID.new(path, pid_body) }

  context 'PID#create' do
    context 'creatable pid file' do
      let(:path) { File.join(Dir.mktmpdir, 'sample.pid') }
      it 'create pid' do
        expect(File.exist? path).to be_falsey
        expect(pid.create).to be_truthy
        expect(File.exist? path).to be_truthy
        expect(File.read(path)).to eq pid_body
      end

      it 'duplicate pid(second #create is not create)' do
        expect(File.exist? path).to be_falsey
        expect(pid.create).to be_truthy
        expect(pid.create).to be_falsey
        expect(File.exist? path).to be_truthy
      end
    end

    context 'can not create pid file (pid path is directory)' do
      let(:path) { Dir.mktmpdir }
      it 'create pid' do
        expect(File.directory? path).to be_truthy
        expect(pid.create).to be_falsey
      end
    end

    context 'can not create pid file (pid path is nothing path)' do
      let(:path) { File.join(Dir.mktmpdir, 'path', 'sample.pid') }
      it 'create pid' do
        expect(File.directory? File.dirname(path)).to be_falsey
        expect(pid.create).to be_falsey
      end
    end
  end

  context 'PID#delete' do
    let(:path) { File.join(Dir.mktmpdir, 'sample.pid') }
    it 'delete pid' do
      expect(File.exist? path).to be_falsey
      expect(pid.create).to be_truthy
      expect(File.exist? path).to be_truthy
      pid.delete
      expect(File.exist? path).to be_falsey
    end

    it 'can not delete pid' do
      expect(File.exist? path).to be_falsey
      expect { pid.delete }.to_not raise_error
    end
  end

  context 'PID#rename' do
    let(:path) { File.join(Dir.mktmpdir, 'sample.pid') }
    let(:rename_path) { File.join(Dir.mktmpdir, 'sample2.pid') }
    it 'rename pid' do
      expect(File.exist? path).to be_falsey
      expect(File.exist? rename_path).to be_falsey
      expect(pid.create).to be_truthy
      expect(File.exist? path).to be_truthy
      pid.rename(rename_path)
      expect(File.exist? path).to be_falsey
      expect(File.exist? rename_path).to be_truthy
    end

  end
end
