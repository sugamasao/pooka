require 'spec_helper'

describe Pooka::CallbackController do
  subject(:controller) { Pooka::CallbackController.new }
  context '#fire_before_callback' do
    it 'called callback' do
      controller.add_before_callback(->{ 'Its Test' })
    end
  end
end