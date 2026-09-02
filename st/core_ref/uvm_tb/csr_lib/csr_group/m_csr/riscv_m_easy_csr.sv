
`M_RO_CSR_DECLARE(mstatus,         "riscv_mstatus",        "mstatus",        'h300, RO, 32'h00001800, 32'h00000000);

`M_EASY_CSR_DECLARE(mepc,          "riscv_mepc",           "mepc",           'h341, WR, 32'h00000000, 32'hfffffffe);
`M_EASY_CSR_DECLARE(mtval,         "riscv_mtval",          "mtval",          'h343, WR, 32'h00000000, 32'hffffffff);
`M_EASY_CSR_DECLARE(mnvec,         "riscv_mnvec",          "mnvec",          'h7e0, WR, 32'h00000000, 32'hffffffff);
`M_EASY_CSR_DECLARE(mcountinhibit, "riscv_mcountinhibit",  "mcountinhibit",  'h320, WR, 32'hfffffff8, 32'hfffffffd);
`M_EASY_CSR_DECLARE(mscratch,      "riscv_mscratch",       "mscratch",       'h340, WR, 32'h00000000, 32'hffffffff);
`M_EASY_CSR_DECLARE(menvcfg,       "riscv_menvcfg",        "menvcfg",        'h30a, WR, 32'h000000f0, 32'h000000f0);
`M_EASY_CSR_DECLARE(misa,          "riscv_misa",           "misa",           'h301, WR, 32'h4094116d, 32'h00000000);

`M_RO_UPDATE_CSR_DECLARE(mcycle,   "riscv_mcycle",         "mcycle",         'hb00, RO, 32'h00000000, 32'hffffffff);
`M_RO_UPDATE_CSR_DECLARE(minstret, "riscv_minstret",       "minstret",       'hb02, RO, 32'h00000000, 32'hffffffff);