# frozen_string_literal: true

require 'base64'
require 'kubeclient'
require 'securerandom'

module WdProvisioner
  class Secret < Kubeclient::Resource
    attr_accessor :password

    def initialize(name)
      secret = RecursiveOpenStruct.new(YAML.safe_load(template_secret))

      @password = generate_password
      secret.metadata.name = name
      secret.data.password = Base64.strict_encode64(@password)

      super(secret.to_h)
    end

    private

    def template_secret
      <<~SECRET
        apiVersion: v1
        kind: Secret
        metadata:
          name: template-secret
          namespace: default
        type: Opaque
        data:
          password: ''
      SECRET
    end

    def generate_password
      SecureRandom.base64[0..15]
    end
  end
end
