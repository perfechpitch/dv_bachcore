typedef struct {
    logic [31:0] base;
    logic [31:0] size;
} dsa_mem_region_s;

localparam logic [31:0] CORE_MEM_BASE     = 32'hxxxx_xxxx; // TODO: confirm global address.
localparam logic [31:0] CORE_MEM_SIZE     = 32'h0010_0000;
localparam logic [31:0] MATRIX_MEM_BASE   = 32'h0400_0000;
localparam logic [31:0] MATRIX_MEM_SIZE   = 32'h0200_0000;
localparam logic [31:0] CORE_SCALE_MEM_BASE = 32'hxxxx_xxxx; // TODO: confirm global address.
localparam logic [31:0] CORE_SCALE_MEM_SIZE = 32'h0000_8000;
localparam logic [31:0] MATRIX_SCALE_MEM_BASE = 32'hxxxx_xxxx; // TODO: confirm global address.
localparam logic [31:0] MATRIX_SCALE_MEM_SIZE = 32'h0040_0000;

localparam int CORE_MEM_SIZE_KB   = CORE_MEM_SIZE / 1024;
localparam int MATRIX_MEM_SIZE_KB = MATRIX_MEM_SIZE / 1024;
localparam int CORE_SCALE_MEM_SIZE_KB = CORE_SCALE_MEM_SIZE / 1024;
localparam int MATRIX_SCALE_MEM_SIZE_KB = MATRIX_SCALE_MEM_SIZE / 1024;

localparam dsa_mem_region_s CORE_MEM_REGION = '{CORE_MEM_BASE, CORE_MEM_SIZE};
localparam dsa_mem_region_s MATRIX_MEM_REGION = '{MATRIX_MEM_BASE, MATRIX_MEM_SIZE};
localparam dsa_mem_region_s CORE_SCALE_MEM_REGION =
    '{CORE_SCALE_MEM_BASE, CORE_SCALE_MEM_SIZE};
localparam dsa_mem_region_s MATRIX_SCALE_MEM_REGION =
    '{MATRIX_SCALE_MEM_BASE, MATRIX_SCALE_MEM_SIZE};
function automatic bit in_region(bit [31:0] addr, dsa_mem_region_s region);
    return addr >= region.base && addr < region.base + region.size;
endfunction : in_region
