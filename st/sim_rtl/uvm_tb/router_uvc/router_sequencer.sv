// ============================================================================
// Filename             : router_sequencer.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_SEQUENCER_SV
`define ROUTER_SEQUENCER_SV
class router_sequencer extends uvm_sequencer #(router_seq_item);
    router_config      router_cfg;
    ///////////////////////////////////////////////////////
    //open when need more than one agent
    //int                                  xxx_num;

    //
    // virtual interface for capture interrupt signals
    //
    // virtual router_if  router_vif;

    //
    // For interrupt seq.
    //
    // event                   except;
    // except_seq              except_seq;



    `uvm_component_utils_begin(router_sequencer)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(router_config)::get(this,"","router_cfg",router_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#(router_config)::get(this,"",$sformatf("router_cfg%0d",xxx_num),router_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".router_cfg"});

        //except_seq = except_seq::type_id::create("except_seq");
    endfunction : build_phase

    //
    // For interrupt sequence
    //
    // For example:
    // virtual task run_phase(uvm_phase phase);
    //     fork
    //         except_seq.start(this);
    //         except_mon();
    //     join
    // endtask : run_phase

    // User define task.
    //
    // Monitor the bus signals, if an exception is captured, trigger an event, the 'except_seq' will
    // grab sequencer and begin to send messages to the sequencer.
    //
    // For example:
    // virtual task except_mon();
    //    forever begin
    //        @(posedge XXXX_vif.clk_i)
    //        if(XXXX_vif.except_valid_i && (XXXX_vif.except_code_i == 5'h2 || XXXX_vif.except_code_i == 5'h3)) begin
    //            ->except;
    //            `uvm_info(get_type_name(),"except generate",UVM_FULL)
    //        end
    //    end
    // endtask : except_mon
endclass : router_sequencer
`endif