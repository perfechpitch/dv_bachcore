// ============================================================================
// Filename             : $(CLASSNAME)_reset_sequence.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef $(FILENAME)_RESET_SEQUENCE_SV
`define $(FILENAME)_RESET_SEQUENCE_SV

class $(CLASSNAME)_reset_sequence extends uvm_sequence;

  /** UVM Object Utility macro */
  `uvm_object_utils($(CLASSNAME)_reset_sequence)

  /** Declare a typed sequencer object that the sequence can access */
  `uvm_declare_p_sequencer($(CLASSNAME)_sequencer)

  /** Class Constructor */
  function new (string name = "$(CLASSNAME)_reset_sequence");
    super.new(name);
  endfunction : new

  /** Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    if (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body

  virtual task body();
    `uvm_info(get_type_name(), "Entered...", UVM_LOW)

    p_sequencer.$(CLASSNAME)_reset_vif.drv_cb.reset <= 1'b1;

    //Assume reset is low active.
    repeat(10) @(p_sequencer.$(CLASSNAME)_reset_vif.drv_cb.clk);
    p_sequencer.$(CLASSNAME)_reset_vif.drv_cb.reset <= 1'b0;

    repeat(10) @(p_sequencer.$(CLASSNAME)_reset_vif.drv_cb.clk);
    p_sequencer.$(CLASSNAME)_reset_vif.drv_cb.reset <= 1'b1;

    `uvm_info(get_type_name(), "Exiting...", UVM_LOW)
  endtask: body

  /** Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
    if (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body



endclass: $(CLASSNAME)_reset_sequence

`endif 