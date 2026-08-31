// ============================================================================
// Filename             : reset_monitor.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_MONITOR_SV
`define RESET_MONITOR_SV
class reset_monitor extends uvm_monitor;
    // 
    // This property is the virtual interfaced needed for this component to drive
    // and view HDL signals.
    //
    virtual reset_if           reset_vif;
    reset_config               reset_cfg;
    // Opitional variable.
    //
    // Declare variable as file handle.
    //
    // For example:
    // int      reset_mon_log;
   
    //
    // Analysis port for delivering information from monitor to scoreboard.
    //
    uvm_analysis_port #(reset_seq_item) reset_ap;

    // Transfer package
    protected reset_seq_item  trans_collected;
    
    //fetch_reference             fetch_ref;
    //fetch_scoreboard            fetch_scb;
    //predecoder_reference        predecoder_ref;
    //predecoder_scoreboard       predecoder_scb;
    //inst_buffer_reference       inst_buffer_ref;
    //inst_buffer_scoreboard      inst_buffer_scb;
    
    //covergroup cov_trans;
    //  option.per_instance = 1;
    //  trans_start_addr : coverpoint trans_collected.addr {
    //    option.auto_bin_max = 16; }
    //  trans_dir : coverpoint trans_collected.read_write;
    //  trans_size : coverpoint trans_collected.size {
    //    bins sizes[] = {1, 2, 4, 8};
    //    illegal_bins invalid_sizes = default; }
    //  trans_addrXdir : cross trans_start_addr, trans_dir;
    //  trans_dirXsize : cross trans_dir, trans_size;
    //endgroup : cov_trans
    
    `uvm_component_utils_begin(reset_monitor)
    `uvm_component_utils_end
    
    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        //
        // Instance user coverage groups.
        // Setting a unique instance name for new coverage group.
        //
        // For example:
        // cov_trans = new();
        // cov_trans.set_inst_name({get_full_name(), ".cov_trans"});

        //
        // Instance analysis port
        //
        reset_ap = new("reset_ap", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //
        // Retrieve the configuration and the virtual interface.
        //
        if(!uvm_config_db#(reset_config)::get(this,"","reset_cfg",reset_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".reset_cfg"});

        reset_vif = reset_cfg.reset_vif;
        
        // Specify uvm_info tag "RESET_MON" with an action ,
        // which argument can take the value UVM_LOG. The uvm_info with 
        // tag "RESET_MON" will print messages to a file pointed by  
        // the filehandle reset_mon_log.
        // 
        // reset_mon_log = $fopen("./log/reset.mon.log","w");
        // set_report_id_action("RESET_MON",UVM_LOG);
        // set_report_id_file("RESET_MON",reset_mon_log);
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();
    //extern virtual protected task collect_xxxx_phase();
    //extern virtual function void perform_transfer_checks();
    //extern virtual protected function void perform_transfer_coverage();
    //extern virtual function void report_phase(uvm_phase phase);

endclass : reset_monitor

task reset_monitor::reset_phase(uvm_phase phase);
endtask : reset_phase

task reset_monitor::monitor_reset();
    // ToDo
    //ref_reset
    //scb_reset
    //fetch_ref.ref_reset();
    //fetch_scb.scb_reset();
    //predecoder_ref.ref_reset();
    //predecoder_scb.scb_reset();
    //inst_buffer_ref.ref_reset();
    //inst_buffer_scb.scb_reset();
endtask :monitor_reset 

// main phase
task reset_monitor::main_phase(uvm_phase phase);
    fork
        collect_transactions();
    join
endtask : main_phase

task reset_monitor::collect_transactions();
    forever begin
    @(reset_vif.mon_cb);
        if(!reset_vif.mon_cb.reset) begin
            monitor_reset();
        end
    end
endtask : collect_transactions

`endif