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

    def create_pvc_event(type, message, pvc)
      event = lookup_event(type, message, pvc)

      if event
        prevoius_count = event.count || 1
        event.count = prevoius_count + 1
        event.lastTimestamp = Event.timestamp
        @client_core.update_event(event)
      else
        event = Event.new(type, message, pvc)
        @client_core.create_event(event)
      end
    end

    def create_secret(name)
      secret = Secret.new(name)
      @client_core.create_secret(secret)

      secret.password
    end

    def delete_pv(name)
      @client_core.delete_persistent_volume(name)
    end

    def pvcs
      pvcs = @client_core.get_persistent_volume_claims.select do |pvc|
        pvc.metadata.annotations['volume.beta.kubernetes.io/storage-provisioner'] == WdProvisioner::PROVISIONER_NAME && pvc.spec.volumeName.nil?
      end
      pvcs.each { |pvc| pvc.kind = 'PersistentVolumeClaim' }
    end

    def pvs
      pvs = @client_core.get_persistent_volumes.select do |pv|
        pv.metadata.annotations['pv.kubernetes.io/provisioned-by'] == WdProvisioner::PROVISIONER_NAME && pv.status.phase == 'Released'
      end
      pvs.each { |pv| pv.kind = 'PersistentVolume' }
    end

    def secret(name)
      encoded_password = @client_core.get_secret(name, 'default').data.password
      Base64.strict_decode64(encoded_password)
    end

    def storage_class(name)
      @client_storage.get_storage_class(name)
    rescue Kubeclient::ResourceNotFoundError => e
      raise ResourceNotFoundError.new, e.message
    end

    private

    def lookup_event(type, message, involved_object)
      @client_core.get_events.find do |event|
        event.source.component == WdProvisioner::PROVISIONER_NAME &&
          event.type == type &&
          event.message == message &&
          event.involvedObject.namespace == involved_object.metadata.namespace &&
          event.involvedObject.kind == involved_object.kind &&
          event.involvedObject.name == involved_object.metadata.name
      end
    end
  end
end
