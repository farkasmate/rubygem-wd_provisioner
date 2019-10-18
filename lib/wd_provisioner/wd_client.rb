# frozen_string_literal: true

require 'wdmc/client'
require 'wdmc/config'

module WdProvisioner
  class WdClient
    def initialize
      @wdmc = Wdmc::Client.new
    end

    def create(name)
      add_user(name)
      add_share(name)
    end

    def delete(name)
      @wdmc.delete_share(name)
      @wdmc.delete_user(name)
    end

    private

    def add_user(name)
      raise UserAlreadyExistsError.new, "User '#{name}' exists" unless @wdmc.user_exists?(name).empty?

      begin
        @wdmc.add_user(
          email: nil,
          username: name,
          password: 'czNjcjN0', # base64(s3cr3t) # TODO: Create secret
          fullname: nil,
          is_admin: nil,
          group_names: 'cloudholders', # FIXME: ?
          first_name: nil,
          last_name: nil
        )
      rescue RestClient::ExceptionWithResponse => e
        raise FailedWdProvisioningError.new, e.message
      end
    end

    def add_share(name)
      raise ShareAlreadyExistsError.new, "Share '#{name}' exists" unless @wdmc.share_exists?(name).empty?

      begin
        @wdmc.add_share(
          share_name: name,
          description: nil,
          media_serving: false,
          public_access: false,
          samba_available: true,
          share_access_locked: false,
          grant_share_access: false
        )

        @wdmc.modify_share(
          share_name: name,
          new_share_name: name,
          description: nil,
          media_serving: false,
          public_access: false,
          remote_access: false
        )

        @wdmc.set_acl(
          share_name: name,
          username: name,
          access: 'RW'
        )
      rescue RestClient::ExceptionWithResponse => e
        raise FailedWdProvisioningError.new, e.message
      end
    end
  end
end
