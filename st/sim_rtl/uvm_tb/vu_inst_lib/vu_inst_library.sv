class vu_inst_library;

    protected int log_fd = 0;

    function void set_log(int fd);
        log_fd = fd;
    endfunction : set_log

    static function automatic vu_valu_op_s to_common_op(
        input bit [7:0] opcode,
        input bit [7:0] src1_sel,
        input bit [7:0] src2_sel,
        input bit [7:0] src3_sel
    );
        vu_valu_op_s op;

        op.opcode = opcode;
        op.src1_sel = src1_sel;
        op.src2_sel = src2_sel;
        op.src3_sel = src3_sel;

        return op;
    endfunction : to_common_op

    static function automatic bit [7:0] valu_src_code(input vu_valu_id_e valu_id);
        case(valu_id)
            VU_VALU0: return `VU_SRC_VALU0;
            VU_VALU1: return `VU_SRC_VALU1;
            default:  return `VU_SRC_VALU2;
        endcase
    endfunction : valu_src_code

    static function automatic void writeback(
        input vu_mmio_set mmio,
        input vu_valu_id_e valu_id,
        input vu_vec_chunk_t result,
        input bit [7:0] p0_src,
        input bit [7:0] p1_src,
        input bit [15:0] p0_idx,
        input bit [15:0] p1_idx,
        input int unsigned chunk_idx
    );
        bit [7:0] src_code;

        src_code = valu_src_code(valu_id);

        mmio.set_valu_bypass(int'(valu_id), result);

        if(p0_src == src_code)
            mmio.write_vrf_entry(
                vu_vv_inst::wrap_vrf_index(p0_idx, chunk_idx),
                result
            );

        if(p1_src == src_code)
            mmio.write_vrf_entry(
                vu_vv_inst::wrap_vrf_index(p1_idx, chunk_idx),
                result
            );
    endfunction : writeback

    function void execute(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param
    );
        vu_valu_op_s ops[3];
        vu_vec_chunk_t result;
        int unsigned vl;
        int unsigned chunks;
        int unsigned active_elems;

        if(param.type_vl.data_type != 1'b0) begin
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] not executed: unsupported data_type=%0d\n",
                    param.type_vl.data_type);
            return;
        end

        vl = param.type_vl.vl;

        if(vl == 0)
            vl = 1;

        if(vl > `VU_MAX_VL)
            vl = `VU_MAX_VL;

        chunks = (vl + `VU_FP32_ELEMS_PER_ENTRY - 1) /
                 `VU_FP32_ELEMS_PER_ENTRY;

        ops[0] = to_common_op(
            param.valu0_op.opcode,
            param.valu0_op.src1_sel,
            param.valu0_op.src2_sel,
            param.valu0_op.src3_sel
        );

        ops[1] = to_common_op(
            param.valu1_op.opcode,
            param.valu1_op.src1_sel,
            param.valu1_op.src2_sel,
            param.valu1_op.src3_sel
        );

        ops[2] = to_common_op(
            param.valu2_op.opcode,
            param.valu2_op.src1_sel,
            param.valu2_op.src2_sel,
            param.valu2_op.src3_sel
        );

        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
            active_elems = vl - chunk * `VU_FP32_ELEMS_PER_ENTRY;

            if(active_elems > `VU_FP32_ELEMS_PER_ENTRY)
                active_elems = `VU_FP32_ELEMS_PER_ENTRY;

            for(int unsigned id = 0; id < 3; id++) begin
                if(vu_vv_inst::execute_chunk(
                    mmio,
                    vu_valu_id_e'(id),
                    ops[id],
                    param.vrf_rd_index.vrf_rd_p0_idx,
                    param.vrf_rd_index.vrf_rd_p1_idx,
                    chunk,
                    active_elems,
                    param.type_vl.round_mode,
                    log_fd,
                    result
                ))
                    writeback(
                        mmio,
                        vu_valu_id_e'(id),
                        result,
                        param.prf_op.vrf_wt_p0_src,
                        param.prf_op.vrf_wt_p1_src,
                        param.vrf_wt_index.vrf_wt_p0_idx,
                        param.vrf_wt_index.vrf_wt_p1_idx,
                        chunk
                    );
            end
        end
    endfunction : execute

    function void do_trigger(input vu_mmio_set mmio);
        vu_mmio_set::vu_exec_param_s param;

        if(!mmio.pop_trigger(param))
            return;

        execute(mmio, param);
    endfunction : do_trigger

endclass : vu_inst_library