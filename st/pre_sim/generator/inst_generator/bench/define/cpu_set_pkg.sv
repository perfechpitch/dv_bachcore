package cpu_set_pkg;
  typedef enum {
    RVI,
    RVM,
    RVA,
    RV64I,
    RV64M,
    RV64A,
    RV64F,
    RV64D,
    RV64C,
    RV64V,
    RV64ZICSR,
    RV64ZIFENCEI,
    RV64CBO,
    RVPREF,
    CUSTOM
  } inst_set_e;

  typedef enum bit [1:0] {
    M_MODE,
    S_MODE,
    U_MODE,
    D_MODE
  } mode_e;

  typedef enum {
    CSR_NONE
  } csr_set_e;
endpackage

`define SUPPORT_INST_SET '{RVI, RVM, RVA}
`define SUPPORT_PRV_MODE '{M_MODE}
`define SUPPORT_CSR_SET CSR_NONE
