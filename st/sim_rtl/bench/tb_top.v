`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import bach_core_env_pkg::*;
    import bach_core_tc_pkg::*;

    logic bach_core_clk;
    logic scp_ctrl_aclk;
    logic dmi_pclk;
    logic bach_core_rstn;
    logic mem_rstn;
    logic dmi_presetn;
    logic scp_ctrl_arstn;
    logic scan_rstn;

    router_if router_vif(bach_core_clk, bach_core_rstn);
    rv_dsa_if rv_dsa_vif(bach_core_clk, bach_core_rstn);
    ts_if ts_vif(bach_core_clk, bach_core_rstn);
    rvcore_checker_if checker_vif(bach_core_clk);
    assign checker_vif.reset_n = bach_core_rstn;

    clk_gen u_clk_gen (
        .bach_core_clk (bach_core_clk),
        .scp_ctrl_aclk (scp_ctrl_aclk),
        .dmi_pclk      (dmi_pclk)
    );

    rst_gen u_rst_gen (
        .bach_core_rstn (bach_core_rstn),
        .mem_rstn       (mem_rstn),
        .dmi_presetn    (dmi_presetn),
        .scp_ctrl_arstn (scp_ctrl_arstn),
        .scan_rstn      (scan_rstn)
    );

    bach_core_top u_bach_core (
        .bach_core_clk              (bach_core_clk),
        .bach_core_rstn             (bach_core_rstn),
        .mem_rstn                   (mem_rstn),
        .dmi_pclk                   (dmi_pclk),
        .dmi_presetn                (dmi_presetn),
        .scan_mode                  (1'b0),
        .scan_rstn                  (scan_rstn),
        .cti_i                      ('0),
        .scp_ctrl_aclk              (scp_ctrl_aclk),
        .scp_ctrl_arstn             (scp_ctrl_arstn),
        .scp_ctrl_awid              ('0),
        .scp_ctrl_awaddr            ('0),
        .scp_ctrl_awlen             ('0),
        .scp_ctrl_awsize            ('0),
        .scp_ctrl_awburst           ('0),
        .scp_ctrl_awlock            (1'b0),
        .scp_ctrl_awcache           ('0),
        .scp_ctrl_awprot            ('0),
        .scp_ctrl_awqos             ('0),
        .scp_ctrl_awregion          ('0),
        .scp_ctrl_awuser            ('0),
        .scp_ctrl_awvalid           (1'b0),
        .scp_ctrl_wdata             ('0),
        .scp_ctrl_wstrb             ('0),
        .scp_ctrl_wlast             (1'b0),
        .scp_ctrl_wuser             ('0),
        .scp_ctrl_wvalid            (1'b0),
        .scp_ctrl_bready            (1'b1),
        .scp_ctrl_arid              ('0),
        .scp_ctrl_araddr            ('0),
        .scp_ctrl_arlen             ('0),
        .scp_ctrl_arsize            ('0),
        .scp_ctrl_arburst           ('0),
        .scp_ctrl_arlock            (1'b0),
        .scp_ctrl_arcache           ('0),
        .scp_ctrl_arprot            ('0),
        .scp_ctrl_arqos             ('0),
        .scp_ctrl_arregion          ('0),
        .scp_ctrl_aruser            ('0),
        .scp_ctrl_arvalid           (1'b0),
        .scp_ctrl_rready            (1'b1),
        .dmi_paddr                  ('0),
        .dmi_psel                   (1'b0),
        .dmi_penable                (1'b0),
        .dmi_pwrite                 (1'b0),
        .dmi_pwdata                 ('0),
        .dmi_pstrb                  ('0),
        .dmi_pprot                  ('0),
        .r2t_trigger_uid            (router_vif.r2t_trigger_uid),
        .r2t_trigger_pid            (router_vif.r2t_trigger_pid),
        .r2t_trigger_reissue        (router_vif.r2t_trigger_reissue),
        .r2t_trigger_task_exe       (router_vif.r2t_trigger_task_exe),
        .r2t_trigger_valid          (router_vif.r2t_trigger_valid),
        .r2t_trigger_ready          (router_vif.r2t_trigger_ready),
        .t2r_credit_release_uid     (router_vif.t2r_credit_release_uid),
        .t2r_credit_release_valid   (router_vif.t2r_credit_release_valid),
        .r2ts_credit_e_uid          (router_vif.r2dte_credit_e_uid),
        .r2ts_credit_e_valid        (router_vif.r2dte_credit_e_valid),
        .r2ts_credit_w_uid          (router_vif.r2dte_credit_w_uid),
        .r2ts_credit_w_valid        (router_vif.r2dte_credit_w_valid),
        .r2ts_credit_ns_uid         (router_vif.r2dte_credit_ns_uid),
        .r2ts_credit_ns_valid       (router_vif.r2dte_credit_ns_valid),
        .rmem2ts_credit_done_uid    (router_vif.rmem2ts_credit_done_uid),
        .rmem2ts_credit_done_valid  (router_vif.rmem2ts_credit_done_valid),
        .r2core_hflit               (router_vif.r2core_hflit),
        .r2core_pflit               (router_vif.r2core_pflit),
        .r2core_head                (router_vif.r2core_head),
        .r2core_tail                (router_vif.r2core_tail),
        .r2core_vld                 (router_vif.r2core_vld),
        .core2r_rdy                 (router_vif.core2r_rdy),
        .core2r_hflit               (router_vif.core2r_hflit),
        .core2r_pflit               (router_vif.core2r_pflit),
        .core2r_head                (router_vif.core2r_head),
        .core2r_tail                (router_vif.core2r_tail),
        .core2r_vld                 (router_vif.core2r_vld),
        .r2core_credit_vld          (router_vif.r2core_credit_vld),
        .r2core_credit_vcid         (router_vif.r2core_credit_vcid)
    );

    initial begin
        if ($test$plusargs("dump")) begin
            $fsdbDumpfile("tb.fsdb");
            $fsdbDumpvars(0, tb_top);
        end
    end

    initial begin
        bach_core_env_cfg cfg;
        router_vif.r2t_trigger_uid = '0;
        router_vif.r2t_trigger_pid = '0;
        router_vif.r2t_trigger_reissue = 1'b0;
        router_vif.r2t_trigger_task_exe = 1'b0;
        router_vif.r2t_trigger_valid = 1'b0;
        router_vif.r2dte_credit_e_uid = '0;
        router_vif.r2dte_credit_e_valid = 1'b0;
        router_vif.r2dte_credit_w_uid = '0;
        router_vif.r2dte_credit_w_valid = 1'b0;
        router_vif.r2dte_credit_ns_uid = '0;
        router_vif.r2dte_credit_ns_valid = 1'b0;
        router_vif.rmem2ts_credit_done_uid = '0;
        router_vif.rmem2ts_credit_done_valid = 1'b0;
        router_vif.r2core_hflit = '0;
        router_vif.r2core_pflit = '0;
        router_vif.r2core_head = 1'b0;
        router_vif.r2core_tail = 1'b0;
        router_vif.r2core_vld = 1'b0;
        router_vif.r2core_credit_vld = 1'b0;
        router_vif.r2core_credit_vcid = '0;

        rv_dsa_vif.req = 1'b0;
        rv_dsa_vif.rw = 1'b0;
        rv_dsa_vif.addr0 = '0;
        rv_dsa_vif.wdata0 = '0;
        rv_dsa_vif.stream_id = '0;
        rv_dsa_vif.task_id = '0;
        rv_dsa_vif.user_id = '0;
        rv_dsa_vif.path_id = '0;
        rv_dsa_vif.vc_id = '0;
        rv_dsa_vif.ready = 1'b0;
        rv_dsa_vif.resp = 1'b0;
        rv_dsa_vif.rdata = '0;

        checker_vif.retire_num = '0;
        checker_vif.retire_pc[0] = '0;
        checker_vif.retire_pc[1] = '0;
        checker_vif.wb_valid = 1'b0;
        checker_vif.wb_reg_idx = '0;
        checker_vif.wb_data = '0;
        checker_vif.reg_write_pending = 1'b0;

        void'($system("mkdir -p log"));
        cfg = bach_core_env_cfg::type_id::create("cfg");
        cfg.router_vif = router_vif;
        cfg.rv_dsa_vif[0] = rv_dsa_vif;
        cfg.rv_dsa_vif[1] = rv_dsa_vif;
        cfg.rv_dsa_vif[2] = rv_dsa_vif;
        cfg.ts_vif = ts_vif;
        uvm_config_db#(bach_core_env_cfg)::set(null, "uvm_test_top", "cfg", cfg);
        uvm_config_db#(virtual rvcore_checker_if)::set(null, "uvm_test_top.env.rvcore*", "vif", checker_vif);
        run_test();
    end
endmodule
