// ============================================================================
// Filename             : inst_gen_monitor.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_MONITOR_SV
`define INST_GEN_MONITOR_SV
class inst_gen_monitor extends uvm_monitor;
    virtual inst_gen_if           inst_gen_vif;
    inst_gen_config               inst_gen_cfg;
    int      inst_gen_mon_log;
   
    uvm_analysis_port #(inst_gen_base_seq_item) inst_gen_ap;

    protected inst_gen_base_seq_item  inst_gen_tr;
    
    `uvm_component_utils_begin(inst_gen_monitor)
    `uvm_component_utils_end
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
        inst_gen_ap = new("inst_gen_ap", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(inst_gen_config)::get(this,"","inst_gen_cfg",inst_gen_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".inst_gen_cfg"});
        if(!uvm_config_db#(virtual inst_gen_if)::get(this,"","inst_gen_vif",inst_gen_vif))
            `uvm_fatal("NOVIF",{"config must be set for: ",get_full_name(),".inst_gen_vif"});    

        inst_gen_mon_log = $fopen("./log/inst_gen.mon.log","w");
        set_report_id_action("INST_GEN_MON",UVM_LOG);
        set_report_id_file("INST_GEN_MON",inst_gen_mon_log);
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task monitor_reset();
    extern virtual protected task collect_transactions();
endclass : inst_gen_monitor

task inst_gen_monitor::reset_phase(uvm_phase phase);
    monitor_reset();
endtask : reset_phase

task inst_gen_monitor::monitor_reset();
    inst_gen_tr = new();
endtask :monitor_reset 

task inst_gen_monitor::main_phase(uvm_phase phase);
    fork
        collect_transactions();
    join
endtask : main_phase

task inst_gen_monitor::collect_transactions();
    forever begin
    @(inst_gen_vif.mon_cb);
        if(!inst_gen_vif.mon_cb.reset) begin
            monitor_reset();
        end
        else begin
            if(inst_gen_vif.mon_cb.vld && inst_gen_vif.mon_cb.rdy) begin
                inst_gen_tr             = new();
                inst_gen_tr.vinst       = inst_gen_vif.mon_cb.vinst;
                inst_gen_tr.minst       = inst_gen_vif.mon_cb.minst;
                inst_gen_tr.inst_type   = inst_gen_vif.mon_cb.inst_type;
                inst_gen_tr.rs1_data    = inst_gen_vif.mon_cb.rs1_data;
                inst_gen_tr.rs2_data    = inst_gen_vif.mon_cb.rs2_data;
                inst_gen_tr.imm         = inst_gen_vif.mon_cb.imm;
                inst_gen_ap.write(inst_gen_tr);
            end
        end
    end
endtask : collect_transactions
`endif
