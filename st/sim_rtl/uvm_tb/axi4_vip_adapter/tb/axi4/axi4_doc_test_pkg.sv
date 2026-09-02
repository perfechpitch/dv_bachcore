package axi4_doc_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;
  import axi4_vip_env_pkg::*;
  import axi4_generated_seq_pkg::*;
`ifdef USE_SYNOPSYS_AXI4_VIP
  import synopsys_axi4_vip_adapter_pkg::*;
`endif
`ifdef USE_SIMPLE_AXI4_BFM
  import simple_axi4_bfm_adapter_pkg::*;
`endif

  class axi4_doc_test extends uvm_test;
    `uvm_component_utils(axi4_doc_test)

    localparam int unsigned IRQ_POST_SEQ_WAIT_CYCLES = 80;

    axi4_vip_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      axi4_vip_adapter_base adapter;
      super.build_phase(phase);
      env = axi4_vip_env::type_id::create("env", this);

`ifdef USE_SYNOPSYS_AXI4_VIP
      adapter = synopsys_axi4_vip_adapter::type_id::create("adapter");
`elsif USE_SIMPLE_AXI4_BFM
      adapter = simple_axi4_bfm_adapter::type_id::create("adapter");
`else
      // Default demo mode. Use SIMPLE_AXI4_BFM=1 for a runnable AXI4 BFM demo,
      // or SYNOPSYS_AXI_VIP=1 to select Synopsys SVT AXI4 VIP.
      adapter = axi4_null_vip_adapter::type_id::create("adapter");
`endif
      uvm_config_db#(axi4_vip_adapter_base)::set(this, "env.axi_sqr", "adapter", adapter);
    endfunction

    task run_phase(uvm_phase phase);
      int irq_en_value;
      axi4_doc_plan_seq seq;
      virtual axi4_irq_if irq_vif;

      phase.raise_objection(this);
      seq = axi4_doc_plan_seq::type_id::create("seq");
      seq.start(env.axi_sqr);

      irq_en_value = 0;
      void'($value$plusargs("IRQ_EN=%d", irq_en_value));
      if (irq_en_value != 0) begin
        if (uvm_config_db#(virtual axi4_irq_if)::get(this, "", "irq_vif", irq_vif)) begin
          `uvm_info(get_type_name(), $sformatf(
            "IRQ_EN=1; keep simulation alive for %0d cycles after main seq",
            IRQ_POST_SEQ_WAIT_CYCLES), UVM_LOW)
          repeat (IRQ_POST_SEQ_WAIT_CYCLES) @(posedge irq_vif.aclk);
        end else begin
          `uvm_warning(get_type_name(), "IRQ_EN=1 but irq_vif is unavailable; skip post-seq IRQ wait")
        end
      end

      phase.drop_objection(this);
    endtask
  endclass
endpackage
