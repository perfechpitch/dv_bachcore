// ============================================================================
// Filename             : $(CLASSNAME)_if.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_INTERFACE_SV
`define $(FILENAME)_INTERFACE_SV
interface $(CLASSNAME)_if(input bit clk,input bit reset);
    //
    // User signals declare
    //
    // default input #10ns output #2ns;//open it only when you need io timing; set input delay before cb,set output delay after cb
    // logic           xxx;
    // logic [x:x]     xxx;
    //
    
    //
    // Clocking blocks declare
    //
    clocking drv_cb@(posedge clk);
        input                   reset;
        //input #1step address; //change default delay to #0;
    endclocking

    clocking mon_cb@(posedge clk);
        input                   reset;
    endclocking

   
    //----------------------------------------
    //if this uvc is active,it is needed
    //if this uvc is just monitor,it is not needed
    //modport DRV(
    //    output  xxxx,
    //    input   xxxx,
    //    input   xxxx
    //);
    //----------------------------------------

    //----------------------------------------
    //always needed
    modport MON(
        output  xxxx,
        output  xxxx,
        output  xxxx
    );
    //----------------------------------------

    // Assert protery && cover property to be implemented here.
    //
    // always @(negedge clk) begin
    //     assertAddrUnknown:assert property (
    //         disable iff(!has_checks) 
    //             ($onehot(sig_grant) |-> !$isunknown(sig_addr)))
    //         else
    //             $error("ERR_ADDR_XZ\n Address went to X or Z during Address Phase");
    // end
endinterface : $(CLASSNAME)_if
`endif