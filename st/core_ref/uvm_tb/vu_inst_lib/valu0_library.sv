`ifndef VU_VALU0_LIBRARY_SV
`define VU_VALU0_LIBRARY_SV
`include "valu_common_library.sv"

// VALU0 template trial. The SAME catalogue defines and registers 29 unique
// classes. Shared instructions and the unchanged interface come from common.

// ============================================================================
// 1. Complete instruction-family templates: source / operation / mask / result
// ============================================================================

// NEED_SRC3=1 resolves the vector accumulator and retains src3 when masked.
// NEED_SRC3=0 covers DIV/sign injection and retains src2 when masked.
// All operations use the existing DPI opcode; active chunks keep zero tails.
`define VU_VALU0_ARITH_INST(CLASS_NAME, OPCODE, NEED_SRC3, REPORT_NAN) \
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
            if(NEED_SRC3) \
                void'(ctx.resolve_vector_source(mmio, param, op.src3_sel, chunk, src3)); \
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
                        result = NEED_SRC3 ? value3 : value2; \
                    else begin \
                        result = vu_fp_alu(OPCODE, value1, value2, value3, \
                                           param.type_vl.data_type, param.type_vl.round_mode); \
                        result = ctx.process_fp_result(mmio, param, result, \
                            param.type_vl.data_type, 3 + id, REPORT_NAN, 1'b0); \
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

// Merge reads src1/src2. A zero mask selector chooses src2; a selected true
// predicate chooses src1. Preserve the original local data and read order.
`define VU_VALU0_MERGE_INST(CLASS_NAME, OPCODE) \
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
            if(1'b0) \
                void'(ctx.resolve_vector_source(mmio, param, op.src3_sel, chunk, src3)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                global_elem = chunk * elems + elem; \
                value1 = vu_vv_inst::get_elem(src1, param.type_vl.data_type, elem); \
                value2 = vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem); \
                value3 = vu_vv_inst::get_elem(src3, param.type_vl.data_type, elem); \
                begin \
                    pred = param.mask_op.valu0_mask_sel != 0 && \
                           ctx.predicate_bit(mmio, param, param.mask_op.valu0_mask_sel, global_elem); \
                    result = pred ? value1 : value2; \
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

// Compare reads scalar/vector src1 and vector src2, writes zero when masked,
// and updates only active mask elements plus valu0_mask_valid.
`define VU_VALU0_COMPARE_INST(CLASS_NAME, OPCODE) \
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
        bit [9:0] class_imm; \
        bit pred; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        int unsigned global_elem; \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        class_imm = {op.src3_sel[1:0], op.src2_sel}; \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            begin \
                void'(ctx.resolve_valu_operand(mmio, param, op.src1_sel, chunk, src1)); \
                void'(ctx.resolve_vector_source(mmio, param, op.src2_sel, chunk, src2)); \
            end \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                global_elem = chunk * elems + elem; \
                pred = ctx.predicate_bit(mmio, param, \
                                         param.mask_op.valu0_mask_sel, global_elem); \
                if(!pred) \
                    ctx.valu0_mask_result[global_elem] = 1'b0; \
                else begin \
                    ctx.valu0_mask_result[global_elem] = vu_fp_compare( \
                        OPCODE, \
                        vu_vv_inst::get_elem(src1, param.type_vl.data_type, elem), \
                        vu_vv_inst::get_elem(src2, param.type_vl.data_type, elem), \
                        param.type_vl.data_type) != 0; \
                end \
            end \
        end \
        ctx.valu0_mask_valid = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] VALU0 mask-result opcode=%02h vl=%0d\n", op.opcode, vl); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Classification reads vector src1 only. The 10-bit class immediate is
// {src3_sel[1:0], src2_sel}; mask range, result flags and logging are preserved.
`define VU_VALU0_CLASSIFY_INST(CLASS_NAME, OPCODE) \
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
        bit [9:0] class_imm; \
        bit pred; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        int unsigned global_elem; \
        op = ctx.get_valu_op(param, id); \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        class_imm = {op.src3_sel[1:0], op.src2_sel}; \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            void'(ctx.resolve_vector_source(mmio, param, op.src1_sel, chunk, src1)); \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                global_elem = chunk * elems + elem; \
                pred = ctx.predicate_bit(mmio, param, \
                                         param.mask_op.valu0_mask_sel, global_elem); \
                if(!pred) \
                    ctx.valu0_mask_result[global_elem] = 1'b0; \
                else begin \
                    ctx.valu0_mask_result[global_elem] = vu_fp_class( \
                        vu_vv_inst::get_elem(src1, param.type_vl.data_type, elem), \
                        param.type_vl.data_type, class_imm) != 0; \
                end \
            end \
        end \
        ctx.valu0_mask_valid = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] VALU0 mask-result opcode=%02h vl=%0d\n", op.opcode, vl); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Scalar insertion reads the existing destination entry (p0 before p1),
// replaces one element in chunk zero, ignores VL/predicate, and emits no log.
`define VU_VALU0_SCALAR_INSERT_INST(CLASS_NAME, OPCODE) \
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
        vu_vec_chunk_t scalar_vec; \
        bit [31:0] scalar; \
        int unsigned source_elem; \
        op = ctx.get_valu_op(param, id); \
        void'(ctx.resolve_valu_operand(mmio, param, op.src1_sel, 0, scalar_vec)); \
        scalar = vu_vv_inst::get_elem(scalar_vec, param.type_vl.data_type, 0); \
        if(param.prf_op.vrf_wt_p0_src == ctx.vexe_src_code(id)) \
            src = mmio.read_vrf_entry(param.vrf_wt_index.vrf_wt_p0_idx); \
        else if(param.prf_op.vrf_wt_p1_src == ctx.vexe_src_code(id)) \
            src = mmio.read_vrf_entry(param.vrf_wt_index.vrf_wt_p1_idx); \
        else \
            src = '0; \
        source_elem = param.type_vl.data_type ? op.src2_sel[5:0] : op.src2_sel[4:0]; \
        vu_vv_inst::set_elem(src, param.type_vl.data_type, source_elem, scalar); \
        ctx.vexe_vec_result[id][0] = src; \
        ctx.vexe_vec_valid[id] = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 2. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// ARITH columns: CLASS_NAME, OPCODE, NEED_SRC3, REPORT_NAN.
// Sign injection is a bit operation, not numerical NaN production.
// Other families: CLASS_NAME, OPCODE. The family selects a distinct algorithm.
// Source routing and macro-level configuration checks stay outside this file.
// New opcodes may also require definitions, context/checker metadata and DPI;
// adding catalogue rows alone does not establish ISA support.
`define VU_VALU0_INSTRUCTION_LIST \
    `VU_VALU0_ARITH_INST(valu0_vfdiv_vv_inst, `VU_OPCODE_VFDIV_VV, 1'b0, 1'b1) \
    `VU_VALU0_SCALAR_INSERT_INST(valu0_vfmv_s_f_inst, `VU_OPCODE_VFMV_S_F) \
    `VU_VALU0_ARITH_INST(valu0_vfmacc_vv_inst, `VU_OPCODE_VFMACC_VV, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfmacc_vf_inst, `VU_OPCODE_VFMACC_VF, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfnmacc_vv_inst, `VU_OPCODE_VFNMACC_VV, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfnmacc_vf_inst, `VU_OPCODE_VFNMACC_VF, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfmsac_vv_inst, `VU_OPCODE_VFMSAC_VV, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfmsac_vf_inst, `VU_OPCODE_VFMSAC_VF, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfnmsac_vv_inst, `VU_OPCODE_VFNMSAC_VV, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfnmsac_vf_inst, `VU_OPCODE_VFNMSAC_VF, 1'b1, 1'b1) \
    `VU_VALU0_ARITH_INST(valu0_vfsgnj_vv_inst, `VU_OPCODE_VFSGNJ_VV, 1'b0, 1'b0) \
    `VU_VALU0_ARITH_INST(valu0_vfsgnj_vf_inst, `VU_OPCODE_VFSGNJ_VF, 1'b0, 1'b0) \
    `VU_VALU0_ARITH_INST(valu0_vfsgnjn_vv_inst, `VU_OPCODE_VFSGNJN_VV, 1'b0, 1'b0) \
    `VU_VALU0_ARITH_INST(valu0_vfsgnjn_vf_inst, `VU_OPCODE_VFSGNJN_VF, 1'b0, 1'b0) \
    `VU_VALU0_ARITH_INST(valu0_vfsgnjx_vv_inst, `VU_OPCODE_VFSGNJX_VV, 1'b0, 1'b0) \
    `VU_VALU0_ARITH_INST(valu0_vfsgnjx_vf_inst, `VU_OPCODE_VFSGNJX_VF, 1'b0, 1'b0) \
    `VU_VALU0_COMPARE_INST(valu0_vmfeq_vv_inst, `VU_OPCODE_VMFEQ_VV) \
    `VU_VALU0_COMPARE_INST(valu0_vmfeq_vf_inst, `VU_OPCODE_VMFEQ_VF) \
    `VU_VALU0_COMPARE_INST(valu0_vmfne_vv_inst, `VU_OPCODE_VMFNE_VV) \
    `VU_VALU0_COMPARE_INST(valu0_vmfne_vf_inst, `VU_OPCODE_VMFNE_VF) \
    `VU_VALU0_COMPARE_INST(valu0_vmflt_vv_inst, `VU_OPCODE_VMFLT_VV) \
    `VU_VALU0_COMPARE_INST(valu0_vmflt_vf_inst, `VU_OPCODE_VMFLT_VF) \
    `VU_VALU0_COMPARE_INST(valu0_vmfle_vv_inst, `VU_OPCODE_VMFLE_VV) \
    `VU_VALU0_COMPARE_INST(valu0_vmfle_vf_inst, `VU_OPCODE_VMFLE_VF) \
    `VU_VALU0_COMPARE_INST(valu0_vmfgt_vf_inst, `VU_OPCODE_VMFGT_VF) \
    `VU_VALU0_COMPARE_INST(valu0_vmfge_vf_inst, `VU_OPCODE_VMFGE_VF) \
    `VU_VALU0_CLASSIFY_INST(valu0_vfclass_mv_inst, `VU_OPCODE_VFCLASS_MV) \
    `VU_VALU0_MERGE_INST(valu0_vfmerge_vfm_inst, `VU_OPCODE_VFMERGE_VFM) \
    `VU_VALU0_MERGE_INST(valu0_vfmerge_vvm_inst, `VU_OPCODE_VFMERGE_VVM)

// First expansion: define 29 independent instruction classes.
`VU_VALU0_INSTRUCTION_LIST

`undef VU_VALU0_ARITH_INST
`undef VU_VALU0_MERGE_INST
`undef VU_VALU0_COMPARE_INST
`undef VU_VALU0_CLASSIFY_INST
`undef VU_VALU0_SCALAR_INSERT_INST

// ============================================================================
// 3. Library adapter -- automatic registration from the same catalogue
// ============================================================================
`define VU_VALU0_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(ctx); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_VALU0_ARITH_INST(CLASS_NAME, OPCODE, NEED_SRC3, REPORT_NAN) \
`VU_VALU0_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU0_MERGE_INST(CLASS_NAME, OPCODE) \
`VU_VALU0_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU0_COMPARE_INST(CLASS_NAME, OPCODE) \
`VU_VALU0_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU0_CLASSIFY_INST(CLASS_NAME, OPCODE) \
`VU_VALU0_REGISTER(CLASS_NAME, OPCODE)
`define VU_VALU0_SCALAR_INSERT_INST(CLASS_NAME, OPCODE) \
`VU_VALU0_REGISTER(CLASS_NAME, OPCODE)

class valu0_library extends valu_common_library;
    function new(input vu_execution_context shared);
        super.new(shared);
        `VU_VALU0_INSTRUCTION_LIST
    endfunction : new
endclass : valu0_library

`undef VU_VALU0_SCALAR_INSERT_INST
`undef VU_VALU0_CLASSIFY_INST
`undef VU_VALU0_COMPARE_INST
`undef VU_VALU0_MERGE_INST
`undef VU_VALU0_ARITH_INST
`undef VU_VALU0_REGISTER
`undef VU_VALU0_INSTRUCTION_LIST

`endif // VU_VALU0_LIBRARY_SV
