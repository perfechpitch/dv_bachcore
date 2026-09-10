# 随机指令生成器机制文档

> 工程：`st/pre_sim/generator/inst_generator`
>
> 本文描述当前实现的机制与边界，不替代 RISC-V ISA 规范。修改生成器机制时，应同步更新第 10 章的变更记录。

## 1. 文档维护规则

- 每次改变指令可选集合、编码、PC、地址、任务布局、配置入口或输出格式时，更新对应章节，并在第 10 章追加一条记录。
- 记录应说明：日期、改动目的、影响文件、验证命令、未覆盖边界。
- 不把未实际接入 sequence 的指令写成“已支持”；应区分“已建类/入队”和“已接入语义生成路径”。

## 2. 工程入口与层次

### 2.1 编译与仿真

- 运行目录：`rsim/`
- 单用例入口：`/fastone/users/yi.tian/work/dv_bachcore/verify_tools/script/single`
- filelist 配置：`rsim/flist_gen.cfg`，生成 `rsim/flist_gen.f`。
- 顶层：`bench/generator_tb_top.sv`。
- UVM testcase package：`uvm_tc/generator_tc_pkg.sv`。

典型命令：

```csh
cd rsim
setenv VERIFY_TOOL_PATH /fastone/users/yi.tian/work/dv_bachcore/verify_tools
setenv VCS_TB_ARGS "+xlen=32"
$VERIFY_TOOL_PATH/script/single case=ls_inst_test lst=int.lst seed=1 uvm=UVM_LOW
```

### 2.2 Package/include 层次

- `bench/define/cpu_set_pkg.sv`：ISA capability 枚举及默认支持集合。
- `uvm_tb/inst_gen/inst_gen_pkg.sv`：指令生成 package；包含 instruction group 与 generator。
- `uvm_tb/inst_gen/inst_gen_e.sv`：指令枚举 `inst_e`。
- `uvm_tb/inst_gen/inst_generator.sv`：指令队列、随机分派、PC/VMEM 输出。
- `uvm_tb/inst_seq_gen/`：按 safe、LS、branch 等 sequence 组织指令流。
- `uvm_tb/inst_gen_case_config.sv`：testcase 到 `inst_gen_config` 的配置汇聚。

## 3. 配置与 capability

`inst_gen_config` 位于 `uvm_tb/inst_gen/inst_gen_config.sv`，承载：

- `xlen`：通过 `+xlen=32` / `+xlen=64` 覆盖，非法值应报 UVM 错误。
- `support_inst_set[]`：启用的 ISA capability 集合。
- `support_inst_name[]`：在 `inst_queue_gen()` 建队列时由实际创建的类填充；各随机 name generator 均受此集合约束。
- `float_en`、GPR/FPR 完整性、VMEM 输出开关。

当前 capability 枚举仍保留历史命名（如 RV64I/RV64M/RV64A）；不得仅因 XLEN=32 重命名或删除旧枚举。队列创建集中在 `inst_generator::inst_queue_gen()`，由 XLEN 选择 RV32 或 RV64 的公开创建宏。

## 4. 指令队列与随机选择

1. `inst_queue_gen()` 根据 `support_inst_set[]` 与 `xlen` 创建 instruction object。
2. 每个对象经 `INST_GEN_CREATE` 写入 `inst_gen_queue[]`，并把其 `inst_name` 加入 `support_inst_name[]`。
3. `safe_inst_generator`、`ls_inst_generator`、`branch_inst_generator` 等先随机出指令名；`inst_generator::get_rand_inst()` 再在队列中匹配对象并调用对应生成函数。
4. 队列建立后打印：`[INST_QUEUE_PROFILE] xlen=<...> queue_size=<...>`；debug 模式可查看最终支持的 instruction name 列表。

### XLEN 过滤

- RV32：I common、M common、A word。
- RV64：上述 common 集合加 I/M/A 的 RV64-only 集合。
- RV32 排除：LD、SD、LWU、整数 `*W`、LR.D/SC.D、AMO*.D。
- F/D/V 不属于 I/M/A 宏，继续受其历史 capability 控制。

## 5. RVC 与混合指令长度

### 5.1 已建类及队列

- RVC capability 在 `cpu_set_pkg.sv`，枚举在 `inst_gen_e.sv`。
- 压缩指令类文件：`uvm_tb/inst_gen/inst_group/c_inst.sv`。
- `RVC` 是外部 compressed capability，XLEN 仍由 `xlen` 独立配置。
- 内部创建层级为 `C_COMMON_INST_CREATE`、`C_RV32_ONLY_INST_CREATE`、`C_RV64_ONLY_INST_CREATE`，再分别组合成 `RV32C_INST_CREATE` 与 `RV64C_INST_CREATE`。
- `inst_queue_gen()` 是唯一的 XLEN 分支点：XLEN=32 调用 `RV32C_INST_CREATE`，XLEN=64 调用 `RV64C_INST_CREATE`。
- `C.JAL` 只位于 RV32-only 集合；RV64-only 宏目前保留为空，待加入 C.ADDIW/C.LD/C.SD/C.LDSP/C.SDSP/C.SUBW/C.ADDW 等类。
- 压缩浮点指令当前未建类；未来加入时必须同时受 RVC 与 F/D capability 控制。

### 5.2 公共 PC 与 VMEM

`inst_generator::inst_print()` 通过 `inst[1:0]` 判定长度：

- `inst[1:0] == 2'b11`：32-bit，PC 增加 4；
- 否则：16-bit，PC 增加 2。

`vmem_write_inst()` 将 16-bit 指令按两个 halfword 打包进既有的 32-bit VMEM word 格式。当前生成器的 `@` 地址沿用 word-address 约定；若 core reference loader 按 byte-address 解释，必须在集成前统一约定。

### 5.3 当前边界

当前 RV32C 状态按语义路径分类：

| 语义路径 | 指令 | 状态 |
| --- | --- | --- |
| SAFE integer | C.ADDI、C.NOP、C.LI、C.LUI、C.SLLI、C.SRLI、C.SRAI、C.ANDI、C.MV、C.ADD、C.SUB、C.XOR、C.OR、C.AND | 已接入；避免 hint/reserved encoding，并保护 LS base/x2 |
| SP arithmetic | C.ADDI4SPN、C.ADDI16SP | 已接入 SAFE；复用 RVC LS base 初始化并维护 SP 状态，详见 7.3 |
| LS | C.LW、C.SW、C.LWSP、C.SWSP | 已接入，详见第 7 章 |
| direct control flow | C.J、C.JAL、C.BEQZ、C.BNEZ | 已接入，详见第 8 章；C.JAL 仅 RV32 |
| indirect control flow | C.JR、C.JALR | 已接入 JALR sequence，详见第 8 章 |
| exception | C.EBREAK | 只接入 exception EBREAK 类型，不进入 normal SAFE 流 |

### 5.4 全压缩指令随机 sequence

`c_inst_sequence` 是独立于既有 SAFE/LS/branch 权重的压缩随机 payload：

- 使用与 `safe_inst_sequence` 相同的 `inst_seq_info_item + safe_seq_config` 长度机制；
- 候选为可线性安全执行的 20 条压缩算术/SP/LS 指令；
- 每个 task 在 payload 前复用 LS base config 初始化 x2、x8-x15 base 和地址窗口；
- C.J/C.JAL/C.BEQZ/C.BNEZ 与 C.JR/C.JALR 不进入该随机集合，继续由 branch/JALR sequence 约束目标；
- C.EBREAK 不进入该随机集合，继续由 exception sequence 控制；
- `c_inst_vsequence` 只调度 `c_inst_sequence`，`c_inst_test` 用于独立回归。

## 6. Task 与输出布局

- task 切换时记录 task 的起始 PC 与该 task 在 `inst_pc_history[]` 中的起始索引。
- `task_info_config.sv` 输出每个 task 的 `task_id`、`start_pc`、`inst_num`、`end_pc`。
- `test.S` 包含逐条指令的 PC 注释；`test.vmem` 为后续取指读取的镜像。
- `inst_pc_history[]` 保存真实指令边界，供 JALR 目标选择，避免将压缩指令流错误地按 4-byte 步长索引。

## 7. Load/store 地址生成

### 7.1 普通 LS

- 基址配置：`uvm_tb/inst_seq_gen/seq/ls_seq/ls_base_config_seq.sv`。
- 地址生成：`uvm_tb/inst_gen/ls_addr_generator.sv`。
- 基址寄存器池：`uvm_tb/inst_gen/register_pool.sv`。

流程：先在 DTCM 或 Share window 内抽有效 EA；拆为 `base_val + imm12`；用 LI 等 sequence 将 `base_val` 写入基址 GPR；随后 load/store 在“窗口与 imm12 可达范围”的交集内再抽 EA。合法访问使用对齐地址；非法访存另走 misalign 机制。

### 7.2 C.LW/C.SW（已接入）

`C.LW/C.SW` 已接入 `ls_inst_generator` 的 load/store 候选：

- rs1'、rd'/rs2' 均限制为 `x8–x15`；
- RVC 启用时，LS base 配置优先保留并初始化至少一个 `x8–x15` 基址；
- offset 使用 CL/CS 的 unsigned word offset：`0x0–0x7c`，4-byte 对齐；
- 普通随机 LS 与线性 LS 的指定 imm 路径均适配；不可编码或越 window 的指定 imm 将重抽合法压缩 offset；
- 输出显示解码后的 `c.lw/c.sw rd_or_rs2, offset(rs1)`。


`C.LWSP/C.SWSP` 同样接入 LS_LOAD/LS_STORE，但固定使用 x2：RVC base config 单独在合法 LS window 内生成并写入 x2；offset 为 `0x0–0xfc` 的 4-byte 倍数，并保证完整 word 访问不越界。x2 从普通 base/GPR 随机目的寄存器池中保留。

### 7.3 C.ADDI4SPN/C.ADDI16SP 的 SP 状态

所有随机 sequence 在生成前都会先执行 LS base config；RVC 下该步骤把合法窗口中的 base 写入 x2，并且该 LI 写入必须早于普通 base 配置中可能插入的 SAFE 指令，因此两条 SP 指令不会读取未初始化或仅更新了元数据的新 SP。

- `C.ADDI4SPN`：rd' 仅选 x8–x15，uimm 为 4–1020 的非零 4-byte 倍数；目的寄存器排除现有 LS base，避免破坏地址元数据。x2 只读，不改变 SP。
- `C.ADDI16SP`：立即数只从 [-512,496] 的非零 16-byte 倍数中选择，并要求更新后的 x2 仍处于绑定 LS window 且至少容纳一个 word 访问；生成后同步更新 register_pool 的 x2 地址和 ls_addr_generator 的 bound-base 值，因此后续 C.LWSP/C.SWSP 使用新 SP。
- RV32 C.JAL 隐式写 x1；RV32C 下 x1 不参与普通 LS base 分配，避免 link 写回破坏 LS 元数据。
- 当前状态跟踪是生成顺序上的线性状态；若运行时控制流重复执行跨越 C.ADDI16SP 的环路，SP 漂移仍属于未建模边界。

## 8. Branch/jump 与混合长度目标

- B/J 指令立即数按实际 byte delta 编码，不再以“指令数 × 4”推导。
- single branch sequence 先记录目标 PC、生成 body，再以当前 PC 与目标 PC 的差生成回跳 branch。
- loop sequence 同样记录每个 loop body 的真实起点，并以实际 delta 编码。
- JALR 从当前 task 的 `inst_pc_history[]` 中选目标，因此目标是已生成的真实 16/32-bit 指令边界。

`C.J`、RV32-only `C.JAL`、`C.BEQZ`、`C.BNEZ` 已接入 single-branch sequence：先计算真实 byte delta，再按距离选择并编码。C.B 仅允许 -256..+254 bytes，C.J/C.JAL 仅允许 -2048..+2046 bytes，均要求 2-byte 对齐；超范围自动保留普通 B/JAL。C.JAL 编码隐式写 x1，硬件 link 值为当前 C.JAL PC + 2。loop sequence 仍使用指定寄存器的普通 B-type。

`C.JR/C.JALR` 已接入 JALR sequence：仅对有效取指目标启用压缩形式，从当前 task 的真实 PC 边界中选择目标，将目标 PC 精确写入 rs1，再随机发出 C.JR 或 C.JALR；非法取指目标仍沿用普通 JALR 路径。

`C.EBREAK` 保留在 RVC queue，但不属于 SAFE/LS/branch 候选。只有既有 exception generator 选中 EBREAK 类型且 RVC 启用时，才在普通 EBREAK 与 C.EBREAK 之间选择。

## 9. 验证与检查

推荐最小检查：

```csh
$VERIFY_TOOL_PATH/script/single case=normal_rand_test lst=int.lst seed=1 uvm=UVM_LOW
$VERIFY_TOOL_PATH/script/single case=branch_inst_test lst=int.lst seed=1 uvm=UVM_LOW
$VERIFY_TOOL_PATH/script/single case=ls_inst_test lst=int.lst seed=1 uvm=UVM_LOW
$VERIFY_TOOL_PATH/script/single case=c_addi16sp_directed_test lst=directed.lst seed=1 uvm=UVM_LOW
# int.lst 的 all_rand_test 当前引用不存在的 rand_flush_except_inst_test；
# 不修改 testcase/filelist 时，可复用 single 已编译的 simv，以源码真实类名验证异常路径：
cd sim_single
./simv +UVM_TESTNAME=rand_flush_except_test +UVM_VERBOSITY=UVM_LOW +ntb_random_seed=1 +xlen=32 +test_mode=INT_TEST +UVM_NO_RELNOTES +ntb_stop_on_constraint_solver_error=1 -l sim.log
```

检查项：

- `sim_single/sim.log`：`UVM_ERROR : 0`、`UVM_FATAL : 0`，且无 `isn't in inst gen queue`。
- `sim_single/test.S`：对每条 `c.j/c.jal/c.beqz/c.bnez` 复算 `target_pc = current_pc + delta`，目标必须存在于实际 PC 注释集合中；C.JAL 的 link 为当前 PC + 2。
- `sim_single/test.S`：检查 C 指令相邻 PC 相差 2；检查 `c.lw/c.sw` 的寄存器为 x8–x15，offset 为 4 对齐且不大于 `0x7c`。
- `sim_single/test.S`：检查每条 `c.jr/c.jalr` 前的 LI 使用相同 rs1 并装入日志中的真实目标 PC；检查 `c.lwsp/c.swsp` 固定以 x2 为 base，offset 为 4-byte 对齐且不大于 `0xfc`。
- `test.S`：检查 C.ADDI4SPN 的 rd 为 x8–x15、uimm 为非零 4-byte 倍数且不覆盖 LS base；检查 C.ADDI16SP 为非零 16-byte 倍数，并按生成顺序更新后续 x2-relative EA。
- exception testcase：C.EBREAK 只能出现在 exception 路径；normal random 未启用 exception 时不生成。
- `sim_single/test.vmem`：检查 16-bit 指令与相邻 halfword 的打包结果。

## 10. RV32C 后续工作清单

### 10.1 优先修复

1. **C.ADDI16SP 连续随机时的 SP/bound 状态同步**：`register_pool.sp_base_addr_info` 与 `ls_addr_generator.bound_base[]` 分别保存 SP 当前值和窗口绑定，后者以可变的 `base_val` 作为身份查找。连续生成或绑定表存在同值/回退时可能更新失败，已观察到 `C.ADDI16SP could not update the bound SP base`。应改为稳定的绑定索引、寄存器编号或专用 SP bound，而不是用当前地址值标识对象。
2. **C.SW 固定偏移校验**：`c_sw_gen` 当前调用普通 `ls_imm_fix()`，与 `C.LW` 的 `ls_c_word_imm_fix(..., 'h7c, ...)` 不对称；需要统一检查 4-byte 对齐、最大 `0x7c` 以及完整 4-byte 访问不越窗口。
3. **混合长度 task 指令计数**：`task_info_config.sv` 仍按 `(end_pc-start_pc)/4` 统计，混合 16/32-bit 后不准确，应累计真实生成指令数。
4. **VMEM 与 task 起点协议**：VMEM 的 `@` 沿用 word address。若 task 从 `PC[1]=1` 的高 halfword 开始，VMEM 地址本身不能表达 halfword 起点，后续 core 必须使用 byte 精度的 task start PC 元数据。

### 10.2 验证补齐

- 覆盖全部 27 条 RV32C 整数指令；RVC 关闭时不得生成 C 指令。
- 检查 C.LW/C.SW offset `0..0x7c`、C.LWSP/C.SWSP offset `0..0xfc`，均为 4-byte 对齐且完整 word 不越窗口。
- 检查 C.BEQZ/C.BNEZ 的 `-256..+254`、C.J/C.JAL 的 `-2048..+2046`、2-byte 对齐、前后跳以及目标不落在 32-bit 指令的后半个 halfword。
- 检查 C.JAL/C.JALR 的 link 为当前 PC+2；检查 JALR 目标来自当前 task 的真实指令边界。
- 覆盖 ITCM 尾部仅余 2-byte、多 task、长 sequence 和多 seed；重点压力测试重复 C.ADDI16SP，不能只以 `+seq_num=1` 作为通过依据。
- 对 `.2byte` 输出增加独立反汇编/解码核对；当前汇编器不会依据注释验证压缩编码合法性。

### 10.3 后续 capability

- 若支持 RV64C，补充 C.ADDIW、C.LD/C.SD、C.LDSP/C.SDSP、C.SUBW/C.ADDW；当前 `C_RV64_ONLY_INST_CREATE` 为空。
- 压缩浮点以及 Zcb/Zcmp/Zcmt 不属于 RV32IMC 必需范围，后续应按独立 capability 接入。
- RVC 应作为公共 compressed capability，由 `xlen` 选择 RV32-only/RV64-only 创建集合，避免形成两套并行开关。

## 11. DSA custom 指令（第一阶段）

- 第一阶段仅启用 `DSAW`、`DSAWI`，由 `CUSTOM` capability 控制；默认 RV32IMC 集合保持不变，测试时使用 `+support_custom` 加入队列。
- 指定指令统一使用 `get_specified_inst(inst_name, rs1, rs2, rd, imm)`：`DSAW` 消费 `rs1/rs2`，`DSAWI` 消费 `rs1/imm[15:0]`，两者均无 `rd` 写回。
- `DSAW` 编码约束为 mask/value `fe007fff/0000100b`；`DSAWI` 为 `8000707f/8000100b`，立即数编码为 `{inst[30:20],inst[11:7]}`。
- `dsa_dsaw` directed scenario 先用现有 `li_sequence` 配置地址寄存器和数据寄存器，再按名称与操作数生成 `DSAW`。地址、数据和寄存器编号可由 `+dsa_addr`、`+dsa_data`、`+dsa_addr_reg`、`+dsa_data_reg` 指定。
- 当前仅验证生成器编码与输出；DSA 地址范围、不同 hart 的寄存器表、DSAWI 专用 scenario 以及 DSA side-effect 检查留待后续阶段。

推荐命令：

```csh
single case=dsa_dsaw_directed_test lst=directed.lst seed=1 uvm=UVM_LOW
```

## 12. 变更记录

| 日期 | 机制变更 | 影响范围 | 验证 | 未覆盖边界 |
| --- | --- | --- | --- | --- |
| 2026-09-05 | XLEN 驱动 I/M/A inst queue 过滤；RV32 排除 RV64-only 指令 | `inst_gen_config.sv`、`inst_generator.sv`、I/M/A 创建宏 | XLEN=32/64 静态核对与既有测试 | C、PC、sequence 权重未在该步骤处理 |
| 2026-09-05 | 增加 RVC 类、16/32-bit PC 更新、VMEM halfword 打包、真实指令边界历史 | `c_inst.sv`、`inst_generator.sv`、RVC 枚举/宏 | normal/branch/LS generator testcase | C 控制流与部分 C LS 尚未接入语义 sequence |
| 2026-09-05 | C.J/C.BEQZ/C.BNEZ 接入真实混合长度直接跳转路径 | `c_inst.sv`、`inst_name_generator.sv`、`branch_seq_info_item.sv`、`single_branch_seq.sv` | `single case=branch_inst_test lst=int.lst seed=1 uvm=UVM_LOW`；UVM error/fatal 均为 0；生成 33 条 C 直接跳转，全部复算命中真实指令边界 | C.JR/C.JALR、C.LWSP/C.SWSP、core-ref VMEM 地址单位统一 |
| 2026-09-05 | B/J/JALR 使用实际 byte delta 和真实 PC 边界 | branch sequence、B/J instruction class、`inst_generator.sv` | `branch_inst_test` | 压缩 branch/jump 编码未接入 |
| 2026-09-05 | C.LW/C.SW 接入 LS base、window 和压缩 offset 约束 | `c_inst.sv`、`ls_addr_generator.sv`、`register_pool.sv`、`inst_name_generator.sv` | `single case=ls_inst_test lst=int.lst seed=1 uvm=UVM_LOW`；UVM error/fatal 均为 0，`test.S` 出现 c.lw/c.sw | C.LWSP/C.SWSP、C 控制流、core-ref 的 VMEM 地址单位统一 |
| 2026-09-07 | C.JR/C.JALR 与 C.LWSP/C.SWSP 接入语义 sequence | `c_inst.sv`、`jalr_seq.sv`、`ls_base_config_seq.sv`、`ls_addr_generator.sv`、`register_pool.sv`、`inst_name_generator.sv` | branch/LS/normal 三个 seed=1 测试均为 UVM warning/error/fatal 0；综合测试生成 C.LWSP 36、C.SWSP 201、C.JR 70、C.JALR 88 条 | C.ADDI16SP 暂不进入 safe 类别；core-ref VMEM 地址单位仍待统一 |
| 2026-09-07 | 完善 RV32C 语义接入：C.ADDI4SPN/C.ADDI16SP 维护 SP/LS 状态，C.JAL 接入真实 byte-delta direct jump，C.EBREAK 仅接入 exception path；C 宏按 common/RV32-only/RV64-only 分层 | `c_inst.sv`、`inst_generator.sv`、`inst_name_generator.sv`、`ls_addr_generator.sv`、`register_pool.sv`、`ls_base_config_seq.sv`、本文档 | normal seed=1、branch seed=1/3、LS seed=1 均 error/fatal 0；exception 真实类名 seed=1 error/fatal 0；C.JAL 0xcda -> 0xc3e，压缩 LS 89 条 bad=0，C.EBREAK 11 条 | RV64-only compressed 类尚未建立；int.lst 的 all_rand_test 类名与源码不一致；运行时循环重复执行 C.ADDI16SP 的动态 SP 漂移未建模 |
| 2026-09-07 | 增加 directed testcase 运行入口：专用 testcase 将 main-phase default sequence 切换到 `directed_vsequence`，`directed.lst` 指定场景名 xx 和每 task 一次场景调用 | `directed_inst_test.sv`、`generator_tc_pkg.sv`、`rsim/case_lst/directed.lst` | `single case=xx_directed_test lst=directed.lst seed=1 uvm=UVM_LOW`；编译通过，7 个 task 均出现 xx 场景标记，UVM warning/error/fatal 均为 0 | task_num 仍随机为 1–8；`task_info_config` 的 inst_num 仍按 byte 数除 4，纯 16-bit task 会显示为 0 |
| 2026-09-07 | scenario 与环境包单向解耦：`scenario/` 与 `uvm_tb/` 同级，列表和场景统一放在 `scenario/`；`directed_seq_pkg` 仅导入 cpu/inst/seq 基础包；`inst_gen_env_pkg` 导入 directed 包并 include `directed_vsequence`；`tc_pkg` 只导入环境包 | `scenario/`、`uvm_tb/directed_seq/directed_seq_pkg.sv`、`uvm_tb/directed_seq/directed_scenario_seq.sv`、`uvm_tb/vseq/directed_vsequence.sv`、`uvm_tb/inst_gen_env_pkg.sv`、`uvm_tb/uvm_tb.local.f`、`uvm_tc/generator_tc_pkg.sv` | 编译顺序为基础包 -> directed_seq_pkg -> inst_gen_env_pkg -> tc_pkg；`single case=xx_directed_test lst=directed.lst seed=1 uvm=UVM_LOW`，UVM warning/error/fatal 均为 0 | scenario API 改为显式传入 inst_gen、inst_seq_gen、inst_seq_type_gen；xx demo 使用 `+seq_num=1` |
| 2026-09-07 | 记录 RV32C 后续正确性与验证清单；梳理 C.ADDI16SP 双状态存储及按可变地址匹配的同步风险 | 本文档第 10 章 | 代码只读核对 | 尚未实施功能修复或运行新增回归 |
| 2026-09-07 | 增加连续 C.ADDI16SP directed scenario；每个 task 先复用 LS base config 同步 x2/window，再在 marker 后精确生成可配置条数 | `scenario/c_addi16sp_repeat_directed_scenario_seq.sv`、`scenario/scenario_list.svh`、`rsim/case_lst/directed.lst` | `single case=c_addi16sp_directed_test lst=directed.lst seed=1 uvm=UVM_LOW`；7 个 task 各生成 16 条，定向区合计 112 条；UVM warning/error/fatal=0，立即数非法数=0 | 本 seed 未复现 bound 同步报错；base config 本身可能在 marker 前插入其他 SAFE 指令 |
| 2026-09-07 | 增加全压缩指令随机 sequence、专用 vsequence 和 testcase；压缩控制流/异常仍由原语义路径负责 | `c_inst_seq.sv`、`c_inst_vsequence.sv`、`c_inst_test.sv`、相关 package include、`int.lst` | `single case=c_inst_test lst=int.lst seed=1 uvm=UVM_LOW`；199 个 payload block、1786 条 C 指令、20 种候选全部命中；UVM warning/error/fatal=0 | payload 前的 LS base 初始化包含普通 32-bit LI/SAFE；ITCM 末端追加 32-bit pass_quit |
| 2026-09-08 | 第一阶段增加 DSAW/DSAWI 指定名称与操作数编码；增加 `+support_custom` 和 DSAW directed scenario | `dsa_custom_inst.sv`、指令枚举/queue/指定编码、`dsa_dsaw_directed_scenario_seq.sv`、`directed.lst` | `single case=dsa_dsaw_directed_test lst=directed.lst seed=1 uvm=UVM_LOW`；7 个 task 均生成 `0062900b`，UVM warning/error/fatal=0 | 尚未运行 DSA side-effect/core-ref 联合检查；DSAWI 尚无独立 scenario |
| 2026-09-10 | Scenario 顶层 sequence 权重改为 `WEIGHT_DISABLE/LOW/MEDIUM/HIGH`；数值映射与 capability 校验统一由 `inst_gen_case_config`下发，AUTO/PLAN 均使用 `inst_seq_type_generator`；directed task 恢复平台默认权重 | `scenario_base_seq.sv`、`inst_gen_case_config.sv`、`inst_seq_type_config.sv`、`inst_seq_type_item.sv`、`scenario_base_vsequence.sv`、MU random scenarios | `mu_random_scenario_test` error/fatal=0；30 次选择结果 SAFE/LS/BRANCH=24/5/1；`multicore_directed_test` MU/VU/DTE 三个 task 均通过且 error/fatal=0 | 本步骤仅覆盖顶层 SAFE/LS/BRANCH/C 等 sequence 类别权重；类内 SAFE/LS/BRANCH 指令权重仍沿用现有配置 |
