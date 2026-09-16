`timescale 1ns/1ps

module clk_gen (
    output logic bach_core_clk,
    output logic scp_ctrl_aclk,
    output logic dmi_pclk
);

    // bach_core_clk: 1 GHz, period = 1 ns
    initial begin
        bach_core_clk = 1'b0;
        forever #0.5 bach_core_clk = ~bach_core_clk;
    end

    // scp_ctrl_aclk: 1 GHz, period = 1 ns
    initial begin
        scp_ctrl_aclk = 1'b0;
        forever #0.5 scp_ctrl_aclk = ~scp_ctrl_aclk;
    end

    // dmi_pclk: 200 MHz, period = 5 ns
    initial begin
        dmi_pclk = 1'b0;
        forever #2.5 dmi_pclk = ~dmi_pclk;
    end

endmodule