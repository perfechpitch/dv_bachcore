module tb_top;

    import uvm_pkg::*;
    import rvcore_tc_pkg::*;

    logic clk_i;
    logic rst_n;

    logic        dsa_rw_req_rdy_i;
    logic        dsa_rd_rsp_i;
    logic [31:0] dsa_rd_data_i;
    wire         dsa_rw_req_vld_o;
    wire         dsa_rw_type_o;
    wire  [31:0] dsa_rw_addr_o;
    wire  [31:0] dsa_wr_data_o;
    wire   [3:0] dsa_sid_o;
    wire  [15:0] dsa_uid_o;
    wire   [5:0] dsa_tid_o;

    logic        sm_rw_req_rdy_i;
    logic        sm_rw_rsp_vld_i;
    logic  [3:0] sm_rsp_id_i;
    logic [31:0] sm_rd_data_i;
    logic        sm_rd_ecc_err_i;
    wire         sm_rw_req_vld_o;
    wire         sm_rw_type_o;
    wire  [31:0] sm_rw_addr_o;
    wire  [31:0] sm_wr_data_o;
    wire   [3:0] sm_amo_type_o;
    wire   [3:0] sm_wr_byte_en_o;
    wire   [3:0] sm_rw_id_o;
    wire         sm_rw_rsp_rdy_o;

    logic [31:0] ctrl_noc_rv_paddr_i;
    logic        ctrl_noc_rv_psel_i;
    logic        ctrl_noc_rv_penable_i;
    logic        ctrl_noc_rv_pwrite_i;
    logic [31:0] ctrl_noc_rv_pwdata_i;
    wire  [31:0] ctrl_noc_rv_prdata_o;
    wire         ctrl_noc_rv_pready_o;
    wire         ctrl_noc_rv_pslverr_o;

    logic [31:0] ctrl_noc_itcm_paddr_i;
    logic        ctrl_noc_itcm_psel_i;
    logic        ctrl_noc_itcm_penable_i;
    logic        ctrl_noc_itcm_pwrite_i;
    logic [31:0] ctrl_noc_itcm_pwdata_i;
    wire  [31:0] ctrl_noc_itcm_prdata_o;
    wire         ctrl_noc_itcm_pready_o;
    wire         ctrl_noc_itcm_pslverr_o;

    logic        ctrl_noc_dtcm_psel_i;
    logic        ctrl_noc_dtcm_penable_i;
    logic        ctrl_noc_dtcm_pwrite_i;
    logic [14:0] ctrl_noc_dtcm_paddr_i;
    logic [31:0] ctrl_noc_dtcm_pwdata_i;
    wire  [31:0] ctrl_noc_dtcm_prdata_o;
    wire         ctrl_noc_dtcm_pready_o;
    wire         ctrl_noc_dtcm_pslverr_o;

    clk_gen u_clk_gen (
        .clk_i (clk_i)
    );

    // The current rv_core_top interface has no reset port. Keep rst_gen in
    // the bench infrastructure so it can be connected when reset is restored.
    rst_gen u_rst_gen (
        .rst_n (rst_n)
    );

    rvcore_checker_if checker_if (clk_i);

    assign checker_if.reset_n = rst_n;

    initial begin
        dsa_rw_req_rdy_i        = 1'b0;
        dsa_rd_rsp_i            = 1'b0;
        dsa_rd_data_i           = '0;
        sm_rw_req_rdy_i         = 1'b0;
        sm_rw_rsp_vld_i         = 1'b0;
        sm_rsp_id_i             = '0;
        sm_rd_data_i            = '0;
        sm_rd_ecc_err_i         = 1'b0;
        ctrl_noc_rv_paddr_i     = '0;
        ctrl_noc_rv_psel_i      = 1'b0;
        ctrl_noc_rv_penable_i   = 1'b0;
        ctrl_noc_rv_pwrite_i    = 1'b0;
        ctrl_noc_rv_pwdata_i    = '0;
        ctrl_noc_itcm_paddr_i   = '0;
        ctrl_noc_itcm_psel_i    = 1'b0;
        ctrl_noc_itcm_penable_i = 1'b0;
        ctrl_noc_itcm_pwrite_i  = 1'b0;
        ctrl_noc_itcm_pwdata_i  = '0;
        ctrl_noc_dtcm_psel_i    = 1'b0;
        ctrl_noc_dtcm_penable_i = 1'b0;
        ctrl_noc_dtcm_pwrite_i  = 1'b0;
        ctrl_noc_dtcm_paddr_i   = '0;
        ctrl_noc_dtcm_pwdata_i  = '0;
    end

    rv_core_top u_dut (
`include "dut_connect.svh"
    );

    initial begin
        if ($test$plusargs("dump")) begin
            $fsdbDumpfile("tb.fsdb");
            $fsdbDumpvars(0, tb_top);
        end
    end

    initial begin
        checker_if.retire_num        = '0;
        checker_if.retire_pc[0]      = '0;
        checker_if.retire_pc[1]      = '0;
        checker_if.wb_valid          = 1'b0;
        checker_if.wb_reg_idx        = '0;
        checker_if.wb_data           = '0;
        checker_if.reg_write_pending = 1'b0;
        void'($system("mkdir -p log"));
        uvm_config_db#(virtual rvcore_checker_if)::set(
            null, "uvm_test_top*", "vif", checker_if
        );
        run_test();
    end

endmodule
