# frozen_string_literal: true

module WdProvisioner
  class Provisioner
    def initialize
      @client = WdProvisioner::Client.new
    end

    def run
      @client.pvcs.each do |pvc|
        if pvc.spec.selector
          @client.create_pvc_event(Event::WARNING, "#{WdProvisioner::PROVISIONER_NAME} does not support PVC selectors", pvc)
          next
        end

        storage_class_name = pvc.spec.storageClassName
        name = pvc.metadata.name
        capacity = pvc.spec.resources.requests.storage

        begin
          pv_password = @client.create_secret(name)
          url, username, wd_password = credentials(storage_class_name)
          wd = WdProvisioner::WdClient.new(url, username, wd_password)

          wd.create(name, pv_password)
          @client.create_pv(name, capacity)
        rescue WdProvisioner::ResourceNotFoundError => e
          @client.create_pvc_event(Event::WARNING, e.message, pvc)
        end
      end
      # TODO: Delete
      # TODO: Loop
    end

    private

    def credentials(storage_class_name)
      storage_class = @client.storage_class(storage_class_name)
      password = @client.secret(storage_class.parameters.passwordSecret)

      [storage_class.parameters.url, storage_class.parameters.username, password]
    end
  end
end
