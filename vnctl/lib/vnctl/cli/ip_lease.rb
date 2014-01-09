# -*- coding: utf-8 -*-

module Vnctl::Cli
  class IpLease < Base
    namespace :ip_lease
    api_suffix "/api/ip_leases"

    add_modify_shared_options {
      option :network_uuid, :type => :string, :desc => "The network to lease this ip in."
      option :mac_lease_uuid, :type => :string, :desc => "The mac lease that this ip lease is tried to."
      option :ip_address, :type => :string, :desc => "The uuid of the ip address to lease."
    }
    set_required_options [:network_uuid, :mac_lease_uuid, :ip_address]

    define_standard_crud_commands
  end
end
