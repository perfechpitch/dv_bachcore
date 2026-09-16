`ifndef VU_VALU2_LIBRARY_SV
`define VU_VALU2_LIBRARY_SV

// VALU2 template catalogue: the same list defines and registers each class.
// Include after vu_execution_context and valu_common_library.

// ============================================================================
// 1. Inherited instruction interface and shared execution state
// ============================================================================
// valu_inst_base supplies ctx and inst_exe(mmio, param, id, vl).
// valu_common_library owns readiness, done, NOP/unsupported handling and logs.
// All four instructions publish vector results; writeback retains the VRF tail.

// ============================================================================
// 2. Complete instruction-family templates: class / sources / result
// ============================================================================
// Move/swap read src1. SOURCE_ELEM is the global source-element expression.
// Preserve per-element source resolution, including ignored failure returns.
`define VU_VALU2_MOVE_INST(CLASS_NAME, OPCODE, SOURCE_ELEM) \
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
        vu_vec_chunk_t src; \
        int unsigned elems; \
        int unsigned source_elem; \
        bit [31:0] value; \
 \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        for(int unsigned chunk = 0; chunk < ctx.vector_chunk_count(vl, param.type_vl.data_type); chunk++) \
            ctx.vexe_vec_result[id][chunk] = '0; \
        for(int unsigned elem = 0; elem < vl; elem++) begin \
            source_elem = SOURCE_ELEM; \
            void'(ctx.resolve_vector_source(mmio, param, op.src1_sel, \
                                            source_elem / elems, src)); \
            value = vu_vv_inst::get_elem(src, param.type_vl.data_type, \
                                        source_elem % elems); \
            vu_vv_inst::set_elem(ctx.vexe_vec_result[id][elem / elems], \
                                 param.type_vl.data_type, elem % elems, value); \
        end \
        ctx.vexe_vec_valid[id] = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Slide inserts src1 at FILL_CONDITION; other elements read src2.
// SHIFTED_SOURCE_ELEM expresses the direction in global element coordinates.
// Scalar/vector fallback and FP32-to-BF16 rounding stay in resolve_valu_operand.
`define VU_VALU2_SLIDE_INST(CLASS_NAME, OPCODE, FILL_CONDITION, SHIFTED_SOURCE_ELEM) \
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
        vu_vec_chunk_t src; \
        vu_vec_chunk_t scalar_vec; \
        int unsigned elems; \
        int unsigned source_elem; \
        bit [31:0] value; \
        bit [31:0] scalar; \
        bit fill; \
 \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        /* Resolve the inserted value before clearing active result chunks. */ \
        void'(ctx.resolve_valu_operand(mmio, param, op.src1_sel, 0, scalar_vec)); \
        scalar = vu_vv_inst::get_elem(scalar_vec, param.type_vl.data_type, 0); \
        for(int unsigned chunk = 0; chunk < ctx.vector_chunk_count(vl, param.type_vl.data_type); chunk++) \
            ctx.vexe_vec_result[id][chunk] = '0; \
        for(int unsigned elem = 0; elem < vl; elem++) begin \
            fill = FILL_CONDITION; \
            source_elem = fill ? 0 : SHIFTED_SOURCE_ELEM; \
            if(fill) \
                value = scalar; \
            else begin \
                void'(ctx.resolve_vector_source(mmio, param, op.src2_sel, \
                                                source_elem / elems, src)); \
                value = vu_vv_inst::get_elem(src, param.type_vl.data_type, \
                                            source_elem % elems); \
            end \
            vu_vv_inst::set_elem(ctx.vexe_vec_result[id][elem / elems], \
                                 param.type_vl.data_type, elem % elems, value); \
        end \
        ctx.vexe_vec_valid[id] = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// MOVE columns:  CLASS_NAME, OPCODE, SOURCE_ELEM.
// SLIDE columns: CLASS_NAME, OPCODE, FILL_CONDITION, SHIFTED_SOURCE_ELEM.
// Expressions use elem/vl; shifted indices are evaluated only outside the fill.
// The selected fill element uses scalar and does not fetch src2.
// An additional opcode still needs its external definition and legality rules.
`define VU_VALU2_INSTRUCTION_LIST \
    `VU_VALU2_MOVE_INST (valu2_vmv_v_v_inst,        `VU_OPCODE_VMV_V_V,         elem) \
    `VU_VALU2_MOVE_INST (valu2_vswap2_v_inst,       `VU_OPCODE_VSWAP2_V,        elem ^ 1) \
    `VU_VALU2_SLIDE_INST(valu2_vfslide1up_vf_inst,   `VU_OPCODE_VFSLIDE1UP_VF,   elem == 0,      elem - 1) \
    `VU_VALU2_SLIDE_INST(valu2_vfslide1down_vf_inst, `VU_OPCODE_VFSLIDE1DOWN_VF, elem == vl - 1, elem + 1)

// First expansion: generate four independent instruction classes.
`VU_VALU2_INSTRUCTION_LIST

`undef VU_VALU2_MOVE_INST
`undef VU_VALU2_SLIDE_INST

// ============================================================================
// 4. Library adapter -- inherited public interface; automatic registration
// ============================================================================
// Second expansion: each row constructs/registers one object after super.new.
`define VU_VALU2_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(shared); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_VALU2_MOVE_INST(CLASS_NAME, OPCODE, SOURCE_ELEM) \
`VU_VALU2_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU2_SLIDE_INST(CLASS_NAME, OPCODE, FILL_CONDITION, SHIFTED_SOURCE_ELEM) \
`VU_VALU2_REGISTER(CLASS_NAME, OPCODE)

class valu2_library extends valu_common_library;
    function new(input vu_execution_context shared);
        super.new(shared);
        `VU_VALU2_INSTRUCTION_LIST
    endfunction : new
endclass : valu2_library

`undef VU_VALU2_SLIDE_INST
`undef VU_VALU2_MOVE_INST
`undef VU_VALU2_REGISTER
`undef VU_VALU2_INSTRUCTION_LIST

`endif // VU_VALU2_LIBRARY_SV
