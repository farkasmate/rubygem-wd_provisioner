# frozen_string_literal: true

require 'spec_helper'

describe WdProvisioner::Secret do
  before :all do
    secret = WdProvisioner::Secret.new('test-secret')
    @secret = RecursiveOpenStruct.new(secret.to_h)
  end

  it 'is named "test-secret"' do
    name = @secret.metadata.name
    expect(name).to equal('test-secret')
  end

  it 'has 16 chars long password' do
    password = Base64.strict_decode64(@secret.data.password)
    expect(password.length).to equal(16)
  end
end
