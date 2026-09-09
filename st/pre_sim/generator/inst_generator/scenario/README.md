# Scenario 使用与调用机制

## 1. 只需要理解三层

```text
testcase / vseq
        ↓ 选择场景
scenario
        ↓ 描述 task 布局和内容
inst_generator / inst_seq_generator
        ↓ 生成指令
每个 core 的 .S / .vmem + log/task_info.log
```

公共代码负责 task/core 切换、寄存器上下文、PC、文件输出；scenario 作者只负责描述 task。

## 2. 目录

```text
uvm_tb/
├── scenario_seq/
│   ├── scenario_seq_pkg.sv
│   └── scenario_base_seq.sv
├── registry/
│   ├── directed_registry_pkg.sv
│   ├── directed_scenario_registry.sv
│   ├── random_registry_pkg.sv
│   └── random_scenario_registry.sv
└── vseq/
    ├── scenario_base_vsequence.sv
    ├── directed_vsequence.sv
    └── random_scenario_vsequence.sv

scenario/
├── directed/
│   ├── directed_scenario_list.svh
│   ├── dte/
│   ├── mu/
│   ├── vu/
│   └── workload/
└── random/
    ├── random_scenario_list.svh
    ├── dte/
    ├── mu/
    ├── vu/
    └── workload/
```

- `scenario_seq_pkg` 是唯一公共依赖。
- `directed_registry_pkg` 和 `random_registry_pkg` 彼此不依赖。
- 定向和随机分别使用自己的 registry、scenario list 和 vsequence。
- `scenario/scenario_list.svh` 已废弃，不再需要。

## 3. Vseq 调用关系

```text
inst_gen_base_vsequence
        ↓
scenario_base_vsequence
        ├── directed_vsequence
        └── random_scenario_vsequence
```

`scenario_base_vsequence` 只实现公共流程：读取场景名、创建场景、调用 `scenario.run()`。

- `directed_vsequence` 从 `directed_scenario_registry` 查找场景。
- `random_scenario_vsequence` 从 `random_scenario_registry` 查找场景。
- random vseq 不继承 directed vseq。

## 4. 新增定向 scenario

把文件放入：

```text
scenario/directed/mu/
scenario/directed/vu/
scenario/directed/dte/
scenario/directed/workload/
```

示例：

```systemverilog
class foo_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(foo_directed_scenario_seq)

    function new(string name = "foo_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(10, HART_MU,  64'h0000);
        add_directed_task(20, HART_VU,  64'h0100);
        add_directed_task(30, HART_DTE, 64'h0200);
    endfunction

    virtual function void generate_task(
        scenario_task_info     task_info,
        inst_generator          inst_gen,
        inst_seq_generator      inst_seq_gen,
        inst_seq_type_generator inst_seq_type_gen
    );
        case(task_info.task_id)
            10: inst_gen.get_specified_rand_inst(C_ADDI);
            20: inst_gen.get_specified_rand_inst(C_LI);
            30: inst_gen.get_specified_rand_inst(C_NOP);
        endcase
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(foo_directed_scenario_seq, "foo")
```

然后只在 `scenario/directed/directed_scenario_list.svh` 增加：

```systemverilog
`include "directed/mu/foo_directed_scenario_seq.sv"
```

## 5. 新增随机 scenario

随机 scenario 仍然由场景作者决定 task ID、core 和 PC；区别只是 task 内部使用随机 sequence。

```systemverilog
class foo_random_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(foo_random_scenario_seq)

    function new(string name = "foo_random_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        // task_id, core, seq_num, use_start_pc, start_pc
        add_random_task(100, HART_MU, 5, 1'b1, 64'h0);
        // 未指定 PC：紧接同 core 前一个 task 的 end_pc
        add_random_task(101, HART_MU, 5);
    endfunction
endclass

`RANDOM_SCENARIO_REGISTER(foo_random_scenario_seq, "foo_random")
```

然后只在 `scenario/random/random_scenario_list.svh` 增加：

```systemverilog
`include "random/mu/foo_random_scenario_seq.sv"
```

## 6. 公共 task 规则

- task ID 由 scenario 提供，必须全局唯一。
- 显式 start PC 必须 2-byte 对齐。
- 生成器按 MU、VU、DTE 分组静态生成。
- 同一 core 的 task 共享该 core 的 register pool。
- 不同 core 使用独立 register pool。
- 三个 core 共用 `addr_space_gen`，因此共享同一份 Share Memory 分配上下文。
- `inst_num` 根据真实指令边界数量计算，支持 16/32-bit 混合指令流。
- 当前每个 core 末尾写入 `pass_quit`；它不是未来的 `TASK_DONE` 指令。

## 7. 同一个 RV core 配置多个 task

同一个 `HART_MU`、`HART_VU` 或 `HART_DTE` 可以配置多个 task。每个 task 都要使用全局唯一的 task ID，并设置自己的 start PC。

例如，MU 配置三个 task，VU 配置两个 task：

```systemverilog
virtual function void configure_tasks();
    add_directed_task(10, HART_MU, 64'h0000);
    add_directed_task(11, HART_MU, 64'h0100);
    add_directed_task(12, HART_MU, 64'h0200);

    add_directed_task(20, HART_VU, 64'h1000);
    add_directed_task(21, HART_VU, 64'h1100);
endfunction
```

同一个 core 的 `rv_core` 相同，因此不同 task 的指令流应主要通过 `task_info.task_id` 区分：

```systemverilog
virtual function void generate_task(
    scenario_task_info      task_info,
    inst_generator          inst_gen,
    inst_seq_generator      inst_seq_gen,
    inst_seq_type_generator inst_seq_type_gen
);
    case (task_info.task_id)
        10: begin
            inst_gen.get_specified_rand_inst(C_ADDI);
            inst_gen.get_specified_rand_inst(C_LI);
        end

        11: begin
            inst_seq_gen.ls_inst_seq.seq_gen();
        end

        12: begin
            inst_gen.get_specified_rand_inst(C_NOP);
        end

        20: begin
            // VU task 20 指令流
        end

        21: begin
            // VU task 21 指令流
        end
    endcase
endfunction
```

执行和状态规则：

- 生成器按 core 分组。同一 core 内，task 按加入 `task_plan` 的先后顺序生成。
- 每个 task 开始前都会调用 `switch_task()`，切换到该 task 的 start PC。
- 同一 core 的多个 task 写入同一组文件，例如所有 MU task 都写入 `mu_test.S` 和 `mu_test.vmem`。
- `test.vmem` 在每个 task 开始处写入 `@<start_pc/4>` 地址定位标记。
- 同一 core 的多个 task 共享 register pool；当前 LS base 状态也会在这些 task 之间延续。
- 如果某个 task 需要独立的寄存器或 LS 初始状态，应在该 task 的指令流中显式完成初始化。
- 不同 task 的地址范围是否重叠由 scenario 编写者保证，公共框架目前只检查 start PC 两字节对齐。
- `pass_quit` 在该 core 的全部 task 生成完成后只添加一次，不会在每个 task 末尾自动添加。
- 每个 task 都会在 `log/task_info.log` 中单独记录 task ID、core、start PC、指令数和 end PC。

随机场景同样支持同一 core 多个 task，只需多次调用：

```systemverilog
add_random_task(100, HART_MU, 5, 1'b1, 64'h0000);
add_random_task(101, HART_MU, 5, 1'b1, 64'h0100);
```

## 8. 输出

```text
mu_test.S      mu_test.vmem
vu_test.S      vu_test.vmem
dte_test.S     dte_test.vmem
log/task_info.log
```

未使用 core 的输出文件会被清空，避免误读上一次仿真的旧文件。

## 9. 已验证命令

```text
single case=multicore_directed_test lst=directed.lst seed=1 uvm=UVM_LOW
single case=mu_random_scenario_test lst=random_scenario.lst seed=1 uvm=UVM_LOW
```
