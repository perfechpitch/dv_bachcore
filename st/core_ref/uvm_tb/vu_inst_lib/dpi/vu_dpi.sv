// Centralized DPI declarations for VU numeric operations and format conversion.
// Instruction files must not redeclare imports.
import "DPI-C" function int unsigned vu_bf16_to_fp32(
    input int unsigned value
);

import "DPI-C" function int unsigned vu_fp32_to_bf16(
    input int unsigned bits,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_fp_alu(
    input int unsigned opcode,
    input int unsigned src1,
    input int unsigned src2,
    input int unsigned src3,
    input int unsigned data_type,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_fp_compare(
    input int unsigned opcode,
    input int unsigned src1,
    input int unsigned src2,
    input int unsigned data_type
);

import "DPI-C" function int unsigned vu_fp_class(
    input int unsigned src,
    input int unsigned data_type,
    input int unsigned class_mask
);

import "DPI-C" function int unsigned vu_fp_vsfu(
    input int unsigned opcode,
    input int unsigned src,
    input int unsigned data_type,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_fp_sexe(
    input int unsigned opcode,
    input int unsigned src1,
    input int unsigned src2
);

import "DPI-C" function chandle vu_sum_create(
    input int unsigned initial_fp32
);

import "DPI-C" function void vu_sum_add(
    input chandle accumulator,
    input int unsigned fp32_bits
);

import "DPI-C" function int unsigned vu_sum_finish(
    input chandle accumulator,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_load_convert(
    input int unsigned opcode,
    input int unsigned raw,
    input int unsigned data_type,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_store_convert(
    input int unsigned opcode,
    input int unsigned value,
    input int unsigned data_type,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_mxfp8_scale_encode(
    input int unsigned max_abs_bits,
    input int unsigned round_up
);

import "DPI-C" function int unsigned vu_mxfp8_load_convert(
    input int unsigned raw,
    input int unsigned scale,
    input int unsigned data_type,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_mxfp8_store_convert(
    input int unsigned value,
    input int unsigned scale,
    input int unsigned data_type,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_fp32_add(
    input int unsigned src1,
    input int unsigned src2,
    input int unsigned round_mode
);

import "DPI-C" function int unsigned vu_fp32_min(
    input int unsigned src1,
    input int unsigned src2,
    input int unsigned round_mode
);
