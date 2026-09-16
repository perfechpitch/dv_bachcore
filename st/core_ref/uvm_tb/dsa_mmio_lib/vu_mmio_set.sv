class vu_mmio_set extends uvm_object;

    `uvm_object_utils(vu_mmio_set)

    protected int log_fd = 0;

    `include "generated/vu_mmio_decl_auto.svh"
    `include "generated/vu_mmio_semantic_auto.svh"

    protected bit [31:0] current_snapshot[13];
    protected bit [31:0] sticky_snapshot[13];
    protected bit [7:0] next_snapshot_tag;
    protected bit [15:0] current_user_id;
    protected bit [3:0] current_event_stream_id;

    function new(string name = "vu_mmio_set");
        super.new(name);
    endfunction

    protected function void mmio_log(string msg);
        if(log_fd != 0)
            $fwrite(log_fd, "%s", msg);
    endfunction

    function void set_log(int fd);
        log_fd = fd;
    endfunction

    function void reset_mmio();
        `include "generated/vu_mmio_reset_auto.svh"
        foreach(current_snapshot[i]) current_snapshot[i] = '0;
        foreach(sticky_snapshot[i]) sticky_snapshot[i] = '0;
        next_snapshot_tag = '0;
        current_user_id = '0;
        current_event_stream_id = '0;
    endfunction

    // Called once per replaced element by reduction/SU numerical paths only.
    // This is a functional count; no cycle-accurate performance model is implied.
    function void note_replacement(input bit is_nan);
        if(is_nan) begin
            increment_counter(nan_replace_cnt_lo_val, nan_replace_cnt_hi_val);
            nan_replace_cnt_lo = nan_replace_cnt_lo_val;
            nan_replace_cnt_hi = nan_replace_cnt_hi_val;
        end else begin
            increment_counter(inf_replace_cnt_lo_val, inf_replace_cnt_hi_val);
            inf_replace_cnt_lo = inf_replace_cnt_lo_val;
            inf_replace_cnt_hi = inf_replace_cnt_hi_val;
        end
    endfunction

    function bit [15:0] get_current_user_id();
        return current_snapshot[0][0] ? current_user_id : 16'h0000;
    endfunction

    function bit [3:0] get_current_event_stream_id();
        return current_snapshot[0][0] ? current_event_stream_id : 4'h0;
    endfunction

    protected function void increment_counter(
        ref bit [31:0] lo,
        ref bit [31:0] hi
    );
        if(profile_ctrl.run)
            {hi, lo} = {hi, lo} + 64'd1;
    endfunction

    protected function void capture_macro(input vu_exec_param_s param);
        current_snapshot[0] = {16'b0, next_snapshot_tag, 6'b0, 1'b0, 1'b1};
        next_snapshot_tag++;
        current_snapshot[1] = macro_inst_trigger_val;
        current_snapshot[1][10:8] = param.config_idx;
        current_snapshot[1][0] = (param.type_vl.src == PARAM_DYNAMIC);
        current_snapshot[1][1] = (param.ld_addr.src == PARAM_DYNAMIC);
        current_snapshot[1][2] = (param.st_addr.src == PARAM_DYNAMIC);
        current_snapshot[1][3] = (param.vrf_rd_index.src == PARAM_DYNAMIC);
        current_snapshot[1][4] = (param.vrf_wt_index.src == PARAM_DYNAMIC);
        current_snapshot[1][5] = (param.mrf_rd_index.src == PARAM_DYNAMIC);
        current_snapshot[1][6] = (param.srf_rd_index_0.src == PARAM_DYNAMIC);
        current_snapshot[2] = {11'b0, param.type_vl.nan_inf_replace_en,
                              param.type_vl.round_mode,
                              param.type_vl.data_type, param.type_vl.vl};
        current_snapshot[3] = param.ld_addr.cm_addr;
        current_snapshot[4] = param.st_addr.cm_addr;
        current_snapshot[5] = {param.vrf_rd_index.vrf_rd_p1_idx,
                              param.vrf_rd_index.vrf_rd_p0_idx};
        current_snapshot[6] = {param.vrf_wt_index.vrf_wt_p1_idx,
                              param.vrf_wt_index.vrf_wt_p0_idx};
        current_snapshot[7] = {param.mrf_rd_index.mrf_rd_p1_idx,
                              param.mrf_rd_index.mrf_rd_p0_idx};
        current_snapshot[8] = {16'b0, param.mrf_wt_index.mrf_wt_idx};
        current_snapshot[9] = {param.srf_rd_index_0.srf_rd_p3_idx,
                              param.srf_rd_index_0.srf_rd_p2_idx,
                              param.srf_rd_index_0.srf_rd_p1_idx,
                              param.srf_rd_index_0.srf_rd_p0_idx};
        current_snapshot[10] = {param.srf_rd_index_1.srf_rd_p7_idx,
                               param.srf_rd_index_1.srf_rd_p6_idx,
                               param.srf_rd_index_1.srf_rd_p5_idx,
                               param.srf_rd_index_1.srf_rd_p4_idx};
        current_snapshot[11] = {param.srf_wt_index_0.srf_wt_p3_idx,
                               param.srf_wt_index_0.srf_wt_p2_idx,
                               param.srf_wt_index_0.srf_wt_p1_idx,
                               param.srf_wt_index_0.srf_wt_p0_idx};
        current_snapshot[12] = {16'b0, param.srf_wt_index_1.srf_wt_p5_idx,
                               param.srf_wt_index_1.srf_wt_p4_idx};
        macro_inst_left_val = 1;
        macro_inst_left = macro_inst_left_val;
        status.busy = 1'b1;
        status.isq_empty = 1'b0;
        status_val = status;
        increment_counter(macro_inst_total_num_lo_val, macro_inst_total_num_hi_val);
        macro_inst_total_num_lo = macro_inst_total_num_lo_val;
        macro_inst_total_num_hi = macro_inst_total_num_hi_val;
    endfunction

    function void begin_macro(input vu_exec_param_s param);
        if(!current_snapshot[0][0])
            capture_macro(param);
        current_snapshot[0][1] = 1'b1;
        status.isq_empty = 1'b1;
        status_val = status;
    endfunction

    function void end_macro();
        macro_inst_left_val = '0;
        macro_inst_left = macro_inst_left_val;
        status.busy = 1'b0;
        status.isq_empty = 1'b1;
        status_val = status;
        foreach(current_snapshot[i]) current_snapshot[i] = '0;
        current_user_id = '0;
        current_event_stream_id = '0;
        increment_counter(macro_inst_retire_num_lo_val, macro_inst_retire_num_hi_val);
        macro_inst_retire_num_lo = macro_inst_retire_num_lo_val;
        macro_inst_retire_num_hi = macro_inst_retire_num_hi_val;
    endfunction

    function void report_error(input bit [31:0] error_bits,
                               input int unsigned unit = 0,
                               input bit [15:0] user_id_override = 16'h0000,
                               input bit use_user_override = 1'b0);
        bit [31:0] valid_errors;
        bit [15:0] error_user_id;
        int first_error;
        valid_errors = error_bits & 32'h000001ff;
        if(valid_errors == 0)
            return;
        error_user_id = use_user_override ? user_id_override : get_current_user_id();
        first_error = 0;
        for(int i = 8; i >= 0; i--)
            if(valid_errors[i]) first_error = i;
        if(!error_info.valid) begin
            error_info = '0;
            error_info.valid = 1'b1;
            error_info.user_id = error_user_id;
            error_info.err_unit = 4'(unit);
            error_info.first_err = 4'(first_error);
            if(current_snapshot[0][0]) begin
                error_info.config_idx = current_snapshot[1][10:8];
                // The specification records the raw trigger STREAM_ID field,
                // not the separately resolved Event stream selection.
                error_info.stream_id = current_snapshot[1][21:18];
                foreach(sticky_snapshot[i]) sticky_snapshot[i] = current_snapshot[i];
            end else begin
                foreach(sticky_snapshot[i]) sticky_snapshot[i] = '0;
            end
            sticky_snapshot[0][0] = 1'b1;
            sticky_snapshot[0][1] = !(first_error inside {0, 1});
            error_info_val = error_info;
        end
        // Each specialized context has its own independent first-error latch.
        if((valid_errors & `VU_ERR_NAN) != 0 && !nan_err_info.valid) begin
            nan_err_info = '0;
            nan_err_info.user_id = error_user_id;
            nan_err_info.valid = 1'b1;
            nan_err_info_val = nan_err_info;
        end
        error_code_val |= valid_errors;
        error_code = error_code_val;
        status.error_flag = 1'b1;
        status_val = status;
    endfunction

    // Explicit reference-model injection hooks: RF storage has no ECC bits or
    // detector. Correctable errors cause no error/context update. Debug/NOC
    // callers supply user_id=0 and use_current_macro=0.
    function void inject_rf_ecc(input bit [1:0] rf_sel,
                               input bit [8:0] entry_idx,
                               input bit uncorrectable = 1'b1,
                               input bit [15:0] user_id = 16'h0000,
                               input bit use_current_macro = 1'b1);
        bit [15:0] error_user_id;
        if(!uncorrectable)
            return;
        error_user_id = use_current_macro ? get_current_user_id() : user_id;
        case(rf_sel)
            2'b00: begin
                if(!vrf_err_info.valid) begin
                    vrf_err_info = '0;
                    vrf_err_info.user_id = error_user_id;
                    vrf_err_info.rf_err_idx = entry_idx;
                    vrf_err_info.valid = 1'b1;
                    vrf_err_info_val = vrf_err_info;
                end
                report_error(`VU_ERR_VRF_ECC, 13, error_user_id, 1'b1);
            end
            2'b01: begin
                if(!mrf_err_info.valid) begin
                    mrf_err_info = '0;
                    mrf_err_info.user_id = error_user_id;
                    mrf_err_info.rf_err_idx = entry_idx;
                    mrf_err_info.valid = 1'b1;
                    mrf_err_info_val = mrf_err_info;
                end
                report_error(`VU_ERR_MRF_ECC, 14, error_user_id, 1'b1);
            end
            2'b10: begin
                if(entry_idx >= 64) begin
                    `uvm_error("VU_ECC_INJECT", "SRF ECC injection index must be 0..63")
                    return;
                end
                if(!srf_err_info.valid) begin
                    srf_err_info = '0;
                    srf_err_info.user_id = error_user_id;
                    srf_err_info.rf_err_idx = entry_idx;
                    srf_err_info.valid = 1'b1;
                    srf_err_info_val = srf_err_info;
                end
                report_error(`VU_ERR_SRF_ECC, 15, error_user_id, 1'b1);
            end
            default: `uvm_error("VU_ECC_INJECT", "RF ECC injection requires rf_sel=0,1,2")
        endcase
    endfunction

    // External injection only: the model does not invent a CM ECC response.
    // The store flag records the specified context; it does not add a hardware
    // store-error channel or resolve the pending interface specification issue.
    function void inject_cm_ecc(input bit [31:0] addr,
                               input bit is_store = 1'b0,
                               input bit uncorrectable = 1'b1,
                               input bit [15:0] user_id = 16'h0000,
                               input bit use_current_macro = 1'b1);
        bit [15:0] error_user_id;
        if(!uncorrectable)
            return;
        error_user_id = use_current_macro ? get_current_user_id() : user_id;
        if(!cm_err_info.valid) begin
            cm_err_info = '0;
            cm_err_info.user_id = error_user_id;
            cm_err_info.dir = is_store;
            cm_err_info.valid = 1'b1;
            cm_err_info_val = cm_err_info;
            cm_err_addr_val = addr;
            cm_err_addr = addr;
        end
        report_error(`VU_ERR_CM_ECC, is_store ? 2 : 1, error_user_id, 1'b1);
    endfunction

    protected function void clear_errors();
        error_code_val = '0;
        error_code = '0;
        error_info_val = '0;
        error_info = '0;
        vrf_err_info_val = '0;
        vrf_err_info = '0;
        mrf_err_info_val = '0;
        mrf_err_info = '0;
        srf_err_info_val = '0;
        srf_err_info = '0;
        cm_err_info_val = '0;
        cm_err_info = '0;
        cm_err_addr_val = '0;
        cm_err_addr = '0;
        nan_err_info_val = '0;
        nan_err_info = '0;
        status.error_flag = 1'b0;
        status_val = status;
        foreach(sticky_snapshot[i]) sticky_snapshot[i] = '0;
    endfunction

    protected function bit [31:0] read_snapshot();
        if(snapshot_addr.snap_idx > 12)
            return '0;
        if(snapshot_addr.snap_sel == 8'hff)
            return sticky_snapshot[0][0] ? sticky_snapshot[snapshot_addr.snap_idx] : '0;
        if(snapshot_addr.snap_sel == 0 && current_snapshot[0][0])
            return current_snapshot[snapshot_addr.snap_idx];
        return '0;
    endfunction

    function void resolve_exec_param();
        `include "generated/vu_mmio_resolve_auto.svh"

        mmio_log($sformatf(
            "[VU_MMIO] trigger cfg=%0d vl=%0d type=%0d round=%0d valu0_op=%02h valu1_op=%02h valu2_op=%02h\n",
            exec_param.config_idx,
            exec_param.type_vl.vl,
            exec_param.type_vl.data_type,
            exec_param.type_vl.round_mode,
            exec_param.valu0_op.opcode,
            exec_param.valu1_op.opcode,
            exec_param.valu2_op.opcode
        ));
    endfunction

    function bit pop_trigger(ref vu_exec_param_s param);
        if(!trigger_pending)
            return 1'b0;

        param = exec_param;
        trigger_pending = 1'b0;
        return 1'b1;
    endfunction

    function void write(bit [31:0] addr, bit [31:0] data,
                        bit [15:0] user_id = 16'h0000,
                        bit [3:0] stream_id = 4'h0);
        bit mmio_hit;
        bit inst_trigger;

        mmio_hit = 1'b0;
        inst_trigger = 1'b0;

        if(addr == REG_FILE_DATA_BASE_ADDR) begin
            reg_file_data_write(data);

            mmio_hit = 1'b1;
        end

        `include "generated/vu_mmio_write_auto.svh"

        if(!mmio_hit)
            report_error(`VU_ERR_REG_ADDR, 0, user_id, 1'b1);

        if(mmio_hit && addr == PROFILE_CTRL_BASE_ADDR) begin
            if(data[1]) begin
                `include "generated/vu_mmio_profile_clear_auto.svh"
            end
            profile_ctrl.clear = 1'b0;
            profile_ctrl_val = profile_ctrl;
        end

        if(mmio_hit) begin
            mmio_log({get_write_desc(addr, data), "\n"});
            if(addr < MACRO_INST_LEFT_BASE_ADDR ||
               addr == SNAPSHOT_ADDR_BASE_ADDR || addr == PROFILE_CTRL_BASE_ADDR) begin
                increment_counter(cfg_wr_num_lo_val, cfg_wr_num_hi_val);
                cfg_wr_num_lo = cfg_wr_num_lo_val;
                cfg_wr_num_hi = cfg_wr_num_hi_val;
            end
        end

        if(inst_trigger) begin
            current_user_id = user_id;
            current_event_stream_id = macro_inst_trigger.stream_id_override ?
                                      macro_inst_trigger.stream_id : stream_id;
            resolve_exec_param();
            trigger_pending = 1'b1;
            capture_macro(exec_param);
        end
    endfunction

    function bit [31:0] read(bit [31:0] addr);
        bit mmio_hit;
        bit [31:0] data;

        mmio_hit = 1'b0;
        data = 32'h0;

        if(addr == REG_FILE_DATA_BASE_ADDR) begin
            data = reg_file_data_read();
            mmio_hit = 1'b1;
        end

        if(addr == SNAPSHOT_DATA_BASE_ADDR) begin
            snapshot_data_val = read_snapshot();
            snapshot_data = snapshot_data_val;
        end

        `include "generated/vu_mmio_read_auto.svh"

        if(!mmio_hit)
            report_error(`VU_ERR_REG_ADDR, 0, 16'h0000, 1'b1);

        if(mmio_hit)
            mmio_log({get_read_desc(addr, data), "\n"});
        if(addr == ERROR_CODE_BASE_ADDR)
            clear_errors();

        return data;
    endfunction

    protected function void reg_file_data_write(bit [31:0] data);
        bit [15:0] byte_addr;
        int unsigned entry_idx;
        int unsigned word_idx;

        byte_addr = reg_file_addr.rf_addr & 16'hfffc;

        case(reg_file_addr.rf_sel)
            2'b00: begin
                entry_idx = (byte_addr / 128) % 512;
                word_idx = (byte_addr % 128) / 4;
                vrf[entry_idx][word_idx*32 +: 32] = data;
            end
            2'b01: begin
                if(byte_addr >= 16'h1000)
                    report_error(`VU_ERR_RF_IDX, 12, 16'h0000, 1'b1);
                byte_addr = byte_addr % 16'h1000;
                entry_idx = (byte_addr / 8) % 512;
                word_idx = (byte_addr % 8) / 4;
                mrf[entry_idx][word_idx*32 +: 32] = data;
            end
            2'b10: begin
                if(byte_addr >= 16'h0100)
                    report_error(`VU_ERR_RF_IDX, 12, 16'h0000, 1'b1);
                byte_addr = byte_addr % 16'h0100;
                entry_idx = (byte_addr / 4) % 64;
                srf[entry_idx] = data;
            end
            default: report_error(`VU_ERR_RF_IDX, 12, 16'h0000, 1'b1);
        endcase
    endfunction

    protected function bit [31:0] reg_file_data_read();
        bit [15:0] byte_addr;
        bit [31:0] data;
        int unsigned entry_idx;
        int unsigned word_idx;

        byte_addr = reg_file_addr.rf_addr & 16'hfffc;
        data = 32'h0;

        case(reg_file_addr.rf_sel)
            2'b00: begin
                entry_idx = (byte_addr / 128) % 512;
                word_idx = (byte_addr % 128) / 4;
                data = vrf[entry_idx][word_idx*32 +: 32];
            end
            2'b01: begin
                if(byte_addr >= 16'h1000)
                    report_error(`VU_ERR_RF_IDX, 12, 16'h0000, 1'b1);
                byte_addr = byte_addr % 16'h1000;
                entry_idx = (byte_addr / 8) % 512;
                word_idx = (byte_addr % 8) / 4;
                data = mrf[entry_idx][word_idx*32 +: 32];
            end
            2'b10: begin
                if(byte_addr >= 16'h0100)
                    report_error(`VU_ERR_RF_IDX, 12, 16'h0000, 1'b1);
                byte_addr = byte_addr % 16'h0100;
                entry_idx = (byte_addr / 4) % 64;
                data = srf[entry_idx];
            end
            default: begin
                report_error(`VU_ERR_RF_IDX, 12, 16'h0000, 1'b1);
                data = 32'h0;
            end
        endcase

        return data;
    endfunction

    function bit [1023:0] read_vrf_entry(int unsigned entry_idx);
        return vrf[entry_idx % 512];
    endfunction

    function void write_vrf_entry(
        int unsigned entry_idx,
        bit [1023:0] data
    );
        vrf[entry_idx % 512] = data;
    endfunction

    function bit [31:0] read_srf_entry(int unsigned entry_idx);
        return srf[entry_idx % 64];
    endfunction

    function void write_srf_entry(
        int unsigned entry_idx,
        bit [31:0] data
    );
        srf[entry_idx % 64] = data;
    endfunction

    function bit [63:0] read_mrf_entry(int unsigned entry_idx);
        return mrf[entry_idx % 512];
    endfunction

    function void write_mrf_entry(
        int unsigned entry_idx,
        bit [63:0] data
    );
        mrf[entry_idx % 512] = data;
    endfunction

    function bit read_mrf_bit(
        int unsigned start_idx,
        int unsigned elem_idx,
        bit data_type
    );
        int unsigned entry_idx;
        int unsigned bit_idx;
        int unsigned elems;

        elems = data_type ? 64 : 32;
        entry_idx = (start_idx & 511) + elem_idx / elems;
        bit_idx = elem_idx % elems;
        if(entry_idx >= 512)
            report_error(`VU_ERR_RF_IDX);
        return mrf[entry_idx % 512][bit_idx];
    endfunction

    function void write_mrf_bit(
        int unsigned start_idx,
        int unsigned elem_idx,
        bit value,
        bit data_type
    );
        int unsigned entry_idx;
        int unsigned bit_idx;
        int unsigned elems;

        elems = data_type ? 64 : 32;
        entry_idx = (start_idx & 511) + elem_idx / elems;
        bit_idx = elem_idx % elems;
        if(entry_idx >= 512)
            report_error(`VU_ERR_RF_IDX);
        mrf[entry_idx % 512][bit_idx] = value;
    endfunction

    function bit [1023:0] get_lu_bypass();
        return lu_bypass;
    endfunction

    function void set_lu_bypass(bit [1023:0] data);
        lu_bypass = data;
    endfunction

    function bit [1023:0] get_valu_bypass(int unsigned valu_id);
        case(valu_id)
            0: return valu0_bypass;
            1: return valu1_bypass;
            2: return valu2_bypass;
            default: return '0;
        endcase
    endfunction

    function void set_valu_bypass(
        int unsigned valu_id,
        bit [1023:0] data
    );
        case(valu_id)
            0: valu0_bypass = data;
            1: valu1_bypass = data;
            2: valu2_bypass = data;
            default: begin
            end
        endcase
    endfunction

    function bit [1023:0] get_vsfu_bypass(int unsigned vsfu_id);
        case(vsfu_id)
            0: return vsfu0_bypass;
            1: return vsfu1_bypass;
            default: return '0;
        endcase
    endfunction

    function void set_vsfu_bypass(
        int unsigned vsfu_id,
        bit [1023:0] data
    );
        case(vsfu_id)
            0: vsfu0_bypass = data;
            1: vsfu1_bypass = data;
            default: begin
            end
        endcase
    endfunction

endclass
