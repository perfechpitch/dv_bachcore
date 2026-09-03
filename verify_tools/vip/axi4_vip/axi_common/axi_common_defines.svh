// ============================================================================
// Filename             : axi_common_defines.svh
// Author               : kippy xyz
// Created On           :
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef AXI_COMMON_DEFINES_SVH
`define AXI_COMMON_DEFINES_SVH

// Each leaf-UVC family owns one compile-time interface shape.  The macros are
// deliberately independent: all instances of one family share its shape,
// while the four families may use different shapes in the same build.

`ifndef AXI_MASTER_READ_ID_WIDTH
`define AXI_MASTER_READ_ID_WIDTH 4
`endif
`ifndef AXI_MASTER_READ_ADDR_WIDTH
`define AXI_MASTER_READ_ADDR_WIDTH 32
`endif
`ifndef AXI_MASTER_READ_DATA_WIDTH
`define AXI_MASTER_READ_DATA_WIDTH 64
`endif
`ifndef AXI_MASTER_READ_USER_WIDTH
`define AXI_MASTER_READ_USER_WIDTH 1
`endif
`ifndef AXI_MASTER_READ_MAX_BEATS
`define AXI_MASTER_READ_MAX_BEATS 256
`endif

`ifndef AXI_MASTER_WRITE_ID_WIDTH
`define AXI_MASTER_WRITE_ID_WIDTH 4
`endif
`ifndef AXI_MASTER_WRITE_ADDR_WIDTH
`define AXI_MASTER_WRITE_ADDR_WIDTH 32
`endif
`ifndef AXI_MASTER_WRITE_DATA_WIDTH
`define AXI_MASTER_WRITE_DATA_WIDTH 64
`endif
`ifndef AXI_MASTER_WRITE_USER_WIDTH
`define AXI_MASTER_WRITE_USER_WIDTH 1
`endif
`ifndef AXI_MASTER_WRITE_MAX_BEATS
`define AXI_MASTER_WRITE_MAX_BEATS 256
`endif

`ifndef AXI_SLAVER_READ_ID_WIDTH
`define AXI_SLAVER_READ_ID_WIDTH 4
`endif
`ifndef AXI_SLAVER_READ_ADDR_WIDTH
`define AXI_SLAVER_READ_ADDR_WIDTH 32
`endif
`ifndef AXI_SLAVER_READ_DATA_WIDTH
`define AXI_SLAVER_READ_DATA_WIDTH 64
`endif
`ifndef AXI_SLAVER_READ_USER_WIDTH
`define AXI_SLAVER_READ_USER_WIDTH 1
`endif
`ifndef AXI_SLAVER_READ_MAX_BEATS
`define AXI_SLAVER_READ_MAX_BEATS 256
`endif

`ifndef AXI_SLAVER_WRITE_ID_WIDTH
`define AXI_SLAVER_WRITE_ID_WIDTH 4
`endif
`ifndef AXI_SLAVER_WRITE_ADDR_WIDTH
`define AXI_SLAVER_WRITE_ADDR_WIDTH 32
`endif
`ifndef AXI_SLAVER_WRITE_DATA_WIDTH
`define AXI_SLAVER_WRITE_DATA_WIDTH 64
`endif
`ifndef AXI_SLAVER_WRITE_USER_WIDTH
`define AXI_SLAVER_WRITE_USER_WIDTH 1
`endif
`ifndef AXI_SLAVER_WRITE_MAX_BEATS
`define AXI_SLAVER_WRITE_MAX_BEATS 256
`endif

`endif
