class rvcore_retire_monitor extends uvm_monitor;
  `uvm_component_utils(rvcore_retire_monitor)
  virtual rvcore_checker_if vif;
  core_reference core_ref_h;
  uvm_analysis_port #(inst_retire_structure) analysis_port;
  int unsigned retire_cycle_count;
  int unsigned retired_inst_count;

  function new(string name="rvcore_retire_monitor", uvm_component parent=null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rvcore_checker_if)::get(this, "", "vif", vif))
      `uvm_fatal("RVCORE_NO_VIF", "rvcore_checker_if was not configured")
    if (!uvm_config_db#(core_reference)::get(this, "", "core_ref_h", core_ref_h))
      `uvm_fatal("RVCORE_NO_REF", "core_reference was not configured")
  endfunction

  function bit is_task_done(bit [31:0] pc);
    bit [31:0] inst;
    if (!core_ref_h.core_ref_cfg.inst_quit)
      return 1'b0;
    inst = core_ref_h.mem_lib.peek_inst(pc);
    return inst == core_ref_h.core_ref_cfg.quit_inst;
  endfunction

  task main_phase(uvm_phase phase);
    inst_retire_structure item;
    forever begin
      @(posedge vif.clk);
      if (!vif.reset_n || vif.retire_num == 0)
        continue;
      item.retire_num = vif.retire_num;
      foreach (item.retire_pc[i])
        item.retire_pc[i] = vif.retire_pc[i];
      retire_cycle_count++;
      retired_inst_count += item.retire_num;
      for (int i = 0; i < item.retire_num; i++) begin
        if (is_task_done(item.retire_pc[i]) && vif.reg_write_pending)
          `uvm_error("RVCORE_PENDING_WB", $sformatf("task done at pc=%08x while reg_write_pending=1", item.retire_pc[i]))
      end
      analysis_port.write(item);
    end
  endtask
endclass
