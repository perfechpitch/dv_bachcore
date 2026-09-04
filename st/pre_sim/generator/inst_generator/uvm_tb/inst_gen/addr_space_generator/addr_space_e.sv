typedef enum{RESERVED,//load only.fetchable
             FETCH_VALID,FETCH_INVALID,
             LOAD_VALID,LOAD_INVALID,
             LS_VALID,LS_INVALID,
             AMO_VALID,AMO_INVALID,
             PTE_VALID,PTE_INVALID
             } addr_type_e;
typedef enum{NONE_ADDR_EXCEPT,
             VADDR_HIGH_BITS_ERR,
             PMA_ACCESS_FAULT,
             PMP_ACCESS_FAULT,
             PTE_PAGE_FAULT,
             ADDR_MISALIGN
             //MIX_ADDR_EXCEPT?????
             }addr_except_e;
//typedef enum{
//    PMP_WINDOW_MISS,
//    PMP_ATTR_ERR
//}pmp_except_e;
typedef enum{/*1G,2M,4K*/ HUGE_PAGE,BIG_PAGE,SMALL_PAGE}page_size_e;
//typedef enum{INVALID,VALID,IDEM,UNIDEM}pma_type_e;
typedef enum{INVALID,MEMORY,IO_IDEM,IO_UNIDEM}pma_type_e;
typedef struct packed{
    mode_e      mode;
    addr_type_e addr_type;
    page_size_e page_size;
    pma_type_e  pma_type;
    addr_except_e   addr_except;
    bit[63:0]   start_vaddr;
    bit[39:0]   start_paddr;
    bit[39:0]   size_in_bytes;
    bit[29:0]   addr_offset;    // save in link addr is seg start addr + addr_offset
    int         link_seg_index;
}seg_info_s;
typedef struct packed{
    mode_e          mode;
    addr_type_e     addr_type;
    addr_except_e   addr_except;
    pma_type_e      pma_type;
    bit[63:0]       vaddr;
    bit[39:0]       paddr;
    int             link_seg_index;
}addr_structure_s;
typedef struct packed{
    bit[39:0]   start_addr;
    bit[39:0]   end_addr;
    bit[2:0]    pma_attr;
    bit[3:0]    pma_window_index;
}pma_window_s;
typedef struct packed{
    bit[39:0]   addr;
    bit[7:0]    pmp_cfg;
    bit[3:0]    pmp_window_index;
}pmp_window_s;
typedef enum{PTE_ADDR_PMA_ACCESS_FAULT, PTE_ADDR_PMP_ACCESS_FAULT,
            ROOT_PTE_PBMT_NONE_ZERO,
            PTE_INVALID_PAGE_FAULT,
            MISALIGNED_SUPERPAGE,
            MISS_LEAF_PTE,
            LEAF_PTE_PBMT_3,
            LEAF_PTE_U_MISMATCH,
            LEAF_PTE_A_INVALID,
            LEAF_PTE_R_INVALID,
            LEAF_PTE_DW_INVALID,
            LEAF_PTE_X_INVALID,
             NONE_PTE_EXCEPT}pte_except_e;
typedef enum{
    VALID_1G_ROOT_PAGE, INVALID_1G_ROOT_PAGE,
    VALID_1G_LEAF_PAGE, INVALID_1G_LEAF_PAGE,
    VALID_2M_ROOT_PAGE, INVALID_2M_ROOT_PAGE,
    VALID_2M_LEAF_PAGE, INVALID_2M_LEAF_PAGE,
    VALID_4K_LEAF_PAGE, INVALID_4K_LEAF_PAGE
}pte_type_e;

   parameter pmp_window_num = 16;
    parameter pma_window_num = 16;
    parameter memory_seg_index = 0;
    parameter io_idem_seg_index = 1;
    parameter io_unidem_seg_index = 2;
    parameter invalid_seg_index = 3;
    parameter pagesize = 'h1000;
typedef struct {
    addr_type_e     addr_type;  //valid page need check attr
    pte_type_e      pte_type;
    pte_except_e    pte_except;
    bit [511:0]     next_level_cnt;
    bit[8:0]        vpn2;
    bit[39:0]       pte_addr;
    bit[63:0]       pte;
    bit[63:0]       vaddr;
    bit[63:0]       paddr;
}page_1G_pte_info_s;

typedef struct {
    addr_type_e     addr_type;  //valid page need check attr
    pte_type_e      pte_type;
    pte_except_e    pte_except;
    bit [511:0]     next_level_cnt;
    bit[8:0]        vpn2;
    bit[8:0]        vpn1;
    bit[39:0]       pte_addr;
    bit[63:0]       pte;
    bit[63:0]       vaddr;
    bit[63:0]       paddr;
}page_2M_pte_info_s;

typedef struct {
    addr_type_e     addr_type;  //valid page need check attr
    pte_type_e      pte_type;
    pte_except_e    pte_except;
    bit[8:0]        vpn2;
    bit[8:0]        vpn1;
    bit[8:0]        vpn0;
    bit[39:0]       pte_addr;
    bit[63:0]       pte;
    bit[63:0]       vaddr;
    bit[63:0]       paddr;
}page_4K_pte_info_s;
                          