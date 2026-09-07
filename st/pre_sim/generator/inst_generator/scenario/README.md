

## 怎么新增一个 scenario

只动两处：**自己的 .sv**，以及 **scenario_list.svh 一行 include**。不要改 `directed_seq.sv`。

1. 复制 demo，例如 `scenario/mu/foo_directed_scenario_seq.sv`：

```systemverilog
class foo_directed_scenario_seq extends directed_scenario_seq;
    `uvm_object_utils(foo_directed_scenario_seq)

    function new (string name = "foo_directed_scenario_seq");
        super.new(name);
    endfunction : new

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
        // 调用已有 inst / API / complex / helper
        // 例：void'(inst_seq_gen.ls_inst_seq.seq_gen());
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(foo_directed_scenario_seq, "foo")
```

2. 在 `scenario_list.svh` 追加：

```systemverilog
`include "mu/foo_directed_scenario_seq.sv"
```
3.在directed.lst中新增case：

 #---------------------directed scenario
 - case_name      = foo_directed_test
   uvm_tc         = directed_inst_test
   vcs_tb_args    = +directed_seq_name=foo
   batch_times    = 1
