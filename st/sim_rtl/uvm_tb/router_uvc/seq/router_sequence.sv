// ============================================================================
// Filename             : router_sequence.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_SEQUENCE_SV
`define ROUTER_SEQUENCE_SV
class router_sequence extends router_base_sequence;
    `uvm_object_utils(router_sequence)

    function new(string name = "router_sequence");
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
            req.router_cfg = p_sequencer.router_cfg;
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
endclass : router_sequence
`endif