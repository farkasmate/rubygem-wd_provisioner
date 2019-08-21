# frozen_string_literal: true

require 'kubeclient'

module WdProvisioner
  class Client
    def initialize
      config = Kubeclient::Config.read(ENV['KUBECONFIG'] || File.expand_path('~/.kube/config'))
      context = config.context
      @client = Kubeclient::Client.new(
        context.api_endpoint,
        'v1',
        ssl_options: context.ssl_options,
        auth_options: context.auth_options
      )
    end

    def create_pv(name, capacity)
      @client.create_persistent_volume(PersistentVolume.new(name, capacity))
    end

    def create_pvc_event(message, pvc)
      @client.create_event(Event.new(message, pvc))
    end

    def delete_pv(name)
      @client.delete_persistent_volume(name)
    end

    def pvcs
      @client.get_persistent_volume_claims.select do |pvc|
        pvc.metadata.annotations['volume.beta.kubernetes.io/storage-provisioner'] == WdProvisioner::PROVISIONER_NAME && pvc.spec.volumeName.nil?
      end
    end

    def pvs
      @client.get_persistent_volumes.select do |pv|
        pv.metadata.annotations['pv.kubernetes.io/provisioned-by'] == WdProvisioner::PROVISIONER_NAME && pv.status.phase == 'Released'
      end
    end
  end
end
