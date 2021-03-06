# -*- coding: utf-8 -*-

module Vnet::Core::Networks

  class Physical < Base

    def network_type
      :physical
    end

    def log_type
      'network/physical'
    end

    def install
      flows = []
      flows << flow_create(table: TABLE_NETWORK_SRC_CLASSIFIER,
                           goto_table: TABLE_ROUTE_INGRESS_INTERFACE,
                           priority: 30,
                           match_network: @id)
      flows << flow_create(table: TABLE_NETWORK_DST_CLASSIFIER,
                           goto_table: TABLE_NETWORK_DST_MAC_LOOKUP,
                           priority: 30,
                           match_network: @id)
      flows << flow_create(table: TABLE_NETWORK_DST_MAC_LOOKUP,
                           goto_table: TABLE_LOOKUP_NETWORK_TO_HOST_IF_EGRESS,
                           priority: 20,
                           match_network: @id)

      @dp_info.add_flows(flows)
    end

    def update_flows(port_numbers)
      local_actions = port_numbers.collect { |port_number|
        { :output => port_number }
      }

      # Include port LOCAL until we implement interfaces for local eth
      # ports.
      local_actions << { :output => OFPP_LOCAL }

      flows = []
      flows << flow_create(table: TABLE_FLOOD_LOCAL,
                           goto_table: TABLE_LOOKUP_NETWORK_TO_HOST_IF_EGRESS,
                           priority: 1,
                           match_network: @id,
                           actions: local_actions)

      @dp_info.add_flows(flows)
    end

  end

end
