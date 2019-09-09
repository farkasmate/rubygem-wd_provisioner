# frozen_string_literal: true

require 'kubeclient'

module WdProvisioner
  class Event < Kubeclient::Resource
    NORMAL = 'Normal'
    WARNING = 'Warning'

    def initialize(type, message, involved_object)
      event = RecursiveOpenStruct.new(YAML.safe_load(template_event))

      name = involved_object.metadata.name
      time = Event.timestamp

      event.type = type
      event.message = message
      event.metadata.name = "#{name}.#{time}"
      event.involvedObject.name = name
      event.involvedObject.uid = involved_object.metadata.uid
      event.firstTimestamp = time
      event.lastTimestamp = time

      super(event.to_h)
    end

    def self.timestamp
      Time.now.iso8601(6)
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
          component: #{WdProvisioner::PROVISIONER_NAME}
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
