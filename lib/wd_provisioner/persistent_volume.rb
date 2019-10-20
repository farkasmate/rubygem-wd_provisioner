# frozen_string_literal: true

require 'kubeclient'

module WdProvisioner
  class PersistentVolume < Kubeclient::Resource
    def initialize(name, capacity)
      pv = RecursiveOpenStruct.new(YAML.safe_load(template_pv))

      pv.metadata.name = name
      pv.spec.capacity.storage = capacity
      pv.spec.nfs.path = "/nfs/#{name}"
      pv.spec.nfs.server = 'nas'

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
          nfs:
            path: /share
            server: localhost
      PV
    end
  end
end
