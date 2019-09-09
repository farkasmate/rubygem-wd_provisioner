# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe WdProvisioner::Client do
  before :all do
    @client = WdProvisioner::Client.new
  end

  it 'has pvcs' do
    expect(@client.pvcs).not_to be_empty
  end

  it 'can emit event' do
    expect { @client.create_pvc_event(WdProvisioner::Event::NORMAL, 'Hello World', @client.pvcs.first) }.not_to raise_error
  end

  it 'can create persistent volume' do
    pvc = @client.pvcs.first
    name = pvc.metadata.name
    capacity = pvc.spec.resources.requests.storage

    expect { @client.create_pv(name, capacity) }.not_to raise_error
  end

  it 'can delete persistent volume' do
    pv = @client.pvs.first
    name = pv.metadata.name

    expect { @client.delete_pv(name) }.not_to raise_error
  end

  it 'has `wd` storage class' do
    expect { @client.storage_class('wd') }.not_to raise_error
  end

  it 'fails on non-existing storage class' do
    expect { @client.storage_class('none') }.to raise_error(WdProvisioner::ResourceNotFoundError)
  end
end
# rubocop:enable Metrics/BlockLength
