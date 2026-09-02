typedef enum {
    INST_WRITE,
    ABS_WRITE,
    EXCEPT_UPDATE,
    INST_READ,
    ABS_READ
} csr_access_type_e;

typedef enum {
    NONE_CSR_EXCEPT,
    WRITE_READ_ONLY_CSR,
    FIND_NO_CSR
} csr_acc_except_type_e;

`define CSR_DECLARATION(N) \
    riscv_``N ``N;

`define CSR_CREATE(N,M) \
    ``N = riscv_``N::type_id::create(``M); \
    csr_queue.push_back(``N); \
    ``N.csr_lib_log = csr_lib_log;

`define M_CSR_CREATE \
    `CSR_CREATE(mstatus,       "mstatus") \
    `CSR_CREATE(mcause,        "mcause") \
    `CSR_CREATE(mtvec,         "mtvec") \
    `CSR_CREATE(mepc,          "mepc") \
    `CSR_CREATE(mtval,         "mtval") \
    `CSR_CREATE(mnvec,         "mnvec") \
    `CSR_CREATE(mcountinhibit, "mcountinhibit") \
    `CSR_CREATE(mscratch,      "mscratch") \
    `CSR_CREATE(menvcfg,       "menvcfg") \
    `CSR_CREATE(misa,          "misa") \
    `CSR_CREATE(mcycle,        "mcycle") \
    `CSR_CREATE(minstret,      "minstret")

`define CSR_WRITE \
    val = (val & ~write_en) | (wdata & write_en); \
    csr = val;

`define NORMAL_SET_VAL \
    function void set_val(bit [63:0] wdata); \
        `CSR_WRITE \
    endfunction

// S: CSR name
// A: CSR address
// T: access attribute
// R: reset value
// W: write mask
`define CSR_NEW(S,A,T,R,W) \
    csr_name = S; \
    csr_addr = A; \
    rw_type = T; \
    reset_val = R; \
    write_en = W; \
    csr = reset_val; \
    val = csr;

// Normal writable M-mode CSR.
`define M_EASY_CSR_DECLARE(C,N,S,A,T,R,W) \
typedef struct packed { \
    bit [63:0] val; \
} ``C``_field_s; \
class riscv_``C extends riscv_csr; \
    ``C``_field_s csr; \
    `uvm_object_utils(riscv_``C) \
    function new(string name = ``N); \
        super.new(name); \
        `CSR_NEW(S,A,T,R,W) \
    endfunction \
    function csr_acc_except_type_e csr_acc_except_gen(csr_access_type_e acc_type); \
        return NONE_CSR_EXCEPT; \
    endfunction \
    `NORMAL_SET_VAL \
endclass

// Read-only to architectural CSR instruction.
`define M_RO_CSR_DECLARE(C,N,S,A,T,R,W) \
typedef struct packed { \
    bit [63:0] val; \
} ``C``_field_s; \
class riscv_``C extends riscv_csr; \
    ``C``_field_s csr; \
    `uvm_object_utils(riscv_``C) \
    function new(string name = ``N); \
        super.new(name); \
        `CSR_NEW(S,A,T,R,W) \
    endfunction \
    function csr_acc_except_type_e csr_acc_except_gen(csr_access_type_e acc_type); \
        if(acc_type == INST_WRITE) \
            return WRITE_READ_ONLY_CSR; \
        return NONE_CSR_EXCEPT; \
    endfunction \
endclass

// Architecturally read-only, but reference model can update value internally.
`define M_RO_UPDATE_CSR_DECLARE(C,N,S,A,T,R,W) \
typedef struct packed { \
    bit [63:0] val; \
} ``C``_field_s; \
class riscv_``C extends riscv_csr; \
    ``C``_field_s csr; \
    `uvm_object_utils(riscv_``C) \
    function new(string name = ``N); \
        super.new(name); \
        `CSR_NEW(S,A,T,R,W) \
    endfunction \
    function csr_acc_except_type_e csr_acc_except_gen(csr_access_type_e acc_type); \
        if(acc_type == INST_WRITE) \
            return WRITE_READ_ONLY_CSR; \
        return NONE_CSR_EXCEPT; \
    endfunction \
    `NORMAL_SET_VAL \
endclass