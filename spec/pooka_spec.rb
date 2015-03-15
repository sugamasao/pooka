require 'spec_helper'

describe Pooka do
  it 'has a version number' do
    expect(Pooka::VERSION).not_to be nil
  end

  describe Pooka::Master do
    let(:yaml_path) { File.join(Dir.mktmpdir('rspec'), 'config.yml') }
    let(:worker) { MyWorker.new }
    subject(:master) { Pooka::Master.new(worker, true) }
    before do
      File.write(yaml_path, 'foo: bar')
    end

    it 'generate master and configuration' do
      master.configure_load(yaml_path)
      expect(master.config['foo']).to eq 'bar'
    end

    context 'call worker method' do
      before do
        expect(worker).to receive(:run_before)
        expect(worker).to receive(:run_after)
      end
      it 'generate master log' do
        master.configure_load(yaml_path)
        allow(worker).to receive(:run)
        expect { master.run(false) }.to output(/#{Pooka::VERSION}\n.+pid path/).to_stderr
      end
    end

    context 'raise worker exception' do
      it 'worker raise error catch' do
        allow(worker).to receive(:run).and_raise(ArgumentError.new('rspec-test'))
        master.configure_load(yaml_path)
        expect { master.run(false) }.to output(/rspec-test/).to_stderr
      end
    end

    context 'Worker#run' do
      it 'worker received int signal' do
        expect {
          thread = Thread.new do
            master.configure_load(yaml_path)
            master.run(false)
          end

          # Ensure process is running.
          sleep 1.0
          Process.kill('INT', $PROCESS_ID)
          sleep 0.2
          thread.kill
        }.to output(/process shutdown/).to_stderr
      end

      it 'worker received hup signal' do
        expect {
          thread = Thread.new do
            master.configure_load(yaml_path)
            master.run(false)
          end

          # Ensure process is running.
          sleep 0.1
          Process.kill('HUP', $PROCESS_ID)
          sleep 1.0
          Process.kill('TERM', $PROCESS_ID)
          sleep 0.3
          thread.kill
        }.to output(/execute configuration reload/).to_stderr
      end

      it 'worker received hup signal(fail config reload)' do
        expect {
          thread = Thread.new do
            master.run(false)
          end

          # Ensure process is running.
          sleep 0.1
          Process.kill('HUP', $PROCESS_ID)
          sleep 1.0
          Process.kill('TERM', $PROCESS_ID)
          sleep 0.3
          thread.kill
        }.to output(/Configuration ReLoad Fail/).to_stderr
      end

      it 'worker received usr1 signal' do
        expect_any_instance_of(Pooka::Logger).to receive(:reopen)
        expect {
          thread = Thread.new do
            master.configure_load(yaml_path)
            master.run(false)
          end

          # Ensure process is running.
          sleep 0.1
          Process.kill('USR1', $PROCESS_ID)
          sleep 1.0
          Process.kill('TERM', $PROCESS_ID)
          sleep 0.3
          thread.kill
        }.to output(/process start/).to_stderr
      end

      it 'worker received usr1 signal(signal_handler_thread Error)' do
        expect_any_instance_of(Pooka::Logger).to receive(:reopen).and_raise(ArgumentError)
        expect {
          thread = Thread.new do
            master.run(false)
          end

          # Ensure process is running.
          sleep 0.1
          Process.kill('USR1', $PROCESS_ID)
          sleep 1.0
          Process.kill('TERM', $PROCESS_ID)
          sleep 0.3
          thread.kill
        }.to output(/Master Process Signal Handler Error.*ArgumentError/).to_stderr
      end
    end
  end
end
