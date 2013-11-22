# -*- coding: utf-8 -*-

module Vnet::Models
  class DatapathNetwork < Base
    plugin :paranoia
    plugin :mac_address, :attr_name => :broadcast_mac_address

    many_to_one :datapath
    many_to_one :network

    dataset_module do
      def on_segment(datapath)
        ds = self.join(:datapaths, :id => :datapath_id)
        ds = ds.where(~{:datapath_networks__datapath_id => datapath.id} &
                      {:datapaths__dc_segment_id => datapath.dc_segment_id})
        ds = ds.select_all(:datapath_networks)
      end

      def on_other_segment(datapath)
        ds = self.join(:datapaths, :id => :datapath_id)
        ds = ds.where(~{:datapath_networks__datapath_id => datapath.id} &
                      ~{:datapaths__dc_segment_id => datapath.dc_segment_id})
        ds = ds.select_all(:datapath_networks)
      end

      def on_specific_datapath(datapath)
        ds = self.join(:datapaths, :id => :datapath_id)
        ds = ds.where({:datapath_networks__datapath_id => datapath.id} &
                      {:datapaths__dc_segment_id => datapath.dc_segment_id})
        ds = ds.select_all(:datapath_networks)
      end

      def only_deleted
        with_deleted.~(deleted_at: nil)
      end
    end

    def datapath_networks_in_the_same_network
      ds = self.class.join(:datapaths, id: datapath_id).where(network_id: self.network_id).all
    end
  end
end
