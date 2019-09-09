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
        begin
          storage_class = @client.storage_class(storage_class_name)
          # TODO: Parse parameters
          # TODO: Provision share
          # TODO: Create PV
        rescue WdProvisioner::ResourceNotFoundError => e
          @client.create_pvc_event(Event::WARNING, e.message, pvc)
        end
      end
      # TODO: Loop
    end
  end
end
