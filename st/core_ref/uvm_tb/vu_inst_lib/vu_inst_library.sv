// Execution-unit split functional reference model.
// Include through the existing vu_inst_lib_pkg, after definitions/DPI/vu_vv_inst.
`ifndef VU_INST_LIBRARY_FULL_SPLIT_SV
`define VU_INST_LIBRARY_FULL_SPLIT_SV
`ifndef VU_EXECUTION_CONTEXT_SV
`define VU_EXECUTION_CONTEXT_SV

// Shared transient results, source routing and feature metadata.
// No instruction execution kernels live here. Not a macro queue or timing model.
class vu_execution_context;
    int log_fd = 0;

    // LU results share the same lifetime and routing context as other producers.
    vu_vec_chunk_t lu_vector_result[`VU_MAX_VEC_CHUNKS];
    bit lu_mask_result[`VU_MAX_VL];
    bit [31:0] lu_scalar_result;
    bit lu_vector_valid;
    bit lu_mask_valid;
    bit lu_scalar_valid;

    // Instruction features, populated from LU's catalogue during registration.
    // These describe the installed instruction objects and survive state clear.
    typedef struct packed {
        bit enabled;
        bit [7:0] src_sel;
    } lu_mask_feature_s;
    protected lu_mask_feature_s lu_mask_features[bit [7:0]];

    function void register_lu_mask_feature(
        input bit [7:0] opcode,
        input bit enabled,
        input bit [7:0] src_sel
    );
        lu_mask_features[opcode] = {enabled, src_sel};
    endfunction : register_lu_mask_feature

    function bit lu_uses_mask(input bit [7:0] opcode);
        if(!lu_mask_features.exists(opcode))
            return 1'b0;
        return lu_mask_features[opcode].enabled;
    endfunction : lu_uses_mask

    function bit [7:0] lu_mask_source(input bit [7:0] opcode);
        if(!lu_uses_mask(opcode))
            return 8'h00;
        return lu_mask_features[opcode].src_sel;
    endfunction : lu_mask_source

    function bit lu_mask_config_valid(input bit [7:0] opcode);
        return !lu_uses_mask(opcode) ||
               lu_mask_source(opcode) inside {`VU_SRC_MRF_P0, `VU_SRC_MRF_P1};
    endfunction : lu_mask_config_valid

    // VEXE slots: 0/1/2=VALU0/1/2, 3/4=VSFU0/1.
    vu_vec_chunk_t vexe_vec_result[5][`VU_MAX_VEC_CHUNKS];
    bit vexe_done[5];
    bit vexe_vec_valid[5];
    bit vexe_scalar_valid[5];
    bit [31:0] vexe_scalar_result[5];
    bit valu0_mask_result[`VU_MAX_VL];
    bit valu0_mask_valid;

    bit mexe_mask_result[`VU_MAX_VL];
    bit mexe_mask_valid;
    bit [31:0] mexe_scalar_result;
    bit mexe_scalar_valid;

    bit [31:0] sexe_result[3];
    bit sexe_valid[3];

    function void set_log(int fd);
        log_fd = fd;
    endfunction : set_log

    // Classify exactly once at a semantic output/input boundary. Callers omit
    // this helper for masked passthrough, moves, comparisons and empty reduce.
    // Scalars are always FP32; a BF16 vector element occupies value[15:0].
    function automatic bit [31:0] process_fp_result(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input bit [31:0] value,
        input bit data_type,
        input int unsigned unit,
        input bit report_nan,
        input bit allow_replace,
        input int replacement_data_type = -1
    );
        bit is_nan;
        bit is_inf;
        bit negative;
        bit replacement_bf16;
        bit [31:0] replacement;

        if(data_type) begin
            is_nan = value[14:7] == 8'hff && value[6:0] != 0;
            is_inf = value[14:0] == 15'h7f80;
            negative = value[15];
        end else begin
            is_nan = value[30:23] == 8'hff && value[22:0] != 0;
            is_inf = value[30:0] == 31'h7f800000;
            negative = value[31];
        end
        if(!param.type_vl.nan_inf_replace_en) begin
            if(report_nan && is_nan)
                mmio.report_error(`VU_ERR_NAN, unit);
            return value;
        end
        if(!allow_replace || !(is_nan || is_inf))
            return value;

        // Normally replacement bits use the actual output precision. A BF16
        // reduction instead reads the programmed low-16 BF16 pattern and then
        // expands it to its always-FP32 fd. The call site selects this explicitly.
        // Scalar SU keeps the default FP32 format, independent of TYPE_VL.
        replacement_bf16 = replacement_data_type < 0 ? data_type :
                           (replacement_data_type != 0);
        replacement = is_nan ? mmio.nan_replace_value_val : mmio.inf_replace_value_val;
        if(replacement_bf16)
            replacement = {16'h0, replacement[15:0]};
        if(is_inf && negative)
            replacement ^= replacement_bf16 ? 32'h00008000 : 32'h80000000;
        if(replacement_bf16 && !data_type)
            replacement = vu_bf16_to_fp32(replacement);
        else if(!replacement_bf16 && data_type)
            replacement = vu_fp32_to_bf16(replacement, param.type_vl.round_mode);
        // A programmed NaN/Inf replacement is not recursively reprocessed.
        mmio.note_replacement(is_nan);
        return replacement;
    endfunction : process_fp_result

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

    // Result kinds: 0=none, 1=vector, 2=mask, 3=scalar.
    static function automatic int lu_result_kind(input bit [7:0] opcode);
        case(opcode)
            `VU_OPCODE_LDST_FP8E4M3, `VU_OPCODE_LDST_MXFP8,
            `VU_OPCODE_LDST_BF16, `VU_OPCODE_LDST_FP32: return 1;
            `VU_OPCODE_LDST_MASK: return 2;
            `VU_OPCODE_LDST_SCALAR: return 3;
            default: return 0;
        endcase
    endfunction : lu_result_kind

    // Query only: the top-level checker reports CFG errors before execution.
    // Mask/scalar and reserved opcodes impose no LU VL/stride constraints.
    static function automatic bit lu_check_config(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        if(param.lu_op.opcode == `VU_OPCODE_LDST_MXFP8 && vl % 32 != 0)
            return 1'b0;
        return !(lu_result_kind(param.lu_op.opcode) == 1 &&
                 param.lu_op.stride_run != 0 &&
                 param.lu_op.stride_skip != 0 && vl % 32 != 0);
    endfunction : lu_check_config

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
            2: return opcode inside {[`VU_OPCODE_VMV_V_V:`VU_OPCODE_VFSLIDE1DOWN_VF]};
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
            `VU_SRC_LU: return lu_vector_valid;
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
                if(!lu_vector_valid)
                    return 1'b0;
                data = lu_vector_result[chunk];
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
        input bit [7:0] mask_sel,
        input int unsigned global_elem
    );
        case(mask_sel)
            8'h00: return 1'b1;
            `VU_SRC_LU: return lu_mask_valid && lu_mask_result[global_elem];
            `VU_SRC_MRF_P0: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p0_idx, global_elem,
                param.type_vl.data_type);
            `VU_SRC_MRF_P1: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p1_idx, global_elem,
                param.type_vl.data_type);
            default: return 1'b0;
        endcase
    endfunction : predicate_bit

    function automatic bit [7:0] valu_mask_sel(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id
    );
        case(id)
            0: return param.mask_op.valu0_mask_sel;
            1: return param.mask_op.valu1_mask_sel;
            default: return param.mask_op.valu2_mask_sel;
        endcase
    endfunction : valu_mask_sel

    // Preserve LU's active-range mask clearing and retained vector storage.
    function automatic void clear_lu_execution_state(input int unsigned vl);
        lu_vector_valid = 1'b0;
        lu_mask_valid = 1'b0;
        lu_scalar_valid = 1'b0;
        lu_scalar_result = '0;
        for(int unsigned elem = 0; elem < vl; elem++)
            lu_mask_result[elem] = 1'b0;
    endfunction : clear_lu_execution_state

    function automatic void clear_execution_state(input int unsigned vl);
        clear_lu_execution_state(vl);
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
            valu0_mask_result[elem] = 1'b0;
            mexe_mask_result[elem] = 1'b0;
        end
    endfunction : clear_execution_state

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
                param.mrf_rd_index.mrf_rd_p0_idx, elem, param.type_vl.data_type);
            `VU_SRC_MRF_P1: return mmio.read_mrf_bit(
                param.mrf_rd_index.mrf_rd_p1_idx, elem, param.type_vl.data_type);
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

    static function automatic bit scalar_valu_opcode(input bit [7:0] opcode);
        return opcode inside {8'h02, 8'h04, 8'h05, 8'h07, 8'h11, 8'h13,
            8'h20, 8'h21, 8'h25, 8'h26, 8'h31, 8'h33, 8'h35, 8'h37,
            8'h41, 8'h43, 8'h45, 8'h51, 8'h53, 8'h55, 8'h57, 8'h58,
            8'h59, 8'h61, 8'h70, 8'h71, 8'h72};
    endfunction : scalar_valu_opcode

    static function automatic bit single_valu_source(input bit [7:0] opcode);
        return opcode inside {[8'h20:8'h24]} || opcode == 8'h60 ||
               is_topk_opcode(opcode);
    endfunction : single_valu_source

    static function automatic bit masked_valu_opcode(input bit [7:0] opcode);
        return !(opcode inside {[8'h20:8'h26]});
    endfunction : masked_valu_opcode

    function automatic int source_kind(
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src
    );
        int id;
        bit [7:0] opcode;
        vu_valu_op_s op;

        if(src inside {`VU_SRC_VRF_P0, `VU_SRC_VRF_P1})
            return 1;
        if(src inside {`VU_SRC_MRF_P0, `VU_SRC_MRF_P1})
            return 2;
        if(is_srf_src(src))
            return 3;
        if(src == `VU_SRC_LU)
            return lu_result_kind(param.lu_op.opcode);
        id = vexe_src_id(src);
        if(id >= 0 && id < 3) begin
            op = get_valu_op(param, id);
            if(op.opcode == 0 || !valu_opcode_supported(id, op.opcode)) return 0;
            if(id == 0 && (is_compare_opcode(op.opcode) ||
                           op.opcode == `VU_OPCODE_VFCLASS_MV)) return 2;
            if(id == 1 && (is_reduction_opcode(op.opcode) ||
                           op.opcode == `VU_OPCODE_VFMV_F_S)) return 3;
            return 1;
        end
        if(id >= 3) begin
            if(id == 4 && param.type_vl.data_type) return 0;
            opcode = id == 3 ? param.vsfu_op.vsfu0_opcode :
                               param.vsfu_op.vsfu1_opcode;
            return opcode != 0 && vsfu_opcode_supported(opcode) ? 1 : 0;
        end
        if(src == `VU_SRC_MEXE) begin
            opcode = param.mexe_op.opcode;
            if(opcode inside {[8'h01:8'h08], [8'h12:8'h16]}) return 2;
            if(opcode inside {8'h10, 8'h11}) return 3;
            return 0;
        end
        if(src inside {[`VU_SRC_SEXE0:`VU_SRC_SEXE2]}) begin
            opcode = sexe_opcode(param, src - `VU_SRC_SEXE0);
            return opcode inside {[8'h01:8'h07]} ? 3 : 0;
        end
        return 0;
    endfunction : source_kind

    function automatic bit valid_vector_source(
        input vu_mmio_set::vu_exec_param_s param,
        input bit [7:0] src,
        input int consumer
    );
        return source_kind(param, src) == 1 &&
               src inside {`VU_SRC_LU, [`VU_SRC_VALU0:`VU_SRC_VSFU1],
                           `VU_SRC_VRF_P0, `VU_SRC_VRF_P1} &&
               (consumer < 0 || vexe_src_id(src) != consumer);
    endfunction : valid_vector_source
endclass : vu_execution_context
`endif // VU_EXECUTION_CONTEXT_SV
`include "lu_library.sv"
`include "valu_common_library.sv"
`include "valu0_library.sv"
`include "valu1_library.sv"
`include "valu2_library.sv"
`include "vsfu_library.sv"
`include "mexe_library.sv"
`include "sexe_library.sv"
`include "su_library.sv"
`ifndef VU_CONFIG_CHECKER_SV
`define VU_CONFIG_CHECKER_SV

// Cross-unit configuration/resource checks migrated without behavioral changes.
class vu_config_checker;
    protected vu_execution_context ctx;
    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    function automatic bit validate_config(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        vu_valu_op_s op[3];
        bit [7:0] sources[5][3];
        bit used[5][3];
        bit edges[5][5];
        int unsigned read_chunks[2];
        bit mrf_read[2];
        bit [7:0] masks[$];
        int mask_owners[$];
        int owner[3];
        int unsigned srf_indices[6];
        int unsigned write_start[2];
        int unsigned write_chunks[2];
        int unsigned chunks;
        bit [7:0] src;
        bit [7:0] opcode;
        bit [7:0] s1;
        bit [7:0] s2;
        bit unary;
        bit bad;
        int producer;
        int mask_port;
        int unsigned occupied;

        bad = param.type_vl.round_mode == 3'b111 || param.prf_op.srf_wt_en[7:6] != 0;
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type);
        foreach(sources[i,j]) begin sources[i][j] = 0; used[i][j] = 0; end
        foreach(edges[i,j]) edges[i][j] = 0;
        foreach(read_chunks[i]) begin read_chunks[i] = 0; mrf_read[i] = 0; end
        foreach(owner[i]) owner[i] = -1;
        // LU feature constraints use the shared metadata; report errors here.
        if(!ctx.lu_check_config(param, vl))
            bad = 1;
        // LU executes first, so only existing MRF ports can supply its mask.
        // Consumer 5 joins the same port-ownership/range checks used below.
        if(!ctx.lu_mask_config_valid(param.lu_op.opcode))
            bad = 1;
        else if(ctx.lu_uses_mask(param.lu_op.opcode)) begin
            masks.push_back(ctx.lu_mask_source(param.lu_op.opcode));
            mask_owners.push_back(5);
        end
        if(param.su_op.opcode == `VU_OPCODE_LDST_MXFP8 && vl % 32 != 0)
            bad = 1;
        if(param.su_op.opcode == `VU_OPCODE_LDST_MASK && vl % 8 != 0)
            bad = 1;
        if(param.valu2_op.opcode == `VU_OPCODE_VSWAP2_V && vl % 2 != 0)
            bad = 1;

        for(int id = 0; id < 3; id++) begin
            op[id] = ctx.get_valu_op(param, id);
            if(op[id].opcode == 0 || !ctx.valu_opcode_supported(id, op[id].opcode))
                continue;
            sources[id][0] = op[id].src1_sel;
            used[id][0] = 1;
            if(ctx.scalar_valu_opcode(op[id].opcode)) begin
                if(op[id].src1_sel != `VU_SRC_SRF_P1 + id)
                    bad = 1;
                used[id][0] = 0;
            end else if(!ctx.valid_vector_source(param, op[id].src1_sel, id))
                bad = 1;
            if(!ctx.single_valu_source(op[id].opcode)) begin
                sources[id][1] = op[id].src2_sel;
                used[id][1] = 1;
                if(!ctx.valid_vector_source(param, op[id].src2_sel, id)) bad = 1;
            end
            if(ctx.is_macc_opcode(op[id].opcode)) begin
                sources[id][2] = op[id].src3_sel;
                used[id][2] = 1;
                if(!ctx.valid_vector_source(param, op[id].src3_sel, id)) bad = 1;
            end
            if(ctx.masked_valu_opcode(op[id].opcode) && ctx.valu_mask_sel(param, id) != 0) begin
                src = ctx.valu_mask_sel(param, id);
                if(!(src inside {`VU_SRC_LU, `VU_SRC_MRF_P0, `VU_SRC_MRF_P1}) ||
                   ctx.source_kind(param, src) != 2) bad = 1;
                masks.push_back(src);
                mask_owners.push_back(id);
            end
        end
        for(int id = 3; id < 5; id++) begin
            if(id == 4 && param.type_vl.data_type) continue;
            opcode = id == 3 ? param.vsfu_op.vsfu0_opcode : param.vsfu_op.vsfu1_opcode;
            if(opcode == 0 || !ctx.vsfu_opcode_supported(opcode)) continue;
            src = id == 3 ? param.vsfu_op.vsfu0_src1_sel : param.vsfu_op.vsfu1_src1_sel;
            if(!ctx.valid_vector_source(param, src, id)) bad = 1;
            sources[id][0] = src;
            used[id][0] = 1;
        end
        foreach(sources[id,port]) begin
            if(!used[id][port]) continue;
            src = sources[id][port];
            producer = ctx.vexe_src_id(src);
            if(producer >= 0) edges[id][producer] = 1;
            if(src inside {`VU_SRC_VRF_P0, `VU_SRC_VRF_P1}) begin
                occupied = id == 1 && op[1].opcode == `VU_OPCODE_VFMV_F_S ? 1 : chunks;
                if(occupied > read_chunks[src - `VU_SRC_VRF_P0])
                    read_chunks[src - `VU_SRC_VRF_P0] = occupied;
            end
        end
        for(int k = 0; k < 5; k++)
            for(int i = 0; i < 5; i++)
                for(int j = 0; j < 5; j++)
                    edges[i][j] |= edges[i][k] && edges[k][j];
        for(int i = 0; i < 5; i++)
            if(edges[i][i]) bad = 1;

        opcode = param.mexe_op.opcode;
        if(opcode inside {[8'h01:8'h08], [8'h10:8'h16]}) begin
            src = param.mexe_op.src1_sel;
            if(!(src inside {`VU_SRC_LU, `VU_SRC_VALU0, `VU_SRC_MRF_P0, `VU_SRC_MRF_P1}) ||
               ctx.source_kind(param, src) != 2) bad = 1;
            masks.push_back(src); mask_owners.push_back(3);
            src = param.mexe_op.src2_sel;
            if(opcode inside {[8'h01:8'h08]}) begin
                if(!(src inside {`VU_SRC_LU, `VU_SRC_VALU0, `VU_SRC_MRF_P0, `VU_SRC_MRF_P1}) ||
                   ctx.source_kind(param, src) != 2) bad = 1;
                masks.push_back(src); mask_owners.push_back(3);
            end else if(opcode inside {8'h15, 8'h16}) begin
                if(src == `VU_SRC_VALU1) begin
                    if(!ctx.is_topk_opcode(param.valu1_op.opcode)) bad = 1;
                end else if(src inside {`VU_SRC_VRF_P0, `VU_SRC_VRF_P1}) begin
                    if(read_chunks[src - `VU_SRC_VRF_P0] == 0)
                        read_chunks[src - `VU_SRC_VRF_P0] = 1;
                end else bad = 1;
            end
        end
        for(int slot = 0; slot < 3; slot++) begin
            opcode = ctx.sexe_opcode(param, slot);
            if(!(opcode inside {[8'h01:8'h07]})) continue;
            s1 = ctx.sexe_src1(param, slot);
            s2 = ctx.sexe_src2(param, slot);
            unary = opcode >= `VU_OPCODE_FSQRT_S;
            if(slot == 0) begin
                if(!(s1 inside {`VU_SRC_LU, `VU_SRC_VALU1, `VU_SRC_SRF_P4})) bad = 1;
                if(!unary && !(s2 inside {`VU_SRC_LU, `VU_SRC_VALU1, `VU_SRC_SRF_P5})) bad = 1;
            end else begin
                if(!(s1 == `VU_SRC_LU || s1 == `VU_SRC_SEXE0 + slot - 1 ||
                     s1 == `VU_SRC_SRF_P5 + slot)) bad = 1;
                if(!unary && !(s2 == `VU_SRC_LU || s2 == `VU_SRC_SEXE0 + slot - 1 ||
                               s2 == `VU_SRC_SRF_P5 + slot)) bad = 1;
                if(s1 != `VU_SRC_SEXE0 + slot - 1 &&
                   (unary || s2 != `VU_SRC_SEXE0 + slot - 1)) bad = 1;
                if(!unary && ctx.is_srf_src(s1) && ctx.is_srf_src(s2)) bad = 1;
            end
            if(ctx.source_kind(param, s1) != 3 || (!unary && ctx.source_kind(param, s2) != 3)) bad = 1;
        end
        opcode = param.su_op.opcode;
        src = param.su_op.src_sel;
        if(opcode inside {[8'h01:8'h06]}) begin
            if(src == `VU_SRC_LU && opcode != param.lu_op.opcode) bad = 1;
            if(opcode <= 4) begin
                if(!ctx.valid_vector_source(param, src, -1)) bad = 1;
                if(src inside {`VU_SRC_VRF_P0, `VU_SRC_VRF_P1})
                    read_chunks[src - `VU_SRC_VRF_P0] = chunks;
            end else if(opcode == `VU_OPCODE_LDST_MASK) begin
                if(!(src inside {`VU_SRC_LU, `VU_SRC_VALU0, `VU_SRC_MEXE,
                                 `VU_SRC_MRF_P0, `VU_SRC_MRF_P1}) ||
                   ctx.source_kind(param, src) != 2) bad = 1;
                masks.push_back(src); mask_owners.push_back(4);
            end else if(!(src inside {`VU_SRC_LU, `VU_SRC_VALU1, `VU_SRC_MEXE,
                                      [`VU_SRC_SEXE0:`VU_SRC_SEXE2], `VU_SRC_SRF_P0}) ||
                        ctx.source_kind(param, src) != 3) bad = 1;
        end
        foreach(masks[i]) begin
            mask_port = -1;
            if(masks[i] == `VU_SRC_LU) mask_port = 2;
            else if(masks[i] inside {`VU_SRC_MRF_P0, `VU_SRC_MRF_P1})
                mask_port = masks[i] - `VU_SRC_MRF_P0;
            if(mask_port >= 0) begin
                if(owner[mask_port] >= 0 && owner[mask_port] != mask_owners[i]) bad = 1;
                owner[mask_port] = mask_owners[i];
                if(mask_port < 2) mrf_read[mask_port] = 1;
            end
        end
        for(int port = 0; port < 2; port++) begin
            src = port == 0 ? param.prf_op.vrf_wt_p0_src : param.prf_op.vrf_wt_p1_src;
            write_start[port] = port == 0 ? param.vrf_wt_index.vrf_wt_p0_idx[8:0] :
                                          param.vrf_wt_index.vrf_wt_p1_idx[8:0];
            write_chunks[port] = 0;
            if(src == 0) continue;
            if(!(src inside {[`VU_SRC_LU:`VU_SRC_VSFU1]}) || ctx.source_kind(param, src) != 1)
                bad = 1;
            write_chunks[port] = ((src == `VU_SRC_VALU1 && ctx.is_topk_opcode(param.valu1_op.opcode)) ||
                                  (src == `VU_SRC_VALU0 && param.valu0_op.opcode == `VU_OPCODE_VFMV_S_F)) ?
                                 1 : chunks;
        end
        if(write_chunks[0] != 0 && write_chunks[1] != 0) begin
            if(param.prf_op.vrf_wt_p0_src == param.prf_op.vrf_wt_p1_src) bad = 1;
            for(int unsigned i = 0; i < write_chunks[0]; i++)
                if(((write_start[0] + i + 512 - write_start[1]) % 512) < write_chunks[1])
                    bad = 1;
        end
        src = param.prf_op.mrf_wt_src;
        if(src != 0 && (!(src inside {`VU_SRC_LU, `VU_SRC_VALU0, `VU_SRC_MEXE}) ||
                        ctx.source_kind(param, src) != 2)) bad = 1;
        if(param.prf_op.srf_wt_en[0] && ctx.lu_result_kind(param.lu_op.opcode) != 3) bad = 1;
        if(param.prf_op.srf_wt_en[1] && ctx.source_kind(param, `VU_SRC_VALU1) != 3) bad = 1;
        if(param.prf_op.srf_wt_en[2] && ctx.source_kind(param, `VU_SRC_MEXE) != 3) bad = 1;
        for(int slot = 0; slot < 3; slot++)
            if(param.prf_op.srf_wt_en[3 + slot] && ctx.source_kind(param, `VU_SRC_SEXE0 + slot) != 3)
                bad = 1;
        srf_indices[0] = param.srf_wt_index_0.srf_wt_p0_idx[5:0];
        srf_indices[1] = param.srf_wt_index_0.srf_wt_p1_idx[5:0];
        srf_indices[2] = param.srf_wt_index_0.srf_wt_p2_idx[5:0];
        srf_indices[3] = param.srf_wt_index_0.srf_wt_p3_idx[5:0];
        srf_indices[4] = param.srf_wt_index_1.srf_wt_p4_idx[5:0];
        srf_indices[5] = param.srf_wt_index_1.srf_wt_p5_idx[5:0];
        for(int i = 0; i < 6; i++)
            for(int j = i + 1; j < 6; j++)
                if(param.prf_op.srf_wt_en[i] && param.prf_op.srf_wt_en[j] &&
                   srf_indices[i] == srf_indices[j]) bad = 1;
        if(bad) begin
            mmio.report_error(`VU_ERR_CFG, 0);
            return 1'b0;
        end
        for(int port = 0; port < 2; port++) begin
            occupied = port == 0 ? param.vrf_rd_index.vrf_rd_p0_idx[8:0] :
                                   param.vrf_rd_index.vrf_rd_p1_idx[8:0];
            if(occupied + read_chunks[port] > `VU_VRF_ENTRY_NUM ||
               write_start[port] + write_chunks[port] > `VU_VRF_ENTRY_NUM)
                mmio.report_error(`VU_ERR_RF_IDX, 0);
            occupied = port == 0 ? param.mrf_rd_index.mrf_rd_p0_idx[8:0] :
                                   param.mrf_rd_index.mrf_rd_p1_idx[8:0];
            if(mrf_read[port] && occupied + chunks > `VU_MRF_ENTRY_NUM)
                mmio.report_error(`VU_ERR_RF_IDX, 0);
        end
        if(param.prf_op.mrf_wt_src != 0 &&
           int'(param.mrf_wt_index.mrf_wt_idx[8:0]) + chunks > `VU_MRF_ENTRY_NUM)
            mmio.report_error(`VU_ERR_RF_IDX, 0);
        return 1'b1;
    endfunction : validate_config
endclass : vu_config_checker
`endif
`ifndef VU_WRITEBACK_LIBRARY_SV
`define VU_WRITEBACK_LIBRARY_SV

// Central PRF writeback, after SU; preserves masks, tails and wrapping.
class vu_writeback_library;
    protected vu_execution_context ctx;
    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    function automatic void write_vector_chunk(
        input vu_mmio_set mmio,
        input int unsigned start_idx,
        input int unsigned chunk,
        input vu_vec_chunk_t data,
        input bit data_type,
        input int unsigned active
    );
        vu_vec_chunk_t merged;
        int unsigned entry_idx;

        entry_idx = vu_vv_inst::wrap_vrf_index(start_idx, chunk);
        merged = mmio.read_vrf_entry(entry_idx);
        for(int unsigned elem = 0; elem < active; elem++)
            vu_vv_inst::set_elem(merged, data_type, elem,
                                 vu_vv_inst::get_elem(data, data_type, elem));
        mmio.write_vrf_entry(entry_idx, merged);
    endfunction : write_vector_chunk

    function automatic void write_vector_result(
        input vu_mmio_set mmio,
        input int unsigned start_idx,
        input int unsigned unit_id,
        input int unsigned chunks,
        input int unsigned vl,
        input bit data_type,
        input bit whole_entry
    );
        int unsigned elems;
        int unsigned active;

        elems = ctx.elem_count_per_entry(data_type);
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin
            active = whole_entry ? elems : vl - chunk * elems;
            if(active > elems)
                active = elems;
            write_vector_chunk(mmio, start_idx, chunk,
                               ctx.vexe_vec_result[unit_id][chunk], data_type, active);
        end
    endfunction : write_vector_result

    function automatic void writebacks(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        int unsigned chunks;
        int unsigned vector_chunks;
        int unsigned elems;
        int unsigned active;
        bit whole_entry;
        bit [7:0] src;

        vector_chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type);
        elems = ctx.elem_count_per_entry(param.type_vl.data_type);

        // VRF write ports.
        for(int port = 0; port < 2; port++) begin
            if(port == 0)
                src = param.prf_op.vrf_wt_p0_src;
            else
                src = param.prf_op.vrf_wt_p1_src;

            if(src == `VU_SRC_LU && ctx.lu_vector_valid) begin
                for(int unsigned chunk = 0; chunk < vector_chunks; chunk++) begin
                    active = vl - chunk * elems;
                    if(active > elems)
                        active = elems;
                    write_vector_chunk(mmio,
                        port == 0 ? param.vrf_wt_index.vrf_wt_p0_idx :
                                    param.vrf_wt_index.vrf_wt_p1_idx,
                        chunk, ctx.lu_vector_result[chunk], param.type_vl.data_type,
                        active);
                end
            end else if(src inside {[`VU_SRC_VALU0:`VU_SRC_VSFU1]}) begin
                int id;
                id = ctx.vexe_src_id(src);
                if(id >= 0 && ctx.vexe_vec_valid[id]) begin
                    whole_entry = (id == 1 &&
                                   ctx.is_topk_opcode(param.valu1_op.opcode)) ||
                                  (id == 0 && param.valu0_op.opcode ==
                                              `VU_OPCODE_VFMV_S_F);
                    chunks = whole_entry ? 1 : vector_chunks;
                    write_vector_result(
                        mmio,
                        port == 0 ? param.vrf_wt_index.vrf_wt_p0_idx :
                                    param.vrf_wt_index.vrf_wt_p1_idx,
                        id, chunks, vl, param.type_vl.data_type, whole_entry
                    );
                end
            end
        end

        // MRF write port.
        if(param.prf_op.mrf_wt_src == `VU_SRC_LU && ctx.lu_mask_valid)
            for(int unsigned elem = 0; elem < vl; elem++)
                mmio.write_mrf_bit(param.mrf_wt_index.mrf_wt_idx,
                                   elem, ctx.lu_mask_result[elem], param.type_vl.data_type);
        else if(param.prf_op.mrf_wt_src == `VU_SRC_VALU0 &&
                ctx.valu0_mask_valid)
            for(int unsigned elem = 0; elem < vl; elem++)
                mmio.write_mrf_bit(param.mrf_wt_index.mrf_wt_idx,
                                   elem, ctx.valu0_mask_result[elem], param.type_vl.data_type);
        else if(param.prf_op.mrf_wt_src == `VU_SRC_MEXE &&
                ctx.mexe_mask_valid)
            for(int unsigned elem = 0; elem < vl; elem++)
                mmio.write_mrf_bit(param.mrf_wt_index.mrf_wt_idx,
                                   elem, ctx.mexe_mask_result[elem], param.type_vl.data_type);

        // SRF virtual write ports p0..p5.
        if(param.prf_op.srf_wt_en[0] && ctx.lu_scalar_valid)
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p0_idx,
                                 ctx.lu_scalar_result);
        if(param.prf_op.srf_wt_en[1] && ctx.vexe_scalar_valid[1])
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p1_idx,
                                 ctx.vexe_scalar_result[1]);
        if(param.prf_op.srf_wt_en[2] && ctx.mexe_scalar_valid)
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p2_idx,
                                 ctx.mexe_scalar_result);
        if(param.prf_op.srf_wt_en[3] && ctx.sexe_valid[0])
            mmio.write_srf_entry(param.srf_wt_index_0.srf_wt_p3_idx,
                                 ctx.sexe_result[0]);
        if(param.prf_op.srf_wt_en[4] && ctx.sexe_valid[1])
            mmio.write_srf_entry(param.srf_wt_index_1.srf_wt_p4_idx,
                                 ctx.sexe_result[1]);
        if(param.prf_op.srf_wt_en[5] && ctx.sexe_valid[2])
            mmio.write_srf_entry(param.srf_wt_index_1.srf_wt_p5_idx,
                                 ctx.sexe_result[2]);
    endfunction : writebacks
endclass : vu_writeback_library
`endif

// Top-level lifecycle and intra-macro dependency scheduling only.
// Macros complete synchronously; this is not a cycle/ISQ/overlap model.
// Individual instruction kernels belong to the corresponding unit libraries.
class vu_inst_library;
    protected vu_execution_context ctx;
    protected lu_library lu_lib;
    protected valu_common_library valu_lib[3];
    protected vsfu_library vsfu_lib;
    protected mexe_library mexe_lib;
    protected sexe_library sexe_lib;
    protected su_library su_lib;
    protected vu_config_checker cfg_checker;
    protected vu_writeback_library writeback_lib;

    function new();
        valu0_library valu0;
        valu1_library valu1;
        valu2_library valu2;
        ctx = new();
        lu_lib = new(ctx);
        valu0 = new(ctx);
        valu1 = new(ctx);
        valu2 = new(ctx);
        valu_lib[0] = valu0;
        valu_lib[1] = valu1;
        valu_lib[2] = valu2;
        vsfu_lib = new(ctx);
        mexe_lib = new(ctx);
        sexe_lib = new(ctx);
        su_lib = new(ctx);
        cfg_checker = new(ctx);
        writeback_lib = new(ctx);
    endfunction : new

    function void set_log(input int fd);
        ctx.set_log(fd);
    endfunction : set_log

    function automatic void execute_vexe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        if(param.type_vl.data_type)
            ctx.vexe_done[4] = 1'b1;
        for(int pass = 0; pass < 5; pass++) begin
            for(int id = 0; id < 3; id++)
                if(!ctx.vexe_done[id] && valu_lib[id].can_execute(param, id))
                    valu_lib[id].execute(mmio, param, id, vl);
            for(int vsfu_id = 0; vsfu_id < 2; vsfu_id++)
                if(!ctx.vexe_done[3+vsfu_id] &&
                   vsfu_lib.can_execute(param, vsfu_id))
                    vsfu_lib.execute(mmio, param, vsfu_id, vl);
        end

        for(int id = 0; id < 5; id++) begin
            if(!ctx.vexe_done[id]) begin
                ctx.vexe_done[id] = 1'b1;
                if(ctx.log_fd != 0)
                    $fwrite(ctx.log_fd,
                        "[VU_INST] VEXE%0d not executed: unresolved source dependency\n",
                        id);
            end
            if(ctx.vexe_vec_valid[id]) begin
                if(id < 3)
                    mmio.set_valu_bypass(id, ctx.vexe_vec_result[id][0]);
                else
                    mmio.set_vsfu_bypass(id-3, ctx.vexe_vec_result[id][0]);
            end
        end
    endfunction : execute_vexe

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

        mmio.begin_macro(param);
        if(!cfg_checker.validate_config(mmio, param, vl)) begin
            mmio.end_macro();
            return;
        end

        ctx.clear_execution_state(vl);
        lu_lib.execute(mmio, dsa_mem, param, vl);
        execute_vexe(mmio, param, vl);
        mexe_lib.execute(mmio, param, vl);
        sexe_lib.execute(mmio, param);

        // Preserve the original sequence: SU reads before RF writeback.
        su_lib.execute(mmio, dsa_mem, param, vl);
        writeback_lib.writebacks(mmio, param, vl);
        mmio.end_macro();
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

`endif // VU_INST_LIBRARY_FULL_SPLIT_SV
