# frozen_string_literal: true

require 'spec_helper'

describe WdProvisioner::Event do
  before :all do
    involved_object = RecursiveOpenStruct.new(metadata: { name: 'test-object', uid: 'test-uid' })
    event = WdProvisioner::Event.new(WdProvisioner::Event::NORMAL, 'test-event', involved_object)
    @event = RecursiveOpenStruct.new(event.to_h)
  end

  it 'has involved object "test-object"' do
    name = @event.involvedObject.name
    uid = @event.involvedObject.uid

    expect(name).to equal('test-object')
    expect(uid).to equal('test-uid')
  end
end
