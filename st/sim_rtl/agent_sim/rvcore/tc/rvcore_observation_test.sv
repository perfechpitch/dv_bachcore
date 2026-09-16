class rvcore_observation_test extends uvm_test;
  `uvm_component_utils(rvcore_observation_test)
  rvcore_env env;
  virtual rvcore_checker_if vif;
  int case_id;

  function new(string name="rvcore_observation_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rvcore_checker_if)::get(this, "", "vif", vif))
      `uvm_fatal("RVCORE_NO_VIF", "rvcore_checker_if was not configured")
    void'($value$plusargs("CASE_ID=%d", case_id));
    env = rvcore_env::type_id::create("env", this);
  endfunction

  task drive_retire(int n, bit [31:0] pc0, bit [31:0] pc1=0, bit pending=0);
    @(negedge vif.clk);
    vif.retire_num = n;
    vif.retire_pc[0] = pc0;
    vif.retire_pc[1] = pc1;
    vif.reg_write_pending = pending;
    @(negedge vif.clk);
    vif.retire_num = 0;
    vif.reg_write_pending = 0;
  endtask

  task drive_wb(bit [4:0] idx, bit [31:0] data);
    @(negedge vif.clk);
    vif.wb_valid = 1;
    vif.wb_reg_idx = idx;
    vif.wb_data = data;
    @(negedge vif.clk);
    vif.wb_valid = 0;
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    wait(vif.reset_n);
    case (case_id)
      0: begin
        env.core_ref[0].mem_lib.itcm.write_mem(2'd2, 0, 32'h00500093);
        drive_retire(1, 0);
      end
      1: begin
        env.core_ref[0].mem_lib.itcm.write_mem(2'd2, 0, 32'h00500093);
        drive_retire(1, 0);
        drive_wb(1, 5);
      end
      2: begin
        env.core_ref[0].mem_lib.itcm.write_mem(2'd2, 0, 32'h00500093);
        env.core_ref[0].mem_lib.itcm.write_mem(2'd2, 4, 32'h00700113);
        drive_retire(2, 0, 4);
      end
      3, 4: begin
        env.core_ref[0].core_ref_cfg.inst_quit = 1;
        env.core_ref[0].core_ref_cfg.quit_inst = 32'h00000033;
        env.core_ref[0].mem_lib.itcm.write_mem(2'd2, 0, 32'h00000033);
        drive_retire(1, 0, 0, case_id == 4);
      end
      default: `uvm_fatal("RVCORE_BAD_CASE", $sformatf("unsupported CASE_ID=%0d", case_id))
    endcase
    repeat (2) @(posedge vif.clk);
    if (case_id != 4) begin
      if (env.retire_monitor[0].retire_cycle_count == 0)
        `uvm_error("RVCORE_SELFTEST", "retire monitor observed no transaction")
      if (case_id == 1 && env.writeback_monitor[0].writeback_count != 1)
        `uvm_error("RVCORE_SELFTEST", "writeback monitor count mismatch")
    end
    phase.drop_objection(this);
  endtask
endclass
