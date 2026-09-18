module clk_gen (
    output logic clk_i
);

    // RV Core clock: 1 GHz, period = 1 ns.
    initial begin
        clk_i = 1'b0;
        forever #0.5 clk_i = ~clk_i;
    end

endmodule
