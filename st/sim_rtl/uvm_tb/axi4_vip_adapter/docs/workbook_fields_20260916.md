# VIP 工作簿字段补齐（08）

本次按用户明确选择“只补齐缺失字段，保留已有配置值”，在三个 sheet 的原55项后追加相同的15项。三张表各70项，键、顺序和类型一致。原55项的值、DUT空白、类型、说明及FINAL来源全部保留。现有 DATA32/ID4/LEN8、max_burst_len=1、读写各1等运行配置没有改成目标profile。

项目主文件是 `docs/vip/vip_cfg.xlsx`。需求来源为 `bach_core_ctrl_noc_project_requirement.xlsx::master!A2:V2`；来源hash及逐sheet语义审计见 [机器可读diff](workbook_schema_migration_20260916.json)。Excel原生三张table范围延长到第71行，沿用字体、边框、底色。类型列加宽到16以完整显示可空类型；仅新增行使用42点行高和换行。导出器会规范化无显示作用的XML格式属性。

## 新增字段

表中行号在三个sheet中相同，值位于C列。BASE保存以下值；DUT新增值全部物理留空，表示继承BASE；FINAL合并值与BASE一致，source为default。表中“空白”表示单元格无值，不是字符串null，也不是0。

| 行 | section.key | type | BASE / FINAL值 | 来源及作用 |
|---|---|---|---|---|
| 57 | axi.max_outstanding_total | optional_int | 空白 | 已实现的运行总上限；空白按合并后的读+写上限求和 |
| 58 | requirements.name | string | scp_bach_ctrl_m0 | A2，需求主体标识，不选择运行profile |
| 59 | requirements.access_mode | string | rw | C2，需求读写方向 |
| 60 | requirements.barrier | bool | false | J2=no，记录需求；不实现barrier |
| 61 | requirements.max_wrap_size | string | no | M2=no，保留不要求WRAP语义；没有擅自定义尺寸单位或0 |
| 62 | requirements.align_info | string | none | O2，整个事务不跨特定边界的保证，不等同unaligned_access |
| 63 | requirements.diff_id | string | none | P2，保留源不同ID约束描述 |
| 64 | requirements.clock_freq_mhz | int | 1000 | S2，MHz；不改变仿真时钟 |
| 65 | requirements.bandwidth_gbps | int | 24 | T2=24G、列头GBps，归一化为24 **GB/s，字节/秒**，不是Gb/s |
| 66 | requirements.bandwidth_scope | optional_string | 空白 | 源未定义读/写/合计口径 |
| 67 | requirements.use_rob | bool | false | U2=no，NoC ROB需求；不配置或实现ROB |
| 68 | requirements.max_burst_beats | optional_int | 空白 | Q2空白，业务最大拍数未知；既有axi.max_burst_len=1是运行默认 |
| 69 | requirements.max_burst_bytes | optional_int | 空白 | R2空白，业务最大字节数未知 |
| 70 | requirements.outstanding | int | 128 | V2，原始需求数，不自动传入运行上限 |
| 71 | requirements.outstanding_scope | optional_string | 空白 | 源未定义读/写/合计口径 |

其余master字段由原有词条表达：B协议→axi.protocol；D/E/F/G/H→data/addr/id/len/qos_width；I user width→awuser_width/aruser_width（源readme!B19仅定义AWUSER/ARUSER，W/R/B USER宽度是额外的原有配置）；K exclusive→support.exclusive_access；L burst type→axi.default_burst_type及原support开关；N narrow burst→support.narrow_burst。源N列仅指窄多拍，当前runtime开关也仅限制多拍窄传输，关闭时仍允许窄单拍；窄单拍不在Excel该禁用项内。此次保留旧值和既有含义。已有词条与需求值不同处由独立目标测试profile表达，未替换工作簿旧值。

## 空白、合并与运行边界

`optional_int/optional_string` 的真实空值读为Python None / JSON null，FINAL写回保留物理空白。字面none/no/0保持数据含义；普通必填BASE字段仍不能留空，显式旧null类型仍兼容。DUT空值继续继承BASE，填0、false或no时不会误当作继承。可空整数字段填非整数会拒绝；运行total必须为正整数。

总上限在BASE+DUT合并之后解析，读=3、写=5、total留空得到8；total显式7得到7。`requirements.outstanding=128`对此无作用。requirements字段保存到JSON并严格检查字段及类型；修改其内容不会改变生成的SV。带requirements的SV只有固定的元数据说明，不输出这些字段为硬件参数。

仿真时钟仍用 `+AXI_CLK_PERIOD_NS`，默认10ns；1GHz测试显式设置1ns。带宽、ROB、barrier、align和不同ID等需求记录不驱动时钟、流量或硬件功能。16拍/512字节及128/128/128仍只是目标测试假设。受控slave结果不能证明真实NoC端到端24 GB/s。

## 保护基线、备份与迁移

- 旧工作簿SHA-256：`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`。
- 新工作簿SHA-256：`77bae6bac46a09a385d0543d0e026eb6825527280e25212c002f518466d99700`。
- 原始文件保存在Git提交 `1de3af5f4f0335e816f4ea95faf758b04fc784e8`，blob `569405bf6d0af221c40db437a50945d2722f67ee`；编辑前另存了临时物理备份。未提交重复的xlsx二进制副本。
- 新BASE语义锁fingerprint：`73194a305a81eecac0703dd5590fb94d03d9d851cd2feb762ab31b8b2c20cdd0`。
- `scripts/workbook_baseline.py`从受版本控制的 `docs/vip/workbook_baseline.json` 读取授权新旧hash和来源。测试启动时固定预期值，运行前后检查；不会自动接受当前文件为新基线。

普通部署仍禁止工作簿、docs/vip和generated路径。专项迁移必须同时指定 `--allow-workbook-migration` 和manifest的 `workbook_migration`，其baseline_sha256/candidate_sha256精确等于上述旧/新hash，且files列齐xlsx、BASE锁、baseline manifest三个精确路径及逐文件hash。其他代码/测试/文档仍使用普通文件manifest规则。

由07在完整候选副本中运行新版工具，先 `--check-only`，再执行有时间戳备份的部署。所有候选和生产旧hash须匹配，缺失状态用null；冲突时先拒绝，不能把生产的新用户改动当成旧基线。每文件原子替换、写前再次检查SHA；编辑器须保存关闭，哈希检查无法阻止事后外部写入。

备份含原文件、每项before/after hash及absence、独立rollback.py/sh、helper和钉住的基线上下文。回滚不依赖目标中将被恢复/删除的helper或baseline；恢复旧xlsx/锁及删除新增文件后验证旧hash。回滚会先拒绝本次部署后的用户修改。08回退到旧表后，才可继续使用07此前硬编码旧hash的回滚工具。

## 验证入口

所有生成均在临时项目副本进行，正式工作簿前后hash不变。

```sh
python3 -B -m unittest discover -s tests -p 'test_vip_cfg.py' -v
python3 -B -m unittest discover -s tests -p 'test_workbook*.py' -v
python3 -B -m unittest discover -s tests/integration -p 'test_*.py' -v
python3 scripts/deploy_verified.py self-test
# 仅在项目副本运行完整表格链：
make vip_cfg
```

审计验证原55×3行全字段一致、70项键/顺序/类型一致、三张native table扩展正确、可空字段物理空白、已有0/no/none不丢失；定向测试覆盖空值继承、最终方向上限求和、无效配置失败不改输出、元数据不改变SV和普通/专项部署保护。真实VCS默认/目标冒烟证据见本次 `tests/integration/results/workbook08_smoke_20260916.json`，与历史07结果分开保存。没有改写历史PASS证据，也没有在08任务中更新生产目录。
