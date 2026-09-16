// SEXE instruction classes and ordered scalar execution.
// Include after vu_inst_define.svh, vu_dpi.sv and vu_execution_context.
`ifndef VU_SEXE_LIBRARY_SV
`define VU_SEXE_LIBRARY_SV

// Class definitions and opcode registration use the SAME catalogue in section 3.
// The seven instruction classes are shared by all three ordered SEXE slots.

// ============================================================================
// 1. Shared instruction interface
// ============================================================================

virtual class sexe_inst_base;
    protected vu_execution_context ctx;

    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    pure virtual function void inst_exe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned slot
    );
endclass : sexe_inst_base

// ============================================================================
// 2. Complete instruction-family template: class / sources / execution / result
// ============================================================================
// IS_BINARY: 1 resolves both sources; 0 resolves src1 and leaves src2 as zero.
// Each expansion defines one instruction class. The original DPI owns the
// arithmetic and its fixed FP32 / rounding-mode-zero behavior.
`define VU_SEXE_DEFINE_INST(CLASS_NAME, OPCODE, IS_BINARY) \
class CLASS_NAME extends sexe_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned slot \
    ); \
        bit [7:0] src1_sel; \
        bit [7:0] src2_sel; \
        bit [31:0] src1; \
        bit [31:0] src2; \
        src1_sel = ctx.sexe_src1(param, slot); \
        src2_sel = ctx.sexe_src2(param, slot); \
        if(!ctx.resolve_scalar_source(mmio, param, src1_sel, src1)) begin \
            if(ctx.log_fd != 0) \
                $fwrite(ctx.log_fd, \
                    "[VU_INST] SEXE%0d not executed: invalid src1=%02h\n", \
                    slot, src1_sel); \
            return; \
        end \
        src2 = '0; \
        if(IS_BINARY && \
           !ctx.resolve_scalar_source(mmio, param, src2_sel, src2)) begin \
            if(ctx.log_fd != 0) \
                $fwrite(ctx.log_fd, \
                    "[VU_INST] SEXE%0d not executed: invalid src2=%02h\n", \
                    slot, src2_sel); \
            return; \
        end \
        ctx.sexe_result[slot] = vu_fp_sexe(OPCODE, src1, src2); \
        ctx.sexe_result[slot] = ctx.process_fp_result(mmio, param, \
            ctx.sexe_result[slot], 1'b0, 9 + slot, 1'b1, 1'b0); \
        ctx.sexe_valid[slot] = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] SEXE%0d opcode=%02h result=%08h\n", \
                slot, OPCODE, ctx.sexe_result[slot]); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// Columns: CLASS_NAME, OPCODE, IS_BINARY (1=two sources, 0=src1 only).
// Opcode selects the existing DPI operation; no param rounding mode is used.
// Future opcode additions also need matching definitions, metadata and DPI.
`define VU_SEXE_INSTRUCTION_LIST \
    `VU_SEXE_DEFINE_INST(sexe_fadd_s_inst,   `VU_OPCODE_FADD_S,   1'b1) \
    `VU_SEXE_DEFINE_INST(sexe_fsub_s_inst,   `VU_OPCODE_FSUB_S,   1'b1) \
    `VU_SEXE_DEFINE_INST(sexe_fmul_s_inst,   `VU_OPCODE_FMUL_S,   1'b1) \
    `VU_SEXE_DEFINE_INST(sexe_fdiv_s_inst,   `VU_OPCODE_FDIV_S,   1'b1) \
    `VU_SEXE_DEFINE_INST(sexe_fsqrt_s_inst,  `VU_OPCODE_FSQRT_S,  1'b0) \
    `VU_SEXE_DEFINE_INST(sexe_frsqrt_s_inst, `VU_OPCODE_FRSQRT_S, 1'b0) \
    `VU_SEXE_DEFINE_INST(sexe_frcp_s_inst,   `VU_OPCODE_FRCP_S,   1'b0)

// First expansion: generate seven independent instruction classes.
`VU_SEXE_INSTRUCTION_LIST

`undef VU_SEXE_DEFINE_INST

// ============================================================================
// 4. Library adapter -- unchanged interface/order; automatic registration
// ============================================================================
// Second expansion: construct/register from the same catalogue. IS_BINARY is
// consumed only by the class template in the first expansion.
`define VU_SEXE_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(ctx); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_SEXE_DEFINE_INST(CLASS_NAME, OPCODE, IS_BINARY) \
`VU_SEXE_REGISTER(CLASS_NAME, OPCODE)

class sexe_library;
    protected vu_execution_context ctx;
    protected sexe_inst_base instructions[bit [7:0]];

    function new(input vu_execution_context shared);
        ctx = shared;
        `VU_SEXE_INSTRUCTION_LIST
    endfunction : new

    protected function void register_inst(
        input bit [7:0] opcode,
        input sexe_inst_base inst_obj
    );
        instructions[opcode] = inst_obj;
    endfunction : register_inst

    function automatic void execute(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param
    );
        bit [7:0] opcode;

        // Publish each result before the next slot resolves its scalar sources.
        // Clearing execution state remains the top-level context's responsibility.
        for(int slot = 0; slot < 3; slot++) begin
            opcode = ctx.sexe_opcode(param, slot);
            if(opcode == 0) begin
                if(ctx.log_fd != 0)
                    $fwrite(ctx.log_fd, "[VU_INST] SEXE%0d opcode=00 NOP\n", slot);
                continue;
            end
            if(!instructions.exists(opcode)) begin
                if(ctx.log_fd != 0)
                    $fwrite(ctx.log_fd,
                        "[VU_INST] SEXE%0d opcode=%02h reserved: NOP\n",
                        slot, opcode);
                continue;
            end
            instructions[opcode].inst_exe(mmio, param, slot);
        end
    endfunction : execute
endclass : sexe_library

`undef VU_SEXE_DEFINE_INST
`undef VU_SEXE_REGISTER
`undef VU_SEXE_INSTRUCTION_LIST

`endif // VU_SEXE_LIBRARY_SV
