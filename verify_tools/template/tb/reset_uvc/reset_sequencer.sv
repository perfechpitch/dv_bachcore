// ============================================================================
// Filename             : reset_sequencer.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef RESET_SEQUENCER_SV
`define RESET_SEQUENCER_SV 

class reset_sequencer extends uvm_sequencer #(reset_seq_item);
    
    reset_config      reset_cfg;
    //
    // virtual interface for capture interrupt signals 
    //
    // virtual reset_if  reset_vif;
    
    //
    // For interrupt seq.
    //
    // event                   except;
    // except_seq              except_seq;



    `uvm_component_utils_begin(reset_sequencer)
    `uvm_component_utils_end
      
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(reset_config)::get(this,"","reset_cfg",reset_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".reset_cfg"});
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
    //
    //    forever begin
    //        @(posedge XXXX_vif.clk_i)
    //        if(XXXX_vif.except_valid_i && (XXXX_vif.except_code_i == 5'h2 || XXXX_vif.except_code_i == 5'h3)) begin
    //            ->except;
    //            `uvm_info(get_type_name(),"except generate",UVM_FULL)
    //        end
    //    end
    // endtask : except_mon
endclass : reset_sequencer

`endif