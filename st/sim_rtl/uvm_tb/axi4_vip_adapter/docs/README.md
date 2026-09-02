# AXI4 UVM Verification System Guide

工程根目录：

```sh
cd ~/axi4_vip_adapter
```

本文档分为三部分：VIP 配置、sequence 表格配置和整个系统的 Make 操作。

## 0. 主要文件

```text
docs/vip/vip_cfg.xlsx                 VIP 参数 workbook
docs/seq/seq_table.xlsx               Sequence 与使用说明 workbook
docs/txt/mem20_data.txt               Range sequence 示例数据文件
docs/txt/irq_seq.txt                  中断处理操作列表
scripts/gen_dut_vip_cfg.py            最终 VIP 配置生成器
scripts/table_to_seq_plan.py          Sequence 表格到 JSON 生成器
scripts/update_user_seq_table.py      Make 参数到 USER_SEQ 更新器
scripts/gen_axi4_seq.py               JSON 到 UVM sequence 生成器
tb/axi4/axi4_vip_adapter_pkg.sv       AXI adapter 公共 API
tb/generated/seqs/*.svh               自动生成的 sequence
```

## 1. VIP cfg 使用方法

### 1.1 配置文件和三张参数表

VIP 配置统一维护在：

```text
docs/vip/vip_cfg.xlsx
```

该 workbook 包含三张 sheet：

| sheet | 作用 | 是否手动修改 |
|---|---|---|
| `BASE_VIP_CFG` | 保存全部 AXI VIP 参数及默认值 | 通常不修改，作为默认模板 |
| `DUT_BUFF_FEATURE` | 保存当前 DUT 相对默认配置的改动 | 修改绿色的 `value` 单元格 |
| `FINAL_FEATURE` | 保存最终生效参数，并在 `source` 中标记参数来源 | 不修改，由 `make vip_cfg` 生成 |

配置新 DUT 时按以下步骤操作：

1. 打开 `docs/vip/vip_cfg.xlsx`。
2. 进入 `DUT_BUFF_FEATURE` sheet。
3. 只填写需要覆盖的 `value`，不修改的参数保持空白。
4. 保持 `section`、`key`、`type` 和参数顺序与 `BASE_VIP_CFG` 一致。
5. 执行 `make vip_cfg` 生成最终配置。

`DUT_BUFF_FEATURE.value` 为空时使用 `BASE_VIP_CFG` 的默认值；填写后使用 DUT 配置值，`FINAL_FEATURE.source` 会显示 `dut_override`。

如果需要增加当前代码尚未支持的新 VIP 参数，必须同时完成以下修改：

1. 在 `BASE_VIP_CFG` 和 `DUT_BUFF_FEATURE` 的相同位置增加相同的 `section/key/type`。
2. 在 `BASE_VIP_CFG.value` 中给出默认值，`DUT_BUFF_FEATURE.value` 默认留空。
3. 在 `scripts/gen_vip_cfg.py` 和对应 AXI adapter 中接入该参数。

只向 Excel 增加一个未知字段不会自动改变 VIP 行为。

### 1.2 配置 AXI VIP 路径

VIP 路径参数为：

```text
section = axi
key     = vip_path
```

默认值：

```text
tb/axi4
```

切换目标 VIP 时，在 `DUT_BUFF_FEATURE` 中填写：

```text
section  key       value
axi      vip_path  <目标 AXI VIP 兼容目录>
```

路径可以是相对工程根目录的相对路径，也可以是绝对路径。`DUT_BUFF_FEATURE.value` 留空时继续使用 `tb/axi4`。

目标目录必须提供当前 adapter filelist 所需的兼容文件：

```text
axi4_if.sv
axi4_irq_if.sv
axi4_vip_adapter_pkg.sv
simple_axi4_bfm_adapter.sv
axi4_interrupt_pkg.sv
axi4_vip_env_pkg.sv
axi4_doc_test_pkg.sv
axi4_simple_mem_slave.sv
```

路径不存在、包含空格或缺少上述文件时，`make vip_cfg` 会报错并停止。

### 1.3 配置 AXI 地址和数据位宽

以下三个概念需要区分：

| 参数 | 位置 | 含义 |
|---|---|---|
| `axi.vip_path` | `vip_cfg.xlsx::DUT_BUFF_FEATURE` | AXI VIP/adapter 源码目录 |
| `axi.addr_width` | `vip_cfg.xlsx::DUT_BUFF_FEATURE` | AXI 地址总线位宽 |
| `addr` | `seq_table.xlsx::BASE_SEQ/USER_SEQ` | 某个 transaction 实际访问的地址 |

例如，将地址位宽改为 40 bit、数据位宽改为 64 bit：

```text
section  key         value
axi      addr_width  40
axi      data_width  64
```

`axi.data_width` 必须是 8 的倍数。修改位宽后，还需要检查 seq 中的地址、数据、`write_mode` 和目标 DUT 接口是否匹配新位宽。

数据位宽改为 64 bit 后，可直接创建一个完整 64-bit 写入的 user seq：

```sh
make user_seq BASE_SEQ=axi4_single_addr_cfg_seq NEW_SEQ=axi4_user_64b \
  addr=0x1000 data=0x1122334455667788 \
  write_mode=FULL_ADDR_FULL_BYTE
```

对于多个 64-bit 对齐寄存器，地址通常按 8 byte 递增：

```sh
make user_seq BASE_SEQ=axi4_single_addr_cfg_seq NEW_SEQ=axi4_user_64b_regs \
  addr_list=0x1000,0x1008 \
  data_list=0x1122334455667788,0x8877665544332211
```

range seq 通常使用 `addr_stride=0x8`。`data` 和 `expect` 会按照
`FINAL_FEATURE` 中最终生效的 `axi.data_width` 进行位宽检查。

### 1.4 生成最终 VIP cfg

执行：

```sh
make vip_cfg
```

该命令会：

1. 检查 `BASE_VIP_CFG` 与 `DUT_BUFF_FEATURE` 的参数名称、顺序和类型。
2. 将 DUT 非空值覆盖到 base 默认值上。
3. 更新 `FINAL_FEATURE` sheet。
4. 生成 `tb/generated/axi4_vip_cfg.json`。
5. 生成 `tb/generated/axi4_vip_cfg_pkg.sv`。
6. 根据 `axi.vip_path` 生成 `tb/generated/axi4_vip_filelist.f`。

`make seq_gen`、`make SEQ=<seq_name>` 和 `make SEQ_ALL` 都会使用最终生成的 VIP 配置。

## 2. seq_table 使用方法

### 2.1 Workbook 结构

sequence 统一维护在：

```text
docs/seq/seq_table.xlsx
```

| sheet | 作用 |
|---|---|
| `BASE_SEQ` | base sequence 模板和参考用例 |
| `USER_SEQ` | 用户生成或手动填写的 sequence |
| `TABLE_USAGE` | 表格字段、FIXED/RANDOM gap 参数及随机权重 |
| `MAKE_USAGE` | Make 命令和变量说明 |

`make SEQ_ALL` 只运行 `USER_SEQ` 中的 sequence，并为每个 seq 启动一次独立的编译和仿真；`BASE_SEQ` 仍可通过 `make SEQ=<base_seq_name>` 单独运行。

### 2.2 可以直接修改的字段

`BASE_SEQ` 和 `USER_SEQ` 中可以按功能修改以下字段：

| 字段 | 可填写内容 | 使用规则 |
|---|---|---|
| `seq_name` | 合法的 SystemVerilog 标识符 | 每个 seq 第一行填写，后续操作行留空 |
| `seq_description` | 说明文字 | 每个 seq 第一行填写 |
| `seq_gap` | `FIXED` 或 `RANDOM` | 当前 seq 完成后到下一个 seq 的延时 |
| `step` | `0, 1, 2, ...` | transaction 执行顺序 |
| `op` | `write` 或 `read` | 不再支持 `wait`，延时使用 gap |
| `addr_mode` | `single` 或 `range` | 选择单地址或地址范围访问 |
| `addr` | 十六进制或整数地址 | transaction 基地址 |
| `data` | 十六进制或整数数据 | `single + write` 必填 |
| `expect` | 十六进制或整数数据 | `single + read` 必填，缺失时 `make seq_gen` 报错 |
| `tr_gap` | `FIXED` 或 `RANDOM` | 当前 transaction 完成后的延时 |
| `addr_stride` | 正整数或十六进制步长 | `range` 必填，例如 `0x4` |
| `count` | 正整数 | `range` transaction 数量 |
| `data_file` | txt 文件路径 | `range write/read` 必填，每行一个数据 |
| `data_start` | 非负整数 | 从 `data_file` 的第几个 entry 开始，0-based |
| `readback` | `0/1` 或 `false/true` | range write 后是否自动读回检查，默认 `1` |
| `write_mode` | 三种 write mode 之一 | 仅 write 行有效，空白时默认 `FULL_ADDR_FULL_BYTE` |

`USER_SEQ` 还有两个记录字段：

| 字段 | 说明 |
|---|---|
| `base_seq` | 记录 user seq 来源；手写 seq 可留空或填写 `MANUAL` |
| `change_para` | 自动记录相对 base seq 的改动，不需要用户填写 |

### 2.3 不同操作的必填字段

| 操作 | 必填字段 |
|---|---|
| single write | `step/op/addr_mode/addr/data/tr_gap`，`write_mode` 可留空使用默认值 |
| single read | `step/op/addr_mode/addr/expect/tr_gap` |
| range write | `step/op/addr_mode/addr/addr_stride/count/data_file/data_start/tr_gap`，`readback/write_mode` 可使用默认值 |
| range read | `step/op/addr_mode/addr/addr_stride/count/data_file/data_start/tr_gap` |

range 操作使用 `data_file`，不要在同一行再填写 `data` 或 `expect`。每个 seq 之间建议保留一个空行，便于阅读。

### 2.4 write_mode

| write_mode | 行为 |
|---|---|
| `FULL_ADDR_FULL_BYTE` | 一个完整地址执行一次 32-bit 全字节写，默认模式 |
| `FULL_ADDR_SINGLE_BYTE` | 同一地址执行 4 次 byte-lane 写，`wstrb` 依次左移 |
| `SINGLE_ADDR_SINGLE_BYTE` | `wstrb=0x1`，地址按 byte 递增执行 4 次写 |

所有 write transaction 都会检查 `BRESP=OKAY`。所有带 `expect` 或 range readback 的 read transaction 都会检查读回值。

### 2.5 gap 配置

`seq_gap` 和 `tr_gap` 在 seq 表中填写 `FIXED` 或 `RANDOM`：

| 值 | 行为 |
|---|---|
| `FIXED` | 使用 `TABLE_USAGE` 中 FIXED 对应的固定 cycle 数 |
| `RANDOM` | 按 `TABLE_USAGE` 中 MIN/MID/HIGH/MAX 的范围和权重随机选择 |

需要修改固定延时、随机范围或权重时，修改 `TABLE_USAGE` sheet，不在 VIP cfg 中配置 gap。

`TABLE_USAGE` 中的 gap 参数可以用于仿真，但仿真器不会在运行时直接读取 Excel。修改表格后，需要重新生成 `tb/generated/axi4_seq_cfg_pkg.sv` 并重新编译。

FIXED 延时在 `table.gap_mode/FIXED` 行的 `current_value` 中填写，例如：

```text
5 cycles
```

RANDOM 模式包含两级权重：

1. `table.random_level` 控制选择 MIN/MID/HIGH/MAX 档位的权重。
2. `table.random_cycle_weights` 控制选中档位后，各 cycle 的权重。

随机档位的配置格式如下：

```text
MIN:
range=[0,5]; level_weight=50
```

档位内部的 cycle 权重格式如下：

```text
MIN.cycle_weights:
0:30;1:25;2:20;3:15;4:7;5:3
```

权重是相对比例，不要求总和等于 100。cycle 范围内的每个 cycle 都必须配置一个权重，并且至少有一个权重大于 0。

`table.gap_mode/RANDOM` 行的 `current_value` 支持：

| 值 | 档位选择方式 | 档位内部 cycle 选择方式 |
|---|---|---|
| `WEIGHTED` | 使用各档位的 `level_weight` | 使用对应的 `cycle_weights` |
| `UNIFORM` | MIN/MID/HIGH/MAX 等概率 | 仍使用对应的 `cycle_weights` |

保存并关闭 Excel 后，可以只重新生成配置：

```sh
make seq_gen
```

也可以直接重新生成、编译并运行，修改后的 gap 会在本次仿真中生效：

```sh
make SEQ=<seq_name>
make SEQ_ALL
```

仿真日志会打印每次实际使用的 gap，例如：

```text
TR gap: setting=RANDOM selected=MIN cycles=2
SEQ gap: setting=FIXED selected=FIXED cycles=5
```

`make SEQ=<seq_name> verdi` 和 `make SEQ_ALL <seq_name> verdi` 只打开已有波形，不会重新生成配置或重新仿真，因此修改 gap 后不能只执行 Verdi 命令。

### 2.6 修改表格后的生成与运行

修改 `BASE_SEQ` 或 `USER_SEQ` 后，先检查必填字段，然后执行：

```sh
make seq_gen
```

该命令会生成 `docs/seq/seq_plan.json` 和 `tb/generated/seqs/` 下的 SystemVerilog sequence。也可以直接运行某个 seq，运行流程会自动执行 `seq_gen`：

```sh
make SEQ=<seq_name>
```

## 3. 整个系统的使用方法

### 3.1 常用命令

| 命令 | 功能 |
|---|---|
| `make help` | 显示当前 seq 数量、可用 seq、Make 命令和参数 |
| `make vip_cfg` | 合并 base/DUT VIP 参数并生成最终 VIP cfg 与 filelist |
| `make seq_gen` | 生成 VIP 配置、seq plan、gap 配置、中断 seq 和所有 SV seq |
| `make user_seq BASE_SEQ=<base> NEW_SEQ=<new> ...` | 基于 base seq 创建或替换 user seq，默认立即编译并运行 |
| `make clear_user_seq USER_SEQ=<name>` | 从 `USER_SEQ` sheet 删除指定 seq，并重新生成 seq |
| `make clear_user_seq` | 清空 `USER_SEQ` sheet，并重新生成 seq |
| `make SEQ=<seq_name>` | 重新生成、编译并运行一个 base 或 user seq |
| `make SEQ_ALL` | 重新生成，并分别编译、仿真 `USER_SEQ` sheet 中的每个 seq，结果保存到独立子目录 |
| `make SEQ=<seq_name> verdi` | 直接打开该 seq 已存在的 FSDB，不重新仿真 |
| `make SEQ_ALL <seq_name> verdi` | 打开 `work/SEQ_ALL/<seq_name>/` 中已有的 FSDB，不重新仿真 |
| `make clean` | 删除编译产物、日志、波形和 `work` 目录，不删除表格和 generated seq 源码 |

### 3.2 常用变量

| 变量 | 默认值 | 功能 |
|---|---|---|
| `IRQ_EN=0/1` | `0` | `1` 时启用中断检测和中断处理 seq |
| `WAVE=0/1` | `1` | 是否生成 FSDB 波形 |
| `write_mode=<mode>` | 表格值 | 创建 user seq 时写入表格；普通运行时覆盖当前 seq 的写模式 |
| `range_write_mode=<mode>` | 空 | user seq 创建时是 `write_mode` 别名；运行时只覆盖 range write |
| `RUN_AFTER_USER_SEQ=0/1` | `1` | `0` 时只创建 user seq，不立即编译和运行 |
| `PYTHON=<cmd>` | 自动检测 | 优先使用 `python3`，不存在时回退到 `python` |
| `WORK_ROOT=<dir>` | `work` | 修改仿真输出根目录 |
| `NOVAS_PLI_DIR=<dir>` | 自动搜索 | FSDB PLI 无法自动找到时手动指定 |

### 3.3 推荐操作流程

首次适配一个 DUT：

```sh
# 1. 修改 docs/vip/vip_cfg.xlsx::DUT_BUFF_FEATURE 后生成最终配置
make vip_cfg

# 2. 修改 seq_table.xlsx 后生成所有 sequence
make seq_gen

# 3. 检查当前可用 seq 和命令
make help

# 4. 运行一个 seq
make SEQ=<seq_name> IRQ_EN=0

# 5. 打开已有波形
make SEQ=<seq_name> verdi
```

基于模板快速创建 user seq：

```sh
make user_seq \
  BASE_SEQ=axi4_single_addr_cfg_seq \
  NEW_SEQ=axi4_user_reg0 \
  addr=0x120 \
  data=0x55 \
  write_mode=FULL_ADDR_FULL_BYTE \
  IRQ_EN=0
```

创建 range user seq：

```sh
make user_seq \
  BASE_SEQ=axi4_range_window_seq \
  NEW_SEQ=axi4_user_range0 \
  addr=0x800 \
  addr_stride=0x4 \
  count=8 \
  data_file=docs/txt/mem20_data.txt \
  data_start=0 \
  tr_gap=RANDOM
```

批量运行所有 user seq：

```sh
make SEQ_ALL IRQ_EN=0
```

该命令不会把所有 seq 放在同一次仿真中连续执行。每个 user seq 都会独立编译、独立仿真，并生成自己的日志和波形。打开其中一个波形：

```sh
make SEQ_ALL <seq_name> verdi
```

每次运行的所有编译、日志和波形文件都会放入对应目录：

```text
work/<seq_name>/
work/SEQ_ALL/<seq_name>/
```

主要文件包括 `simv`、`csrc/`、`compile.log`、`sim.log` 和 `axi4_bfm.fsdb`。

`make user_seq` 在表格校验、生成、编译或仿真失败时会恢复修改前的 `seq_table.xlsx`，失败的 user seq 不会留在表格中。

### 3.4 中断处理序列

中断处理操作维护在：

```text
docs/txt/irq_seq.txt
```

支持的操作格式：

```text
write addr=<addr> data=<data> [strb=<strb>] [gap=FIXED|RANDOM] [comment="text"]
read  addr=<addr> expect=<data> [gap=FIXED|RANDOM] [comment="text"]
```

修改后执行 `make seq_gen`，生成新的中断处理 sequence。运行时使用
`IRQ_EN=1` 启用中断检测；默认 `IRQ_EN=0` 不执行中断处理。
