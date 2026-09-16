class rvcore_writeback_monitor extends uvm_monitor;
  `uvm_component_utils(rvcore_writeback_monitor)
  virtual rvcore_checker_if vif;
  uvm_analysis_port #(reg_update_s) analysis_port;
  int unsigned writeback_count;

  function new(string name="rvcore_writeback_monitor", uvm_component parent=null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rvcore_checker_if)::get(this, "", "vif", vif))
      `uvm_fatal("RVCORE_NO_VIF", "rvcore_checker_if was not configured")
  endfunction

  task main_phase(uvm_phase phase);
    reg_update_s item;
    forever begin
      @(posedge vif.clk);
      if (!vif.reset_n || !vif.wb_valid)
        continue;
      item.reg_idx = vif.wb_reg_idx;
      item.data = vif.wb_data;
      writeback_count++;
      analysis_port.write(item);
    end
  endtask
endclass
