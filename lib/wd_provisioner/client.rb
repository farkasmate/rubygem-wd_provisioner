# frozen_string_literal: true

require 'kubeclient'

module WdProvisioner
  class Client
    def initialize
      config = Kubeclient::Config.read(ENV['KUBECONFIG'] || File.expand_path('~/.kube/config'))

      uri = URI.parse(config.context.api_endpoint)
      core_uri = uri.clone
      core_uri.path = '/api'
      storage_uri = uri.clone
      storage_uri.path = '/apis/storage.k8s.io'
      options = {
        ssl_options: config.context.ssl_options,
        auth_options: config.context.auth_options
      }

      @client_core = Kubeclient::Client.new(
        core_uri,
        'v1',
        options
      )
      @client_storage = Kubeclient::Client.new(
        storage_uri,
        'v1',
        options
      )
    end

    def create_pv(name, capacity)
      @client_core.create_persistent_volume(PersistentVolume.new(name, capacity))
    end

    def create_pvc_event(message, pvc)
      @client_core.create_event(Event.new(message, pvc))
    end

    def delete_pv(name)
      @client_core.delete_persistent_volume(name)
    end

    def finish_watchers
      @pvc_watcher&.finish
    end

    def pvcs
      @pvc_watcher = @client_core.watch_persistent_volume_claims
      @pvc_watcher.each do |watch_event|
        next unless watch_event.type == 'ADDED'
        next unless watch_event.object.metadata.annotations['volume.beta.kubernetes.io/storage-provisioner'] == WdProvisioner::PROVISIONER_NAME
        next unless watch_event.object.spec.volumeName.nil?

        yield watch_event.object
      end
    end

    def pvs
      @client_core.get_persistent_volumes.select do |pv|
        pv.metadata.annotations['pv.kubernetes.io/provisioned-by'] == WdProvisioner::PROVISIONER_NAME && pv.status.phase == 'Released'
      end
    end

    def storage_class(name)
      @client_storage.get_storage_class(name)
    rescue Kubeclient::ResourceNotFoundError => e
      raise ResourceNotFoundError.new, e.message
    end
  end
end
