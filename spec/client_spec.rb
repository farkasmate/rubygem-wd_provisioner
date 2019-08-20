# frozen_string_literal: true

require 'spec_helper'

describe WdProvisioner::Client do
  before :all do
    @client = WdProvisioner::Client.new
  end

  it 'has pvcs' do
    expect(@client.pvcs).not_to be_empty
  end

  it 'can emit events' do
    expect { @client.create_pvc_event('Hello World', @client.pvcs.first) }.not_to raise_error
  end
end
