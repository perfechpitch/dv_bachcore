typedef struct {
    bit [1:0]  retire_num;
    bit [31:0] retire_pc[2];
} inst_retire_structure;
typedef enum bit[32:0]{
        INST_ADDR_MISALIGN            = {1'b0, 32'd0},
        INST_ACCESS_FAULT             = {1'b0, 32'd1},
        ILLEGAL_INST                  = {1'b0, 32'd2},
        BREAKPOINT                    = {1'b0, 32'd3},
        LOAD_ADDR_MISALIGN            = {1'b0, 32'd4},
        LOAD_ACCESS_FAULT             = {1'b0, 32'd5},
        STORE_AMO_ADDR_MISALIGN       = {1'b0, 32'd6},
        STORE_AMO_ACCESS_FAULT        = {1'b0, 32'd7},
        M_ECALL                       = {1'b0, 32'd11},
        NONE_EXCEPT                   = {1'b1, 32'h7fffffff}
}exception_type_e;

typedef enum {FETCH, LOAD, STORE, AMO, LR,SC}mem_access_type_e;

typedef enum {M_MODE} mode_e;

typedef enum {WR,RO}csr_rw_type_e;

typedef struct packed{
    bit[31:0] pc;
    exception_type_e    except;
    bit [31:0] except_info;
    bit lrbit;
    bit [1:0] lrsize;
    bit [31:0] lraddr;
}core_state_s;

typedef struct packed{
    mem_access_type_e acc_type;
    bit[1:0]  size;
    bit[31:0] addr;
}addr_state_s;

//different test can add other test features.
//test features are test_modes' particular scenes cross
//scenes are releaized by agts. so test features are trsanslated to agts config
typedef enum{
    SINGLE_CORE,               // one test core , another core interface connect zero
    SINGLE_CORE_WITH_SNOOP,    // one test core + test scache, another core snoop req simulated by snoop uvc
    MULT_CORE
    // can be extended
}work_mode_e;

typedef enum{
    NORMAL_TEST,    // no int, debug req, bus err ...
    DEBUG_TEST,     // support debug req test
    RESET_TEST      // support reset test
    //TODO: cross scenes
}test_mode_e;

typedef enum{
    WHOLE_REF   , // all ref functions work
    BYPASS_DUT,   // bypass dut
    IGNORE_REF
}ref_mode_e;


typedef enum {
ABS_REG,
ABS_FAST_ACCESS,
HALT,
RESUME,
ABS_EXE} dm_req_type_e;

typedef enum {
GPR,
FPR,
VPR,
NONE,
CSR} reg_type_e;

typedef enum {
    /*machine-level CSR address*/
    MVENDORID      = 'hF11,
    MARCHID        = 'hF12,
    MICACHESIZE        = 'hFC0,
    MDCACHESIZE        = 'hFC1,
    MSCACHESIZE        = 'hFC2,
    MIMPID         = 'hF13,
    MHARTID        = 'hF14,
    MSTATUS        = 'h300,
    MISA           = 'h301,
    MEDELEG        = 'h302,
    MIDELEG        = 'h303,
    MIE            = 'h304,
    MTVEC          = 'h305,


    MCOUNTEREN     = 'h306,
    MSCRATCH       = 'h340,
    MEPC           = 'h341,
    MCAUSE         = 'h342,
    MTVAL          = 'h343,
    MIP            = 'h344,
    PMPCFG0        = 'h3a0,
    PMPCFG2        = 'h3a2,
    PMPADDR0       = 'h3b0,
    PMPADDR1       = 'h3b1,
    PMPADDR2       = 'h3b2,
    PMPADDR3       = 'h3b3,
    PMPADDR4       = 'h3b4,
    PMPADDR5       = 'h3b5,
    PMPADDR6       = 'h3b6,
    PMPADDR7       = 'h3b7,
    PMPADDR8       = 'h3b8,
    PMPADDR9       = 'h3b9,
    PMPADDR10       = 'h3ba,
    PMPADDR11       = 'h3bb,
    PMPADDR12       = 'h3bc,
    PMPADDR13       = 'h3bd,
    PMPADDR14       = 'h3be,
    PMPADDR15       = 'h3bf,
    MCYCLE          = 'hb00,
    MINSTRET        = 'hb02,
    MHPMCOUNTER3    = 'hb03,
    MHPMCOUNTER4    = 'hb04,
    MHPMCOUNTER5    = 'hb05,
    MHPMCOUNTER6    = 'hb06,
    MHPMCOUNTER7    = 'hb07,
    MHPMCOUNTER8    = 'hb08,
    MHPMCOUNTER9    = 'hb09,
    MHPMCOUNTER10    = 'hb0a,
    MHPMCOUNTER11    = 'hb0b,
    MHPMCOUNTER12    = 'hb0c,
    MHPMCOUNTER13    = 'hb0d,
    MHPMCOUNTER14    = 'hb0e,
    MHPMCOUNTER15    = 'hb0f,
    MHPMCOUNTER16    = 'hb10,
    MHPMCOUNTER17    = 'hb11,
    MHPMCOUNTER18    = 'hb12,
    MHPMCOUNTER19    = 'hb13,
    MHPMCOUNTER20    = 'hb14,
 MHPMCOUNTER21    = 'hb15,
    MHPMCOUNTER22    = 'hb16,
    MHPMCOUNTER23    = 'hb17,
    MHPMCOUNTER24    = 'hb18,
    MHPMCOUNTER25    = 'hb19,
    MHPMCOUNTER26    = 'hb1a,
    MHPMCOUNTER27    = 'hb1b,
    MHPMCOUNTER28    = 'hb1c,
    MHPMCOUNTER29    = 'hb1d,
    MHPMCOUNTER30    = 'hb1e,
    MHPMCOUNTER31    = 'hb1f,
    MCOUNTINHIBIT    = 'h320,
    MHPMEVENT3        = 'h323,
    MHPMEVENT4        = 'h324,
    MHPMEVENT5        = 'h325,
    MHPMEVENT6        = 'h326,
    MHPMEVENT7        = 'h327,
    MHPMEVENT8        = 'h328,
    MHPMEVENT9        = 'h329,
    MHPMEVENT10       = 'h32a,
    MHPMEVENT11       = 'h32b,
    MHPMEVENT12       = 'h32c,
    MHPMEVENT13       = 'h32d,
    MHPMEVENT14       = 'h32e,
    MHPMEVENT15       = 'h32f,
    MHPMEVENT16       = 'h330,
    MHPMEVENT17       = 'h331,
    MHPMEVENT18       = 'h332,
    MHPMEVENT19       = 'h333,
    MHPMEVENT20       = 'h334,
 MHPMEVENT21       = 'h335,
    MHPMEVENT22       = 'h336,
    MHPMEVENT23       = 'h337,
    MHPMEVENT24       = 'h338,
    MHPMEVENT25       = 'h339,
    MHPMEVENT26       = 'h33a,
    MHPMEVENT27       = 'h33b,
    MHPMEVENT28       = 'h33c,
    MHPMEVENT29       = 'h33d,
    MHPMEVENT30       = 'h33e,
    MHPMEVENT31       = 'h33f,
    //TSELECT          = 'h7A0,
    //TDATA1           = 'h7A1,
    //TDATA2           = 'h7A2,
    //TDATA3           = 'h7A3,
    DCSR             = 'h7B0,
    DPC              = 'h7B1,
    DSCRATCH0        = 'h7B2,
    DSCRATCH1        = 'h7B3,
    /*trigger reg*/
    TSELECT          = 'h7a0,
    MCONTROL         = 'h7a1,
    TDATA2           = 'h7a2,
    TEXTRA64         = 'h7a3,
    TINFO            = 'h7a4,
    TCONTROL         = 'h7a5,
    MCONTEXT         = 'h7a8,
    SCONTEXT         = 'h7aa,
    MPREFETCH_CFG    = 'h7c0,
    SPREFETCH_CFG    = 'h5c0,
    UPREFETCH_CFG    = 'h800,
    CACHE_TAG        = 'hbff,
//mmu csr
      STLBCTRL  = 'h7c5,
      STLBEV    = 'h7c6,
      STLBEP    = 'h7c7,
      STLBIDX   = 'h7c8,
      SFTLBEV   = 'h7c9,
      SFTLBEP   = 'h7ca,

    /*new csr add */
    SAMPLE_CTRL                = 'h7b4,
    SCACHE_CFG                 = 'h7c4,
    TRACE_ASYNC_EXCEPT         = 'hc000,
    TRACE_RETIRE_PC            = 'hc001,
    TRACE_BRANCH_RETIRE_TARGET = 'hc002,
    TRACE_IF1_STATUS           = 'hc008,
    TRACE_DCACHE_STATE         = 'hc010,
    TRACE_STBF_STATE           = 'hc011,
    TRACE_LDQ_STATE            = 'hc012,
    TRACE_STQ_STATE            = 'hc013,
    TRACE_SMQ_STATE            = 'hc018,
    TRACE_SCQ_STATE            = 'hc019,
    TRACE_CSQ_STATE            = 'hc01a,
    TRACE_BRQ_STATE            = 'hc01b,
    TRACE_BWQ_STATE            = 'hc01c,
    TRACE_BCQ_STATE            = 'hc01d,
    /*trace no use*/

 PERF_CNT_CTRL              = 'h5c1,
    PERF_CNT_0                 = 'hdc0,
    PERF_CNT_1                 = 'hdc1,
    PERF_CNT_2                 = 'hdc2,
    PERF_CNT_3                 = 'hdc3,
    PERF_CNT_4                 = 'hdc4,
    PERF_CNT_5                 = 'hdc5,
    PERF_CNT_6                 = 'hdc6,
    PERF_CNT_7                 = 'hdc7,
    PERF_CNT_8                 = 'hdc8,
    PERF_CNT_9                 = 'hdc9,
    PERF_CNT_10                = 'hdca,
    PERF_CNT_11                = 'hdcb,
    PERF_CNT_12                = 'hdcc,
    PERF_CNT_13                = 'hdcd,
    PERF_CNT_14                = 'hdce,
    PERF_CNT_15                = 'hdcf,
    PERF_CNT_16                = 'hdd0,
    PERF_CNT_17                = 'hdd1,
    PERF_CNT_18                = 'hdd2,
    PERF_CNT_19                = 'hdd3,
    PERF_CNT_20                = 'hdd4,
    PERF_CNT_21                = 'hdd5,
    PERF_CNT_22                = 'hdd6,
    PERF_CNT_23                = 'hdd7,
    PERF_CNT_24                = 'hdd8,
    PERF_CNT_25                = 'hdd9,
    PERF_CNT_26                = 'hdda,
    PERF_CNT_27                = 'hddb,
    PERF_CNT_28                = 'hddc,
    PERF_CNT_29                = 'hddd,
    PERF_CNT_30                = 'hdde,
    PERF_CNT_31                = 'hddf,

/**/
    PMA_START_ADDRESS_0        = 'hbc1,
    PMA_START_ADDRESS_1        = 'hbc5,
    PMA_START_ADDRESS_2        = 'hbc9,
    PMA_START_ADDRESS_3        = 'hbcd,
    PMA_START_ADDRESS_4        = 'hbd1,
    PMA_START_ADDRESS_5        = 'hbd5,
    PMA_START_ADDRESS_6        = 'hbd9,
    PMA_START_ADDRESS_7        = 'hbdd,
    PMA_START_ADDRESS_8        = 'hbe1,
    PMA_START_ADDRESS_9        = 'hbe5,
    PMA_START_ADDRESS_10       = 'hbe9,
    PMA_START_ADDRESS_11       = 'hbed,
    PMA_START_ADDRESS_12       = 'hbf1,
    PMA_START_ADDRESS_13       = 'hbf5,
    PMA_START_ADDRESS_14       = 'hbf9,
    PMA_START_ADDRESS_15       = 'hbfd,
    PMA_END_ADDRESS_0          = 'hbc2,
    PMA_END_ADDRESS_1          = 'hbc6,
    PMA_END_ADDRESS_2          = 'hbca,
    PMA_END_ADDRESS_3          = 'hbce,
    PMA_END_ADDRESS_4          = 'hbd2,
    PMA_END_ADDRESS_5          = 'hbd6,
    PMA_END_ADDRESS_6          = 'hbda,
    PMA_END_ADDRESS_7          = 'hbde,
    PMA_END_ADDRESS_8          = 'hbe2,
    PMA_END_ADDRESS_9          = 'hbe6,
    PMA_END_ADDRESS_10         = 'hbea,
    PMA_END_ADDRESS_11         = 'hbee,
    PMA_END_ADDRESS_12         = 'hbf2,
    PMA_END_ADDRESS_13         = 'hbf6,
    PMA_END_ADDRESS_14         = 'hbfa,
    PMA_END_ADDRESS_15         = 'hbfe,
    MSPECIAL_PMA_START_ADDRESS = 'h7c2,
    MSPECIAL_PMA_END_ADDRESS   = 'h7c3,
    MSPECIAL_PMA_ATTRIBUTE     = 'h7c1,
PMA_ATTRIBUTE_0            = 'hbc0,
    PMA_ATTRIBUTE_1            = 'hbc4,
    PMA_ATTRIBUTE_2            = 'hbc8,
    PMA_ATTRIBUTE_3            = 'hbcc,
    PMA_ATTRIBUTE_4            = 'hbd0,
    PMA_ATTRIBUTE_5            = 'hbd4,
    PMA_ATTRIBUTE_6            = 'hbd8,
    PMA_ATTRIBUTE_7            = 'hbdc,
    PMA_ATTRIBUTE_8            = 'hbe0,
    PMA_ATTRIBUTE_9            = 'hbe4,
    PMA_ATTRIBUTE_10           = 'hbe8,
    PMA_ATTRIBUTE_11           = 'hbec,
    PMA_ATTRIBUTE_12           = 'hbf0,
    PMA_ATTRIBUTE_13           = 'hbf4,
    PMA_ATTRIBUTE_14           = 'hbf8,
    PMA_ATTRIBUTE_15           = 'hbfc,
    //kalm_add
    MENVCFG                    = 'h30a,
    SENVCFG                    = 'h10a,
    SCOUNTOVF                  = 'hda0,
    MSIMPOINT_CFG              = 'h7cf,
    MCONFIGPTR                 = 'hf15,
    MCACHEERROR                = 'hfe2,
    MIPREFCFG                  = 'h7cb,
    MDPREFCFG                  = 'h7cc,
    MZONEFLUSH_STARTADDR       = 'h7cd,
    MZONEFLUSH_ENDADDR         = 'h7ce,
    REQBUSERRPADDR_ADDR        = 'hfe3

} csr_reg_type_e;
 typedef enum {
    NONE_RI,
    RI_VILL_SET,
    RI_EMUL_MISALIGN,
    RI_OVERLAP,
    RI_FLOAT_DISABLE,
    RI_VECTOR_DISABLE,
    RI_VSTART_NONEZERO,
    //RI_VSTART_GTEQ_VL,
    RI_VM_OVERLAP,
    RI_EMUL_ILLEGAL,
    RI_EEW_ILLEGAL,
    RI_SEG_REGOVERFLOW,
    RI_NR_INVALID,
    //RI_VSTART_OVERLAP,
    //RI_VL_ZERO,
    RI_FLOAT_SEW_ILLEGAL,
    RI_FRM_ILLEGAL
  } vector_ri_e;
