class vu_inst_library;

    protected int log_fd = 0;

    protected vu_vec_chunk_t lu_vec_result[`VU_MAX_VEC_CHUNKS];
    protected bit lu_mask_result[`VU_MAX_VL];
    protected bit [31:0] lu_scalar_result;
    protected bit lu_vec_valid;
    protected bit lu_mask_valid;
    protected bit lu_scalar_valid;

    // VEXE slots: 0/1/2=VALU0/1/2, 3/4=VSFU0/1.
    protected vu_vec_chunk_t vexe_vec_result[5][`VU_MAX_VEC_CHUNKS];
    protected bit vexe_done[5];
    protected bit vexe_vec_valid[5];
    protected bit vexe_scalar_valid[5];
    protected bit [31:0] vexe_scalar_result[5];
    protected bit valu0_mask_result[`VU_MAX_VL];
    protected bit valu0_mask_valid;

    protected bit mexe_mask_result[`VU_MAX_VL];
    protected bit mexe_mask_valid;
    protected bit [31:0] mexe_scalar_result;
    protected bit mexe_scalar_valid;

    protected bit [31:0] sexe_result[3];
    protected bit sexe_valid[3];

    function void set_log(int fd);
        log_fd = fd;
    endfunction : set_log

    static function automatic int unsigned elem_count_per_entry(input bit data_type);
        return vu_vv_inst::elems_per_entry(data_type);
    endfunction : elem_count_per_entry

    static function automatic int unsigned vector_chunk_count(
        input int unsigned vl,
        input bit data_type
    );
        int unsigned elems;

        elems = elem_count_per_entry(data_type);
        return (vl + elems - 1) / elems;
    endfunction : vector_chunk_count

    static function automatic bit [7:0] vexe_src_code(input int unsigned id);
        case(id)
            0: return `VU_SRC_VALU0;
            1: return `VU_SRC_VALU1;
            2: return `VU_SRC_VALU2;
            3: return `VU_SRC_VSFU0;
            default: return `VU_SRC_VSFU1;
        endcase
    endfunction : vexe_src_code

    static function automatic int vexe_src_id(input bit [7:0] src_sel);
        case(src_sel)
            `VU_SRC_VALU0: return 0;
            `VU_SRC_VALU1: return 1;
            `VU_SRC_VALU2: return 2;
            `VU_SRC_VSFU0: return 3;
            `VU_SRC_VSFU1: return 4;
            default: return -1;
        endcase
    endfunction : vexe_src_id

    static function automatic bit is_srf_src(input bit [7:0] src_sel);
        return src_sel inside {[`VU_SRC_SRF_P0:`VU_SRC_SRF_P7]};
    endfunction : is_srf_src

    static function automatic bit is_compare_opcode(input bit [7:0] opcode);
        return opcode inside {[`VU_OPCODE_VMFEQ_VV:`VU_OPCODE_VMFGE_VF]};
    endfunction : is_compare_opcode

    static function automatic bit is_reduction_opcode(input bit [7:0] opcode);
        return opcode inside {[`VU_OPCODE_VFREDUSUM_VS:`VU_OPCODE_VFREDMIN_VS]};
    endfunction : is_reduction_opcode

    static function automatic bit is_topk_opcode(input bit [7:0] opcode);
        return opcode == `VU_OPCODE_VSORTMAX16_V ||
               opcode == `VU_OPCODE_VSORTMIN16_V;
    endfunction : is_topk_opcode

    static function automatic bit is_macc_opcode(input bit [7:0] opcode);
        return opcode inside {[`VU_OPCODE_VFMACC_VV:`VU_OPCODE_VFNMSAC_VF]};
    endfunction : is_macc_opcode

    static function automatic bit valu_opcode_supported(
        input int unsigned id,
        input bit [7:0] opcode
    );
        if(opcode == `VU_OPCODE_NOP)
            return 1'b1;

        if(opcode inside {[8'h01:8'h07]} ||
           opcode inside {[8'h10:8'h13]} ||
           opcode == `VU_OPCODE_VFMV_V_F)
            return 1'b1;

        case(id)
            0: return opcode == `VU_OPCODE_VFDIV_VV ||
                      opcode == `VU_OPCODE_VFMV_S_F ||
                      opcode inside {[8'h30:8'h37]} ||
                      opcode inside {[8'h40:8'h45]} ||
                      opcode inside {[8'h50:8'h59]} ||
                      opcode inside {[8'h60:8'h62]};
            1: return opcode == `VU_OPCODE_VFMV_F_S ||
                      opcode inside {[8'h70:8'h74]};
            2: return opcode == `VU_OPCODE_VMV_V_V;
            default: return 1'b0;
        endcase
    endfunction : valu_opcode_supported

    static function automatic bit vsfu_opcode_supported(input bit [7:0] opcode);
        return opcode == 8'h00 || opcode inside {[8'h01:8'h0c]};
    endfunction : vsfu_opcode_supported

    function automatic bit [7:0] srf_read_index(
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel
    );
        case(src_sel)
            `VU_SRC_SRF_P0: return param.srf_rd_index_0.srf_rd_p0_idx;
            `VU_SRC_SRF_P1: return param.srf_rd_index_0.srf_rd_p1_idx;
            `VU_SRC_SRF_P2: return param.srf_rd_index_0.srf_rd_p2_idx;
            `VU_SRC_SRF_P3: return param.srf_rd_index_0.srf_rd_p3_idx;
            `VU_SRC_SRF_P4: return param.srf_rd_index_1.srf_rd_p4_idx;
            `VU_SRC_SRF_P5: return param.srf_rd_index_1.srf_rd_p5_idx;
            `VU_SRC_SRF_P6: return param.srf_rd_index_1.srf_rd_p6_idx;
            default: return param.srf_rd_index_1.srf_rd_p7_idx;
        endcase
    endfunction : srf_read_index

    function automatic bit vector_source_ready(input bit [7:0] src_sel);
        int id;

        case(src_sel)
            `VU_SRC_LU: return lu_vec_valid;
            `VU_SRC_VRF_P0, `VU_SRC_VRF_P1: return 1'b1;
            default: begin
                id = vexe_src_id(src_sel);
                if(id < 0)
                    return 1'b0;
                return vexe_done[id] && vexe_vec_valid[id];
            end
        endcase
    endfunction : vector_source_ready

    function automatic bit scalar_source_ready(input bit [7:0] src_sel);
        if(is_srf_src(src_sel))
            return 1'b1;

        case(src_sel)
            `VU_SRC_LU: return lu_scalar_valid;
            `VU_SRC_VALU1: return vexe_done[1] && vexe_scalar_valid[1];
            `VU_SRC_MEXE: return mexe_scalar_valid;
            `VU_SRC_SEXE0: return sexe_valid[0];
            `VU_SRC_SEXE1: return sexe_valid[1];
            `VU_SRC_SEXE2: return sexe_valid[2];
            default: return 1'b0;
        endcase
    endfunction : scalar_source_ready

    function automatic bit operand_source_ready(input bit [7:0] src_sel);
        return vector_source_ready(src_sel) || scalar_source_ready(src_sel);
    endfunction : operand_source_ready

    function automatic bit resolve_vector_source(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        input int unsigned chunk,
        output vu_vec_chunk_t data
    );
        int id;

        data = '0;
        case(src_sel)
            `VU_SRC_LU: begin
                if(!lu_vec_valid)
                    return 1'b0;
                data = lu_vec_result[chunk];
                return 1'b1;
            end
            `VU_SRC_VRF_P0: begin
                data = mmio.read_vrf_entry(
                    vu_vv_inst::wrap_vrf_index(
                        param.vrf_rd_index.vrf_rd_p0_idx,
                        chunk
                    )
                );
                return 1'b1;
            end
            `VU_SRC_VRF_P1: begin
                data = mmio.read_vrf_entry(
                    vu_vv_inst::wrap_vrf_index(
                        param.vrf_rd_index.vrf_rd_p1_idx,
                        chunk
                    )
                );
                return 1'b1;
            end
            default: begin
                id = vexe_src_id(src_sel);
                if(id < 0 || !vexe_done[id] || !vexe_vec_valid[id])
                    return 1'b0;
                data = vexe_vec_result[id][chunk];
                return 1'b1;
            end
        endcase
    endfunction : resolve_vector_source

    function automatic bit resolve_scalar_source(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        output bit [31:0] data
    );
        data = '0;
        if(is_srf_src(src_sel)) begin
            data = mmio.read_srf_entry(srf_read_index(param, src_sel));
            return 1'b1;
        end

        case(src_sel)
            `VU_SRC_LU: begin
                data = lu_scalar_result;
                return lu_scalar_valid;
            end
            `VU_SRC_VALU1: begin
                data = vexe_scalar_result[1];
                return vexe_done[1] && vexe_scalar_valid[1];
            end
            `VU_SRC_MEXE: begin
                data = mexe_scalar_result;
                return mexe_scalar_valid;
            end
            `VU_SRC_SEXE0: begin data = sexe_result[0]; return sexe_valid[0]; end
            `VU_SRC_SEXE1: begin data = sexe_result[1]; return sexe_valid[1]; end
            `VU_SRC_SEXE2: begin data = sexe_result[2]; return sexe_valid[2]; end
            default: return 1'b0;
        endcase
    endfunction : resolve_scalar_source

    function automatic bit resolve_valu_operand(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        input int unsigned chunk,
        output vu_vec_chunk_t data
    );
        bit [31:0] scalar;
        bit [31:0] internal_scalar;
        int unsigned elems;

        data = '0;
        if(!scalar_source_ready(src_sel))
            return resolve_vector_source(mmio, param, src_sel, chunk, data);

        if(!resolve_scalar_source(mmio, param, src_sel, scalar))
            return 1'b0;

        internal_scalar = param.type_vl.data_type ?
            vu_fp32_to_bf16(scalar, param.type_vl.round_mode) : scalar;
        elems = elem_count_per_entry(param.type_vl.data_type);
        for(int unsigned elem = 0; elem < elems; elem++)
            vu_vv_inst::set_elem(data, param.type_vl.data_type,
                                 elem, internal_scalar);
        return 1'b1;
    endfunction : resolve_valu_operand

    function automatic bit predicate_bit(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [1:0] mask_sel,
        input int unsigned global_elem
    );
        case(mask_sel)
            2'b00: return 1'b1;
            2'b01: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p0_idx, global_elem);
            2'b10: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p1_idx, global_elem);
            default: return 1'b0;
        endcase
    endfunction : predicate_bit

    function automatic bit [1:0] valu_mask_sel(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id
    );
        case(id)
            0: return param.mask_op.valu0_mask_sel;
            1: return param.mask_op.valu1_mask_sel;
            default: return param.mask_op.valu2_mask_sel;
        endcase
    endfunction : valu_mask_sel

    static function automatic int unsigned load_physical_elem(
        input int unsigned logical_elem,
        input bit [7:0] stride_run,
        input bit [7:0] stride_skip
    );
        int unsigned block;
        int unsigned in_block;
        int unsigned physical_block;

        if(stride_run == 0 || stride_skip == 0)
            return logical_elem;

        block = logical_elem / 32;
        in_block = logical_elem % 32;
        physical_block = (block / stride_run) * (stride_run + stride_skip) +
                         (block % stride_run);
        return physical_block * 32 + in_block;
    endfunction : load_physical_elem

    function automatic bit [31:0] read_cm(
        input dsa_mem_library dsa_mem,
        input bit [31:0] addr,
        input bit [1:0] size
    );
        return dsa_mem.read_core(size, addr);
    endfunction : read_cm

    function automatic void write_cm(
        input dsa_mem_library dsa_mem,
        input bit [31:0] addr,
        input bit [1:0] size,
        input bit [31:0] data
    );
        dsa_mem.write_core(size, addr, data);
    endfunction : write_cm

    function automatic void clear_execution_state(input int unsigned vl);
        lu_vec_valid = 1'b0;
        lu_mask_valid = 1'b0;
        lu_scalar_valid = 1'b0;
        lu_scalar_result = '0;
        valu0_mask_valid = 1'b0;
        mexe_mask_valid = 1'b0;
        mexe_scalar_valid = 1'b0;
        for(int id = 0; id < 5; id++) begin
            vexe_done[id] = 1'b0;
            vexe_vec_valid[id] = 1'b0;
            vexe_scalar_valid[id] = 1'b0;
            vexe_scalar_result[id] = '0;
        end
        for(int id = 0; id < 3; id++) begin
            sexe_valid[id] = 1'b0;
            sexe_result[id] = '0;
        end
        for(int unsigned elem = 0; elem < vl; elem++) begin
            lu_mask_result[elem] = 1'b0;
            valu0_mask_result[elem] = 1'b0;
            mexe_mask_result[elem] = 1'b0;
        end
    endfunction : clear_execution_state

    function automatic void execute_lu(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        int unsigned chunks;
        int unsigned elems_per_chunk;
        int unsigned physical_elem;
        int unsigned bytes;
        bit [31:0] raw;
        bit [31:0] value;
        bit [31:0] addr;

        if(param.lu_op.opcode == 8'h00)
            return;

        elems_per_chunk = elem_count_per_entry(param.type_vl.data_type);
        chunks = vector_chunk_count(vl, param.type_vl.data_type);
        for(int unsigned chunk = 0; chunk < chunks; chunk++)
            lu_vec_result[chunk] = '0;

        case(param.lu_op.opcode)
            `VU_OPCODE_LDST_FP8E4M3,
            `VU_OPCODE_LDST_MXFP8,
            `VU_OPCODE_LDST_BF16,
            `VU_OPCODE_LDST_FP32: begin
                for(int unsigned elem = 0; elem < vl; elem++) begin
                    physical_elem = load_physical_elem(
                        elem,
                        param.lu_op.stride_run,
                        param.lu_op.stride_skip
                    );
                    case(param.lu_op.opcode)
                        `VU_OPCODE_LDST_FP8E4M3,
                        `VU_OPCODE_LDST_MXFP8: begin
                            addr = param.ld_addr.cm_addr + physical_elem;
                            raw = read_cm(dsa_mem, addr, 2'd0);
                        end
                        `VU_OPCODE_LDST_BF16: begin
                            addr = param.ld_addr.cm_addr + physical_elem * 2;
                            raw = read_cm(dsa_mem, addr, 2'd1);
                        end
                        default: begin
                            addr = param.ld_addr.cm_addr + physical_elem * 4;
                            raw = read_cm(dsa_mem, addr, 2'd2);
                        end
                    endcase
                    value = vu_load_convert(param.lu_op.opcode, raw,
                                            param.type_vl.data_type,
                                            param.type_vl.round_mode);
                    vu_vv_inst::set_elem(
                        lu_vec_result[elem / elems_per_chunk],
                        param.type_vl.data_type,
                        elem % elems_per_chunk,
                        value
                    );
                end
                lu_vec_valid = 1'b1;
                mmio.set_lu_bypass(lu_vec_result[0]);
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] LU opcode=%02h vl=%0d vector-loaded%s\n",
                        param.lu_op.opcode, vl,
                        param.lu_op.opcode == `VU_OPCODE_LDST_MXFP8 ?
                            " (MXFP8 scale=1 fallback)" : "");
            end

            `VU_OPCODE_LDST_MASK: begin
                bytes = (vl + 7) / 8;
                for(int unsigned byte_idx = 0; byte_idx < bytes; byte_idx++) begin
                    raw = read_cm(dsa_mem,
                                  param.ld_addr.cm_addr + byte_idx, 2'd0);
                    for(int unsigned bit_idx = 0; bit_idx < 8; bit_idx++)
                        if(byte_idx * 8 + bit_idx < vl)
                            lu_mask_result[byte_idx * 8 + bit_idx] = raw[bit_idx];
                end
                lu_mask_valid = 1'b1;
                if(log_fd != 0)
                    $fwrite(log_fd, "[VU_INST] LU ld.mask vl=%0d\n", vl);
            end

            `VU_OPCODE_LDST_SCALAR: begin
                lu_scalar_result = read_cm(dsa_mem,
                                           param.ld_addr.cm_addr, 2'd2);
                lu_scalar_valid = 1'b1;
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] LU ld.s.fp32 result=%08h\n",
                        lu_scalar_result);
            end

            default: begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] LU opcode=%02h reserved: NOP\n",
                        param.lu_op.opcode);
            end
        endcase
    endfunction : execute_lu

    function automatic vu_valu_op_s get_valu_op(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id
    );
        vu_valu_op_s op;

        op = '0;
        case(id)
            0: begin
                op.opcode = param.valu0_op.opcode;
                op.src1_sel = param.valu0_op.src1_sel;
                op.src2_sel = param.valu0_op.src2_sel;
                op.src3_sel = param.valu0_op.src3_sel;
            end
            1: begin
                op.opcode = param.valu1_op.opcode;
                op.src1_sel = param.valu1_op.src1_sel;
                op.src2_sel = param.valu1_op.src2_sel;
                op.src3_sel = param.valu1_op.src3_sel;
            end
            default: begin
                op.opcode = param.valu2_op.opcode;
                op.src1_sel = param.valu2_op.src1_sel;
                op.src2_sel = param.valu2_op.src2_sel;
                op.src3_sel = param.valu2_op.src3_sel;
            end
        endcase
        return op;
    endfunction : get_valu_op

    function automatic bit can_execute_valu(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id
    );
        vu_valu_op_s op;

        op = get_valu_op(param, id);
        if(op.opcode == 8'h00 || !valu_opcode_supported(id, op.opcode))
            return 1'b1;

        case(op.opcode)
            `VU_OPCODE_VFMV_V_F,
            `VU_OPCODE_VFMV_S_F:
                return scalar_source_ready(op.src1_sel);
            `VU_OPCODE_VFMV_F_S,
            `VU_OPCODE_VMV_V_V:
                return vector_source_ready(op.src2_sel);
            `VU_OPCODE_VFCLASS_MV,
            `VU_OPCODE_VSORTMAX16_V,
            `VU_OPCODE_VSORTMIN16_V:
                return vector_source_ready(op.src1_sel);
            default: begin
                if(!operand_source_ready(op.src1_sel) ||
                   !vector_source_ready(op.src2_sel))
                    return 1'b0;
                if(is_macc_opcode(op.opcode) &&
                   !vector_source_ready(op.src3_sel))
                    return 1'b0;
                return 1'b1;
            end
        endcase
    endfunction : can_execute_valu

    function automatic void execute_reduction(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input vu_valu_op_s op,
        input int unsigned vl
    );
        vu_vec_chunk_t src1;
        vu_vec_chunk_t src2;
        bit [31:0] accum;
        bit [31:0] value;
        int unsigned elems;
        int unsigned chunks;
        int unsigned active;

        elems = elem_count_per_entry(param.type_vl.data_type);
        chunks = vector_chunk_count(vl, param.type_vl.data_type);
        void'(resolve_valu_operand(mmio, param, op.src1_sel, 0, src1));
        accum = vu_vv_inst::get_elem(src1, param.type_vl.data_type, 0);
        if(param.type_vl.data_type)
            accum = vu_bf16_to_fp32(accum);

        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
            void'(resolve_vector_source(mmio, param, op.src2_sel, chunk, src2));
            active = vl - chunk * elems;
            if(active > elems)
                active = elems;
            for(int unsigned elem = 0; elem < active; elem++) begin
                if(!predicate_bit(mmio, param,
                                  param.mask_op.valu1_mask_sel,
                                  chunk * elems + elem))
                    continue;
                value = vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem);
                if(param.type_vl.data_type)
                    value = vu_bf16_to_fp32(value);
                case(op.opcode)
                    `VU_OPCODE_VFREDUSUM_VS:
                        accum = vu_fp_sexe(`VU_OPCODE_FADD_S, accum, value);
                    `VU_OPCODE_VFREDMAX_VS:
                        accum = vu_fp_alu(`VU_OPCODE_VFMAX_VV,
                                          accum, value, 0, 0, 0);
                    default:
                        accum = vu_fp_alu(`VU_OPCODE_VFMIN_VV,
                                          accum, value, 0, 0, 0);
                endcase
            end
        end
        vexe_scalar_result[1] = accum;
        vexe_scalar_valid[1] = 1'b1;
        if(log_fd != 0)
            $fwrite(log_fd,
                "[VU_INST] VALU1 reduction opcode=%02h vl=%0d result=%08h\n",
                op.opcode, vl, accum);
    endfunction : execute_reduction

    function automatic void execute_topk(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input vu_valu_op_s op,
        input int unsigned vl
    );
        vu_vec_chunk_t src;
        bit [31:0] best_value[16];
        int best_index[16];
        bit best_valid[16];
        bit [31:0] candidate;
        int insert_at;
        int unsigned elems;
        int unsigned chunks;
        int unsigned active;
        bit better;

        elems = elem_count_per_entry(param.type_vl.data_type);
        chunks = vector_chunk_count(vl, param.type_vl.data_type);
        vexe_vec_result[1][0] = '0;
        for(int slot = 0; slot < 16; slot++) begin
            best_value[slot] = '0;
            best_index[slot] = -1;
            best_valid[slot] = 1'b0;
        end

        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
            void'(resolve_vector_source(mmio, param, op.src1_sel, chunk, src));
            active = vl - chunk * elems;
            if(active > elems)
                active = elems;
            for(int unsigned elem = 0; elem < active; elem++) begin
                if(!predicate_bit(mmio, param,
                                  param.mask_op.valu1_mask_sel,
                                  chunk * elems + elem))
                    continue;
                candidate = vu_vv_inst::get_elem(src, param.type_vl.data_type, elem);
                insert_at = -1;
                for(int slot = 0; slot < 16; slot++) begin
                    if(!best_valid[slot])
                        better = 1'b1;
                    else if(op.opcode == `VU_OPCODE_VSORTMAX16_V)
                        better = vu_fp_compare(`VU_OPCODE_VMFGT_VF,
                                               best_value[slot], candidate,
                                               param.type_vl.data_type) != 0;
                    else
                        better = vu_fp_compare(`VU_OPCODE_VMFLT_VV,
                                               best_value[slot], candidate,
                                               param.type_vl.data_type) != 0;
                    if(better) begin
                        insert_at = slot;
                        break;
                    end
                end
                if(insert_at >= 0) begin
                    for(int slot = 15; slot > insert_at; slot--) begin
                        best_value[slot] = best_value[slot-1];
                        best_index[slot] = best_index[slot-1];
                        best_valid[slot] = best_valid[slot-1];
                    end
                    best_value[insert_at] = candidate;
                    best_index[insert_at] = int'(chunk * elems + elem);
                    best_valid[insert_at] = 1'b1;
                end
            end
        end

        for(int slot = 0; slot < 16; slot++) begin
            if(best_valid[slot]) begin
                vu_vv_inst::set_elem(vexe_vec_result[1][0],
                                     param.type_vl.data_type,
                                     slot, best_value[slot]);
                vexe_vec_result[1][0][512 + slot*16 +: 16] =
                    best_index[slot][15:0];
            end else begin
                vexe_vec_result[1][0][512 + slot*16 +: 16] = 16'hffff;
            end
        end
        vexe_vec_valid[1] = 1'b1;
        if(log_fd != 0)
            $fwrite(log_fd,
                "[VU_INST] VALU1 top16 opcode=%02h candidates=%0d\n",
                op.opcode, vl);
    endfunction : execute_topk

    function automatic void execute_valu(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id,
        input int unsigned vl
    );
        vu_valu_op_s op;
        vu_vec_chunk_t src1;
        vu_vec_chunk_t src2;
        vu_vec_chunk_t src3;
        bit [31:0] value1;
        bit [31:0] value2;
        bit [31:0] value3;
        bit [31:0] result;
        bit [9:0] class_imm;
        bit pred;
        int unsigned elems;
        int unsigned chunks;
        int unsigned active;
        int unsigned global_elem;
        int unsigned elem_imm;
        bit [7:0] src_code;

        op = get_valu_op(param, id);
        vexe_done[id] = 1'b1;

        if(op.opcode == 8'h00) begin
            if(log_fd != 0)
                $fwrite(log_fd, "[VU_INST] VALU%0d opcode=00 NOP\n", id);
            return;
        end
        if(!valu_opcode_supported(id, op.opcode)) begin
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] VALU%0d opcode=%02h unsupported/reserved: NOP\n",
                    id, op.opcode);
            return;
        end

        if(is_reduction_opcode(op.opcode)) begin
            execute_reduction(mmio, param, op, vl);
            return;
        end
        if(is_topk_opcode(op.opcode)) begin
            execute_topk(mmio, param, op, vl);
            return;
        end
        if(op.opcode == `VU_OPCODE_VFMV_F_S) begin
            void'(resolve_vector_source(mmio, param, op.src2_sel, 0, src2));
            elem_imm = op.src1_sel[5:0];
            result = vu_vv_inst::get_elem(src2, param.type_vl.data_type,
                                          elem_imm);
            if(param.type_vl.data_type)
                result = vu_bf16_to_fp32(result);
            vexe_scalar_result[1] = result;
            vexe_scalar_valid[1] = 1'b1;
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] VALU1 vfmv.f.s elem=%0d result=%08h\n",
                    elem_imm, result);
            return;
        end

        elems = elem_count_per_entry(param.type_vl.data_type);
        chunks = vector_chunk_count(vl, param.type_vl.data_type);

        if(is_compare_opcode(op.opcode) ||
           op.opcode == `VU_OPCODE_VFCLASS_MV) begin
            class_imm = {op.src3_sel[1:0], op.src2_sel};
            for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
                if(op.opcode == `VU_OPCODE_VFCLASS_MV)
                    void'(resolve_vector_source(mmio, param, op.src1_sel,
                                                chunk, src1));
                else begin
                    void'(resolve_valu_operand(mmio, param, op.src1_sel,
                                               chunk, src1));
                    void'(resolve_vector_source(mmio, param, op.src2_sel,
                                                chunk, src2));
                end
                active = vl - chunk * elems;
                if(active > elems)
                    active = elems;
                for(int unsigned elem = 0; elem < active; elem++) begin
                    global_elem = chunk * elems + elem;
                    pred = predicate_bit(mmio, param,
                                         param.mask_op.valu0_mask_sel,
                                         global_elem);
                    if(!pred)
                        valu0_mask_result[global_elem] = 1'b0;
                    else if(op.opcode == `VU_OPCODE_VFCLASS_MV)
                        valu0_mask_result[global_elem] = vu_fp_class(
                            vu_vv_inst::get_elem(src1, param.type_vl.data_type,
                                                 elem),
                            param.type_vl.data_type,
                            class_imm
                        ) != 0;
                    else
                        valu0_mask_result[global_elem] = vu_fp_compare(
                            op.opcode,
                            vu_vv_inst::get_elem(src1, param.type_vl.data_type,
                                                 elem),
                            vu_vv_inst::get_elem(src2, param.type_vl.data_type,
                                                 elem),
                            param.type_vl.data_type
                        ) != 0;
                end
            end
            valu0_mask_valid = 1'b1;
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] VALU0 mask-result opcode=%02h vl=%0d\n",
                    op.opcode, vl);
            return;
        end

        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
            vexe_vec_result[id][chunk] = '0;

            if(op.opcode == `VU_OPCODE_VFMV_S_F) begin
                src_code = vexe_src_code(id);
                if(param.prf_op.vrf_wt_p0_src == src_code)
                    vexe_vec_result[id][chunk] = mmio.read_vrf_entry(
                        vu_vv_inst::wrap_vrf_index(
                            param.vrf_wt_index.vrf_wt_p0_idx, chunk));
                else if(param.prf_op.vrf_wt_p1_src == src_code)
                    vexe_vec_result[id][chunk] = mmio.read_vrf_entry(
                        vu_vv_inst::wrap_vrf_index(
                            param.vrf_wt_index.vrf_wt_p1_idx, chunk));
                void'(resolve_valu_operand(mmio, param, op.src1_sel,
                                           chunk, src1));
            end else begin
                if(op.opcode != `VU_OPCODE_VMV_V_V)
                    void'(resolve_valu_operand(mmio, param, op.src1_sel,
                                               chunk, src1));
                if(op.opcode != `VU_OPCODE_VFMV_V_F)
                    void'(resolve_vector_source(mmio, param, op.src2_sel,
                                                chunk, src2));
                if(is_macc_opcode(op.opcode))
                    void'(resolve_vector_source(mmio, param, op.src3_sel,
                                                chunk, src3));
            end

            active = vl - chunk * elems;
            if(active > elems)
                active = elems;
            for(int unsigned elem = 0; elem < active; elem++) begin
                global_elem = chunk * elems + elem;
                value1 = vu_vv_inst::get_elem(src1,
                                              param.type_vl.data_type, elem);
                value2 = vu_vv_inst::get_elem(src2,
                                              param.type_vl.data_type, elem);
                value3 = vu_vv_inst::get_elem(src3,
                                              param.type_vl.data_type, elem);

                case(op.opcode)
                    `VU_OPCODE_VFMV_V_F:
                        result = value1;
                    `VU_OPCODE_VFMV_S_F: begin
                        elem_imm = op.src2_sel[5:0];
                        if(global_elem == elem_imm)
                            result = value1;
                        else
                            result = vu_vv_inst::get_elem(
                                vexe_vec_result[id][chunk],
                                param.type_vl.data_type, elem);
                    end
                    `VU_OPCODE_VMV_V_V:
                        result = value2;
                    `VU_OPCODE_VFMERGE_VFM,
                    `VU_OPCODE_VFMERGE_VVM: begin
                        pred = predicate_bit(mmio, param,
                                             param.mask_op.valu0_mask_sel,
                                             global_elem);
                        result = pred ? value1 : value2;
                    end
                    default: begin
                        pred = predicate_bit(mmio, param,
                                             valu_mask_sel(param, id),
                                             global_elem);
                        if(!pred)
                            result = is_macc_opcode(op.opcode) ? value3 : value2;
                        else
                            result = vu_fp_alu(op.opcode, value1, value2,
                                               value3,
                                               param.type_vl.data_type,
                                               param.type_vl.round_mode);
                    end
                endcase
                vu_vv_inst::set_elem(vexe_vec_result[id][chunk],
                                     param.type_vl.data_type, elem, result);
            end
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] VALU%0d chunk=%0d opcode=%02h elems=%0d\n",
                    id, chunk, op.opcode, active);
        end
        vexe_vec_valid[id] = 1'b1;
    endfunction : execute_valu

    function automatic bit can_execute_vsfu(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vsfu_id
    );
        bit [7:0] opcode;
        bit [7:0] src_sel;

        if(vsfu_id == 0) begin
            opcode = param.vsfu_op.vsfu0_opcode;
            src_sel = param.vsfu_op.vsfu0_src1_sel;
        end else begin
            opcode = param.vsfu_op.vsfu1_opcode;
            src_sel = param.vsfu_op.vsfu1_src1_sel;
        end
        if(opcode == 0 || !vsfu_opcode_supported(opcode))
            return 1'b1;
        return vector_source_ready(src_sel);
    endfunction : can_execute_vsfu

    function automatic void execute_vsfu(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vsfu_id,
        input int unsigned vl
    );
        vu_vec_chunk_t src;
        bit [7:0] opcode;
        bit [7:0] src_sel;
        bit [1:0] mask_sel;
        bit [31:0] value;
        bit [31:0] result;
        int unsigned id;
        int unsigned elems;
        int unsigned chunks;
        int unsigned active;
        int unsigned global_elem;

        id = 3 + vsfu_id;
        vexe_done[id] = 1'b1;
        if(vsfu_id == 0) begin
            opcode = param.vsfu_op.vsfu0_opcode;
            src_sel = param.vsfu_op.vsfu0_src1_sel;
            mask_sel = param.mask_op.vsfu0_mask_sel;
        end else begin
            opcode = param.vsfu_op.vsfu1_opcode;
            src_sel = param.vsfu_op.vsfu1_src1_sel;
            mask_sel = param.mask_op.vsfu1_mask_sel;
        end

        if(opcode == 0) begin
            if(log_fd != 0)
                $fwrite(log_fd, "[VU_INST] VSFU%0d opcode=00 NOP\n", vsfu_id);
            return;
        end
        if(!vsfu_opcode_supported(opcode)) begin
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] VSFU%0d opcode=%02h reserved: NOP\n",
                    vsfu_id, opcode);
            return;
        end

        elems = elem_count_per_entry(param.type_vl.data_type);
        chunks = vector_chunk_count(vl, param.type_vl.data_type);
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
            void'(resolve_vector_source(mmio, param, src_sel, chunk, src));
            vexe_vec_result[id][chunk] = '0;
            active = vl - chunk * elems;
            if(active > elems)
                active = elems;
            for(int unsigned elem = 0; elem < active; elem++) begin
                global_elem = chunk * elems + elem;
                value = vu_vv_inst::get_elem(src, param.type_vl.data_type, elem);
                if(predicate_bit(mmio, param, mask_sel, global_elem))
                    result = vu_fp_vsfu(opcode, value,
                                        param.type_vl.data_type,
                                        param.type_vl.round_mode);
                else
                    result = value;
                vu_vv_inst::set_elem(vexe_vec_result[id][chunk],
                                     param.type_vl.data_type, elem, result);
            end
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] VSFU%0d chunk=%0d opcode=%02h elems=%0d%s\n",
                    vsfu_id, chunk, opcode, active,
                    opcode == `VU_OPCODE_VFCUSTOM_V ?
                        " (identity fallback: coefficients undefined)" : "");
        end
        vexe_vec_valid[id] = 1'b1;
    endfunction : execute_vsfu

    function automatic void execute_vexe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        for(int pass = 0; pass < 5; pass++) begin
            for(int id = 0; id < 3; id++)
                if(!vexe_done[id] && can_execute_valu(param, id))
                    execute_valu(mmio, param, id, vl);
            for(int vsfu_id = 0; vsfu_id < 2; vsfu_id++)
                if(!vexe_done[3+vsfu_id] &&
                   can_execute_vsfu(param, vsfu_id))
                    execute_vsfu(mmio, param, vsfu_id, vl);
        end

        for(int id = 0; id < 5; id++) begin
            if(!vexe_done[id]) begin
                vexe_done[id] = 1'b1;
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] VEXE%0d not executed: unresolved source dependency\n",
                        id);
            end
            if(vexe_vec_valid[id]) begin
                if(id < 3)
                    mmio.set_valu_bypass(id, vexe_vec_result[id][0]);
                else
                    mmio.set_vsfu_bypass(id-3, vexe_vec_result[id][0]);
            end
        end
    endfunction : execute_vexe

    function automatic bit resolve_mask_source_bit(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        input int unsigned elem
    );
        case(src_sel)
            `VU_SRC_LU: return lu_mask_valid && lu_mask_result[elem];
            `VU_SRC_VALU0: return valu0_mask_valid && valu0_mask_result[elem];
            `VU_SRC_MRF_P0: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p0_idx, elem);
            `VU_SRC_MRF_P1: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p1_idx, elem);
            default: return 1'b0;
        endcase
    endfunction : resolve_mask_source_bit

    function automatic bit resolve_index_vector(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        output vu_vec_chunk_t data
    );
        data = '0;
        case(src_sel)
            `VU_SRC_VALU1: begin
                if(vexe_vec_valid[1]) begin
                    data = vexe_vec_result[1][0];
                    return 1'b1;
                end
                return 1'b0;
            end
            `VU_SRC_VRF_P0: begin
                data = mmio.read_vrf_entry(param.vrf_rd_index.vrf_rd_p0_idx);
                return 1'b1;
            end
            `VU_SRC_VRF_P1: begin
                data = mmio.read_vrf_entry(param.vrf_rd_index.vrf_rd_p1_idx);
                return 1'b1;
            end
            default: return 1'b0;
        endcase
    endfunction : resolve_index_vector

    function automatic void execute_mexe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        bit src1;
        bit src2;
        bit [7:0] opcode;
        bit [31:0] count;
        int first;
        vu_vec_chunk_t indices;
        int index;

        opcode = param.mexe_op.opcode;
        if(opcode == 0) begin
            if(log_fd != 0)
                $fwrite(log_fd, "[VU_INST] MEXE opcode=00 NOP\n");
            return;
        end

        count = 0;
        first = -1;
        for(int unsigned elem = 0; elem < vl; elem++) begin
            src1 = resolve_mask_source_bit(mmio, param,
                                           param.mexe_op.src1_sel, elem);
            if(src1) begin
                count++;
                if(first < 0)
                    first = elem;
            end
        end

        case(opcode)
            `VU_OPCODE_VCPOP_M: begin
                mexe_scalar_result = count;
                mexe_scalar_valid = 1'b1;
            end
            `VU_OPCODE_VFIRST_M: begin
                mexe_scalar_result = first;
                mexe_scalar_valid = 1'b1;
            end
            `VU_OPCODE_VMAND_MM,
            `VU_OPCODE_VMNAND_MM,
            `VU_OPCODE_VMANDN_MM,
            `VU_OPCODE_VMXOR_MM,
            `VU_OPCODE_VMOR_MM,
            `VU_OPCODE_VMNOR_MM,
            `VU_OPCODE_VMORN_MM,
            `VU_OPCODE_VMXNOR_MM: begin
                for(int unsigned elem = 0; elem < vl; elem++) begin
                    src1 = resolve_mask_source_bit(mmio, param,
                                                   param.mexe_op.src1_sel,
                                                   elem);
                    src2 = resolve_mask_source_bit(mmio, param,
                                                   param.mexe_op.src2_sel,
                                                   elem);
                    case(opcode)
                        `VU_OPCODE_VMAND_MM:  mexe_mask_result[elem] = src2 & src1;
                        `VU_OPCODE_VMNAND_MM: mexe_mask_result[elem] = ~(src2 & src1);
                        `VU_OPCODE_VMANDN_MM: mexe_mask_result[elem] = src2 & ~src1;
                        `VU_OPCODE_VMXOR_MM:  mexe_mask_result[elem] = src2 ^ src1;
                        `VU_OPCODE_VMOR_MM:   mexe_mask_result[elem] = src2 | src1;
                        `VU_OPCODE_VMNOR_MM:  mexe_mask_result[elem] = ~(src2 | src1);
                        `VU_OPCODE_VMORN_MM:  mexe_mask_result[elem] = src2 | ~src1;
                        default:              mexe_mask_result[elem] = ~(src2 ^ src1);
                    endcase
                end
                mexe_mask_valid = 1'b1;
            end
            `VU_OPCODE_VMSBF_M,
            `VU_OPCODE_VMSIF_M,
            `VU_OPCODE_VMSOF_M: begin
                for(int unsigned elem = 0; elem < vl; elem++) begin
                    case(opcode)
                        `VU_OPCODE_VMSBF_M:
                            mexe_mask_result[elem] = first < 0 || elem < first;
                        `VU_OPCODE_VMSIF_M:
                            mexe_mask_result[elem] = first < 0 || elem <= first;
                        default:
                            mexe_mask_result[elem] = first >= 0 && elem == first;
                    endcase
                end
                mexe_mask_valid = 1'b1;
            end
            `VU_OPCODE_VMIUSET_MV,
            `VU_OPCODE_VMISET_MV: begin
                for(int unsigned elem = 0; elem < vl; elem++)
                    mexe_mask_result[elem] = resolve_mask_source_bit(
                        mmio, param, param.mexe_op.src1_sel, elem);
                if(resolve_index_vector(mmio, param,
                                        param.mexe_op.src2_sel, indices)) begin
                    for(int slot = 0; slot < 16; slot++) begin
                        index = $signed(indices[512 + slot*16 +: 16]);
                        if(index >= 0 && index < vl)
                            mexe_mask_result[index] =
                                opcode == `VU_OPCODE_VMISET_MV;
                    end
                end
                mexe_mask_valid = 1'b1;
            end
            default: begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] MEXE opcode=%02h reserved: NOP\n", opcode);
                return;
            end
        endcase

        if(log_fd != 0) begin
            if(mexe_scalar_valid)
                $fwrite(log_fd,
                    "[VU_INST] MEXE opcode=%02h scalar=%08h\n",
                    opcode, mexe_scalar_result);
            else
                $fwrite(log_fd,
                    "[VU_INST] MEXE opcode=%02h mask-result vl=%0d\n",
                    opcode, vl);
        end
    endfunction : execute_mexe

    function automatic bit [7:0] sexe_opcode(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned slot
    );
        case(slot)
            0: return param.sexe0_op.opcode;
            1: return param.sexe1_op.opcode;
            default: return param.sexe2_op.opcode;
        endcase
    endfunction : sexe_opcode

    function automatic bit [7:0] sexe_src1(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned slot
    );
        case(slot)
            0: return param.sexe0_op.src1_sel;
            1: return param.sexe1_op.src1_sel;
            default: return param.sexe2_op.src1_sel;
        endcase
    endfunction : sexe_src1

    function automatic bit [7:0] sexe_src2(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned slot
    );
        case(slot)
            0: return param.sexe0_op.src2_sel;
            1: return param.sexe1_op.src2_sel;
            default: return param.sexe2_op.src2_sel;
        endcase
    endfunction : sexe_src2

    function automatic void execute_sexe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param
    );
        bit [7:0] opcode;
        bit [7:0] src1_sel;
        bit [7:0] src2_sel;
        bit [31:0] src1;
        bit [31:0] src2;

        for(int slot = 0; slot < 3; slot++) begin
            opcode = sexe_opcode(param, slot);
            if(opcode == 0) begin
                if(log_fd != 0)
                    $fwrite(log_fd, "[VU_INST] SEXE%0d opcode=00 NOP\n", slot);
                continue;
            end
            if(opcode > `VU_OPCODE_FRCP_S) begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] SEXE%0d opcode=%02h reserved: NOP\n",
                        slot, opcode);
                continue;
            end
            src1_sel = sexe_src1(param, slot);
            src2_sel = sexe_src2(param, slot);
            if(!resolve_scalar_source(mmio, param, src1_sel, src1)) begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] SEXE%0d not executed: invalid src1=%02h\n",
                        slot, src1_sel);
                continue;
            end
            src2 = '0;
            if(opcode <= `VU_OPCODE_FDIV_S &&
               !resolve_scalar_source(mmio, param, src2_sel, src2)) begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] SEXE%0d not executed: invalid src2=%02h\n",
                        slot, src2_sel);
                continue;
            end
            sexe_result[slot] = vu_fp_sexe(opcode, src1, src2);
            sexe_valid[slot] = 1'b1;
            if(log_fd != 0)
                $fwrite(log_fd,
                    "[VU_INST] SEXE%0d opcode=%02h result=%08h\n",
                    slot, opcode, sexe_result[slot]);
        end
    endfunction : execute_sexe

    function automatic bit resolve_su_vector(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        input int unsigned chunk,
        output vu_vec_chunk_t data
    );
        return resolve_vector_source(mmio, param, src_sel, chunk, data);
    endfunction : resolve_su_vector

    function automatic bit resolve_su_mask_bit(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src_sel,
        input int unsigned elem
    );
        case(src_sel)
            `VU_SRC_MEXE: return mexe_mask_valid && mexe_mask_result[elem];
            default: return resolve_mask_source_bit(mmio, param, src_sel, elem);
        endcase
    endfunction : resolve_su_mask_bit

    function automatic void execute_su(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        vu_vec_chunk_t src;
        bit [31:0] value;
        bit [31:0] raw;
        bit [31:0] scalar;
        bit [31:0] addr;
        int unsigned elems;
        int unsigned chunks;
        int unsigned bytes;

        if(param.su_op.opcode == 0)
            return;

        case(param.su_op.opcode)
            `VU_OPCODE_LDST_FP8E4M3,
            `VU_OPCODE_LDST_MXFP8,
            `VU_OPCODE_LDST_BF16,
            `VU_OPCODE_LDST_FP32: begin
                elems = elem_count_per_entry(param.type_vl.data_type);
                chunks = vector_chunk_count(vl, param.type_vl.data_type);
                for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
                    if(!resolve_su_vector(mmio, param, param.su_op.src_sel,
                                          chunk, src))
                        return;
                    for(int unsigned elem = 0; elem < elems; elem++) begin
                        if(chunk * elems + elem >= vl)
                            break;
                        value = vu_vv_inst::get_elem(src,
                                                     param.type_vl.data_type,
                                                     elem);
                        raw = vu_store_convert(param.su_op.opcode, value,
                                               param.type_vl.data_type,
                                               param.type_vl.round_mode);
                        case(param.su_op.opcode)
                            `VU_OPCODE_LDST_FP8E4M3,
                            `VU_OPCODE_LDST_MXFP8: begin
                                addr = param.st_addr.cm_addr +
                                       chunk * elems + elem;
                                write_cm(dsa_mem, addr, 2'd0, raw);
                            end
                            `VU_OPCODE_LDST_BF16: begin
                                addr = param.st_addr.cm_addr +
                                       (chunk * elems + elem) * 2;
                                write_cm(dsa_mem, addr, 2'd1, raw);
                            end
                            default: begin
                                addr = param.st_addr.cm_addr +
                                       (chunk * elems + elem) * 4;
                                write_cm(dsa_mem, addr, 2'd2, raw);
                            end
                        endcase
                    end
                end
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] SU opcode=%02h vl=%0d vector-stored%s\n",
                        param.su_op.opcode, vl,
                        param.su_op.opcode == `VU_OPCODE_LDST_MXFP8 ?
                            " (MXFP8 scale=1 fallback)" : "");
            end

            `VU_OPCODE_LDST_MASK: begin
                bytes = vl / 8;
                for(int unsigned byte_idx = 0; byte_idx < bytes; byte_idx++) begin
                    raw = '0;
                    for(int unsigned bit_idx = 0; bit_idx < 8; bit_idx++)
                        raw[bit_idx] = resolve_su_mask_bit(
                            mmio, param, param.su_op.src_sel,
                            byte_idx * 8 + bit_idx);
                    write_cm(dsa_mem,
                             param.st_addr.cm_addr + byte_idx, 2'd0, raw);
                end
                if(log_fd != 0)
                    $fwrite(log_fd, "[VU_INST] SU st.mask vl=%0d\n", vl);
            end

            `VU_OPCODE_LDST_SCALAR: begin
                if(resolve_scalar_source(mmio, param,
                                         param.su_op.src_sel, scalar))
                    write_cm(dsa_mem, param.st_addr.cm_addr, 2'd2,
                             scalar);
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] SU st.s.fp32 value=%08h\n", scalar);
            end

            default: begin
                if(log_fd != 0)
                    $fwrite(log_fd,
                        "[VU_INST] SU opcode=%02h reserved: NOP\n",
                        param.su_op.opcode);
            end
        endcase
    endfunction : execute_su

    function automatic void write_vector_result(
        input vu_mmio_set mmio,
        input int unsigned start_idx,
        input int unsigned unit_id,
        input int unsigned chunks
    );
        for(int unsigned chunk = 0; chunk < chunks; chunk++)
            mmio.write_vrf_entry(
                vu_vv_inst::wrap_vrf_index(start_idx, chunk),
                vexe_vec_result[unit_id][chunk]
            );
    endfunction : write_vector_result

    function automatic void writebacks(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        int unsigned chunks;
        int unsigned vector_chunks;
        bit [7:0] src;

        vector_chunks = vector_chunk_count(vl, param.type_vl.data_type);

        // VRF write ports.
        for(int port = 0; port < 2; port++) begin
            if(port == 0)
                src = param.prf_op.vrf_wt_p0_src;
            else
                src = param.prf_op.vrf_wt_p1_src;

            if(src == `VU_SRC_LU && lu_vec_valid) begin
                for(int unsigned chunk = 0; chunk < vector_chunks; chunk++)
                    mmio.write_vrf_entry(
                        vu_vv_inst::wrap_vrf_index(
                            port == 0 ? param.vrf_wt_index.vrf_wt_p0_idx :
                                        param.vrf_wt_index.vrf_wt_p1_idx,
                            chunk),
                        lu_vec_result[chunk]
                    );
            end else if(src inside {[`VU_SRC_VALU0:`VU_SRC_VSFU1]}) begin
                int id;
                id = vexe_src_id(src);
                if(id >= 0 && vexe_vec_valid[id]) begin
                    chunks = (id == 1 &&
                              is_topk_opcode(param.valu1_op.opcode)) ?
                             1 : vector_chunks;
                    write_vector_result(
                        mmio,
                        port == 0 ? param.vrf_wt_index.vrf_wt_p0_idx :
                                    param.vrf_wt_index.vrf_wt_p1_idx,
                        id,
                        chunks
                    );
                end
            end
        end

        // MRF write port.
        if(param.prf_op.mrf_wt_src == `VU_SRC_LU && lu_mask_valid)
            for(int unsigned elem = 0; elem < vl; elem++)
                mmio.write_mrf_bit(param.mrf_wt_index.mrf_wt_idx,
                                   elem, lu_mask_result[elem]);
        else if(param.prf_op.mrf_wt_src == `VU_SRC_VALU0 &&
                valu0_mask_valid)
            for(int unsigned elem = 0; elem < vl; elem++)
                mmio.write_mrf_bit(param.mrf_wt_index.mrf_wt_idx,
                                   elem, valu0_mask_result[elem]);
        else if(param.prf_op.mrf_wt_src == `VU_SRC_MEXE &&
                mexe_mask_valid)
            for(int unsigned elem = 0; elem < vl; elem++)
                mmio.write_mrf_bit(param.mrf_wt_index.mrf_wt_idx,
                                   elem, mexe_mask_result[elem]);

        // SRF virtual write ports p0..p5.
        if(param.prf_op.srf_wt_en[0] && lu_scalar_valid)
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p0_idx,
                                 lu_scalar_result);
        if(param.prf_op.srf_wt_en[1] && vexe_scalar_valid[1])
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p1_idx,
                                 vexe_scalar_result[1]);
        if(param.prf_op.srf_wt_en[2] && mexe_scalar_valid)
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p2_idx,
                                 mexe_scalar_result);
        if(param.prf_op.srf_wt_en[3] && sexe_valid[0])
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p3_idx,
                                 sexe_result[0]);
        if(param.prf_op.srf_wt_en[4] && sexe_valid[1])
            mmio.write_srf_entry(param.srf_wt_index_1.srf_wt_p4_idx,
                                 sexe_result[1]);
        if(param.prf_op.srf_wt_en[5] && sexe_valid[2])
            mmio.write_srf_entry(param.srf_wt_index_1.srf_wt_p5_idx,
                                 sexe_result[2]);
    endfunction : writebacks

    function void execute(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param
    );
        int unsigned vl;

        vl = param.type_vl.vl;
        if(vl == 0)
            vl = 1;
        if(vl > `VU_MAX_VL)
            vl = `VU_MAX_VL;

        clear_execution_state(vl);
        execute_lu(mmio, dsa_mem, param, vl);
        execute_vexe(mmio, param, vl);
        execute_mexe(mmio, param, vl);
        execute_sexe(mmio, param);

        // SU reads the pre-writeback RF state or the current bypass results.
        execute_su(mmio, dsa_mem, param, vl);
        writebacks(mmio, param, vl);
    endfunction : execute

    function void do_trigger(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem
    );
        vu_mmio_set::vu_exec_param_s param;

        if(!mmio.pop_trigger(param))
            return;
        execute(mmio, dsa_mem, param);
    endfunction : do_trigger

endclass : vu_inst_library
