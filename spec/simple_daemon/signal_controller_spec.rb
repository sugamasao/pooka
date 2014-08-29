require 'spec_helper'

describe SimpleDaemon::SignalController do
  let(:hup_number)  {  1 }
  let(:int_number)  {  2 }
  let(:term_number) { 15 }
  let(:usr1_number) { 30 }

  subject(:controller) { SimpleDaemon::SignalController.new }

  context 'change signal state' do
    before do
      @controller = SimpleDaemon::SignalController.new
    end

    it 'change hup' do
      expect {
        @controller.signal_set(hup_number)
      }.to change{ @controller.hup? }.from(false).to(true)
    end
    it 'change int' do
      expect {
        @controller.signal_set(int_number)
      }.to change{ @controller.int? }.from(false).to(true)
    end
    it 'change term' do
      expect {
        @controller.signal_set(term_number)
      }.to change{ @controller.term? }.from(false).to(true)
    end
    it 'change usr1' do
      expect {
        @controller.signal_set(usr1_number)
      }.to change{ @controller.usr1? }.from(false).to(true)
    end
  end

  context '#received_signal?' do
    before do
      @controller = SimpleDaemon::SignalController.new
    end

    it 'hup true' do
      expect {
        @controller.signal_set(hup_number)
      }.to change { @controller.received_signal? }.from(false).to(true)
    end
    it 'int true' do
      expect {
        @controller.signal_set(int_number)
      }.to change { @controller.received_signal? }.from(false).to(true)
    end
    it 'term true' do
      expect {
        @controller.signal_set(term_number)
      }.to change { @controller.received_signal? }.from(false).to(true)
    end
    it 'usr1 true' do
      expect {
        @controller.signal_set(usr1_number)
      }.to change { @controller.received_signal? }.from(false).to(true)
    end

  end

end