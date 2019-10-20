# frozen_string_literal: true

require 'wdmc/client'

module WdProvisioner
  module Wdmc
    class Client < ::Wdmc::Client
      def initialize(url, username, password)
        @config = {
          'url' => url,
          'username' => username,
          'password' => password,
          'api_net_nl_bug' => true,
          'validate_cert' => false,
          verify_ssl: false
        }
        @cookiefile = File.join(ENV['HOME'], '.wdmc_cookie')
        login
      end
    end
  end
end
