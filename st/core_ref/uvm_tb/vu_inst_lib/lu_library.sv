`ifndef VU_LU_LIBRARY_SV
`define VU_LU_LIBRARY_SV

// Include after vu_execution_context, the VU types, and the common DPI imports.
// Class definitions and construction/registration use the SAME instruction list.

// ============================================================================
// 1. Shared instruction interface and load address helper
// ============================================================================

virtual class lu_inst_base;
    protected vu_execution_context ctx;

    function new(input vu_execution_context shared);
        ctx = shared;
    endfunction : new

    // A skipped block contains 32 elements, independently of the load width.
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

    pure virtual function void inst_exe(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
endclass : lu_inst_base

// ============================================================================
// 2. Complete instruction-family templates: address / execution / results / logs
// ============================================================================
// READ_SIZE: 0=8 bits, 1=16 bits, 2=32 bits. Address step follows this width.
// USE_SCALE and USE_MASK are per-class constants. LU never reports numerical
// NaN/Inf conversion errors; it preserves their class without replacement.
// MASK_SRC selects MRF_P0/P1; the existing MRF read index selects the mask data.
// USE_MASK=0 ignores MASK_SRC and preserves the original unmasked behavior.
// Masked-off elements remain zero and perform no data/scale read or conversion.
`define VU_LU_VECTOR_INST(CLASS_NAME, OPCODE, READ_SIZE, ADDR_ALIGN, USE_SCALE, USE_MASK, MASK_SRC, LOG_SUFFIX) \
class CLASS_NAME extends lu_inst_base; \
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
        int unsigned elems_per_chunk; \
        int unsigned chunks; \
        int unsigned physical_elem; \
        bit [31:0] addr; \
        bit [31:0] raw; \
        bit [31:0] value; \
        bit [7:0] scale; \
        longint unsigned last_addr; \
 \
        /* 1. Preflight the entire load before any memory read/publication. */ \
        if(param.ld_addr.cm_addr % ADDR_ALIGN != 0) begin \
            mmio.report_error(`VU_ERR_CM_ADDR, 1); \
            return; \
        end \
        last_addr = 64'(param.ld_addr.cm_addr) + \
                    64'(load_physical_elem(vl - 1, param.lu_op.stride_run, \
                                          param.lu_op.stride_skip)) * (1 << READ_SIZE); \
        if(!dsa_mem.core_range_valid(last_addr, 1 << READ_SIZE) || \
           (USE_SCALE && !dsa_mem.core_scale_range_valid(last_addr, 1))) begin \
            mmio.report_error(`VU_ERR_CM_ADDR, 1); \
            return; \
        end \
 \
        /* 2. Allocate the active result chunks; do not touch inactive chunks. */ \
        elems_per_chunk = vu_vv_inst::elems_per_entry(param.type_vl.data_type); \
        chunks = (vl + elems_per_chunk - 1) / elems_per_chunk; \
        for(int unsigned chunk = 0; chunk < chunks; chunk++) \
            ctx.lu_vector_result[chunk] = '0; \
 \
        /* 3. Address/stride -> memory read -> conversion -> result element. */ \
        for(int unsigned elem = 0; elem < vl; elem++) begin \
            if(USE_MASK) begin \
                if(!ctx.predicate_bit(mmio, param, MASK_SRC, elem)) \
                    continue; \
            end \
            physical_elem = load_physical_elem( \
                elem, param.lu_op.stride_run, param.lu_op.stride_skip); \
            addr = param.ld_addr.cm_addr + physical_elem * (1 << READ_SIZE); \
            raw = dsa_mem.read_core(READ_SIZE, addr); \
            if(USE_SCALE) begin \
                scale = dsa_mem.read_core_scale(2'd0, addr); \
                value = vu_mxfp8_load_convert(raw, scale, \
                                             param.type_vl.data_type, \
                                             param.type_vl.round_mode); \
            end else begin \
                value = vu_load_convert(OPCODE, raw, \
                                        param.type_vl.data_type, \
                                        param.type_vl.round_mode); \
            end \
            vu_vv_inst::set_elem( \
                ctx.lu_vector_result[elem / elems_per_chunk], \
                param.type_vl.data_type, elem % elems_per_chunk, value); \
        end \
 \
        /* 4. Publish the vector result and retain the existing log format. */ \
        ctx.lu_vector_valid = 1'b1; \
        mmio.set_lu_bypass(ctx.lu_vector_result[0]); \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] LU opcode=%02h vl=%0d vector-loaded%s\n", \
                OPCODE, vl, LOG_SUFFIX); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Mask load: bit 0 is the first element; a partial final byte is allowed.
`define VU_LU_MASK_INST(CLASS_NAME, OPCODE, ADDR_ALIGN) \
class CLASS_NAME extends lu_inst_base; \
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
        int unsigned bytes; \
        bit [31:0] raw; \
 \
        bytes = (vl + 7) / 8; \
        if(param.ld_addr.cm_addr % ADDR_ALIGN != 0 || \
           !dsa_mem.core_range_valid(param.ld_addr.cm_addr, bytes)) begin \
            mmio.report_error(`VU_ERR_CM_ADDR, 1); \
            return; \
        end \
        for(int unsigned byte_idx = 0; byte_idx < bytes; byte_idx++) begin \
            raw = dsa_mem.read_core(2'd0, param.ld_addr.cm_addr + byte_idx); \
            for(int unsigned bit_idx = 0; bit_idx < 8; bit_idx++) \
                if(byte_idx * 8 + bit_idx < vl) \
                    ctx.lu_mask_result[byte_idx * 8 + bit_idx] = raw[bit_idx]; \
        end \
        ctx.lu_mask_valid = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, "[VU_INST] LU ld.mask vl=%0d\n", vl); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// Scalar load: exactly one FP32 word, independent of VL/type/stride.
`define VU_LU_SCALAR_INST(CLASS_NAME, OPCODE, ADDR_ALIGN) \
class CLASS_NAME extends lu_inst_base; \
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
        if(param.ld_addr.cm_addr % ADDR_ALIGN != 0 || \
           !dsa_mem.core_range_valid(param.ld_addr.cm_addr, 4)) begin \
            mmio.report_error(`VU_ERR_CM_ADDR, 1); \
            return; \
        end \
        ctx.lu_scalar_result = dsa_mem.read_core(2'd2, param.ld_addr.cm_addr); \
        ctx.lu_scalar_valid = 1'b1; \
        if(ctx.log_fd != 0) \
            $fwrite(ctx.log_fd, \
                "[VU_INST] LU ld.s.fp32 result=%08h\n", ctx.lu_scalar_result); \
    endfunction : inst_exe \
endclass : CLASS_NAME

// ============================================================================
// 3. Instruction catalogue -- the ONLY class/opcode registration list
// ============================================================================
// Vector columns:
//   CLASS, OPCODE, READ_SIZE, ADDR_ALIGN(bytes),
//   USE_SCALE, USE_MASK, MASK_SRC, LOG_SUFFIX
// Change USE_MASK to 1 to enable masking for that row; MASK_SRC is MRF_P0/P1.
// Registration publishes the same row's mask features to the shared checker.
// All existing instructions default to USE_MASK=0; no MMIO encoding is changed.
// Result kinds and VL/stride legality live in vu_execution_context and are
// checked by vu_config_checker before execution; address checks stay above.
// MXFP8 reads its E8M0 scale through read_core_scale(data_address).
// FP32->BF16 follows the memory-conversion DPI; NaN/Inf never raise a LU error.
// Mask/scalar columns: CLASS, OPCODE, ADDR_ALIGN(bytes).
//
// Modify an existing instruction's row to change a listed feature.
// Add a row of the same family to define AND register another instruction.
// A new opcode still requires a definition in vu_inst_define.svh and matching
// upper-level source-kind/legality rules; this file does not change those rules.
`define VU_LU_INSTRUCTION_LIST \
    `VU_LU_VECTOR_INST(lu_ld_fp8e4m3_inst, `VU_OPCODE_LDST_FP8E4M3, 2'd0, 32, 1'b0, 1'b0, `VU_SRC_MRF_P0, "") \
    `VU_LU_VECTOR_INST(lu_ld_mxfp8_inst,   `VU_OPCODE_LDST_MXFP8,   2'd0, 32, 1'b1, 1'b0, `VU_SRC_MRF_P0, " (MXFP8 block scale applied)") \
    `VU_LU_VECTOR_INST(lu_ld_bf16_inst,    `VU_OPCODE_LDST_BF16,    2'd1, 32, 1'b0, 1'b0, `VU_SRC_MRF_P0, "") \
    `VU_LU_VECTOR_INST(lu_ld_fp32_inst,   `VU_OPCODE_LDST_FP32,    2'd2, 32, 1'b0, 1'b0, `VU_SRC_MRF_P0, "") \
    `VU_LU_MASK_INST  (lu_ld_mask_inst,   `VU_OPCODE_LDST_MASK,   32) \
    `VU_LU_SCALAR_INST(lu_ld_scalar_inst, `VU_OPCODE_LDST_SCALAR,  4)

// First expansion: generate six independent instruction classes.
`VU_LU_INSTRUCTION_LIST

`undef VU_LU_VECTOR_INST
`undef VU_LU_MASK_INST
`undef VU_LU_SCALAR_INST

// ============================================================================
// 4. Library adapter and automatic opcode registration
// ============================================================================
// Second expansion: reuse the same catalogue to construct/register each class.
// Mask features are registered with the object so checker policy follows the
// same catalogue row; no separate per-opcode mask switch needs maintenance.
`define VU_LU_REGISTER(CLASS_NAME, OPCODE, USE_MASK, MASK_SRC) \
    begin \
        CLASS_NAME inst_obj; \
        inst_obj = new(shared); \
        register_inst(OPCODE, inst_obj, USE_MASK, MASK_SRC); \
    end
`define VU_LU_VECTOR_INST(CLASS_NAME, OPCODE, READ_SIZE, ADDR_ALIGN, USE_SCALE, USE_MASK, MASK_SRC, LOG_SUFFIX) \
`VU_LU_REGISTER(CLASS_NAME, OPCODE, USE_MASK, MASK_SRC)
`define VU_LU_MASK_INST(CLASS_NAME, OPCODE, ADDR_ALIGN) \
`VU_LU_REGISTER(CLASS_NAME, OPCODE, 1'b0, 8'h00)
`define VU_LU_SCALAR_INST(CLASS_NAME, OPCODE, ADDR_ALIGN) \
`VU_LU_REGISTER(CLASS_NAME, OPCODE, 1'b0, 8'h00)

class lu_library;
    protected vu_execution_context ctx;
    protected lu_inst_base instructions[bit [7:0]];

    function new(input vu_execution_context shared);
        ctx = shared;
        `VU_LU_INSTRUCTION_LIST
    endfunction : new

    protected function void register_inst(
        input bit [7:0] opcode,
        input lu_inst_base inst_obj,
        input bit use_mask,
        input bit [7:0] mask_src
    );
        instructions[opcode] = inst_obj;
        ctx.register_lu_mask_feature(opcode, use_mask, mask_src);
    endfunction : register_inst

    // Compatibility helpers use the same context as all instruction objects.
    function void set_log(input int fd);
        ctx.set_log(fd);
    endfunction : set_log

    // VL is already clamped by the enclosing VU library. Preserve its original
    // active-range mask clearing and leave vector storage untouched here.
    function automatic void clear_execution_state(input int unsigned vl);
        ctx.clear_lu_execution_state(vl);
    endfunction : clear_execution_state

    function bit has_vector();
        return ctx.lu_vector_valid;
    endfunction : has_vector

    function bit has_mask();
        return ctx.lu_mask_valid;
    endfunction : has_mask

    function bit has_scalar();
        return ctx.lu_scalar_valid;
    endfunction : has_scalar

    function vu_vec_chunk_t get_vector_chunk(input int unsigned chunk);
        return ctx.lu_vector_result[chunk];
    endfunction : get_vector_chunk

    function bit get_mask_bit(input int unsigned elem);
        return ctx.lu_mask_result[elem];
    endfunction : get_mask_bit

    function bit [31:0] get_scalar();
        return ctx.lu_scalar_result;
    endfunction : get_scalar

    function int result_kind(input bit [7:0] opcode);
        return ctx.lu_result_kind(opcode);
    endfunction : result_kind

    // Return legality only. The caller reports the existing CFG error and
    // stops the whole macro instruction before any execution side effects.
    function bit check_config(
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        return ctx.lu_check_config(param, vl) &&
               ctx.lu_mask_config_valid(param.lu_op.opcode);
    endfunction : check_config

    function void execute(
        input vu_mmio_set mmio,
        input dsa_mem_library dsa_mem,
        input vu_mmio_set::vu_exec_param_s param,
        input int unsigned vl
    );
        if(param.lu_op.opcode == 8'h00)
            return;
        if(instructions.exists(param.lu_op.opcode))
            instructions[param.lu_op.opcode].inst_exe(mmio, dsa_mem, param, vl);
        else if(ctx.log_fd != 0)
            $fwrite(ctx.log_fd, "[VU_INST] LU opcode=%02h reserved: NOP\n",
                    param.lu_op.opcode);
    endfunction : execute
endclass : lu_library

`undef VU_LU_SCALAR_INST
`undef VU_LU_MASK_INST
`undef VU_LU_VECTOR_INST
`undef VU_LU_REGISTER
`undef VU_LU_INSTRUCTION_LIST

`endif // VU_LU_LIBRARY_SV
