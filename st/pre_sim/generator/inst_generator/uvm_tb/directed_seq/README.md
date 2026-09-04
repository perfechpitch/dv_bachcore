

## 怎么新增一个 scenario

只动两处：**自己的 .sv**，以及 **scenario_list.svh 一行 include**。不要改 `directed_seq.sv`。

1. 复制 demo，例如 `scenario/foo_directed_scenario_seq.sv`：

```systemverilog
class foo_directed_scenario_seq extends directed_scenario_seq;
    `uvm_object_utils(foo_directed_scenario_seq)

    function new (string name = "foo_directed_scenario_seq");
        super.new(name);
    endfunction : new

    virtual function void seq_gen(inst_gen_vsequencer vsqr);
        // 调用已有 inst / API / complex / helper
        // 例：void'(vsqr.inst_seq_gen.ls_inst_seq.seq_gen());
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(foo_directed_scenario_seq, "foo")
```

2. 在 `scenario_list.svh` 追加：

```systemverilog
`include "directed_seq/scenario/foo_directed_scenario_seq.sv"
```

