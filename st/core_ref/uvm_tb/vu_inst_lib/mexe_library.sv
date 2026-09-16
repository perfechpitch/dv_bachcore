`ifndef VU_MEXE_LIBRARY_SV
`define VU_MEXE_LIBRARY_SV

// Class definitions and opcode registration use the SAME instruction catalogue.
// Included after vu_execution_context and the existing VU type definitions.

// ============================================================================
// 1. Shared instruction interface
// ============================================================================
virtual class mexe_inst_base;
    protected vu_execution_context ctx;

    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    // execute() supplies the original unconditional src1 mask scan results.
    pure virtual function void inst_exe(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl,
        input bit [31:0] count,
        input int first
    );
endclass : mexe_inst_base

// ============================================================================
// 2. Complete instruction-family templates: class / source / operation / result
// ============================================================================
// The adapter preserves the common pre-scan and logging for every instruction.
// Each template keeps its existing result flags and active-range writes.
// Scalar statistics: SCALAR_VALUE selects the pre-scanned count or first index.
`define VU_MEXE_SCALAR_INST(CLASS_NAME, OPCODE, SCALAR_VALUE) \
class CLASS_NAME extends mexe_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl, \
        input bit [31:0] count, \
        input int first \
    ); \
        ctx.mexe_scalar_result = (SCALAR_VALUE); \
        ctx.mexe_scalar_valid = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Boolean masks: MASK_EXPR uses one-bit src1/src2 in the original read order.
`define VU_MEXE_BOOLEAN_INST(CLASS_NAME, OPCODE, MASK_EXPR) \
class CLASS_NAME extends mexe_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl, \
        input bit [31:0] count, \
        input int first \
    ); \
        bit src1; \
        bit src2; \
        for(int unsigned elem = 0; elem < vl; elem++) begin \
            src1 = ctx.resolve_mask_source_bit( \
                mmio, param, param.mexe_op.src1_sel, elem); \
            src2 = ctx.resolve_mask_source_bit( \
                mmio, param, param.mexe_op.src2_sel, elem); \
            ctx.mexe_mask_result[elem] = (MASK_EXPR); \
        end \
        ctx.mexe_mask_valid = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Prefix masks: FIRST_TEST uses the signed first index (-1 when no bit is set).
`define VU_MEXE_PREFIX_INST(CLASS_NAME, OPCODE, FIRST_TEST) \
class CLASS_NAME extends mexe_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl, \
        input bit [31:0] count, \
        input int first \
    ); \
        for(int unsigned elem = 0; elem < vl; elem++) \
            ctx.mexe_mask_result[elem] = (FIRST_TEST); \
        ctx.mexe_mask_valid = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Indexed masks: INDEX_BIT replaces each valid indexed bit after copying src1.
// Keep all 16 signed indices, repeated writes and out-of-range ignores unchanged.
`define VU_MEXE_INDEXED_INST(CLASS_NAME, OPCODE, INDEX_BIT) \
class CLASS_NAME extends mexe_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl, \
        input bit [31:0] count, \
        input int first \
    ); \
        vu_vec_chunk_t indices; \
        int index; \
        for(int unsigned elem = 0; elem < vl; elem++) \
            ctx.mexe_mask_result[elem] = ctx.resolve_mask_source_bit( \
                mmio, param, param.mexe_op.src1_sel, elem); \
        if(ctx.resolve_index_vector( \
            mmio, param, param.mexe_op.src2_sel, indices)) begin \
            for(int slot = 0; slot < 16; slot++) begin \
                index = $signed(indices[512 + slot*16 +: 16]); \
                if(index >= 0 && index < vl) \
                    ctx.mexe_mask_result[index] = (INDEX_BIT); \
            end \
        end \
        ctx.mexe_mask_valid = 1'b1; \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// All rows start with CLASS_NAME, OPCODE. The third argument is family-specific:
//   SCALAR_VALUE: count or first from the nonzero-opcode pre-scan.
//   MASK_EXPR: Boolean expression over the one-bit src1 and src2 operands.
//   FIRST_TEST: per-element predicate using elem and the signed first index.
//   INDEX_BIT: constant written at valid signed indices (0=clear, 1=set).
// Family choice retains the complete source-read and result-publication behavior.
// Future opcodes may still require external definitions and source/legality rules.
`define VU_MEXE_INSTRUCTION_LIST \
    `VU_MEXE_SCALAR_INST(mexe_vcpop_m_inst, `VU_OPCODE_VCPOP_M, count) \
    `VU_MEXE_SCALAR_INST(mexe_vfirst_m_inst, `VU_OPCODE_VFIRST_M, first) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmand_mm_inst, `VU_OPCODE_VMAND_MM, src2 & src1) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmnand_mm_inst, `VU_OPCODE_VMNAND_MM, ~(src2 & src1)) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmandn_mm_inst, `VU_OPCODE_VMANDN_MM, src2 & ~src1) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmxor_mm_inst, `VU_OPCODE_VMXOR_MM, src2 ^ src1) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmor_mm_inst, `VU_OPCODE_VMOR_MM, src2 | src1) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmnor_mm_inst, `VU_OPCODE_VMNOR_MM, ~(src2 | src1)) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmorn_mm_inst, `VU_OPCODE_VMORN_MM, src2 | ~src1) \
    `VU_MEXE_BOOLEAN_INST(mexe_vmxnor_mm_inst, `VU_OPCODE_VMXNOR_MM, ~(src2 ^ src1)) \
    `VU_MEXE_PREFIX_INST(mexe_vmsbf_m_inst, `VU_OPCODE_VMSBF_M, first < 0 || elem < first) \
    `VU_MEXE_PREFIX_INST(mexe_vmsif_m_inst, `VU_OPCODE_VMSIF_M, first < 0 || elem <= first) \
    `VU_MEXE_PREFIX_INST(mexe_vmsof_m_inst, `VU_OPCODE_VMSOF_M, first >= 0 && elem == first) \
    `VU_MEXE_INDEXED_INST(mexe_vmiuset_mv_inst, `VU_OPCODE_VMIUSET_MV, 1'b0) \
    `VU_MEXE_INDEXED_INST(mexe_vmiset_mv_inst, `VU_OPCODE_VMISET_MV, 1'b1)

// First expansion: generate 15 independent instruction classes.
`VU_MEXE_INSTRUCTION_LIST

`undef VU_MEXE_SCALAR_INST
`undef VU_MEXE_BOOLEAN_INST
`undef VU_MEXE_PREFIX_INST
`undef VU_MEXE_INDEXED_INST

// ============================================================================
// 4. Library adapter -- unchanged public interface; automatic registration
// ============================================================================
// Second expansion: construct/register from the same catalogue. Operation
// arguments are consumed only when the instruction classes are generated.
`define VU_MEXE_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(ctx); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_MEXE_SCALAR_INST(CLASS_NAME, OPCODE, SCALAR_VALUE) \
`VU_MEXE_REGISTER(CLASS_NAME, OPCODE)
`define VU_MEXE_BOOLEAN_INST(CLASS_NAME, OPCODE, MASK_EXPR) \
`VU_MEXE_REGISTER(CLASS_NAME, OPCODE)
`define VU_MEXE_PREFIX_INST(CLASS_NAME, OPCODE, FIRST_TEST) \
`VU_MEXE_REGISTER(CLASS_NAME, OPCODE)
`define VU_MEXE_INDEXED_INST(CLASS_NAME, OPCODE, INDEX_BIT) \
`VU_MEXE_REGISTER(CLASS_NAME, OPCODE)

class mexe_library;
    protected vu_execution_context ctx;
    protected mexe_inst_base instructions[bit [7:0]];

    function void register_inst(
        input bit [7:0] opcode,
        input mexe_inst_base inst_obj
    );
        instructions[opcode] = inst_obj;
    endfunction : register_inst

    function new(input vu_execution_context shared);
        ctx = shared;
        `VU_MEXE_INSTRUCTION_LIST
    endfunction : new

    function void execute(
        input vu_mmio_set mmio,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        bit src1;
        bit [7:0] opcode;
        bit [31:0] count;
        int first;

        opcode = param.mexe_op.opcode;
        if(opcode == 0) begin
            if(ctx.log_fd != 0)
                $fwrite(ctx.log_fd, "[VU_INST] MEXE opcode=00 NOP\n");
            return;
        end

        // Keep this pre-scan for every nonzero opcode, including reserved ones,
        // so source reads retain the original order and frequency.
        count = 0;
        first = -1;
        for(int unsigned elem = 0; elem < vl; elem++) begin
            src1 = ctx.resolve_mask_source_bit(
                mmio, param, param.mexe_op.src1_sel, elem);
            if(src1) begin
                count++;
                if(first < 0)
                    first = elem;
            end
        end

        if(!instructions.exists(opcode)) begin
            if(ctx.log_fd != 0)
                $fwrite(ctx.log_fd,
                    "[VU_INST] MEXE opcode=%02h reserved: NOP\n", opcode);
            return;
        end
        instructions[opcode].inst_exe(mmio, param, vl, count, first);

        if(ctx.log_fd != 0) begin
            if(ctx.mexe_scalar_valid)
                $fwrite(ctx.log_fd,
                    "[VU_INST] MEXE opcode=%02h scalar=%08h\n",
                    opcode, ctx.mexe_scalar_result);
            else
                $fwrite(ctx.log_fd,
                    "[VU_INST] MEXE opcode=%02h mask-result vl=%0d\n",
                    opcode, vl);
        end
    endfunction : execute
endclass : mexe_library

`undef VU_MEXE_SCALAR_INST
`undef VU_MEXE_BOOLEAN_INST
`undef VU_MEXE_PREFIX_INST
`undef VU_MEXE_INDEXED_INST
`undef VU_MEXE_REGISTER
`undef VU_MEXE_INSTRUCTION_LIST

`endif // VU_MEXE_LIBRARY_SV
