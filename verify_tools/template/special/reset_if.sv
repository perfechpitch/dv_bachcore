// ============================================================================
// Filename             : reset_if.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// Defines an interface that provides access to a reset signal. This
// interface can be used to write sequences to drive the reset logic.
// ============================================================================


`ifndef $(FILENAME)_RESET_IF_SV
`define $(FILENAME)_RESET_IF_SV

interface $(CLASSNAME)_reset_if(input bit clk);
    logic reset;

    //
    // Clocking blocks declare
    //
    clocking drv_cb@(posedge clk);
        output       reset;
    endclocking
    
    clocking mon_cb@(posedge clk);
        input        reset;
    endclocking
endinterface

`endif 