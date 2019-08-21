# frozen_string_literal: true

require 'kubeclient'

module WdProvisioner
  class PersistentVolume < Kubeclient::Resource
    def initialize(name, capacity)
      pv = RecursiveOpenStruct.new(YAML.safe_load(template_pv))

      pv.metadata.name = name
      pv.spec.capacity.storage = capacity

      super(pv.to_h)
    end

    private

    def template_pv
      <<~PV
        apiVersion: v1
        kind: PersistentVolume
        metadata:
          name: template-pv
          annotations:
            pv.kubernetes.io/provisioned-by: #{WdProvisioner::PROVISIONER_NAME}
        spec:
          storageClassName: wd
          capacity:
            storage: 1Mi
          accessModes:
            - ReadWriteOnce
          hostPath:
            path: /dev/null
      PV
    end
  end
end
