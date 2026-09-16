`timescale 1ns/1ps

module rst_gen (
    output logic bach_core_rstn,
    output logic mem_rstn,
    output logic dmi_presetn,
    output logic scp_ctrl_arstn,
    output logic scan_rstn
);

    initial begin
        bach_core_rstn = 1'b0;
        mem_rstn       = 1'b0;
        dmi_presetn    = 1'b0;
        scp_ctrl_arstn = 1'b0;
        scan_rstn      = 1'b0;

        // TODO: temporary TB bring-up assumption.
        // Replace with design-defined reset sequence when confirmed.
        #100ns;

        bach_core_rstn = 1'b1;
        mem_rstn       = 1'b1;
        dmi_presetn    = 1'b1;
        scp_ctrl_arstn = 1'b1;
        scan_rstn      = 1'b1;
    end

endmodule