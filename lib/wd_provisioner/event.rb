# frozen_string_literal: true

require 'kubeclient'

module WdProvisioner
  class Event < Kubeclient::Resource
    def initialize(message, involved_object)
      event = RecursiveOpenStruct.new(YAML.safe_load(template_event))

      name = involved_object.metadata.name
      time = Time.now.iso8601(6)

      event.message = message
      event.metadata.name = "#{name}.#{time}"
      event.involvedObject.name = name
      event.involvedObject.uid = involved_object.metadata.uid
      event.firstTimestamp = time
      event.lastTimestamp = time

      super(event.to_h)
    end

    private

    def template_event
      <<~EVENT
        apiVersion: v1
        kind: Event
        metadata:
          name: template-event
          namespace: default
        type: Normal
        reason: ExternalProvisioning
        source:
          component: wd-provisioner
        message: Template message
        involvedObject:
          apiVersion: v1
          kind: PersistentVolumeClaim
          name: template-claim
          namespace: default
          uid: template-uid
        firstTimestamp: '1970-01-01T00:00:00Z'
        lastTimestamp: '1970-01-01T00:00:00Z'
      EVENT
    end
  end
end
