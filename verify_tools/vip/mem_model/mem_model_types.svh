`ifndef MEM_MODEL_TYPES_SVH
`define MEM_MODEL_TYPES_SVH

typedef bit [63:0] mem_addr_t;
typedef bit [63:0] mem_id_t;
typedef bit [7:0]  mem_byte_t;
typedef bit [7:0]  mem_supported_size_mask_t;
typedef mem_byte_t mem_byte_array_t[];

parameter int unsigned MEM_BACKDOOR_MAX_BITS = 4096;

typedef struct {
    bit                                       success;
    int unsigned                              bit_size;
    logic [MEM_BACKDOOR_MAX_BITS-1:0]         data;
} mem_backdoor_read_result_s;

typedef enum int unsigned {
    MEM_OK,
    MEM_SLV_ERR,
    MEM_DEC_ERR,
    MEM_R_SLV_ERR,
    MEM_W_SLV_ERR,
    MEM_R_DEC_ERR,
    MEM_W_DEC_ERR
} mem_seg_attr_e;

typedef enum bit [1:0] {
    MEM_RESP_OKAY   = 2'b00,
    MEM_RESP_EXOKAY = 2'b01,
    MEM_RESP_SLVERR = 2'b10,
    MEM_RESP_DECERR = 2'b11
} mem_resp_e;

typedef enum int unsigned {
    MEM_OP_RESET,
    MEM_OP_READ,
    MEM_OP_WRITE,
    MEM_OP_COMPARE
} mem_op_e;

typedef struct {
    mem_addr_t      start_addr;
    mem_addr_t      end_addr;
    mem_seg_attr_e  attr;
    bit             exclusive_support;
    // Bit n means that an adapter may issue an access with size code n.
    // The standalone model stores this neutral capability metadata; protocol
    // adapters decide how an unsupported size maps to their response codes.
    mem_supported_size_mask_t supported_size_mask;
} mem_segment_s;

typedef struct {
    time            op_time;
    mem_op_e        op;
    mem_addr_t      addr;
    int unsigned    byte_size;
    mem_byte_array_t data;
    mem_resp_e      response;
    mem_seg_attr_e  seg_attr;
    string          note;
} mem_history_s;

class mem_exclusive_reservation;
    mem_addr_t address;
    bit [7:0]  len;
    bit [2:0]  size;
    bit [1:0]  burst;
    bit [3:0]  cache;
    bit [2:0]  prot;
    bit [3:0]  region;
    mem_addr_t low_address;
    mem_addr_t high_address;
endclass : mem_exclusive_reservation

`endif
