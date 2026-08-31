// ============================================================================
// Filename             : reset_if.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef RESET_INTERFACE_SV
`define RESET_INTERFACE_SV
interface reset_if(input logic clk);
    logic                        reset;
    
    clocking drv_cb@(posedge clk);
    endclocking

    clocking mon_cb@(posedge clk);
      input                   reset;
    endclocking
endinterface : reset_if
`endif