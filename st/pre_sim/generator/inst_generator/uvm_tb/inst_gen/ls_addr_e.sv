typedef enum {HART_MU, HART_VU, HART_DTE} tcm_hart_e;
typedef enum {LS_MEM_DTCM, LS_MEM_SHARE} ls_mem_type_e;
typedef enum {SHARE_RAND_3CORE, SHARE_SW_PARTITION} share_layout_e;

typedef struct packed {
    ls_mem_type_e   mem_type;
    addr_type_e     addr_type;
    bit[63:0]       ea;
    bit[63:0]       base_val;
    bit[11:0]       imm;
    bit[63:0]       win_lo;
    bit[63:0]       win_hi;
} ls_addr_s;
