# 09：按 master 设置 DUT 并生成 FINAL

用户本次明确授权将 `vip_cfg.xlsx` 的 `DUT_BUFF_FEATURE` 设置为需求表 master 的参数，并执行生成 `FINAL_FEATURE`；随后确认 outstanding 为读/写上限各128、读写合计上限128。此授权允许修改 DUT 和 FINAL，BASE 及其锁保持不变。

需求来源：`bach_core_ctrl_noc_project_requirement.xlsx::master!A2:V2`，SHA-256 `14cb665a71652b2ef908085d5065a338a31e644bc75eec43acbab8d836081935`。来源作为数据读取；`readme!B19` 将 USER 定义为 AW/AR 请求通道，未据此修改 W/R/B USER。

## 修改结果

三张表仍各70项，键、顺序和类型一致。DUT 从全部空白变为28项显式赋值、42项空白；实际执行 `scripts/gen_dut_vip_cfg.py` 后，FINAL 对应28项的 source 为 `dut_override`，其余为 `default`。包括与 BASE 相等的已明确需求，也显式记录覆盖来源。

| DUT 字段 | 值 |
| --- | --- |
| axi.protocol / addr_width / data_width | AXI4 / 32 / 256 |
| axi.id_width / len_width / qos_width | 8 / 4 / 0 |
| axi.awuser_width / aruser_width | 0 / 0 |
| axi.default_burst_type | INCR |
| axi.max_outstanding_reads / writes / total | 128 / 128 / 128 |
| support.exclusive_access / narrow_burst / fixed_burst / wrapping_burst | false / false / false / false |
| support.incrementing_burst | true |
| requirements.name / access_mode | scp_bach_ctrl_m0 / rw |
| requirements.barrier / max_wrap_size | false / no |
| requirements.align_info / diff_id | none / none |
| requirements.clock_freq_mhz / bandwidth_gbps | 1000 MHz / 24 GB/s（字节/秒） |
| requirements.use_rob / outstanding / outstanding_scope | false / 128 / read+write |

`outstanding_scope=read+write` 来自用户2026-09-17确认；原需求 Excel 没有给出读/写/合计定义。其他没有来源的 DUT 项保持空白，包括 locked_access、REGION、W/R/B USER、默认ID/属性、timeout、checker 和 coverage；例如 locked_access 最终继承 BASE=false。沿用 BASE 描述文本以保护原表，outstanding 描述中的“源未定义”仍指原始需求表，不否定本次用户补充确认。

需求最大拍数/字节和带宽方向仍未知：`requirements.max_burst_beats`、`max_burst_bytes`、`bandwidth_scope` 在三表中保持物理空白。`axi.max_burst_len` 的 DUT 也保持空白，**FINAL 继承 BASE=1**；LEN4 不是业务最大16拍的确认。本次没有更改源表未知值来迁就测试。

1000 MHz、24 GB/s、ROB、barrier、align 和 diffID 是需求元数据，不改变仿真时钟或驱动功能。`narrow_burst=false` 限制窄多拍；原需求和现有实现仍允许窄单拍。

## 编辑、保护与审计

使用 Artifact Tool 导入并修改现有工作簿，导出后实际运行项目合并器生成 FINAL；最后才记录新的受保护 SHA。只读审计确认 BASE 全部单元格值/类型/公式/number format 和锁不变，原字体、填充、边框、对齐、保护、行高、列宽、native table 范围、数据验证和冻结窗格保留。已检查 DUT/FINAL 变更区域的渲染图，未改变版式。逐项审计见 [09机器记录](workbook_master_activation_20260917.json)。

| 项目 | SHA-256 |
| --- | --- |
| 迁移前 vip_cfg.xlsx | `77bae6bac46a09a385d0543d0e026eb6825527280e25212c002f518466d99700` |
| 本次最终 vip_cfg.xlsx | `2fc6354c5b2b98fbcd362c545c63c83dfc75c5b4ac1035de4554ccc1f1e3811c` |
| BASE 锁（未变） | `2dbd10dee82458b869e231342f2b788be6ed9616c817a35a916a30063bbf08e1` |
| 本次 workbook_baseline.json | `d93bbe386f78ccc56c5c792f62b668cd5d482083fe25eea0f9bee68af50209b0` |

迁移前工作簿备份：Git revision `215757ba20fe6e25a64d791413dceffd446ca331`，路径 `axi4_vip_adapter/docs/vip/vip_cfg.xlsx`，已核对该 blob 的内容 SHA 为上表旧值。08原始备份、审计和部署记录原样保留。09审计测试将08历史值保护限定于完整 BASE，同时严格验证当前授权 DUT 值、未赋值项物理空白、FINAL 全部值与来源，未删除工作簿或部署保护。

普通测试不得直接在源项目执行会回写工作簿的 `make vip_cfg`。专项部署仍须显式迁移清单，精确列出新旧xlsx、baseline以及不变的BASE锁；由07执行生产备份、迁移及回滚核验。09没有写生产项目、源 `tb/generated` 或 sequence 输入。

## 验证

- 本地配置测试17项、工作簿测试12项、隔离/迁移测试32项全部通过；部署工具自测12项通过。
- scratch 配置链实际执行 `make vip_cfg`：BASE锁、FINAL合并、JSON/SV/filelist生成全部通过，三表语义与候选一致。
- 生成的 JSON SHA 为 `00bf578b1b1de7ac3915dacec749a7422aa376dd779f9459446d4ee5c45cefec`；SV确认 DATA256、ID8、LEN4、QOS/AWUSER/ARUSER=0、max_burst_len=1、读/写/总上限128/128/128。
- `tests/integration/run_workbook_smoke.py` 现按实际 JSON 生成匹配宽度的单拍计划：两次32B对齐全256位写入、两次完整256位读比较，ID255/254，含高224位非零数据和全WSTRB；使用独立scratch计划，不覆盖已有32位sequence表。
- 服务器 VCS S-2021.09-SP2 真实运行通过，AW/W/B/AR/R=3/3/3/2/2（含IRQ一次写入），checker errors=0，UVM_ERROR/FATAL=0；实测默认时钟10ns。
- 配置链副本A回写的ZIP字节SHA为 `c6c36b4ce79eb7640b81a6d928b73dd3225c4a1c19d4863aa4a2689c51b9996b`，逐项语义不变；仿真副本B仍保留保护基线，显式使用A生成的JSON。源xlsx前后始终为本次最终SHA。

真实运行目录：`/fastone/users/shibin.lu/axi09_master_20260917_Cg8gGj/smoke`。结构化证据见 [09验证结果](../tests/integration/results/workbook09_smoke_20260917.json)。

该冒烟证明新工作簿配置链可用于受控slave的单拍仿真；不代表重新完成128在途压力回归或真实NoC 24 GB/s验收。业务burst最大值、带宽方向、实际地址图及目标RTL仍需后续输入。
