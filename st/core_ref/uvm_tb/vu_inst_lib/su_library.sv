`ifndef VU_SU_LIBRARY_SV
`define VU_SU_LIBRARY_SV

// Include after vu_execution_context, the VU types, and the common DPI imports.
// SU writes CM immediately; the top-level scheduler calls it before RF writeback.
// Class definitions and construction/registration use the SAME instruction list.

// ============================================================================
// 1. Shared instruction interface and CM write helpers
// ============================================================================

virtual class su_inst_base;
    protected vu_execution_context ctx;

    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    protected function automatic void write_cm(
        input dsa_mem_library dsa_mem,
        input bit [31:0] addr,
        input bit [1:0] size,
        input bit [31:0] data
    );
        dsa_mem.write_core(size, addr, data);
    endfunction : write_cm

    // One e8m0 byte per 32-element block. dsa_mem_library applies the
    // data-address >> 5 mapping; pass the block's data address unchanged.
    protected function automatic void write_cm_scale(
        input dsa_mem_library dsa_mem,
        input bit [31:0] data_addr,
        input bit [7:0] scale
    );
        dsa_mem.write_core_scale(2'd0, data_addr, {24'h0, scale});
    endfunction : write_cm_scale

    pure virtual function void inst_exe(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
endclass : su_inst_base

// ============================================================================
// 2. Complete instruction-family templates: source / execution / writes / logs
// ============================================================================
// Ordinary vectors: ELEM_BYTES is the CM address step; WRITE_SIZE is the
// write_core size (0=8 bits, 1=16 bits, 2=32 bits). Floating-point inputs are
// replaced once before conversion; SU conversion never reports NAN_ERROR.
// Address checks stay in su_library.execute, before any instruction dispatch.
`define VU_SU_VECTOR_INST(CLASS_NAME, OPCODE, ELEM_BYTES, WRITE_SIZE) \
class CLASS_NAME extends su_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input dsa_mem_library dsa_mem, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl \
    ); \
        vu_vec_chunk_t src; \
        bit [31:0] value; \
        bit [31:0] raw; \
        bit [31:0] addr; \
        int unsigned elems; \
        int unsigned chunks; \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        chunks = ctx.vector_chunk_count(vl, param.type_vl.data_type); \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) begin \
            if(!ctx.resolve_su_vector(mmio, param, param.su_op.src_sel, \
                                      chunk, src)) \
                return; \
            for(int unsigned elem = 0; elem < elems; elem++) begin \
                if(chunk * elems + elem >= vl) \
                    break; \
                value = vu_vv_inst::get_elem(src, \
                                             param.type_vl.data_type, elem); \
                value = ctx.process_fp_result(mmio, param, value, \
                    param.type_vl.data_type, 2, 1'b0, 1'b1); \
                raw = vu_store_convert(OPCODE, value, \
                                       param.type_vl.data_type, \
                                       param.type_vl.round_mode); \
                addr = param.st_addr.cm_addr + \
                       (chunk * elems + elem) * ELEM_BYTES; \
                write_cm(dsa_mem, addr, WRITE_SIZE, raw); \
            end \
        end \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] SU opcode=%02h vl=%0d vector-stored\n", \
                param.su_op.opcode, vl); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// MXFP8 has a distinct fixed 32-element algorithm: scan the block, choose its
// scale, quantize/write bytes, then write that scale. Cache replaced inputs so
// both passes use identical data and count each replacement only once.
`define VU_SU_MXFP8_INST(CLASS_NAME, OPCODE) \
class CLASS_NAME extends su_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
 \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input dsa_mem_library dsa_mem, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl \
    ); \
        vu_vec_chunk_t src; \
        bit [31:0] value; \
        bit [31:0] block_values[32]; \
        bit [31:0] raw; \
        int unsigned elems; \
        int unsigned blk_len; \
        int unsigned idx; \
        int cur_chunk; \
        bit [31:0] abs_bits; \
        bit [31:0] max_abs; \
        bit [7:0] scale; \
 \
        elems = ctx.elem_count_per_entry(param.type_vl.data_type); \
        for(int unsigned base = 0; base < vl; base += 32) begin \
            blk_len = (vl - base < 32) ? (vl - base) : 32; \
 \
            /* Pass 1: block max |element|. FP32/BF16 magnitudes */ \
            /* order like their bit patterns with the sign masked. */ \
            max_abs = '0; \
            cur_chunk = -1; \
            for(int unsigned i = 0; i < blk_len; i++) begin \
                idx = base + i; \
                if(int'(idx / elems) != cur_chunk) begin \
                    cur_chunk = idx / elems; \
                    if(!ctx.resolve_su_vector(mmio, param, \
                                              param.su_op.src_sel, \
                                              cur_chunk, src)) \
                        return; \
                end \
                value = vu_vv_inst::get_elem(src, \
                                             param.type_vl.data_type, \
                                             idx % elems); \
                value = ctx.process_fp_result(mmio, param, value, \
                    param.type_vl.data_type, 2, 1'b0, 1'b1); \
                block_values[i] = value; \
                abs_bits = param.type_vl.data_type ? \
                    {1'b0, value[14:0], 16'h0} : \
                    (value & 32'h7fff_ffff); \
                if(abs_bits > max_abs) \
                    max_abs = abs_bits; \
            end \
            scale = vu_mxfp8_scale_encode( \
                max_abs, param.su_op.mxfp8_scale_round); \
 \
            /* Pass 2: quantize against the shared scale, write the */ \
            /* data bytes and the block's e8m0 scale byte. */ \
            for(int unsigned i = 0; i < blk_len; i++) begin \
                idx = base + i; \
                value = block_values[i]; \
                raw = vu_mxfp8_store_convert( \
                    value, scale, \
                    param.type_vl.data_type, \
                    param.type_vl.round_mode); \
                write_cm(dsa_mem, \
                         param.st_addr.cm_addr + idx, 2'd0, raw); \
            end \
            write_cm_scale(dsa_mem, \
                           param.st_addr.cm_addr + base, scale); \
        end \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] SU opcode=%02h vl=%0d vector-stored (MXFP8 block scale generated, round=%0d)\n", \
                param.su_op.opcode, vl, \
                param.su_op.mxfp8_scale_round); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Mask store: bit 0 is the first element; retain the original vl/8 truncation.
`define VU_SU_MASK_INST(CLASS_NAME, OPCODE) \
class CLASS_NAME extends su_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
 \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input dsa_mem_library dsa_mem, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl \
    ); \
        bit [31:0] raw; \
        int unsigned bytes; \
 \
        bytes = vl / 8; \
        for(int unsigned byte_idx = 0; byte_idx < bytes; byte_idx++) begin \
            raw = '0; \
            for(int unsigned bit_idx = 0; bit_idx < 8; bit_idx++) \
                raw[bit_idx] = ctx.resolve_su_mask_bit( \
                    mmio, param, param.su_op.src_sel, \
                    byte_idx * 8 + bit_idx); \
            write_cm(dsa_mem, \
                     param.st_addr.cm_addr + byte_idx, 2'd0, raw); \
        end \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, "[VU_INST] SU st.mask vl=%0d\n", vl); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Scalar store: one FP32 word. Preserve logging even when source resolution fails.
`define VU_SU_SCALAR_INST(CLASS_NAME, OPCODE) \
class CLASS_NAME extends su_inst_base; \
    function new(input vu_execution_context shared); \
        super.new(shared); \
    endfunction : new \
 \
    virtual function void inst_exe( \
        input vu_mmio_set mmio, \
        input dsa_mem_library dsa_mem, \
        input vu_mmio_set::vu_exec_param_s param, \
        input int unsigned vl \
    ); \
        bit [31:0] scalar; \
 \
        if(ctx.resolve_scalar_source(mmio, param, \
                                     param.su_op.src_sel, scalar)) begin \
            scalar = ctx.process_fp_result(mmio, param, scalar, \
                1'b0, 2, 1'b0, 1'b1); \
            write_cm(dsa_mem, param.st_addr.cm_addr, 2'd2, scalar); \
        end \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] SU st.s.fp32 value=%08h\n", scalar); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// Vector columns: CLASS_NAME, OPCODE, ELEM_BYTES, WRITE_SIZE.
// Floating-point stores replace inputs (when enabled) before conversion and
// never raise a conversion/NaN error. Mask data is not floating-point input.
// MXFP8/mask/scalar columns: CLASS_NAME, OPCODE. Their family selects the full
// fixed algorithm, including MXFP8's 32-element blocks and separate scale writes.
// Execution-time address checks and macro-level configuration validation are
// unchanged outside these templates. New opcodes may also require metadata,
// validation, or DPI changes; adding a row alone does not define ISA support.
`define VU_SU_INSTRUCTION_LIST \
    `VU_SU_VECTOR_INST(su_st_fp8e4m3_inst, `VU_OPCODE_LDST_FP8E4M3, 1, 2'd0) \
    `VU_SU_MXFP8_INST (su_st_mxfp8_inst,   `VU_OPCODE_LDST_MXFP8) \
    `VU_SU_VECTOR_INST(su_st_bf16_inst,    `VU_OPCODE_LDST_BF16,    2, 2'd1) \
    `VU_SU_VECTOR_INST(su_st_fp32_inst,    `VU_OPCODE_LDST_FP32,    4, 2'd2) \
    `VU_SU_MASK_INST  (su_st_mask_inst,    `VU_OPCODE_LDST_MASK) \
    `VU_SU_SCALAR_INST(su_st_scalar_inst,  `VU_OPCODE_LDST_SCALAR)

// First expansion: generate the six existing, independent instruction classes.
`VU_SU_INSTRUCTION_LIST

`undef VU_SU_VECTOR_INST
`undef VU_SU_MXFP8_INST
`undef VU_SU_MASK_INST
`undef VU_SU_SCALAR_INST

// ============================================================================
// 4. Library adapter -- unchanged public interface; automatic registration
// ============================================================================
// Second expansion: use the same catalogue to construct/register every class.
// Each block scopes its typed handle; family features affect class generation.
`define VU_SU_REGISTER(CLASS_NAME, OPCODE) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(shared); \
        register_inst(OPCODE, inst_obj); \
    end
`define VU_SU_VECTOR_INST(CLASS_NAME, OPCODE, ELEM_BYTES, WRITE_SIZE) \
`VU_SU_REGISTER(CLASS_NAME, OPCODE)
`define VU_SU_MXFP8_INST(CLASS_NAME, OPCODE) \
`VU_SU_REGISTER(CLASS_NAME, OPCODE)
`define VU_SU_MASK_INST(CLASS_NAME, OPCODE) \
`VU_SU_REGISTER(CLASS_NAME, OPCODE)
`define VU_SU_SCALAR_INST(CLASS_NAME, OPCODE) \
`VU_SU_REGISTER(CLASS_NAME, OPCODE)

class su_library;
    protected vu_execution_context ctx;
    protected su_inst_base instructions[bit [7:0]];

    function new(input vu_execution_context shared);
        ctx = shared;
        `VU_SU_INSTRUCTION_LIST
    endfunction : new

    function void register_inst(input bit [7:0] opcode, input su_inst_base inst_obj);
        instructions[opcode] = inst_obj;
    endfunction : register_inst

    function automatic void execute(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        longint unsigned byte_num;

        if(param.su_op.opcode == 0)
            return;
        if(param.su_op.opcode inside {[8'h01:8'h06]} &&
           (param.su_op.opcode == `VU_OPCODE_LDST_SCALAR ?
            param.st_addr.cm_addr[1:0] != 0 : param.st_addr.cm_addr[4:0] != 0)) begin
            mmio.report_error(`VU_ERR_CM_ADDR, 2);
            return;
        end

        // Validate the entire operation before source conversion, replacement
        // counters or any data/scale write. Arithmetic stays wider than CM_ADDR.
        byte_num = 0;
        case(param.su_op.opcode)
            `VU_OPCODE_LDST_FP8E4M3, `VU_OPCODE_LDST_MXFP8: byte_num = vl;
            `VU_OPCODE_LDST_BF16: byte_num = 64'(vl) * 2;
            `VU_OPCODE_LDST_FP32: byte_num = 64'(vl) * 4;
            `VU_OPCODE_LDST_MASK: byte_num = (64'(vl) + 7) / 8;
            `VU_OPCODE_LDST_SCALAR: byte_num = 4;
            default: begin end // Reserved opcodes are NOP, not address checks.
        endcase
        if(byte_num != 0 &&
           !dsa_mem.core_range_valid(64'(param.st_addr.cm_addr), byte_num)) begin
            mmio.report_error(`VU_ERR_CM_ADDR, 2);
            return;
        end
        if(param.su_op.opcode == `VU_OPCODE_LDST_MXFP8 &&
           !dsa_mem.core_scale_range_valid(64'(param.st_addr.cm_addr), 64'(vl) / 32)) begin
            mmio.report_error(`VU_ERR_CM_ADDR, 2);
            return;
        end

        if(instructions.exists(param.su_op.opcode))
            instructions[param.su_op.opcode].inst_exe(mmio, dsa_mem, param, vl);
        else if(ctx.log_fd != 0)
            $fwrite(ctx.log_fd,
                "[VU_INST] SU opcode=%02h reserved: NOP\n",
                param.su_op.opcode);
    endfunction : execute
endclass : su_library

`undef VU_SU_SCALAR_INST
`undef VU_SU_MASK_INST
`undef VU_SU_MXFP8_INST
`undef VU_SU_VECTOR_INST
`undef VU_SU_REGISTER
`undef VU_SU_INSTRUCTION_LIST

`endif // VU_SU_LIBRARY_SV
