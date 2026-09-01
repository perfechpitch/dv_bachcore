// ============================================================================
// Filename             : vu_reference.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef VU_REFERENCE_SV
`define VU_REFERENCE_SV

//`uvm_analysis_imp_decl(_vu)

class vu_reference extends uvm_component;

    //uvm_analysis_imp_vu  #(vu_seq_item,vu_reference) vu_imp;
    //uvm_analysis_port              #(vu_seq_item)                        vu_ap;

    // 
    // This property is the virtual interfaced needed for this component to drive
    // and view HDL signals.
    //
    //vu_config               vu_cfg;
    // add for mul_core evironment,this environment will be  may times  which are equal to core_num
    // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
    //xxx_config                          xxx_cfg;

    // Opitional variable.
    //
    // Declare variable as file handle.
    //
    // For example:
    // int      vu_ref_log;
   
    // Transfer package
    //protected vu_seq_item  vu_q[$];
    //protected vu_seq_item  vu_tr;
    
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

    `uvm_component_utils_begin(vu_reference)
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        cov_trans = new();
        cov_trans.set_inst_name({get_full_name(), ".cov_trans"});

        //
        // Instance analysis port
        //
        //vu_imp = new("vu_imp", this);
        //vu_ap = new("vu_ap", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //
        // Retrieve the configuration and the virtual interface.
        //
        //if(!uvm_config_db#(vu_config)::get(this,"","vu_cfg",vu_cfg))
        //    `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".vu_cfg"});

        // add for mul_core evironment,this environment will be  may times  which are equal to core_num
        // xxx_cfg is env top config,eg if it is scache,xxx_cfg is scache_cfg
        // if(!uvm_config_db#(xxx_config)::get(this,"","xxx_cfg",xxx_cfg))
        //     `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".xxx_cfg"});

        // Specify uvm_info tag "VU_REF" with an action ,
        // which argument can take the value UVM_LOG. The uvm_info with 
        // tag "VU_REF" will print messages to a file pointed by  
        // the filehandle vu_ref_log.
        // 
        // two choice for log_name
        // 1: for one_core evironment
        // vu_ref_log = $fopen("./log/vu.ref.log","w");
        //
        // 2: for mul_core evironment,this environment will be  may times  which are equal to core_num
        //    to avoild log confusedly in mul_core environment,we should split logs to one log per core
        // vu_ref_log = $fopen($sformatf("./log/core%0d_vu.ref.log",xxx_cfg.core_num),"w");
        //
        // set_report_id_action("VU_REF",UVM_LOG);
        // set_report_id_file("VU_REF",vu_ref_log);
    endfunction: build_phase
   
    //function write_vu(vu_seq_item tr);
          //
          //ref exe
          //
          //cov_trans.sample();
    //endfunction :write_vu

    extern virtual task     reset_phase(uvm_phase phase);
    extern virtual function ref_reset();
endclass : vu_reference

task vu_reference::reset_phase(uvm_phase phase);
    ref_reset();
endtask : reset_phase

function vu_reference::ref_reset();
    // User should reset all queues and internal variables.
    //
    // ToDo
    //vu_q.delete();
endfunction :ref_reset 
`endif