// Memory size.
localparam int ITCM_SIZE_KB = 4;
localparam int DTCM_SIZE_KB = 8;
localparam int SM_SIZE_KB   = 128;

// Memory address map.
localparam bit [31:0] ITCM_BASE_ADDR = 32'h0000_0000;
localparam bit [31:0] DTCM_BASE_ADDR = 32'h0000_1000;
localparam bit [31:0] SM_BASE_ADDR   = 32'h0000_3000;

localparam bit [31:0] ITCM_END_ADDR = ITCM_BASE_ADDR + ITCM_SIZE_KB * 1024 - 1;
localparam bit [31:0] DTCM_END_ADDR = DTCM_BASE_ADDR + DTCM_SIZE_KB * 1024 - 1;
localparam bit [31:0] SM_END_ADDR   = SM_BASE_ADDR + SM_SIZE_KB * 1024 - 1;

localparam int unsigned ATOMIC_MEM_SIZE_KB  = 0;             // TODO
localparam bit [31:0] ATOMIC_MEM_BASE_ADDR = 32'h0000_0000; // TODO
localparam bit [31:0] ATOMIC_MEM_END_ADDR  = ATOMIC_MEM_BASE_ADDR + ATOMIC_MEM_SIZE_KB * 1024 - 1;

// REF/DUT operation source used by base_mem check queue.
typedef enum bit {
    OP_FROM_REF,
    OP_FROM_DUT
} op_source_e;

// DUT memory operation source.
typedef enum bit [1:0] {
    MEM_ITCM,
    MEM_DTCM,
    MEM_SM
} mem_source_e;

// mem_op only represents architectural LOAD/STORE.
// FETCH is not sent through mem_op.
typedef enum bit {
    MEM_LOAD,
    MEM_STORE
} mem_op_e;

// DUT memory operation.
typedef struct {
    mem_source_e source;
    mem_op_e     op;
    bit [31:0]   addr;
    bit [31:0]   data;
    bit [3:0]    mask;
} mem_op_s;

// base_mem read operation check item.
typedef struct {
    op_source_e source;
    bit [31:0]  addr;
} read_op_check_s;

// base_mem write operation check item.
typedef struct {
    op_source_e source;
    bit [31:0]  addr;
    bit [31:0]  data;
    bit [3:0]   mask;
} write_op_check_s;