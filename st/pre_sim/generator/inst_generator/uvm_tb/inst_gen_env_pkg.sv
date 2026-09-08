package inst_gen_env_pkg;
    import  uvm_pkg::*;
    import  cpu_set_pkg::*;
    import  inst_seq_type_pkg::*;
    import  inst_gen_pkg::*;
    import  inst_seq_pkg::*;
    import  directed_seq_pkg::*;

`include "uvm_macros.svh"

`include "task_info_config.sv"
`include "inst_gen_case_config.sv"

`include "inst_gen_vsequencer.sv"
`include "inst_gen_environment.sv"
`include "vseq/inst_gen_base_vsequence.sv"
`include "vseq/asm_gen_vsequence.sv"
`include "vseq/seq_debug_vsequence.sv"
`include "vseq/c_inst_vsequence.sv"
`include "vseq/directed_vsequence.sv"
endpackage : inst_gen_env_pkg
