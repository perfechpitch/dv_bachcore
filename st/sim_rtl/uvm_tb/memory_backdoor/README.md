# Memory Backdoor

## 项目简介

本项目用于在仿真环境中通过 HDL 后门初始化和检查 SRAM。SRAM 的容量、数据
位宽和地址交织方式由 YAML 配置；具体操作由统一的 Operation 组件完成，
testcase 只负责选择操作类型并填写参数。

当前初始化链路操作真实 SRAM；`ref_check` 和 `file_check` 使用独立的 DUT 输入
端口与结果数组，两条链路互不混用。

## 主要功能

- 支持 1 颗 SRAM、4 个等深物理 bank；每个 bank 容量为总容量的四分之一。
- 支持配置数据位宽、总容量、地址交织开关和交织粒度。
- 支持逻辑地址与物理 `bank/row` 地址转换。
- 支持文件初始化、全零初始化和随机初始化。
- 初始化后可选择是否通过后门读回检查。
- 支持 Reference 数组检查和 Golden 文件检查。
- Check 结果按地址保存到 `work/<case>/data/`。

## 主要组件

| 组件 | 作用 |
| --- | --- |
| `memory_backdoor_pkg` | 保存配置，并提供底层 HDL 后门读写能力 |
| `memory_backdoor_operation_component` | 执行初始化、采集 DUT 输入、读取 DUT 输出及调度 Check |
| `memory_reference_component` | 根据 DUT 输入快照生成 Reference 结果数组 |
| `memory_scoreboard_component` | 比较 DUT 输出与 Reference 或 Golden 数据 |
| `interleaved_sram` | 完成逻辑地址到物理 bank/row 的映射 |
| `tc_sram` | SRAM 的物理存储模型 |

TB 是 DUT 输入接口的唯一驱动者。Operation 不产生或修改 DUT 输入，只在 Check
开始后通过 `uvm_hdl_read` 采集 DUT 的 `valid/address/data` 接口，并在 DUT 外按
地址打包成数组。

## YAML 配置

```yaml
data_width: 32bit
capacity: 8KB
address_interleave: 1
interleave_granularity: 4B
memories:
  - hdl_path: tb_top.dut.gen_sram[0].u_interleaved_sram.gen_bank[0].u_sram.sram
  - hdl_path: tb_top.dut.gen_sram[0].u_interleaved_sram.gen_bank[1].u_sram.sram
  - hdl_path: tb_top.dut.gen_sram[0].u_interleaved_sram.gen_bank[2].u_sram.sram
  - hdl_path: tb_top.dut.gen_sram[0].u_interleaved_sram.gen_bank[3].u_sram.sram
```

- `data_width`：单个 word 的数据位宽。
- `capacity`：整颗 SRAM 的总容量，自动平均分配到 4 个 bank。
- `address_interleave`：`1` 表示地址交织，`0` 表示按 bank 连续排列。
- `interleave_granularity`：交织粒度，必须与数据位宽匹配。
- `hdl_path`：每个物理 bank 在仿真层级中的存储路径。

## Testcase

| 用例 | 功能 |
| --- | --- |
| `file_init` | 按 testcase 指定的四个 bank 文件和起始 row 初始化 SRAM |
| `zero_init` | 将指定逻辑地址范围初始化为全零 |
| `random_init` | 在指定数值范围内生成随机数据并初始化 SRAM |
| `ref_check` | 采集 DUT 输入，调用 Reference，并比较 DUT 与 Reference 输出 |
| `file_check` | 采集 DUT 输入，并比较 DUT 输出与 testcase 指定的 Golden 数据 |

初始化用例通过各自的 `*_COMPARE_ENABLE` 控制是否读回检查。Check 用例通过
`*_CHECK_MODE` 选择 `MEMORY_CHECK_REFERENCE` 或 `MEMORY_CHECK_FILE`。

`REF_CHECK_WORD_COUNT` 和 `FILE_CHECK_WORD_COUNT` 控制实际检查的数据数量：

- `MEM_BKDR_ADDRESS_AUTO`：检查整颗 SRAM 的全部 word。
- 正整数 `N`：只检查连续地址 `0..N-1`，且 `N` 不能超过 SRAM 总 word 数。

## Check 流程

1. Operation 启动 DUT 输入接口采集。
2. TB 从随机源或输入文件向 DUT 接口逐拍发送数据。
3. Operation 后门读取 DUT 输入接口，并在 DUT 外打包输入数组。
4. Operation 后门读取 DUT 输出数组。
5. `ref_check` 将输入数组交给 Reference；`file_check` 加载 Golden 数据。
6. Scoreboard 逐地址比较 DUT 输出与期望结果。
7. 数据一致时输出 `TEST_PASS`，否则输出 `TEST_FAIL`。

当前 DUT 和 Reference 的算法均为透传，二者应独立修改；Operation 和 Scoreboard
不实现 DUT 算法。

## 数据文件

- 文件初始化数据：`config/file_init/`
- File Check 输入及 Golden 数据：`config/file_check/`
- 仿真输出：`work/<case>/data/`

Check 输出目录中包含 DUT 输入接口快照、Reference 或 Golden 期望结果、DUT 输出
数据以及逐地址对比结果。三类数据快照采用：

```text
LOGICAL_WORD_ADDRESS DATA
```

逐地址对比文件采用：

```text
LOGICAL_WORD_ADDRESS EXPECTED_DATA DUT_DATA RESULT
```
