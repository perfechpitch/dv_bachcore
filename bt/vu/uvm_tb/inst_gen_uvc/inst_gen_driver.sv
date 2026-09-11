// ============================================================================
// Filename             : inst_gen_driver.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_DRIVER_SV
`define INST_GEN_DRIVER_SV
class inst_gen_driver extends uvm_driver #(inst_gen_seq_item);
    virtual inst_gen_if             inst_gen_vif;
    inst_gen_config                 inst_gen_cfg;
    int      inst_gen_drv_log;
    int      vld_delay_q[$];
    inst_gen_seq_item inst_q[$];

    `uvm_component_utils_begin(inst_gen_driver)
    `uvm_component_utils_end

    function new(string name ,uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(inst_gen_config)::get(this,"","inst_gen_cfg",inst_gen_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".inst_gen_cfg"});
        if(!uvm_config_db#(virtual inst_gen_if)::get(this,"","inst_gen_vif",inst_gen_vif))
            `uvm_fatal("NOVIF",{"config must be set for: ",get_full_name(),".inst_gen_vif"});

        inst_gen_drv_log = $fopen("./log/inst_gen.drv.log","w");
        set_report_id_action("INST_GEN_DRV",UVM_LOG);
        set_report_id_file("INST_GEN_DRV",inst_gen_drv_log);
    endfunction: build_phase
   
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual protected task driver_reset();
    extern virtual protected task get_and_drive();
    extern virtual protected task send_inst(inst_gen_seq_item tr);
endclass : inst_gen_driver

task inst_gen_driver::driver_reset();
    inst_gen_vif.drv_cb.vld        <= 0;
    inst_gen_vif.drv_cb.inst_type  <= 0;
    inst_gen_vif.drv_cb.rs1_data   <= 0;
    inst_gen_vif.drv_cb.rs2_data   <= 0;
    inst_gen_vif.drv_cb.imm        <= 0;
    vld_delay_q.delete();
    inst_q.delete();
endtask :driver_reset 

task inst_gen_driver::reset_phase(uvm_phase phase);
    driver_reset();
endtask : reset_phase

task inst_gen_driver::main_phase(uvm_phase phase);
    while(1) begin
        driver_reset();
        fork
            begin
                @(negedge inst_gen_vif.drv_cb.reset);
                `uvm_info(get_type_name(),"DRV RESET",UVM_HIGH)
            end
            get_and_drive();
        join_any
        disable fork;
        if(req!=null) begin
            if(req.is_active())   // this is active when you use get_next_item,but you do not use item_done
                this.end_tr(req); // this is equal with item_done
        end
    end    
endtask : main_phase

task inst_gen_driver::get_and_drive();
    repeat(inst_gen_cfg.first_delay) begin
        @(posedge inst_gen_vif.clk);
    end
    forever begin
        @(posedge inst_gen_vif.clk);
        if(!inst_gen_vif.reset) begin
            if(inst_gen_vif.drv_cb.vld && inst_gen_vif.drv_cb.rdy) begin
                inst_gen_vif.drv_cb.vld        <= 0;
                if(inst_q.size==0)begin
                    `uvm_error("INST_Q_EMPTY",{"inst_q is empty when vld is 1 and rdy is 1"});
                end
                if(inst_q[0].vld_delay!=0) begin
                    vld_delay_q.push_back(inst_q[0].vld_delay); 
                end
                inst_q.pop_front();
            end

            if(vld_delay_q.size==0 || (vld_delay_q.size>0 && vld_delay_q[0]==0)) begin
                seq_item_port.get_next_item(req);
                seq_item_port.item_done();
                inst_q.push_back(req);
                vld_delay_q.delete(0);
            end
            else if(vld_delay_q.size>0 && vld_delay_q[0]>0) begin
                vld_delay_q[0]--;
            end
            if(inst_q.size>0)begin
                send_inst(inst_q[0]);
            end
        end
    end
endtask : get_and_drive 

task inst_gen_driver::send_inst(inst_gen_seq_item tr);
    inst_gen_vif.drv_cb.vld        <= 1;
    inst_gen_vif.drv_cb.inst_type  <= tr.inst_type;
    inst_gen_vif.drv_cb.rs1_data   <= tr.rs1_data;
    inst_gen_vif.drv_cb.rs2_data   <= tr.rs2_data;
    inst_gen_vif.drv_cb.imm        <= tr.imm;
endtask : send_inst
`endif    
