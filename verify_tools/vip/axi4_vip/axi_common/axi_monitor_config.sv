// ============================================================================
// Filename             : axi_monitor_config.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_MONITOR_CONFIG_SV
`define AXI_MONITOR_CONFIG_SV

class axi_read_monitor_config #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_object;
    typedef axi_read_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_read_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;

    vif_t vif;

    bit checks_enable = 1'b1;
    bit coverage_enable = 1'b1;
    bit performance_enable = 1'b0;
    bit bandwidth_enable = 1'b0;
    int unsigned bandwidth_window_cycles = 1000;
    int unsigned outstanding_depth = 1;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
        `uvm_field_int(performance_enable, UVM_DEFAULT)
        `uvm_field_int(bandwidth_enable, UVM_DEFAULT)
        `uvm_field_int(bandwidth_window_cycles, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(outstanding_depth, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_read_monitor_config");
        super.new(name);
    endfunction : new

    // prefix is the owning leaf token (for example MR_0 or SR_1); monitor
    // fields add the stable _MON_ namespace below.
    function void get_args(
        string                    prefix,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report
    );
        string           scope;
        bit              parsed_bit;
        longint unsigned parsed_uint;
        int unsigned     max_int_unsigned;

        scope = {prefix, ".monitor_cfg"};
        if (parser == null) begin
            report.invalid(scope, "actual_parser=null expected=non-null",
                "CFG_PLUSARG_PARSER_NULL");
            return;
        end

        if (parser.get_bit({prefix, "_MON_CHECKS_ENABLE"}, scope, report,
                parsed_bit)) begin
            checks_enable = parsed_bit;
        end
        if (parser.get_bit({prefix, "_MON_COVERAGE_ENABLE"}, scope, report,
                parsed_bit)) begin
            coverage_enable = parsed_bit;
        end
        if (parser.get_bit({prefix, "_MON_PERFORMANCE_ENABLE"}, scope, report,
                parsed_bit)) begin
            performance_enable = parsed_bit;
        end
        if (parser.get_bit({prefix, "_MON_BANDWIDTH_ENABLE"}, scope, report,
                parsed_bit)) begin
            bandwidth_enable = parsed_bit;
        end
        if (parser.get_uint({prefix, "_MON_BANDWIDTH_WINDOW_CYCLES"},
                scope, report, parsed_uint)) begin
            max_int_unsigned = '1;
            if (parsed_uint > max_int_unsigned) begin
                report.invalid(scope, $sformatf(
                    {"field=bandwidth_window_cycles actual=%0d ",
                     "expected_range=[0:%0d]"},
                    parsed_uint, max_int_unsigned),
                    "CFG_PLUSARG_FIELD_OVERFLOW");
            end
            else begin
                bandwidth_window_cycles = int'(parsed_uint);
            end
        end
    endfunction : get_args

    // Report-style entry used by axi_multi_env_config before freeze. Keep the
    // legacy validate() below for direct Agent/leaf compatibility.
    function bit validate_cfg(
        axi_cfg_validation_report report,
        string                    scope
    );
        int unsigned errors_before;

        if (report == null) begin
            `uvm_error("AXI_READ_MON_CFG",
                "validate_cfg() requires a non-null validation report")
            return 1'b0;
        end
        errors_before = report.error_count;
        if (outstanding_depth == 0) begin
            report.invalid(scope,
                "actual_outstanding_depth=0 expected_outstanding_depth>=1",
                "READ_MON_CFG_OUTSTANDING_DEPTH_ZERO");
        end
        if (bandwidth_window_cycles == 0) begin
            report.invalid(scope,
                {"actual_bandwidth_window_cycles=0 ",
                 "expected_bandwidth_window_cycles>=1"},
                "READ_MON_CFG_BANDWIDTH_WINDOW_ZERO");
        end
        return report.error_count == errors_before;
    endfunction : validate_cfg

    function bit validate(string report_id = "AXI_READ_MON_CFG");
        validate = 1'b1;
        if (outstanding_depth == 0) begin
            `uvm_error(report_id, axi_diag::format(
                "CFG_OUTSTANDING_DEPTH_ZERO", "AXI_READ_MONITOR_CFG", "CFG",
                "VALIDATE", "outstanding_depth=0", "outstanding_depth>=1",
                "REJECT_CONFIGURATION",
                "Read monitor cannot track accepted requests with a zero outstanding limit"))
            validate = 1'b0;
        end
        if (bandwidth_window_cycles == 0) begin
            `uvm_error(report_id, axi_diag::format(
                "CFG_BANDWIDTH_WINDOW_ZERO", "AXI_READ_MONITOR_CFG", "CFG",
                "VALIDATE", "bandwidth_window_cycles=0",
                "bandwidth_window_cycles>=1", "REJECT_CONFIGURATION",
                "Read bandwidth measurement requires a nonzero ACLK window"))
            validate = 1'b0;
        end
    endfunction : validate
endclass : axi_read_monitor_config

class axi_write_monitor_config #(
    int unsigned ID_WIDTH = 4,
    int unsigned ADDR_WIDTH = 32,
    int unsigned DATA_WIDTH = 64,
    int unsigned USER_WIDTH = 1
) extends uvm_object;
    typedef axi_write_monitor_config #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) this_type;
    typedef virtual axi_write_if #(
        ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;

    vif_t vif;

    bit checks_enable = 1'b1;
    bit coverage_enable = 1'b1;
    bit performance_enable = 1'b0;
    bit bandwidth_enable = 1'b0;
    int unsigned bandwidth_window_cycles = 1000;
    int unsigned outstanding_depth = 1;

    `uvm_object_param_utils_begin(this_type)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
        `uvm_field_int(performance_enable, UVM_DEFAULT)
        `uvm_field_int(bandwidth_enable, UVM_DEFAULT)
        `uvm_field_int(bandwidth_window_cycles, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(outstanding_depth, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "axi_write_monitor_config");
        super.new(name);
    endfunction : new

    // prefix is the owning leaf token (for example MW_0 or SW_1); monitor
    // fields add the stable _MON_ namespace below.
    // outstanding_depth and vif are deliberately not command-line fields:
    // the Agent derives the former from its leaf cfg and binds the latter.
    function void get_args(
        string                    prefix,
        axi_cfg_plusarg_parser    parser,
        axi_cfg_validation_report report
    );
        string           scope;
        bit              parsed_bit;
        longint unsigned parsed_uint;
        int unsigned     max_int_unsigned;

        scope = {prefix, ".monitor_cfg"};
        if (parser == null) begin
            report.invalid(scope, "actual_parser=null expected=non-null",
                "CFG_PLUSARG_PARSER_NULL");
            return;
        end

        if (parser.get_bit({prefix, "_MON_CHECKS_ENABLE"}, scope, report,
                parsed_bit)) begin
            checks_enable = parsed_bit;
        end
        if (parser.get_bit({prefix, "_MON_COVERAGE_ENABLE"}, scope, report,
                parsed_bit)) begin
            coverage_enable = parsed_bit;
        end
        if (parser.get_bit({prefix, "_MON_PERFORMANCE_ENABLE"}, scope, report,
                parsed_bit)) begin
            performance_enable = parsed_bit;
        end
        if (parser.get_bit({prefix, "_MON_BANDWIDTH_ENABLE"}, scope, report,
                parsed_bit)) begin
            bandwidth_enable = parsed_bit;
        end
        if (parser.get_uint({prefix, "_MON_BANDWIDTH_WINDOW_CYCLES"},
                scope, report, parsed_uint)) begin
            max_int_unsigned = '1;
            if (parsed_uint > max_int_unsigned) begin
                report.invalid(scope, $sformatf(
                    {"field=bandwidth_window_cycles actual=%0d ",
                     "expected_range=[0:%0d]"},
                    parsed_uint, max_int_unsigned),
                    "CFG_PLUSARG_FIELD_OVERFLOW");
            end
            else begin
                bandwidth_window_cycles = int'(parsed_uint);
            end
        end
    endfunction : get_args

    // Report-style entry used by axi_multi_env_config before freeze. Keep the
    // legacy validate() below for direct Agent/leaf compatibility.
    function bit validate_cfg(
        axi_cfg_validation_report report,
        string                    scope
    );
        int unsigned errors_before;

        if (report == null) begin
            `uvm_error("AXI_WRITE_MON_CFG",
                "validate_cfg() requires a non-null validation report")
            return 1'b0;
        end
        errors_before = report.error_count;
        if (outstanding_depth == 0) begin
            report.invalid(scope,
                "actual_outstanding_depth=0 expected_outstanding_depth>=1",
                "WRITE_MON_CFG_OUTSTANDING_DEPTH_ZERO");
        end
        if (bandwidth_window_cycles == 0) begin
            report.invalid(scope,
                {"actual_bandwidth_window_cycles=0 ",
                 "expected_bandwidth_window_cycles>=1"},
                "WRITE_MON_CFG_BANDWIDTH_WINDOW_ZERO");
        end
        return report.error_count == errors_before;
    endfunction : validate_cfg

    function bit validate(string report_id = "AXI_WRITE_MON_CFG");
        validate = 1'b1;
        if (outstanding_depth == 0) begin
            `uvm_error(report_id, axi_diag::format(
                "CFG_OUTSTANDING_DEPTH_ZERO", "AXI_WRITE_MONITOR_CFG", "CFG",
                "VALIDATE", "outstanding_depth=0", "outstanding_depth>=1",
                "REJECT_CONFIGURATION",
                "Write monitor cannot track accepted requests with a zero outstanding limit"))
            validate = 1'b0;
        end
        if (bandwidth_window_cycles == 0) begin
            `uvm_error(report_id, axi_diag::format(
                "CFG_BANDWIDTH_WINDOW_ZERO", "AXI_WRITE_MONITOR_CFG", "CFG",
                "VALIDATE", "bandwidth_window_cycles=0",
                "bandwidth_window_cycles>=1", "REJECT_CONFIGURATION",
                "Write bandwidth measurement requires a nonzero ACLK window"))
            validate = 1'b0;
        end
    endfunction : validate
endclass : axi_write_monitor_config

`endif
