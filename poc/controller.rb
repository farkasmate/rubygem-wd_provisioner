#!/usr/bin/env ruby

require 'yaml'

def get_pvcs
  all_pvcs = YAML.load(`kubectl get persistentVolumeClaims --output yaml`)
  all_pvcs['items'].select { |pvc| pvc['spec']['storageClassName'] == 'wd' &&  pvc['spec']['volumeName'].nil? }
end

def create_storage(name, _capacity)
  # TODO: Call WD API
end

def create_pv(name, capacity)
  pv_yaml = <<~PV_YAML
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: test-pv
    spec:
      storageClassName: wd
      capacity:
        storage: 1Mi
      accessModes:
        - ReadWriteOnce
      hostPath:
        path: /dev/null
  PV_YAML

  pv = YAML.load(pv_yaml)
  pv['metadata']['name'] = name
  pv['spec']['capacity']['storage'] = capacity
  pv['spec']['hostPath']['path'] = File.join('/tmp', name)

  puts `echo "#{pv.to_yaml}" | kubectl apply -f -`
end

#puts get_pvcs
get_pvcs.each do |pvc|
  name = pvc['metadata']['name']
  capacity = pvc['spec']['resources']['requests']['storage']

  create_storage(name, capacity)
  create_pv(name, capacity)
end
