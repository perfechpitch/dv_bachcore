# Testcase 数据配置

`config` 中保存静态初始化输入和file check数据：

| 文件 | Testcase | 数据用途 |
|---|---|---|
| `file_init/file_init_sram0_bank0.hex` | `file_init` | SRAM0 bank0 初始化数据 |
| `file_init/file_init_sram0_bank1.hex` | `file_init` | SRAM0 bank1 初始化数据 |
| `file_init/file_init_sram0_bank2.hex` | `file_init` | SRAM0 bank2 初始化数据 |
| `file_init/file_init_sram0_bank3.hex` | `file_init` | SRAM0 bank3 初始化数据 |
| `file_check/dut_input_data.txt` | `file_check` | 按逻辑word地址排列的DUT输入 |
| `file_check/golden_data.txt` | `file_check` | 按逻辑word地址排列的预期DUT输出 |

`zero_init` 不读取数据文件。`random_init` 的随机数据在仿真时生成，
并写入对应的 `work/random_init/data/` 目录。`ref_check` 的随机输入也在
仿真时生成，但由 `tb_top` 的外部 driver 驱动到 DUT 的
`valid/address/data` 输入端口。Operation 在 Check 开始时先进入采集状态，
随后仅通过 `uvm_hdl_read` 读取 DUT 输入端口并在 DUT 外按地址形成数组。
共享 Reference UVM component 只使用该接口采集数组计算结果，
DUT 结果通过后门读出，三份数组写入
`work/ref_check/data/`；共享 `memory_scoreboard_component` 另生成逐地址的
`ref_check_dut_reference_compare.txt`。Reference 定义在
`src/memory_reference_component_pkg.sv`，Scoreboard 定义在
`src/memory_scoreboard_component_pkg.sv`。两者都是可供不同 testcase 调用的
UVM component，不是 `tb_top` 模块实例，不会形成可见的硬件波形层级。
输入接口快照分别保存为 `ref_check_dut_input_interface.txt` 和
`file_check_dut_input_interface.txt`。只有 testcase 选择
`MEMORY_CHECK_REFERENCE` 时才调用 Reference；选择 `MEMORY_CHECK_FILE` 时只读取
Golden 文件。

`ref_check` 默认选择 Reference 模式。如果把
`REF_CHECK_CHECK_MODE` 改为 `MEMORY_CHECK_FILE`，还需要按照 testcase 中的
`REF_CHECK_GOLDEN_FILE` 路径提供与当前随机种子匹配的完整 golden 文件。

`file_check` 的两个文件由 `testcase/file_check_testcase.sv` 中的
`FILE_CHECK_INPUT_FILE` 和 `FILE_CHECK_GOLDEN_FILE` 选择。文件首行为
`LOGICAL_WORD_ADDRESS DATA`，后续地址必须从0连续排列，数据数量必须等于
`FILE_CHECK_WORD_COUNT` 解析后的实际检查数量。该参数默认
`MEM_BKDR_ADDRESS_AUTO`，即 YAML 容量换算出的整颗 SRAM word 数；也可设为
`1..总word数` 内的十进制 N，此时两个文件都必须严格包含地址 `0..N-1`。
`FILE_CHECK_CHECK_MODE` 可选择共享
Reference component 或 `golden_data.txt` 作为期望数据，并在
`work/file_check/data/file_check_dut_reference_compare.txt` 中记录逐地址结果；
该文件的 `EXPECTED_DATA` 列来自当前选中的期望数据源。两种 check 模式和
两个 testcase 都复用同一个 Scoreboard component。

`config/file_check/` 中的静态输入和 Golden 文件继续使用两列格式：

```text
LOGICAL_WORD_ADDRESS DATA
```

`work/ref_check/data/` 和 `work/file_check/data/` 中生成的数据快照采用相同的
两列格式。Scoreboard 对比文件格式为：

```text
LOGICAL_WORD_ADDRESS EXPECTED_DATA DUT_DATA RESULT
```

每个文件的第一条有效数据写入该 bank 在
`testcase/file_init_testcase.sv` 中配置的起始 ROW，后续数据按 ROW
递增写入。
