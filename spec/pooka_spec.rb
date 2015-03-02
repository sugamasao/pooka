require 'spec_helper'

describe Pooka do
  it 'has a version number' do
    expect(Pooka::VERSION).not_to be nil
  end

  describe Pooka::Master do
    let(:yaml_path) { File.join(Dir.mktmpdir('rspec'), 'config.yml') }
    let(:worker) {
      class Worker
        def run(_, __); end

        def run_before(_, __); end

        def run_after(_, __); end
      end
      Worker.new
    }
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
        expect { master.run(false) }.to output(/#{Pooka::VERSION}\n.+pid path/).to_stderr
      end
    end
  end
end
