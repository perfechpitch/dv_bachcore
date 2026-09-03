// ============================================================================
// Filename             : axi_param_rules_pkg.sv
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
package axi_param_rules_pkg;
    function automatic bit is_valid_id_width(int width);
        return width >= 1;
    endfunction : is_valid_id_width

    function automatic bit is_valid_addr_width(int width);
        return width >= 12;
    endfunction : is_valid_addr_width

    function automatic bit is_valid_data_width(int width);
        int bytes;

        if (width < 16 || width > 1024 || (width % 8) != 0) begin
            return 1'b0;
        end
        bytes = width / 8;
        return bytes > 0 && ((bytes & (bytes - 1)) == 0);
    endfunction : is_valid_data_width

    function automatic bit is_valid_user_width(int width);
        return width >= 1;
    endfunction : is_valid_user_width

    function automatic bit is_valid_max_beats(int value);
        return value >= 16 && value <= 256;
    endfunction : is_valid_max_beats

    function automatic bit is_valid_endpoint_shape(
        int id_width,
        int addr_width,
        int data_width,
        int user_width
    );
        return is_valid_id_width(id_width) &&
            is_valid_addr_width(addr_width) &&
            is_valid_data_width(data_width) &&
            is_valid_user_width(user_width);
    endfunction : is_valid_endpoint_shape
endpackage : axi_param_rules_pkg
