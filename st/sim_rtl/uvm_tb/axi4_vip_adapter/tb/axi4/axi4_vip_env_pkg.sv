package axi4_vip_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;
  import axi4_interrupt_pkg::*;

  class axi4_irq_monitor extends uvm_component;
    `uvm_component_utils(axi4_irq_monitor)

    virtual axi4_irq_if irq_vif;
    axi4_adapter_sequencer axi_sqr;
    bit disabled;
    int unsigned handled_count;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      int irq_en_value;

      super.build_phase(phase);
      irq_en_value = 0;
      void'($value$plusargs("IRQ_EN=%d", irq_en_value));
      if (irq_en_value == 0) begin
        disabled = 1'b1;
        `uvm_info(get_type_name(), "IRQ_EN=0; interrupt watcher is disabled", UVM_LOW)
      end else begin
        `uvm_info(get_type_name(), "IRQ_EN=1; interrupt watcher is enabled", UVM_LOW)
      end

      if (!uvm_config_db#(virtual axi4_irq_if)::get(this, "", "irq_vif", irq_vif)) begin
        disabled = 1'b1;
        `uvm_warning(get_type_name(), "No irq_vif configured; interrupt watcher is disabled")
      end
    endfunction

    task run_phase(uvm_phase phase);
      bit irq_d;
      axi4_irq_handler_seq irq_seq;

      if (disabled) begin
        return;
      end

      wait (irq_vif.aresetn === 1'b1);
      irq_d = irq_vif.irq;

      forever begin
        @(posedge irq_vif.aclk);
        if (irq_vif.aresetn !== 1'b1) begin
          irq_d = 1'b0;
          continue;
        end

        if (irq_vif.irq && !irq_d) begin
          irq_d = irq_vif.irq;
          if (axi_sqr == null) begin
            `uvm_fatal(get_type_name(), "Interrupt watcher has no AXI sequencer handle")
          end

          handled_count++;
          `uvm_info(get_type_name(), $sformatf(
            "Interrupt rising edge detected; start handler seq #%0d", handled_count), UVM_LOW)
          phase.raise_objection(this, "interrupt handler running");
          irq_seq = axi4_irq_handler_seq::type_id::create(
            $sformatf("irq_handler_seq_%0d", handled_count));
          irq_seq.start(axi_sqr);
          phase.drop_objection(this, "interrupt handler done");
        end else begin
          irq_d = irq_vif.irq;
        end
      end
    endtask
  endclass

  class axi4_vip_env extends uvm_env;
    `uvm_component_utils(axi4_vip_env)

    axi4_adapter_sequencer axi_sqr;
    axi4_irq_monitor irq_mon;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      axi_sqr = axi4_adapter_sequencer::type_id::create("axi_sqr", this);
      irq_mon = axi4_irq_monitor::type_id::create("irq_mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      irq_mon.axi_sqr = axi_sqr;
    endfunction
  endclass
endpackage
