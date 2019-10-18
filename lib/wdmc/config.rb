# frozen_string_literal: true

module Wdmc
  class Config
    def self.load
      # TODO: Parse parameters
      {
        'url' => 'https://nas',
        'username' => 'admin',
        'password' => 'adminpass',
        'validate_cert' => false,
        'api_net_nl_bug' => true
      }
    end
  end
end
