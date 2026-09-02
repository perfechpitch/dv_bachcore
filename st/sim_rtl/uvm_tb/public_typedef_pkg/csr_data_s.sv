typedef struct {
    bit [31:0] mstatus;
    bit [31:0] mepc;
    bit [31:0] mcause;
    bit [31:0] mtval;
    bit [31:0] mnvec;
    bit [31:0] mcountinhibit;
    bit [31:0] mscratch;
    bit [31:0] menvcfg;
    bit [31:0] misa;
    bit [31:0] mvendorid;
    bit [31:0] mhartid;
    bit [31:0] mcycle;
    bit [31:0] minstret;
} csr_data_s;