package vu_inst_lib_pkg;
    import dsa_mmio_lib_pkg::*;
    `include "vu_inst_define.svh"
    typedef enum int unsigned {VU_VALU0=0, VU_VALU1=1, VU_VALU2=2} vu_valu_id_e;
    typedef bit [`VU_VRF_ENTRY_W-1:0] vu_vec_chunk_t;
    typedef struct packed {
        bit [7:0] opcode;
        bit [7:0] src1_sel;
        bit [7:0] src2_sel;
        bit [7:0] src3_sel;
    } vu_valu_op_s;
    `include "dpi/vu_dpi.sv"
    `include "vu_vv_inst.sv"
    `include "vu_inst_library.sv"
endpackage
