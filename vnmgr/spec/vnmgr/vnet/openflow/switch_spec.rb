# -*- coding: utf-8 -*-
require 'spec_helper'
require 'trema'

class MockDatapath < Vnmgr::VNet::Openflow::Datapath
  attr_reader :sent_messages
  attr_reader :added_flows
  attr_reader :added_ovs_flows
  def initialize(*args)
    super(*args)
    @sent_messages = []
    @added_flows = []
    @added_ovs_flows = []
  end

  def send_message(message)
    @sent_messages << message
  end

  def add_flows(flows)
    @added_flows += flows
  end

  def add_ovs_flow(ovs_flow)
    @added_ovs_flows << ovs_flow
  end
end

describe Vnmgr::VNet::Openflow::Switch do
  describe "switch_ready", :focus => true do
    it "create default flows" do
      datapath = MockDatapath.new(double, 1)
      switch = Vnmgr::VNet::Openflow::Switch.new(datapath)
      Vnmgr::VNet::Openflow::Switch.new(datapath).switch_ready

      expect(datapath.sent_messages.size).to eq 2
      expect(datapath.added_flows.size).to eq 15
      expect(datapath.added_ovs_flows.size).to eq 0
    end
  end
  
  describe "handle_port_desc" do
    context "tunnel" do
      it "should create a port objcect whose datapath_id is 1" do
        ofc = double(:ofc)
        dp = Vnmgr::VNet::Openflow::Datapath.new(ofc, 1)
        switch = Vnmgr::VNet::Openflow::Switch.new(dp)
        port_desc = double(:port_desc)
        port_desc.should_receive(:port_no).and_return(5)
        
        switch.update_bridge_hw('aaaa')
        port = double(:port)
        port_info = double(:port_info)
        port.should_receive(:port_number).and_return(5)
        port.should_receive(:port_info).exactly(3).times.and_return(port_info)
        port.should_receive(:extend).and_return(Vnmgr::VNet::Openflow::PortTunnel)
        port.should_receive(:install)
        port_info.should_receive(:name).exactly(3).times.and_return("t-src1dst3")
        
        Vnmgr::VNet::Openflow::Port.stub(:new).and_return(port)

        switch.handle_port_desc(port_desc)

        expect(switch.ports[5]).to eq port
      end
    end

    #TODO
    context "eth" do
    end
  end
end
