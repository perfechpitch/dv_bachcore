// ============================================================================
// Filename             : $(CLASSNAME)_sequencer.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_SEQUENCER_SV
`define $(FILENAME)_SEQUENCER_SV 
class $(CLASSNAME)_sequencer extends uvm_sequencer #($(CLASSNAME)_seq_item);
    $(CLASSNAME)_config      $(CLASSNAME)_cfg;
    ///////////////////////////////////////////////////////
    //open when need more than one agent
    //int                                  xxx_num;

    //
    // virtual interface for capture interrupt signals 
    //
    // virtual $(CLASSNAME)_if  $(CLASSNAME)_vif;
    
    //
    // For interrupt seq.
    //
    // event                   except;
    // except_seq              except_seq;



    `uvm_component_utils_begin($(CLASSNAME)_sequencer)
    `uvm_component_utils_end
      
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    
    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"","$(CLASSNAME)_cfg",$(CLASSNAME)_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});
        ///////////////////////////////////////////////////////
        //open when need more than one agent
        //if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"",$sformatf("$(CLASSNAME)_cfg%0d",xxx_num),$(CLASSNAME)_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});

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
endclass : $(CLASSNAME)_sequencer
`endif