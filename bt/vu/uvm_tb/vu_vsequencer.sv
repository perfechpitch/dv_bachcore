// ============================================================================
// Filename             : vu_vsequencer.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef VU_VSEQUENCER_SV
`define VU_VSEQUENCER_SV

class vu_vsequencer extends uvm_sequencer;

    // 
    // User define sub-sequencers for virtual sequencer
    //
    // alu_sequencer           alu_sqr;
    // bqu_sequencer           bqu_sqr;
    // tlb_sequencer           tlb_sqr;

    
    // XXXX_config              XXXX_cfg;

    //
    // virtual interface for capture interrupt signals 
    //
    // virtual XXXX_if          XXXX_vif;
    
    //
    // For interrupt seq.
    //
    // event                   except;
    // except_seq              except_seq;

    `uvm_component_utils_begin(vu_vsequencer)
    `uvm_component_utils_end
      
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // if(!uvm_config_db#($XXXX_config)::get(this,"","XXXX_cfg",XXXX_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".XXXX_cfg"});
        // XXXX_vif = XXXX_cfg.XXXX_vif;
        // except_seq = except_seq::type_id::create("except_seq");
    endfunction : build_phase

    //
    // For interrupt sequence
    //
    // For example:
    // virtual task main_phase(uvm_phase phase);
    //     fork
    //         except_seq.start(this);
    //         except_mon();
    //     join
    // endtask : main_phase
   
    // User define task.
    //
    // Monitor the bus signals, if an exception is captured, trigger an event, the 'except_seq' will 
    // grab sequencer and begin to send messages to the sequencer. 
    //
    // For example:
    // virtual task except_mon();
    //
    //    forever begin
    //        @(posedge XXXX_vif.clk_i)
    //        if(XXXX_vif.except_valid_i && (XXXX_vif.except_code_i == 5'h2 || XXXX_vif.except_code_i == 5'h3)) begin
    //            ->except;
    //            `uvm_info(get_type_name(),"except generate",UVM_FULL)
    //        end
    //    end
    // endtask : except_mon

endclass : vu_vsequencer

`endif