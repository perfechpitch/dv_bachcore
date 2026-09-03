// ============================================================================
// Filename             : axi_cfg_plusarg_utils.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_CFG_PLUSARG_UTILS_SV
`define AXI_CFG_PLUSARG_UTILS_SV

// Strict command-line override reader for runtime AXI VIP configuration.
// Public keys use the stable form <ROLE>_<INDEX>_<FIELD>; cfg classes pass
// the exact key without the leading '+'.
class axi_cfg_plusarg_parser extends uvm_object;
    `uvm_object_utils(axi_cfg_plusarg_parser)

    string       raw_by_key[string];
    bit          has_equals_by_key[string];
    int unsigned occurrence_count[string];
    bit          consumed_by_key[string];
    bit          duplicate_reported_by_key[string];

    int unsigned captured_arg_count;
    int unsigned matched_key_count;
    bit          finish_called;

    function new(string name = "axi_cfg_plusarg_parser");
        super.new(name);
        captured_arg_count = 0;
        matched_key_count = 0;
        finish_called = 1'b0;
        capture_cfg_plusargs();
    endfunction : new

    protected function byte unsigned ascii_upper(byte unsigned character);
        if (character >= 8'h61 && character <= 8'h7a) begin
            return character - 8'h20;
        end
        return character;
    endfunction : ascii_upper

    protected function bit is_cfg_plusarg(string arg);
        byte unsigned role_first;
        byte unsigned role_second;

        if (arg.len() < 4 || arg.getc(0) != 8'h2b ||
            arg.getc(3) != 8'h5f) begin
            return 1'b0;
        end
        role_first = ascii_upper(arg.getc(1));
        role_second = ascii_upper(arg.getc(2));
        return (role_first == 8'h4d &&
                (role_second == 8'h52 || role_second == 8'h57)) ||
               (role_first == 8'h53 &&
                (role_second == 8'h52 || role_second == 8'h57));
    endfunction : is_cfg_plusarg

    protected function string canonical_key(string key);
        return key;
    endfunction : canonical_key

    protected function void capture_cfg_plusargs();
        uvm_cmdline_processor command_line;
        string                plusargs[$];
        string                arg;
        string                key;
        string                raw;
        int                   equals_index;

        command_line = uvm_cmdline_processor::get_inst();
        command_line.get_plusargs(plusargs);

        foreach (plusargs[i]) begin
            arg = plusargs[i];
            if (!is_cfg_plusarg(arg)) begin
                continue;
            end

            captured_arg_count++;
            equals_index = -1;
            for (int j = 1; j < arg.len(); j++) begin
                if (arg.getc(j) == 8'h3d) begin
                    equals_index = j;
                    break;
                end
            end

            if (equals_index < 0) begin
                key = arg.substr(1, arg.len() - 1);
                raw = "";
            end
            else begin
                key = arg.substr(1, equals_index - 1);
                if (equals_index == arg.len() - 1) begin
                    raw = "";
                end
                else begin
                    raw = arg.substr(equals_index + 1, arg.len() - 1);
                end
            end

            occurrence_count[key]++;
            if (occurrence_count[key] == 1) begin
                raw_by_key[key] = raw;
                has_equals_by_key[key] = (equals_index >= 0);
            end
        end
    endfunction : capture_cfg_plusargs

    protected function void report_invalid(
        axi_cfg_validation_report report,
        string                    scope,
        string                    message,
        string                    reason
    );
        if (report == null) begin
            `uvm_error("AXI_CFG_PLUSARG", $sformatf(
                "scope=%s reason=%s %s", scope, reason, message))
            return;
        end
        report.invalid(scope, message, reason);
    endfunction : report_invalid

    // Return 1 only when the exact key occurs once and has a nonempty value.
    // Enum-owning cfg classes use this raw API and perform their own stable
    // symbolic-name mapping before assigning the destination field.
    function bit get_raw(
        string                    key,
        string                    scope,
        axi_cfg_validation_report report,
        output string             value
    );
        string full_key;

        value = "";
        full_key = canonical_key(key);
        if (!occurrence_count.exists(full_key)) begin
            return 1'b0;
        end

        consumed_by_key[full_key] = 1'b1;
        if (occurrence_count[full_key] != 1) begin
            if (!duplicate_reported_by_key.exists(full_key) ||
                !duplicate_reported_by_key[full_key]) begin
                report_invalid(report, scope, $sformatf(
                    "plusarg=+%s occurrence_count=%0d expected=1",
                    full_key, occurrence_count[full_key]),
                    "CFG_PLUSARG_DUPLICATE");
                duplicate_reported_by_key[full_key] = 1'b1;
            end
            return 1'b0;
        end
        if (!has_equals_by_key[full_key] || raw_by_key[full_key].len() == 0) begin
            report_invalid(report, scope, $sformatf(
                "plusarg=+%s raw_value='%s' expected=+%s=<nonempty-value>",
                full_key, raw_by_key[full_key], full_key),
                "CFG_PLUSARG_VALUE_MISSING");
            return 1'b0;
        end

        value = raw_by_key[full_key];
        matched_key_count++;
        `uvm_info("AXI_CFG_PLUSARG", $sformatf(
            "Matched command-line cfg override: scope=%s key=+%s raw_value=%s",
            scope, full_key, value), UVM_MEDIUM)
        return 1'b1;
    endfunction : get_raw

    // Strict base-10 unsigned parser. Signs, whitespace, suffixes and values
    // wider than longint unsigned are rejected instead of being truncated.
    function bit get_uint(
        string                    key,
        string                    scope,
        axi_cfg_validation_report report,
        output longint unsigned   value
    );
        string           raw;
        longint unsigned parsed_value;
        longint unsigned max_value;
        int unsigned     digit;
        byte unsigned    character;

        value = 0;
        if (!get_raw(key, scope, report, raw)) begin
            return 1'b0;
        end

        parsed_value = 0;
        max_value = '1;
        for (int i = 0; i < raw.len(); i++) begin
            character = raw.getc(i);
            if (character < 8'h30 || character > 8'h39) begin
                report_invalid(report, scope, $sformatf(
                    "plusarg=+%s raw_value='%s' expected=unsigned-decimal",
                    canonical_key(key), raw),
                    "CFG_PLUSARG_UINT_FORMAT");
                return 1'b0;
            end
            digit = character - 8'h30;
            if (parsed_value > ((max_value - digit) / 10)) begin
                report_invalid(report, scope, $sformatf(
                    "plusarg=+%s raw_value='%s' expected_range=[0:2^64-1]",
                    canonical_key(key), raw),
                    "CFG_PLUSARG_UINT_OVERFLOW");
                return 1'b0;
            end
            parsed_value = (parsed_value * 10) + digit;
        end

        value = parsed_value;
        return 1'b1;
    endfunction : get_uint

    function bit get_bit(
        string                    key,
        string                    scope,
        axi_cfg_validation_report report,
        output bit                value
    );
        string raw;

        value = 1'b0;
        if (!get_raw(key, scope, report, raw)) begin
            return 1'b0;
        end
        if (raw == "0") begin
            value = 1'b0;
            return 1'b1;
        end
        if (raw == "1") begin
            value = 1'b1;
            return 1'b1;
        end

        report_invalid(report, scope, $sformatf(
            "plusarg=+%s raw_value='%s' expected={0,1}",
            canonical_key(key), raw),
            "CFG_PLUSARG_BIT_FORMAT");
        return 1'b0;
    endfunction : get_bit

    // Strict hexadecimal parser with optional 0x prefix and readable '_'
    // separators. Nonzero bits above width are rejected; no truncation occurs.
    function bit get_hex(
        string                    key,
        string                    scope,
        axi_cfg_validation_report report,
        int unsigned              width,
        output uvm_bitstream_t    value
    );
        string          raw;
        uvm_bitstream_t parsed_value;
        int             first_digit_index;
        int             nibble_index;
        int unsigned    nibble;
        int unsigned    absolute_bit;
        byte unsigned   character;
        bit             previous_was_separator;

        value = '0;
        if (!get_raw(key, scope, report, raw)) begin
            return 1'b0;
        end
        if (width == 0 || width > $bits(uvm_bitstream_t)) begin
            report_invalid(report, scope, $sformatf(
                "plusarg=+%s requested_width=%0d parser_max_width=%0d",
                canonical_key(key), width, $bits(uvm_bitstream_t)),
                "CFG_PLUSARG_HEX_WIDTH_UNSUPPORTED");
            return 1'b0;
        end

        first_digit_index = 0;
        if (raw.len() >= 2 && raw.getc(0) == 8'h30 &&
            (raw.getc(1) == 8'h78 || raw.getc(1) == 8'h58)) begin
            first_digit_index = 2;
        end
        if (first_digit_index >= raw.len()) begin
            report_invalid(report, scope, $sformatf(
                "plusarg=+%s raw_value='%s' expected=hexadecimal",
                canonical_key(key), raw),
                "CFG_PLUSARG_HEX_FORMAT");
            return 1'b0;
        end

        previous_was_separator = 1'b0;
        for (int i = first_digit_index; i < raw.len(); i++) begin
            character = raw.getc(i);
            if (character == 8'h5f) begin
                if (i == first_digit_index || i == raw.len() - 1 ||
                    previous_was_separator) begin
                    report_invalid(report, scope, $sformatf(
                        "plusarg=+%s raw_value='%s' expected=hexadecimal",
                        canonical_key(key), raw),
                        "CFG_PLUSARG_HEX_FORMAT");
                    return 1'b0;
                end
                previous_was_separator = 1'b1;
                continue;
            end
            previous_was_separator = 1'b0;
            if (!((character >= 8'h30 && character <= 8'h39) ||
                  (character >= 8'h41 && character <= 8'h46) ||
                  (character >= 8'h61 && character <= 8'h66))) begin
                report_invalid(report, scope, $sformatf(
                    "plusarg=+%s raw_value='%s' expected=hexadecimal",
                    canonical_key(key), raw),
                    "CFG_PLUSARG_HEX_FORMAT");
                return 1'b0;
            end
        end

        parsed_value = '0;
        nibble_index = 0;
        for (int i = raw.len() - 1; i >= first_digit_index; i--) begin
            character = raw.getc(i);
            if (character == 8'h5f) begin
                continue;
            end
            if (character >= 8'h30 && character <= 8'h39) begin
                nibble = character - 8'h30;
            end
            else if (character >= 8'h41 && character <= 8'h46) begin
                nibble = character - 8'h41 + 10;
            end
            else begin
                nibble = character - 8'h61 + 10;
            end

            for (int bit_index = 0; bit_index < 4; bit_index++) begin
                if (!nibble[bit_index]) begin
                    continue;
                end
                absolute_bit = (nibble_index * 4) + bit_index;
                if (absolute_bit >= width) begin
                    report_invalid(report, scope, $sformatf(
                        {"plusarg=+%s raw_value='%s' value_exceeds_",
                         "field_width=%0d"},
                        canonical_key(key), raw, width),
                        "CFG_PLUSARG_HEX_OVERFLOW");
                    return 1'b0;
                end
                parsed_value[absolute_bit] = 1'b1;
            end
            nibble_index++;
        end

        value = parsed_value;
        return 1'b1;
    endfunction : get_hex

    // Diagnose every namespaced argument that no cfg field claimed. This is
    // what turns misspelled field names and invalid role/index values into
    // deterministic build failures instead of silently ignored overrides.
    function void finish(
        string                    scope,
        axi_cfg_validation_report report
    );
        string key;

        if (finish_called) begin
            report_invalid(report, scope,
                "axi_cfg_plusarg_parser.finish() called more than once",
                "CFG_PLUSARG_FINISH_REPEATED");
            return;
        end
        finish_called = 1'b1;

        if (occurrence_count.first(key)) begin
            do begin
                if (occurrence_count[key] > 1 &&
                    (!duplicate_reported_by_key.exists(key) ||
                     !duplicate_reported_by_key[key])) begin
                    report_invalid(report, scope, $sformatf(
                        "plusarg=+%s occurrence_count=%0d expected=1",
                        key, occurrence_count[key]),
                        "CFG_PLUSARG_DUPLICATE");
                    duplicate_reported_by_key[key] = 1'b1;
                end
                if (!consumed_by_key.exists(key) || !consumed_by_key[key]) begin
                    report_invalid(report, scope, $sformatf(
                        {"unknown_plusarg=+%s raw_value='%s' expected=",
                         "registered MR/MW/SR/SW field and valid index"},
                        key, raw_by_key[key]),
                        "CFG_PLUSARG_UNKNOWN");
                end
            end while (occurrence_count.next(key));
        end

        `uvm_info("AXI_CFG_PLUSARG", $sformatf(
            {"Command-line cfg override scan complete: scope=%s ",
             "captured_args=%0d matched_keys=%0d"},
            scope, captured_arg_count, matched_key_count), UVM_LOW)
    endfunction : finish
endclass : axi_cfg_plusarg_parser

`endif
