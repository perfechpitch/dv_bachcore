`timescale 1ns/1ps

module tb;
    import uvm_pkg::*;
    import axi_master_read_pkg::*;
    import axi_master_write_pkg::*;
    import axi_slaver_read_pkg::*;
    import axi_slaver_write_pkg::*;
    import axi_vip_pkg::*;
    import axi_vip_test_pkg::*;

    bit clk;
    bit reset_n;

    axi_read_if  read_if(clk, reset_n);
    axi_write_if write_if(clk, reset_n);

    initial begin
        clk = 1'b0;
        forever #5ns clk = ~clk;
    end

    initial begin
        reset_n = 1'b0;
        repeat (5) @(posedge clk);
        reset_n <= 1'b1;
    end

    initial begin
        uvm_config_db #(axi_master_read_vif_t)::set(null,
            "uvm_test_top.env", axi_master_read_vif_key(0), read_if);
        uvm_config_db #(axi_master_write_vif_t)::set(null,
            "uvm_test_top.env", axi_master_write_vif_key(0), write_if);
        uvm_config_db #(axi_slaver_read_vif_t)::set(null,
            "uvm_test_top.env", axi_slaver_read_vif_key(0), read_if);
        uvm_config_db #(axi_slaver_write_vif_t)::set(null,
            "uvm_test_top.env", axi_slaver_write_vif_key(0), write_if);

        run_test();
    end

`ifdef AXI_FSDB
    initial begin
        string wave_file;
        wave_file = "waves.fsdb";
        void'($value$plusargs("AXI_WAVE_FILE=%s", wave_file));
        $fsdbDumpfile(wave_file);
        $fsdbDumpvars(0, tb, "+all");
        $fsdbDumpMDA();
    end
`endif
endmodule : tb
