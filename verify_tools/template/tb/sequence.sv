// ============================================================================
// Filename             : $(CLASSNAME)_sequence.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_SEQUENCE_SV
`define $(FILENAME)_SEQUENCE_SV
class $(CLASSNAME)_sequence extends $(CLASSNAME)_base_sequence; 
    `uvm_object_utils($(CLASSNAME)_sequence)
    
    function new(string name = "$(CLASSNAME)_sequence");
        super.new(name);
    endfunction

    //
    // User define variable && constraint
    //
    // rand bit [15:0] start_addr;
    // int unsigned transmit_del = 0;
    // constraint transmit_del_ct { (transmit_del <= 10); }

    virtual task body();
        //  
        // If this is a interrupt sequence, when interrupt event trigger, this
        // sequence will grab the p_sequencer.
        //
        // @p_sequencer.except;
        // p_sequencer.grab(this);

        //
        // Re-define body task. Just send req package, user can 
        // constraint req with macro `uvm_rand_send_with()
        //
        // For example 2:
        forever begin
            `uvm_create(req)
            req.$(CLASSNAME)_cfg = p_sequencer.$(CLASSNAME)_cfg;
            `uvm_rand_send(req)
        // `uvm_rand_send_with(req,{req.addr ==  start_addr})
        // get_response(rsp);
        // `uvm_info(get_type_name(),
        //    $sformatf("%s read : addr = `x%0h, data[0] = `x%0h",
        //    get_sequence_path(), rsp.addr, rsp.data[0]),
        //    UVM_HIGH);
        end
        //  
        // If this is a interrupt sequence, when sequence is done, ungrab
        // sequencer. 
        //
        // p_sequencer.ungrab(this);

    endtask
endclass : $(CLASSNAME)_sequence
`endif