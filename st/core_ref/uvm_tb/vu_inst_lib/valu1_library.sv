// VALU1-only instructions. Include after valu_common_library.sv.
`ifndef VU_VALU1_LIBRARY_SV
`define VU_VALU1_LIBRARY_SV

// Class definitions and opcode registration use the SAME instruction catalogue.
// This structural refactor preserves the deployed algorithms, state and logs.

// ============================================================================
// 1. Existing shared interface
// ============================================================================
// valu_inst_base and valu_common_library remain in valu_common_library.sv.
// Each instruction receives vu_execution_context via new(shared) and implements
// inst_exe(mmio, param, id, vl); no new context or common-library helper is needed.

// ============================================================================
// 2. Complete instruction-family templates: class / sources / execution / result
// ============================================================================
// CLASS_NAME and OPCODE identify each catalogue row. OPCODE is consumed by the
// registry; execution logs retain op.opcode from the original parameter object.

// Sum reduction: scalar FP32 initial value; masked elements are visited in the
// original chunk/element order, with BF16 inputs expanded before high-precision
// DPI accumulation. Finish runs even with no active elements; keep the initial
// bits in that case. Rounding is performed only by the existing sum DPI.
`define VU_VALU1_SUM_INST(CLASS_NAME, OPCODE) \
class CLASS_NAME extends valu_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
 \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned id, \
        input int unsigned vl \
    ); \
        vu_valu_op_s op; \
        vu_vec_chunk_t src2; \
        bit [31:0] accum; \
        bit [31:0] value; \
        chandle sum; \
        bit any_active; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
 \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        void'(ctx.resolve_scalar_source(mmio, param, op.src1_sel, accum)); \
        any_active = 1'b0; \
        sum = vu_sum_create(accum); \
 \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            void'(ctx.resolve_vector_source(mmio, param, op.src2_sel, chunk, src2)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                if(!ctx.predicate_bit(mmio, param, \
                                      param.mask_op.valu1_mask_sel, \
                                      chunk * elems + elem)) \
                    continue; \
                value = vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem); \
                if(param.type_vl.data_type) \
                    value = vu_bf16_to_fp32(value); \
                any_active = 1'b1; \
                vu_sum_add(sum, value); \
            end \
        end \
        /* Finish also releases the DPI accumulator when no elements are active. */ \
        value = vu_sum_finish(sum, param.type_vl.round_mode); \
        if(any_active) \
            accum = ctx.process_fp_result(mmio, param, value, \
                1'b0, 4, 1'b1, 1'b1, int'(param.type_vl.data_type)); \
        ctx.vexe_scalar_result[1] = accum; \
        ctx.vexe_scalar_valid[1] = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] VALU1 reduction opcode=%02h vl=%0d result=%08h\n", \
                op.opcode, vl, accum); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Extrema reduction: ALU_OPCODE selects the existing FP32 max/min DPI operation.
// Preserve source order, the VALU1 predicate and DPI data_type=0/round_mode=0.
`define VU_VALU1_EXTREMA_INST(CLASS_NAME, OPCODE, ALU_OPCODE) \
class CLASS_NAME extends valu_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned id, \
        input int unsigned vl \
    ); \
        vu_valu_op_s op; \
        vu_vec_chunk_t src2; \
        bit [31:0] accum; \
        bit [31:0] value; \
        bit any_active; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        void'(ctx.resolve_scalar_source(mmio, param, op.src1_sel, accum)); \
        any_active = 1'b0; \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            void'(ctx.resolve_vector_source(mmio, param, op.src2_sel, chunk, src2)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                if(!ctx.predicate_bit(mmio, param, \
                                      param.mask_op.valu1_mask_sel, \
                                      chunk * elems + elem)) \
                    continue; \
                value = vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem); \
                if(param.type_vl.data_type) \
                    value = vu_bf16_to_fp32(value); \
                any_active = 1'b1; \
                accum = vu_fp_alu(ALU_OPCODE, accum, value, 0, 0, 0); \
            end \
        end \
        if(any_active) \
            accum = ctx.process_fp_result(mmio, param, accum, \
                1'b0, 4, 1'b1, 1'b1, int'(param.type_vl.data_type)); \
        ctx.vexe_scalar_result[1] = accum; \
        ctx.vexe_scalar_valid[1] = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] VALU1 reduction opcode=%02h vl=%0d result=%08h\n", \
                op.opcode, vl, accum); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// TopK: COMPARE_OPCODE selects the strict comparison in the original operand
// order (best_value, candidate). Keep equal/NaN handling in the existing DPI.
// The family fixes 16 slots: values use the current data width, indices begin at
// bit 512 and hold global element indices; missing values are zero, indices ffff.
`define VU_VALU1_TOPK_INST(CLASS_NAME, OPCODE, COMPARE_OPCODE) \
class CLASS_NAME extends valu_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned id, \
        input int unsigned vl \
    ); \
        vu_valu_op_s op; \
        vu_vec_chunk_t src; \
        bit [31:0] best_value[16]; \
        int best_index[16]; \
        bit best_valid[16]; \
        bit [31:0] candidate; \
        int insert_at; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        bit better; \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        ctx.vexe_vec_result[1][0] = '0; \
        for(int slot = 0; slot < 16; slot++) begin \
            best_value[slot] = '0; \
            best_index[slot] = -1; \
            best_valid[slot] = 1'b0; \
        end \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            void'(ctx.resolve_vector_source(mmio, param, op.src1_sel, chunk, src)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                if(!ctx.predicate_bit(mmio, param, \
                                      param.mask_op.valu1_mask_sel, \
                                      chunk * elems + elem)) \
                    continue; \
                candidate = vu_vv_inst::get_elem(src, param.type_vl.data_type, elem); \
                insert_at = -1; \
                for(int slot = 0; slot < 16; slot++) begin \
                    if(!best_valid[slot]) \
                        better = 1'b1; \
                    else \
                        better = vu_fp_compare(COMPARE_OPCODE, \
                                               best_value[slot], candidate, \
                                               param.type_vl.data_type) != 0; \
                    if(better) begin \
                        insert_at = slot; \
                        break; \
                    end \
                end \
                if(insert_at >= 0) begin \
                    for(int slot = 15; slot > insert_at; slot--) begin \
                        best_value[slot] = best_value[slot-1]; \
                        best_index[slot] = best_index[slot-1]; \
                        best_valid[slot] = best_valid[slot-1]; \
                    end \
                    best_value[insert_at] = candidate; \
                    best_index[insert_at] = int'(chunk * elems + elem); \
                    best_valid[insert_at] = 1'b1; \
                end \
            end \
        end \
        for(int slot = 0; slot < 16; slot++) begin \
            if(best_valid[slot]) begin \
                vu_vv_inst::set_elem(ctx.vexe_vec_result[1][0], \
                                     param.type_vl.data_type, \
                                     slot, best_value[slot]); \
                ctx.vexe_vec_result[1][0][512 + slot*16 +: 16] = \
                    best_index[slot][15:0]; \
            end else begin \
                ctx.vexe_vec_result[1][0][512 + slot*16 +: 16] = 16'hffff; \
            end \
        end \
        ctx.vexe_vec_valid[1] = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] VALU1 top16 opcode=%02h candidates=%0d\n", \
                op.opcode, vl); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Scalar extraction: read chunk 0 without a mask/VL check, select src2 immediate
// bits [FP32_ELEM_MSB:0] or [BF16_ELEM_MSB:0], and expand BF16 to scalar FP32.
`define VU_VALU1_EXTRACT_INST(CLASS_NAME, OPCODE, FP32_ELEM_MSB, BF16_ELEM_MSB) \
class CLASS_NAME extends valu_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
 \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned id, \
        input int unsigned vl \
    ); \
        vu_valu_op_s op; \
        vu_vec_chunk_t src1; \
        bit [31:0] result; \
        int unsigned elem_imm; \
 \
        op = ctx.get_valu_op(param, id); \
        void'(ctx.resolve_vector_source(mmio, param, op.src1_sel, 0, src1)); \
        elem_imm = param.type_vl.data_type ? op.src2_sel[BF16_ELEM_MSB:0] : \
                                           op.src2_sel[FP32_ELEM_MSB:0]; \
        result = vu_vv_inst::get_elem(src1, param.type_vl.data_type, elem_imm); \
        if(param.type_vl.data_type) \
            result = vu_bf16_to_fp32(result); \
        ctx.vexe_scalar_result[1] = result; \
        ctx.vexe_scalar_valid[1] = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] VALU1 vfmv.f.s elem=%0d result=%08h\n", \
                elem_imm, result); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// Sum columns:     CLASS_NAME, OPCODE.
// Extrema columns: CLASS_NAME, OPCODE, ALU_OPCODE (FP32 reduction operation).
// TopK columns:    CLASS_NAME, OPCODE, COMPARE_OPCODE (strict insertion test).
// Extract columns: CLASS_NAME, OPCODE, FP32_ELEM_MSB, BF16_ELEM_MSB.
// Fixed mask/tail/result behavior is defined by each complete family above.
// Future opcode additions may also require metadata, legality and DPI changes;
// the catalogue does not extend the ISA or override outer configuration checks.
`define VU_VALU1_INSTRUCTION_LIST \
    `VU_VALU1_SUM_INST    (valu1_vfredusum_vs_inst,  `VU_OPCODE_VFREDUSUM_VS) \
    `VU_VALU1_EXTREMA_INST(valu1_vfredmax_vs_inst,   `VU_OPCODE_VFREDMAX_VS,  `VU_OPCODE_VFMAX_VV) \
    `VU_VALU1_EXTREMA_INST(valu1_vfredmin_vs_inst,   `VU_OPCODE_VFREDMIN_VS,  `VU_OPCODE_VFMIN_VV) \
    `VU_VALU1_TOPK_INST   (valu1_vsortmax16_v_inst,  `VU_OPCODE_VSORTMAX16_V, `VU_OPCODE_VMFGT_VF) \
    `VU_VALU1_TOPK_INST   (valu1_vsortmin16_v_inst,  `VU_OPCODE_VSORTMIN16_V, `VU_OPCODE_VMFLT_VV) \
    `VU_VALU1_EXTRACT_INST(valu1_vfmv_f_s_inst,      `VU_OPCODE_VFMV_F_S,     4, 5)

// First expansion: generate the six independent instruction classes.
`VU_VALU1_INSTRUCTION_LIST

`undef VU_VALU1_SUM_INST
`undef VU_VALU1_EXTREMA_INST
`undef VU_VALU1_TOPK_INST
`undef VU_VALU1_EXTRACT_INST

// ============================================================================
// 4. Library adapter -- inherited public dispatch; automatic registration
// ============================================================================
// Second expansion: construct/register the SAME catalogue after super.new().
// Family operation/feature arguments are consumed by the first expansion only.
`define VU_VALU1_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(shared); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_VALU1_SUM_INST(CLASS_NAME, OPCODE) \
`VU_VALU1_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU1_EXTREMA_INST(CLASS_NAME, OPCODE, ALU_OPCODE) \
`VU_VALU1_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU1_TOPK_INST(CLASS_NAME, OPCODE, COMPARE_OPCODE) \
`VU_VALU1_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU1_EXTRACT_INST(CLASS_NAME, OPCODE, FP32_ELEM_MSB, BF16_ELEM_MSB) \
`VU_VALU1_REGISTER(CLASS_NAME, OPCODE)

class valu1_library extends valu_common_library;
    function new(input vu_execution_context shared);
        super.new(shared);
        `VU_VALU1_INSTRUCTION_LIST
    endfunction : new
endclass : valu1_library

`undef VU_VALU1_EXTRACT_INST
`undef VU_VALU1_TOPK_INST
`undef VU_VALU1_EXTREMA_INST
`undef VU_VALU1_SUM_INST
`undef VU_VALU1_REGISTER
`undef VU_VALU1_INSTRUCTION_LIST

`endif // VU_VALU1_LIBRARY_SV
