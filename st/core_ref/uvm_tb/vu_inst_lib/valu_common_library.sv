// Shared VALU template trial. Include after vu_execution_context and VU dependencies.
`ifndef VU_VALU_COMMON_LIBRARY_SV
`define VU_VALU_COMMON_LIBRARY_SV

// Class definitions and opcode registration expand the SAME instruction catalogue.
// Current arithmetic mask behavior, including VFADD, is unchanged.

// ============================================================================
// 1. Shared instruction interface -- ABI used by all three VALU sub-libraries
// ============================================================================

virtual class valu_inst_base;
    protected vu_execution_context ctx;

    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    pure virtual function void inst_exe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id,
        input int unsigned vl
    );
endclass : valu_inst_base

// ============================================================================
// 2. Complete instruction-family templates: source / result / mask / tail / log
// ============================================================================
// ARITH: resolve operand src1, resolve vector src2, then evaluate each active
// element. A false predicate keeps src2; active result chunks have zero tails.
// OPCODE selects the existing DPI operation; operand routing remains in ctx.
// The complete class body is here, with no runtime opcode execution dispatch.
`define VU_VALU_COMMON_ARITH_INST(CLASS_NAME, OPCODE) \
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
        vu_vec_chunk_t src1; \
        vu_vec_chunk_t src2; \
        vu_vec_chunk_t src3; \
        bit [31:0] value1; \
        bit [31:0] value2; \
        bit [31:0] value3; \
        bit [31:0] result; \
        bit pred; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        int unsigned global_elem; \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            ctx.vexe_vec_result[id][chunk] = '0; \
            void'(ctx.resolve_valu_operand(mmio, param, op.src1_sel, chunk, src1)); \
            void'(ctx.resolve_vector_source(mmio, param, op.src2_sel, chunk, src2)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                global_elem = chunk * elems + elem; \
                value1 = vu_vv_inst::get_elem(src1, param.type_vl.data_type, elem); \
                value2 = vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem); \
                value3 = vu_vv_inst::get_elem(src3, param.type_vl.data_type, elem); \
                begin \
                    pred = ctx.predicate_bit(mmio, param, ctx.valu_mask_sel(param, id), global_elem); \
                    if(!pred) \
                        result = value2; \
                    else begin \
                        result = vu_fp_alu(OPCODE, value1, value2, value3, \
                                           param.type_vl.data_type, param.type_vl.round_mode); \
                        result = ctx.process_fp_result(mmio, param, result, \
                            param.type_vl.data_type, 3 + id, 1'b1, 1'b0); \
                    end \
                end \
                vu_vv_inst::set_elem(ctx.vexe_vec_result[id][chunk], \
                                     param.type_vl.data_type, elem, result); \
            end \
            if(ctx.log_fd != 0) \
                $fwrite(ctx.log_fd, \
                    "[VU_INST] VALU%0d chunk=%0d opcode=%02h elems=%0d\n", \
                    id, chunk, op.opcode, active); \
        end \
        ctx.vexe_vec_valid[id] = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// BROADCAST: resolve src1 only, ignore the predicate, and fill active elements.
// Retain the original local element extraction and result/log publication order.
`define VU_VALU_COMMON_BROADCAST_INST(CLASS_NAME, OPCODE) \
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
        vu_vec_chunk_t src1; \
        vu_vec_chunk_t src2; \
        vu_vec_chunk_t src3; \
        bit [31:0] value1; \
        bit [31:0] value2; \
        bit [31:0] value3; \
        bit [31:0] result; \
        bit pred; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        int unsigned global_elem; \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            ctx.vexe_vec_result[id][chunk] = '0; \
            void'(ctx.resolve_valu_operand(mmio, param, op.src1_sel, chunk, src1)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                global_elem = chunk * elems + elem; \
                value1 = vu_vv_inst::get_elem(src1, param.type_vl.data_type, elem); \
                value2 = vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem); \
                value3 = vu_vv_inst::get_elem(src3, param.type_vl.data_type, elem); \
                result = value1; \
                vu_vv_inst::set_elem(ctx.vexe_vec_result[id][chunk], \
                                     param.type_vl.data_type, elem, result); \
            end \
            if(ctx.log_fd != 0) \
                $fwrite(ctx.log_fd, \
                    "[VU_INST] VALU%0d chunk=%0d opcode=%02h elems=%0d\n", \
                    id, chunk, op.opcode, active); \
        end \
        ctx.vexe_vec_valid[id] = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// Columns: CLASS_NAME, OPCODE. The family makes mask/source behavior explicit:
// ARITH applies the selected predicate; BROADCAST neither reads src2 nor masks.
// A new opcode may also need definitions, context/checker metadata and DPI work;
// catalogue registration alone does not establish ISA support.
`define VU_VALU_COMMON_INSTRUCTION_LIST \
    `VU_VALU_COMMON_ARITH_INST(valu_vfadd_vv_inst, `VU_OPCODE_VFADD_VV) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfadd_vf_inst, `VU_OPCODE_VFADD_VF) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfsub_vv_inst, `VU_OPCODE_VFSUB_VV) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfsub_vf_inst, `VU_OPCODE_VFSUB_VF) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfrsub_vf_inst, `VU_OPCODE_VFRSUB_VF) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfmul_vv_inst, `VU_OPCODE_VFMUL_VV) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfmul_vf_inst, `VU_OPCODE_VFMUL_VF) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfmin_vv_inst, `VU_OPCODE_VFMIN_VV) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfmin_vf_inst, `VU_OPCODE_VFMIN_VF) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfmax_vv_inst, `VU_OPCODE_VFMAX_VV) \
    `VU_VALU_COMMON_ARITH_INST(valu_vfmax_vf_inst, `VU_OPCODE_VFMAX_VF) \
    `VU_VALU_COMMON_BROADCAST_INST(valu_vfmv_v_f_inst, `VU_OPCODE_VFMV_V_F)

// First expansion: generate 12 independent instruction classes.
`VU_VALU_COMMON_INSTRUCTION_LIST

`undef VU_VALU_COMMON_ARITH_INST
`undef VU_VALU_COMMON_BROADCAST_INST

// ============================================================================
// 4. Library adapter -- unchanged dispatch/readiness; automatic registration
// ============================================================================
// Second expansion: reuse the same catalogue to construct and register objects.
`define VU_VALU_COMMON_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(ctx); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_VALU_COMMON_ARITH_INST(CLASS_NAME, OPCODE) \
`VU_VALU_COMMON_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU_COMMON_BROADCAST_INST(CLASS_NAME, OPCODE) \
`VU_VALU_COMMON_REGISTER(CLASS_NAME, OPCODE)

class valu_common_library;
    protected vu_execution_context ctx;
    protected valu_inst_base instructions[bit [7:0]];

    function new(input vu_execution_context shared);
        ctx = shared;
        `VU_VALU_COMMON_INSTRUCTION_LIST
    endfunction : new

    function void register_inst(input bit [7:0] opcode, input valu_inst_base inst_obj);
        instructions[opcode] = inst_obj;
    endfunction : register_inst

    // Preserve can_execute_valu's original readiness rules for all three units.
    function automatic bit can_execute(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id
    );
        vu_valu_op_s op;

        op = ctx.get_valu_op(param, id);
        if(op.opcode == 8'h00 || !ctx.valu_opcode_supported(id, op.opcode))
            return 1'b1;

        case(op.opcode)
            `VU_OPCODE_VFMV_V_F,
            `VU_OPCODE_VFMV_S_F:
                return ctx.scalar_source_ready(op.src1_sel);
            `VU_OPCODE_VFMV_F_S,
            `VU_OPCODE_VMV_V_V,
            `VU_OPCODE_VSWAP2_V:
                return ctx.vector_source_ready(op.src1_sel);
            `VU_OPCODE_VFCLASS_MV,
            `VU_OPCODE_VSORTMAX16_V,
            `VU_OPCODE_VSORTMIN16_V:
                return ctx.vector_source_ready(op.src1_sel);
            default: begin
                if(!ctx.operand_source_ready(op.src1_sel) ||
                   !ctx.vector_source_ready(op.src2_sel))
                    return 1'b0;
                if(ctx.is_macc_opcode(op.opcode) &&
                   !ctx.vector_source_ready(op.src3_sel))
                    return 1'b0;
                return 1'b1;
            end
        endcase
    endfunction : can_execute

    function automatic void execute(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned id,
        input int unsigned vl
    );
        vu_valu_op_s op;

        op = ctx.get_valu_op(param, id);
        ctx.vexe_done[id] = 1'b1;
        if(op.opcode == 8'h00) begin
            if(ctx.log_fd != 0)
                $fwrite(ctx.log_fd, "[VU_INST] VALU%0d opcode=00 NOP\n", id);
            return;
        end
        if(!ctx.valu_opcode_supported(id, op.opcode) || !instructions.exists(op.opcode)) begin
            if(ctx.log_fd != 0)
                $fwrite(ctx.log_fd,
                    "[VU_INST] VALU%0d opcode=%02h unsupported/reserved: NOP\n",
                    id, op.opcode);
            return;
        end
        instructions[op.opcode].inst_exe(mmio, param, id, vl);
    endfunction : execute
endclass : valu_common_library

`undef VU_VALU_COMMON_BROADCAST_INST
`undef VU_VALU_COMMON_ARITH_INST
`undef VU_VALU_COMMON_REGISTER
`undef VU_VALU_COMMON_INSTRUCTION_LIST

`endif // VU_VALU_COMMON_LIBRARY_SV
