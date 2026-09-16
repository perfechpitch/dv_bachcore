// VSFU instruction classes and dispatch. Include after vu_execution_context,
// vu_inst_define.svh, the central DPI declarations and vu_vv_inst.
`ifndef VU_VSFU_LIBRARY_SV
`define VU_VSFU_LIBRARY_SV

// Class generation and opcode registration use the SAME instruction catalogue.
// This structural refactor preserves the deployed VSFU execution behavior.

// ============================================================================
// 1. Shared context and instruction interface
// ============================================================================

virtual class vsfu_inst_base;
    protected vu_execution_context ctx;

    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    pure virtual function void inst_exe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vsfu_id,
        input int unsigned vl
    );
endclass : vsfu_inst_base

// ============================================================================
// 2. Complete unary instruction-family template
// ============================================================================
// OPCODE is the original 8-bit selector passed to vu_fp_vsfu.
// LOG_SUFFIX preserves the per-chunk diagnostic, including the VFCUSTOM note.
// Source fetch, chunk/tail handling, DPI calls and result publication all live
// in each generated instruction class; the base contains no execution kernel.
`define VU_VSFU_UNARY_INST(CLASS_NAME, OPCODE, LOG_SUFFIX) \
class CLASS_NAME extends vsfu_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
 \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vsfu_id, \
        input int unsigned vl \
    ); \
        vu_vec_chunk_t src; \
        bit [7:0] opcode; \
        bit [7:0] src_sel; \
        bit [31:0] value; \
        bit [31:0] result; \
        int unsigned id; \
        int unsigned elems; \
        int unsigned chunks; \
        int unsigned active; \
        int unsigned global_elem; \
 \
        opcode = OPCODE; \
        id = 3 + vsfu_id; \
        if(vsfu_id == 0) \
            src_sel = param.vsfu_op.vsfu0_src1_sel; \
        else \
            src_sel = param.vsfu_op.vsfu1_src1_sel; \
 \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            void'(ctx.resolve_vector_source(mmio, param, src_sel, chunk, src)); \
            ctx.vexe_vec_result[id][chunk] = '0; \
            active = vl - chunk * elems; \
            if(active > elems) \
                active = elems; \
            for(int unsigned elem = 0; elem < active; elem++) begin \
                global_elem = chunk * elems + elem; \
                value = vu_vv_inst::get_elem(src, param.type_vl.data_type, elem); \
                result = vu_fp_vsfu(opcode, value, \
                                    param.type_vl.data_type, \
                                    param.type_vl.round_mode); \
                result = ctx.process_fp_result(mmio, param, result, \
                    param.type_vl.data_type, 6 + vsfu_id, 1'b1, 1'b0); \
                vu_vv_inst::set_elem(ctx.vexe_vec_result[id][chunk], \
                                     param.type_vl.data_type, elem, result); \
            end \
            if(ctx.log_fd != 0) \
                $fwrite(ctx.log_fd, \
                    "[VU_INST] VSFU%0d chunk=%0d opcode=%02h elems=%0d%s\n", \
                    vsfu_id, chunk, opcode, active, \
                    LOG_SUFFIX); \
        end \
        ctx.vexe_vec_valid[id] = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// Columns: CLASS_NAME, OPCODE, LOG_SUFFIX.
// All twelve instructions keep the same unary DPI path. VFCUSTOM deliberately
// retains the original DPI identity placeholder; no coefficients are added.
// This catalogue defines/registers these classes only. Future opcode support
// may also require metadata and DPI changes outside this file.
`define VU_VSFU_INSTRUCTION_LIST \
    `VU_VSFU_UNARY_INST(vsfu_vfsin_v,     `VU_OPCODE_VFSIN_V,     "") \
    `VU_VSFU_UNARY_INST(vsfu_vfcos_v,     `VU_OPCODE_VFCOS_V,     "") \
    `VU_VSFU_UNARY_INST(vsfu_vftanh_v,    `VU_OPCODE_VFTANH_V,    "") \
    `VU_VSFU_UNARY_INST(vsfu_vfsigmoid_v, `VU_OPCODE_VFSIGMOID_V, "") \
    `VU_VSFU_UNARY_INST(vsfu_vfexp_v,     `VU_OPCODE_VFEXP_V,     "") \
    `VU_VSFU_UNARY_INST(vsfu_vfexp2_v,    `VU_OPCODE_VFEXP2_V,    "") \
    `VU_VSFU_UNARY_INST(vsfu_vfln_v,      `VU_OPCODE_VFLN_V,      "") \
    `VU_VSFU_UNARY_INST(vsfu_vflog2_v,    `VU_OPCODE_VFLOG2_V,    "") \
    `VU_VSFU_UNARY_INST(vsfu_vfsqrt_v,    `VU_OPCODE_VFSQRT_V,    "") \
    `VU_VSFU_UNARY_INST(vsfu_vfrcp_v,     `VU_OPCODE_VFRCP_V,     "") \
    `VU_VSFU_UNARY_INST(vsfu_vfrsqrt_v,   `VU_OPCODE_VFRSQRT_V,   "") \
    `VU_VSFU_UNARY_INST(vsfu_vfcustom_v,  `VU_OPCODE_VFCUSTOM_V,  " (identity fallback: coefficients undefined)")

// First expansion: generate twelve independent instruction classes.
`VU_VSFU_INSTRUCTION_LIST

`undef VU_VSFU_UNARY_INST

// ============================================================================
// 4. Library adapter -- unchanged public interface; automatic registration
// ============================================================================
// Second expansion: construct/register from the same instruction catalogue.
// LOG_SUFFIX is only used by the complete class expansion in section 2.
`define VU_VSFU_REGISTER_INST(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(ctx); \
        instructions[OPCODE] = inst_obj; \
    end
`define VU_VSFU_UNARY_INST(CLASS_NAME, OPCODE, LOG_SUFFIX) \
`VU_VSFU_REGISTER_INST(CLASS_NAME, OPCODE)

class vsfu_library;
    protected vu_execution_context ctx;
    protected vsfu_inst_base instructions[bit [7:0]];

    function new(input vu_execution_context shared);
        ctx = shared;
        `VU_VSFU_INSTRUCTION_LIST
    endfunction : new

    function automatic bit can_execute(
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
        if(opcode == 0 || !ctx.vsfu_opcode_supported(opcode))
            return 1'b1;
        return ctx.vector_source_ready(src_sel);
    endfunction : can_execute

    function automatic void execute(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vsfu_id,
        input int unsigned vl
    );
        bit [7:0] opcode;
        int unsigned id;

        id = 3 + vsfu_id;
        ctx.vexe_done[id] = 1'b1;
        if(vsfu_id == 0) begin
            opcode = param.vsfu_op.vsfu0_opcode;
        end else begin
            // Preserve direct-call behavior as well as the top-level BF16 gate.
            if(param.type_vl.data_type)
                return;
            opcode = param.vsfu_op.vsfu1_opcode;
        end

        if(opcode == 0) begin
            if(ctx.log_fd != 0)
                $fwrite(ctx.log_fd, "[VU_INST] VSFU%0d opcode=00 NOP\n", vsfu_id);
            return;
        end
        if(!ctx.vsfu_opcode_supported(opcode)) begin
            if(ctx.log_fd != 0)
                $fwrite(ctx.log_fd,
                    "[VU_INST] VSFU%0d opcode=%02h reserved: NOP\n",
                    vsfu_id, opcode);
            return;
        end

        instructions[opcode].inst_exe(mmio, param, vsfu_id, vl);
    endfunction : execute
endclass : vsfu_library

`undef VU_VSFU_UNARY_INST
`undef VU_VSFU_REGISTER_INST
`undef VU_VSFU_INSTRUCTION_LIST
`endif // VU_VSFU_LIBRARY_SV
