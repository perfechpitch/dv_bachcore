// ============================================================================
// Filename             : $(CLASSNAME)_reference.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef $(FILENAME)_REFERENCE_SV
`define $(FILENAME)_REFERENCE_SV

//`uvm_analysis_imp_decl(_$(CLASSNAME))

class $(CLASSNAME)_reference extends uvm_component;

    //uvm_analysis_imp_$(CLASSNAME)  #($(CLASSNAME)_seq_item,$(CLASSNAME)_reference) $(CLASSNAME)_imp;
    //uvm_analysis_port              #($(CLASSNAME)_seq_item)                        $(CLASSNAME)_ap;

    // 
    // This property is the virtual interfaced needed for this component to drive
    // and view HDL signals.
    //
    //$(CLASSNAME)_config               $(CLASSNAME)_cfg;
    // add for mul_core evironment,this environment will be  may times  which are equal to core_num
    // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
    //xxx_config                          xxx_cfg;

    // Opitional variable.
    //
    // Declare variable as file handle.
    //
    // For example:
    // int      $(CLASSNAME)_ref_log;
   
    // Transfer package
    //protected $(CLASSNAME)_seq_item  $(CLASSNAME)_q[$];
    //protected $(CLASSNAME)_seq_item  $(CLASSNAME)_tr;
    
    //function covergroup :(eg:outstanding/out-of-order)
    covergroup cov_trans;
        option.per_instance = 1;
    //    trans_start_func : coverpoint ref_tr.func {
    //        option.auto_bin_max = 16; 
    //    }
    //    trans_func0  : coverpoint ref_tr.read_write;
    //    trans_func1 : coverpoint ref_tr.func1 {
    //        bins func1s[] = {1, 2, 4, 8};
    //        illegal_bins invalid_func1s = default; 
    //    }
    //    trans_func0Xfunc1 : cross trans_func0, trans_func1;
    endgroup : cov_trans

    `uvm_component_utils_begin($(CLASSNAME)_reference)
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        cov_trans = new();
        cov_trans.set_inst_name({get_full_name(), ".cov_trans"});

        //
        // Instance analysis port
        //
        //$(CLASSNAME)_imp = new("$(CLASSNAME)_imp", this);
        //$(CLASSNAME)_ap = new("$(CLASSNAME)_ap", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //
        // Retrieve the configuration and the virtual interface.
        //
        //if(!uvm_config_db#($(CLASSNAME)_config)::get(this,"","$(CLASSNAME)_cfg",$(CLASSNAME)_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".$(CLASSNAME)_cfg"});

        // add for mul_core evironment,this environment will be  may times  which are equal to core_num
        // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
        // if(!uvm_config_db#(xxx_config)::get(this,"","xxx_cfg",xxx_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".xxx_cfg"});

        // Specify uvm_info tag "$(FILENAME)_REF" with an action ,
        // which argument can take the value UVM_LOG. The uvm_info with 
        // tag "$(FILENAME)_REF" will print messages to a file pointed by  
        // the filehandle $(CLASSNAME)_ref_log.
        // 
        // two choice for log_name
        // 1: for one_core evironment
        // $(CLASSNAME)_ref_log = $fopen("./log/$(CLASSNAME).ref.log","w");
        //
        // 2: for mul_core evironment,this environment will be  may times  which are equal to core_num
        //    to avoild log confusedly in mul_core environment,we should split logs to one log per core
        // $(CLASSNAME)_ref_log = $fopen($sformatf("./log/core%0d_$(CLASSNAME).ref.log",xxx_cfg.core_num),"w");
        //
        // set_report_id_action("$(FILENAME)_REF",UVM_LOG);
        // set_report_id_file("$(FILENAME)_REF",$(CLASSNAME)_ref_log);
    endfunction: build_phase
   
    //function write_$(CLASSNAME)($(CLASSNAME)_seq_item tr);
          //
          //ref exe
          //
          //cov_trans.sample();
    //endfunction :write_$(CLASSNAME)

    extern virtual task     reset_phase(uvm_phase phase);
    extern virtual function ref_reset();
endclass : $(CLASSNAME)_reference

task $(CLASSNAME)_reference::reset_phase(uvm_phase phase);
    ref_reset();
endtask : reset_phase

function $(CLASSNAME)_reference::ref_reset();
    // User should reset all queues and internal variables.
    //
    // ToDo
    //$(CLASSNAME)_q.delete();
endfunction :ref_reset 
`endif