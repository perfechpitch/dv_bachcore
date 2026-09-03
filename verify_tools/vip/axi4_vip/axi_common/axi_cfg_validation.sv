// ============================================================================
// Filename             : axi_cfg_validation.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_CFG_VALIDATION_SV
`define AXI_CFG_VALIDATION_SV

// One report object is shared by the complete cfg graph.  Leaf cfgs report
// every problem they find; axi_multi_env emits the single aggregate fatal.
class axi_cfg_validation_report extends uvm_object;
    `uvm_object_utils(axi_cfg_validation_report)

    int unsigned error_count;
    int unsigned warning_count;

    function new(string name = "axi_cfg_validation_report");
        super.new(name);
        error_count = 0;
        warning_count = 0;
    endfunction : new

    // The optional reason keeps the public two-argument API source-compatible
    // while allowing every in-tree validation site to expose a stable token.
    function void invalid(
        string scope,
        string message,
        string reason = "CFG_INVALID"
    );
        `uvm_error("AXI_CFG_INVALID", axi_diag::format(
            reason, "CONFIG", "CFG", "BUILD",
            message, "configuration satisfies the named rule",
            "ABORT_BUILD", {"scope=", scope}))
        error_count++;
    endfunction : invalid

    function void conflict(
        string scope,
        string message,
        string reason = "CFG_CONFLICT"
    );
        `uvm_error("AXI_CFG_CONFLICT", axi_diag::format(
            reason, "CONFIG", "CFG", "BUILD",
            message, "configuration fields are mutually consistent",
            "ABORT_BUILD", {"scope=", scope}))
        error_count++;
    endfunction : conflict

    function void filtered(
        string scope,
        string message,
        string reason = "CFG_FILTERED"
    );
        `uvm_warning("AXI_CFG_FILTERED", axi_diag::format(
            reason, "CONFIG", "CFG", "BUILD",
            message, "requested branch remains selectable",
            "CONTINUE_WITH_FILTER", {"scope=", scope}))
        warning_count++;
    endfunction : filtered

    // Open arrays allow the same implementation to validate dynamic and
    // fixed-size unpacked distribution arrays.  Call this only for a dist
    // that is active after applying the cfg mode/fixed-value priority.
    function bit check_dist(
        input string       scope,
        input string       field_name,
        input int unsigned values[],
        input int unsigned expected_size,
        input int unsigned expected_sum = 100
    );
        int unsigned total;

        check_dist = 1'b1;
        total = 0;
        if (values.size() != expected_size) begin
            invalid(scope, $sformatf(
                "field=%s actual_size=%0d expected_size=%0d",
                field_name, values.size(), expected_size),
                "CFG_DIST_SIZE");
            return 1'b0;
        end
        foreach (values[i]) begin
            if (values[i] > 100) begin
                invalid(scope, $sformatf(
                    "field=%s index=%0d actual_weight=%0d expected_range=[0:100]",
                    field_name, i, values[i]),
                    "CFG_DIST_WEIGHT_RANGE");
                check_dist = 1'b0;
            end
            total += values[i];
        end
        if (total != expected_sum) begin
            invalid(scope, $sformatf(
                "field=%s actual_sum=%0d expected_sum=%0d",
                field_name, total, expected_sum),
                "CFG_DIST_SUM");
            check_dist = 1'b0;
        end
    endfunction : check_dist

    function bit ok();
        return error_count == 0;
    endfunction : ok
endclass : axi_cfg_validation_report

`endif
