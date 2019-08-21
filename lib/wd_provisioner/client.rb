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
      @client.get_persistent_volume_claims.select { |pvc| pvc.spec.storageClassName == 'wd' && pvc.spec.volumeName.nil? }
    end

    def pvs
      @client.get_persistent_volumes.select { |pv| pv.metadata.annotations['pv.kubernetes.io/provisioned-by'] == 'wd-provisioner' && pv.status.phase == 'Released' }
    end
  end
end
