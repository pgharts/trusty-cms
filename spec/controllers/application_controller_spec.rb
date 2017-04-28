require 'spec_helper'

describe ApplicationController, :type => :controller do
  routes { TrustyCms::Engine.routes }

  it 'should initialize the javascript and stylesheets arrays' do
    controller.send :set_javascripts_and_stylesheets
    expect(controller.send(:instance_variable_get, :@javascripts)).not_to be_nil
    expect(controller.send(:instance_variable_get, :@javascripts)).to be_instance_of(Array)
    expect(controller.send(:instance_variable_get, :@stylesheets)).not_to be_nil
    expect(controller.send(:instance_variable_get, :@stylesheets)).to be_instance_of(Array)
  end

  describe 'self.template_name' do
    it "should return 'index' when the controller action_name is 'index'" do
      allow(controller).to receive(:action_name).and_return('index')
      expect(controller.template_name).to eq('index')
    end
    ['new', 'create'].each do |action|
      it "should return 'new' when the action_name is #{action}" do
      allow(controller).to receive(:action_name).and_return(action)
      expect(controller.template_name).to eq('new')
      end
    end
    ['edit', 'update'].each do |action|
      it "should return 'edit' when the action_name is #{action}" do
      allow(controller).to receive(:action_name).and_return(action)
      expect(controller.template_name).to eq('edit')
      end
    end
    ['remove', 'destroy'].each do |action|
      it "should return 'remove' when the action_name is #{action}" do
      allow(controller).to receive(:action_name).and_return(action)
      expect(controller.template_name).to eq('remove')
      end
    end
    it "should return 'show' when the action_name is show" do
      allow(controller).to receive(:action_name).and_return('show')
      expect(controller.template_name).to eq('show')
    end
    it "should return the action_name when the action_name is a non-standard name" do
      allow(controller).to receive(:action_name).and_return('other')
      expect(controller.template_name).to eq('other')
    end
  end

  describe "set_timezone" do
    it "should use TrustyCms::Config['local.timezone']" do
      TrustyCms::Config['local.timezone'] = 'UTC'
      controller.send(:set_timezone)
      expect(Time.zone.name).to eq('UTC')
    end

    it "should default to config.time_zone" do
      TrustyCms::Config.initialize_cache # to clear out setting from previous tests
      controller.send(:set_timezone)
      expect(Time.zone.name).to eq('UTC')
    end
  end
end
