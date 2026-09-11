# Scenario 编写与 API 使用手册

本文只说明当前代码已实现、Scenario 作者可以直接使用的接口，重点区分 Directed 和 Random 两种写法。

## 1. Directed 与 Random 怎么选

| 需求 | Scenario 类型 | Testcase | 选择参数 |
| --- | --- | --- | --- |
| 明确指定 task 的指令和顺序 | Directed | `directed_inst_test` | `+directed_seq_name=<name>` |
| task 内按 Sequence 类型和权重随机生成 | Random | `random_scenario_test` | `+random_scenario_name=<name>` |

两类 Scenario 共用 `scenario_base_seq` 和 `scenario_base_vsequence`，但是 registry、scenario list 和 case list 相互独立。两个选择参数不能同时使用。

```text
testcase
  -> scenario_base_vsequence::select_scenario()
  -> directed_scenario_registry / random_scenario_registry
  -> scenario.configure_tasks()
  -> scenario_task_info[]
  -> 按 MU / VU / DTE 分组
  -> switch_task(task_id, start_pc)
  -> Directed generate_task() / Random run_random_task()
  -> 每个 Core 的 .S / .vmem
```

## 2. 公共类型和规则

Core 类型：

```systemverilog
HART_MU
HART_VU
HART_DTE
```

每个 task 对应一个 `scenario_task_info`：

| 字段 | 含义 |
| --- | --- |
| `task_id` | Scenario 指定的全局唯一 task ID |
| `rv_core` | task 属于 MU、VU 或 DTE |
| `kind` | Directed task 或 Random task |
| `use_start_pc` | 是否采用 Scenario 指定的 PC |
| `start_pc` | task 起始取指地址 |
| `seq_num` | Random task 执行顶层 Sequence 的次数，不是最终指令条数 |
| `seq_select_mode` | Random task 使用 AUTO 或 PLAN |
| `seq_plan` | Random task 的 Sequence 类型和权重 |

Scenario 作者不需要自己创建 `scenario_task_info`，应调用 `add_directed_task()` 或 `add_random_task()`。

公共执行规则：

- task ID 必须全局唯一；
- 显式 start PC 必须按 2 字节对齐；
- 同一 Core 的多个 task 是否地址重叠由 Scenario 作者保证；
- 生成器按 MU、VU、DTE 分组静态生成，同一 Core 内按添加顺序执行；
- 同一 Core 的 task 共用该 Core 的 register pool，不同 Core 使用独立 register pool；
- 三个 Core 的 ITCM/DTCM 物理独立，可以使用相同地址窗口；Share Memory 地址窗口共享；
- 每个 task 结束后，公共执行器自动调用 `pass_quit_seq`，当前输出 `TASK_DONE`；
- Scenario 不负责打开文件、切换 Core、切换 task 或打印 task log。

## 3. Directed Scenario：可以调用哪些 API

Directed Scenario 负责：

1. `configure_tasks()` 描述有哪些 task；
2. `generate_task()` 描述每个 task 的具体指令流。

### 3.1 添加 Directed task

```systemverilog
add_directed_task(
    int unsigned task_id,
    tcm_hart_e   rv_core,
    bit [63:0]   start_pc
);
```

| 参数 | 功能 |
| --- | --- |
| `task_id` | 全局唯一 ID；重复会触发 `UVM_FATAL` |
| `rv_core` | `HART_MU`、`HART_VU` 或 `HART_DTE` |
| `start_pc` | 明确指定的 task 起始 PC |

```systemverilog
virtual function void configure_tasks();
    add_directed_task(10, HART_MU,  64'h0000);
    add_directed_task(11, HART_MU,  64'h0200);
    add_directed_task(20, HART_VU,  64'h0000);
    add_directed_task(30, HART_DTE, 64'h0000);
endfunction
```

不同 Core 的 ITCM 独立，所以可以使用相同 start PC。

### 3.2 生成每个 task 的内容

```systemverilog
virtual function void generate_task(
    scenario_task_info      task_info,
    inst_generator          inst_gen,
    inst_seq_generator      inst_seq_gen,
    inst_seq_type_generator inst_seq_type_gen
);
```

公共执行器对每个 Directed task 调用一次。推荐使用 `task_info.task_id` 区分不同 task：

```systemverilog
case (task_info.task_id)
    10: begin /* MU task 10 */ end
    11: begin /* MU task 11 */ end
    20: begin /* VU task 20 */ end
endcase
```

### 3.3 指定指令名称，操作数随机

```systemverilog
inst_gen.get_specified_rand_inst(inst_name);
```

功能：指令名称固定，寄存器和 immediate 由指令类随机生成。

```systemverilog
inst_gen.get_specified_rand_inst(C_ADDI);
inst_gen.get_specified_rand_inst(C_LI);
inst_gen.get_specified_rand_inst(C_NOP);
```

适合“必须出现某条指令，但操作数可以随机”的场景。

### 3.4 指定指令名称和操作数

```systemverilog
inst_gen.get_specified_inst(inst_name, rs1, rs2, rd, imm);
```

功能：调用者明确给出寄存器编号和 immediate。

```systemverilog
inst_gen.get_specified_inst(DSAW,  5, 6, 0, 32'h0);
inst_gen.get_specified_inst(DSAWI, 5, 0, 0, 32'h1234);
inst_gen.get_specified_inst(DSAR,  5, 0, 7, 32'h0);
inst_gen.get_specified_inst(DSARI, 0, 0, 8, 32'habcd);
inst_gen.get_specified_inst(LOOP,  5, 6, 0, 32'h4);
```

参数如何进入编码由指令格式决定。例如 R-type 使用 `rs1/rs2/rd`，I-type 使用 `rs1/rd/imm`。调用前应确认目标指令的 immediate 单位和编码方式。

### 3.5 明确生成一种随机 Sequence

```systemverilog
inst_seq_gen.rand_seq(seq_type);
```

| `seq_type` | 功能 |
| --- | --- |
| `SAFE_INST_SEQ` | 一段安全计算指令流 |
| `LS_INST_SEQ` | 一段 Load/Store/AMO 指令流，并按需初始化 LS base |
| `BRANCH_INST_SEQ` | 一段 Branch/Jump/Loop 指令流 |
| `C_INST_SEQ` | 一段压缩指令流 |
| `FLUSH_INST_SEQ` | 一段 Flush 指令流，要求平台已使能 |
| `EXCEPT_INST_SEQ` | 一段 Exception 指令流，要求平台已使能 |

```systemverilog
inst_seq_gen.rand_seq(LS_INST_SEQ);
inst_seq_gen.rand_seq(BRANCH_INST_SEQ);
```

这是“场景固定 Sequence 类别、类别内部继续随机”的 Directed 写法。LS 指令流优先使用此接口，因为它会按需完成 LS base 初始化。

### 3.6 底层单条随机接口

```systemverilog
inst_gen.get_rand_inst(inst_type);
```

`inst_type` 可使用 `SAFE_INST`、`LS_INST`、`BRANCH_INST`、`FLUSH_INST`、`EXCEPT_INST`。这个接口只随机一条指定类别的指令，但不负责建立该类别依赖的上下文：

- `get_rand_inst(LS_INST)` 不初始化 LS base；
- Branch 指令可能缺少 Sequence 设置的目标信息；
- 一般优先调用 `inst_seq_gen.rand_seq()`。

### 3.7 Directed 完整模板

```systemverilog
class demo_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(demo_directed_scenario_seq)

    function new(string name = "demo_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(10, HART_MU, 64'h0000);
        add_directed_task(11, HART_MU, 64'h0200);
        add_directed_task(20, HART_VU, 64'h0000);
    endfunction

    virtual function void generate_task(
        scenario_task_info      task_info,
        inst_generator          inst_gen,
        inst_seq_generator      inst_seq_gen,
        inst_seq_type_generator inst_seq_type_gen
    );
        case (task_info.task_id)
            10: begin
                inst_gen.get_specified_rand_inst(C_ADDI);
                inst_gen.get_specified_inst(DSAW, 5, 6, 0, '0);
            end
            11: inst_seq_gen.rand_seq(LS_INST_SEQ);
            20: inst_gen.get_specified_rand_inst(C_LI);
        endcase
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(demo_directed_scenario_seq, "demo_directed")
```

### 3.8 注册和运行 Directed Scenario

1. 文件放在 `scenario/directed/mu/`、`vu/`、`dte/` 或 `workload/`；
2. 文件末尾调用 `DIRECTED_SCENARIO_REGISTER`；
3. 在 `scenario/directed/directed_scenario_list.svh` 中 include；
4. 在 `rsim/case_lst/directed.lst` 增加 case。

```text
- case_name      = demo_directed_test
  uvm_tc         = directed_inst_test
  vcs_tb_args    = +directed_seq_name=demo_directed
  batch_times    = 1
```

```csh
single case=demo_directed_test lst=directed.lst seed=1 uvm=UVM_LOW
```

当前已注册：

| Registry 名称 | 文件 |
| --- | --- |
| `multicore_directed` | `directed/workload/multicore_directed_scenario_seq.sv` |

## 4. Random Scenario：可以调用哪些 API

Random Scenario 只描述 task 和随机偏好。通常只重写 `configure_tasks()`，不重写 `generate_task()`，也不直接调用 `inst_generator`。

### 4.1 添加 Random task

```systemverilog
add_random_task(
    int unsigned task_id      = SCENARIO_AUTO_TASK_ID,
    tcm_hart_e   rv_core      = HART_MU,
    int unsigned seq_num      = SCENARIO_AUTO_SEQ_NUM,
    bit          use_start_pc = 1'b0,
    bit [63:0]   start_pc     = '0
);
```

| 参数 | 功能 |
| --- | --- |
| `task_id` | 全局唯一 task ID；省略时由 `scenario_base_seq` 在 `0..15` 内随机分配，并检查当前 plan 内唯一性 |
| `rv_core` | MU、VU 或 DTE |
| `seq_num` | 顶层 Sequence 选择并执行次数；省略时使用本次 `inst_gen_case_config.seq_num` 随机值 |
| `use_start_pc` | `1` 使用指定 PC；`0` 接续该 Core 当前 PC |
| `start_pc` | 显式起始 PC，必须 2 字节对齐 |

```systemverilog
add_random_task(100, HART_MU, 20, 1'b1, 64'h0);
add_random_task(101, HART_MU, 10);                 // 接续MU当前PC
add_random_task(200, HART_VU, 20, 1'b1, 64'h0);  // VU独立ITCM

// 推荐的自动参数写法：返回实际分配的 task_id，供后续权重 API 使用。
task_id = add_random_task(.rv_core(HART_MU),
                          .use_start_pc(1'b1),
                          .start_pc(64'h0));
```

### 4.2 配置 Sequence 类型偏好

```systemverilog
set_task_seq_weight(
    int unsigned      task_id,
    inst_seq_type_e   seq_type,
    scenario_weight_e weight = WEIGHT_MEDIUM
);
```

必须在对应的 `add_random_task()` 之后调用。

| Sequence 类型 | 内容 | 生效条件 |
| --- | --- | --- |
| `SAFE_INST_SEQ` | 安全计算指令流 | SAFE 未关闭 |
| `LS_INST_SEQ` | Load/Store/AMO 指令流 | LS 未关闭 |
| `BRANCH_INST_SEQ` | Branch/Jump/Loop 指令流 | Branch 未关闭 |
| `C_INST_SEQ` | 压缩指令流 | `support_inst_set` 包含 `RVC` |
| `FLUSH_INST_SEQ` | Flush 指令流 | 平台已开启 Flush |
| `EXCEPT_INST_SEQ` | Exception 指令流 | 平台已开启 Exception |

| 权重枚举 | 内部相对值 | 含义 |
| --- | ---: | --- |
| `WEIGHT_DISABLE` | 0 | 禁止选择 |
| `WEIGHT_LOW` | 1 | 低偏好 |
| `WEIGHT_MEDIUM` | 4 | 中等偏好 |
| `WEIGHT_HIGH` | 10 | 高偏好 |

```systemverilog
add_random_task(100, HART_MU, 30, 1'b1, 64'h0);
set_task_seq_weight(100, SAFE_INST_SEQ,   WEIGHT_HIGH);
set_task_seq_weight(100, LS_INST_SEQ,     WEIGHT_MEDIUM);
set_task_seq_weight(100, BRANCH_INST_SEQ, WEIGHT_LOW);
```

### 4.3 AUTO 和 PLAN

还可以直接配置 SAFE、LS 或 BRANCH 的下一层选择权重：

```systemverilog
set_task_subseq_weight(task_id, seq_type, subseq_type, weight);
```

例如：

```systemverilog
set_task_subseq_weight(100, LS_INST_SEQ, SCENARIO_LS_RAND,   WEIGHT_HIGH);
set_task_subseq_weight(100, LS_INST_SEQ, SCENARIO_LS_LINEAR, WEIGHT_LOW);
```

当前支持的直接下一层：

| 父 `seq_type` | 可配置的 `subseq_type` |
| --- | --- |
| `SAFE_INST_SEQ` | `SCENARIO_SAFE_INT_CAL`、`SCENARIO_SAFE_FLOAT_CAL`、`SCENARIO_SAFE_BRANCH`、`SCENARIO_SAFE_INT_LS`、`SCENARIO_SAFE_CUSTOM_DSA` |
| `LS_INST_SEQ` | `SCENARIO_LS_RAND`、`SCENARIO_LS_LINEAR`、`SCENARIO_LS_MEMCPY` |
| `BRANCH_INST_SEQ` | `SCENARIO_BRANCH_SINGLE`、`SCENARIO_BRANCH_LOOP`、`SCENARIO_BRANCH_JALR` |

规则：必须先添加 Random task；父 `seq_type` 不能被显式关闭。每个 task 开始时先恢复平台随机默认值；未配置的顶层类型和子类型都继续使用默认随机权重，只有显式 `WEIGHT_DISABLE` 才关闭，LOW/MEDIUM/HIGH 才改变偏好。C、Flush、Exception 当前没有独立的下一层权重选择器。

AUTO：只调用 `add_random_task()`，不配置权重。该 task 使用平台 `inst_gen_case_config.inst_seq_type_cfg` 的默认权重。

```systemverilog
add_random_task(100, HART_MU, 20, 1'b1, 64'h0);
```

PLAN：只要调用一次 `set_task_seq_weight()`，该 task 自动进入 PLAN；PLAN 从平台随机默认权重开始，只覆盖显式列出的类型。

```systemverilog
add_random_task(100, HART_MU, 20, 1'b1, 64'h0);
set_task_seq_weight(100, SAFE_INST_SEQ, WEIGHT_HIGH);
set_task_seq_weight(100, LS_INST_SEQ,   WEIGHT_LOW);
```

PLAN 规则：

- 未列出的类型保留平台随机默认权重；
- 只有显式 `WEIGHT_DISABLE` 才把对应类型权重置为 0；
- 同一 task 的同一种类型不能配置两次；
- 所有类型均为 `WEIGHT_DISABLE` 会触发 `UVM_FATAL`；
- 非零权重请求平台未开启的类型会触发 `UVM_FATAL`；
- 权重是相对偏好，不保证短样本数量严格等于比例；
- 每个 task 开始前先恢复平台默认权重，再应用自己的显式覆盖，不会继承前一个 task 的配置。

### 4.4 Random 完整模板

```systemverilog
class demo_random_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(demo_random_scenario_seq)

    function new(string name = "demo_random_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        int unsigned task_num;
        int unsigned task_id;

        task_num = random_task_num();

        for(int i = 0; i < task_num; i++) begin
            task_id = add_random_task(.rv_core(HART_MU),
                                      .use_start_pc(i == 0),
                                      .start_pc(64'h0));
            set_task_seq_weight(task_id, SAFE_INST_SEQ, WEIGHT_HIGH);
            set_task_seq_weight(task_id, LS_INST_SEQ,   WEIGHT_LOW);
        end
    endfunction
endclass

`RANDOM_SCENARIO_REGISTER(demo_random_scenario_seq, "demo_random")
```

该示例不指定 task ID 和 seq_num：ID 由基类在 `0..15` 内随机分配，seq_num 来自 `inst_gen_case_config`。`+seq_num=<N>` 可以覆盖配置对象的随机结果。`random_task_num()` 默认在 `1..8` 内随机 task 数，并统一读取 `+scenario_task_num=<N>` 覆盖。

### 4.5 注册和运行 Random Scenario

1. 文件放在 `scenario/random/mu/`、`vu/`、`dte/` 或 `workload/`；
2. 文件末尾调用 `RANDOM_SCENARIO_REGISTER`；
3. 在 `scenario/random/random_scenario_list.svh` 中 include；
4. 在 `rsim/case_lst/random.lst` 增加 case。

```text
- case_name      = demo_random_test
  uvm_tc         = random_scenario_test
  vcs_tb_args    = +random_scenario_name=demo_random+test_mode=INT_TEST
  batch_times    = 1
```

```csh
single case=demo_random_test lst=random.lst seed=1 uvm=UVM_LOW
```

当前已注册：

| Registry 名称 | 功能 |
| --- | --- |
| `mu_random` | SAFE高、LS中、BRANCH低 |
| `mu_safe_random` | 仅SAFE |
| `mu_branch_random` | 仅BRANCH |
| `mu_c_random` | 仅压缩Sequence |
| `mu_ls_random` | 仅LS |

## 5. 不应由 Scenario 作者调用的方法

| 内部方法 | 调用者 | 功能 |
| --- | --- | --- |
| `build_task_plan()` | 公共 vsequence | 清空、建立并校验task计划 |
| `validate_task_plan()` | `build_task_plan()` | 检查task ID和PC对齐 |
| `get_task_count()` | 公共 vsequence | 获取task数量 |
| `get_task()` | 公共 vsequence | 按索引读取task |
| `select_scenario()` | 公共 vsequence | 根据plusarg选择Scenario |
| `execute_scenario()` | 公共 vsequence | 切Core、切task、生成和输出 |
| `run_random_task()` | 公共 vsequence | 应用权重并执行Random task |

`set_task_layout()`、`add_task()` 和 `seq_gen()` 是旧单Core Directed Scenario 的兼容接口。新场景应使用：

```text
Directed: configure_tasks + add_directed_task + generate_task
Random:   configure_tasks + add_random_task + set_task_seq_weight（可选）
          + set_task_subseq_weight（可选，需先使能父seq_type）
```

## 6. 常用 Plusarg

| Plusarg | 使用位置 | 功能 |
| --- | --- | --- |
| `+directed_seq_name=<name>` | 公共执行器 | 选择Directed Scenario |
| `+random_scenario_name=<name>` | 公共执行器 | 选择Random Scenario |
| `+xlen=32/64` | Case Config | 覆盖XLEN，当前平台默认32 |
| `+test_mode=INT_TEST` | Case Config | 设置测试模式 |
| `+seq_num=<N>` | Case Config | 旧平台级Sequence数量；Random task主要使用自己的`seq_num` |
| `+scenario_task_num=<N>` | `scenario_base_seq::random_task_num()` | 覆盖默认的 `1..8` 随机结果 |
| `+seq_num=<N>` | `inst_gen_case_config` | 覆盖每个未指定 seq_num 的 Random task 使用的配置随机值 |

## 7. 输出与检查

```text
mu_test.S       mu_test.vmem
vu_test.S       vu_test.vmem
dte_test.S      dte_test.vmem
log/task_info.log
log/inst_seq.log
log/inst_gen_config.log
sim.log
```

`log/task_info.log` 记录每个 task 的 `task_id/rv_core/start_pc/inst_num/end_pc`。

Random PLAN 模式在 `UVM_LOW` 下还会输出：

```text
SCENARIO_WEIGHT      Scenario偏好转换后的运行权重
SCENARIO_SEQ_RESULT  每类Sequence的实际选择次数
```

未使用 Core 的 `.S/.vmem` 也会被创建并清空，避免误用上一次仿真的旧输出。
