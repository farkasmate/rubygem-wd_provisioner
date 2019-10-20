# frozen_string_literal: true

require 'wd_provisioner/client'
require 'wd_provisioner/error'
require 'wd_provisioner/event'
require 'wd_provisioner/persistent_volume'
require 'wd_provisioner/provisioner'
require 'wd_provisioner/secret'
require 'wd_provisioner/version'
require 'wd_provisioner/wd_client'

module WdProvisioner
  PROVISIONER_NAME = 'farkasmate.github.io/wd-provisioner'
end
