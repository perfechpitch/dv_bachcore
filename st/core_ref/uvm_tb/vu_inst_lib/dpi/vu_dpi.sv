// Centralized DPI declarations for VU arithmetic. Instruction files must not
// redeclare imports.
import "DPI-C" function int unsigned vu_fp32_add(
    input int unsigned src1,
    input int unsigned src2,
    input int unsigned round_mode
);
