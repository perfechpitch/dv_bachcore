// seq 类型层：对照 inst_gen 里 inst_name_generator 抽 inst_e。
// 这里抽下一段该发哪种 inst_seq（SAFE/LS/BRANCH/...），不生成指令本身。
package inst_seq_type_pkg;
    import uvm_pkg::*;

`include "uvm_macros.svh"

    typedef enum {
        SAFE_INST_SEQ,
        LS_INST_SEQ,
        BRANCH_INST_SEQ,
        FLUSH_INST_SEQ,
        EXCEPT_INST_SEQ,
        WFI_INST_SEQ
    } inst_seq_type_e;

`include "inst_seq_type_config.sv"
`include "item/inst_seq_type_item.sv"
`include "inst_seq_type_generator.sv"

endpackage : inst_seq_type_pkg