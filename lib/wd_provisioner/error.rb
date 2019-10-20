# frozen_string_literal: true

module WdProvisioner
  class FailedWdProvisioningError < StandardError; end
  class ResourceNotFoundError < StandardError; end
  class ShareAlreadyExistsError < StandardError; end
  class UserAlreadyExistsError < StandardError; end
end
