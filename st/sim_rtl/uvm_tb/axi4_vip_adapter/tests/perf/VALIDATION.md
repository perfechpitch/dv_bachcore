# 功能06验证记录（2026-09-16）

功能06已在实际 `simple_axi4_bfm_adapter` + 功能04 raw sequence wrapper + 功能05协议监视器上完成验证。受控 slave 全开放时，1GHz 下读、写分别32GB/s，均超过24GB/s；混合为读32＋写32＝合计64GB/s。此结论仅表示 VIP 持续激励及测量能力，未验证真实 NoC 端到端性能。

## 最终实际结果

VCS `S-2021.09-SP2_Full64`，服务器 `xingan-login`。最终目录：

`/fastone/users/shibin.lu/axi06_final_20260916_LZnyJF`

运行命令（在该目录 `source` 下）：

```bash
python3 tests/perf/run_perf.py --checker --out ../results
```

编译配置为 DATA256/ADDR32/ID8/LEN4、INCR、16拍、SIZE5。全1 WSTRB 为32个有效byte；半 WSTRB 为16个有效byte。持续128提交滑动窗口，read/write/total cap均128，driver与monitor的三个timeout预算均100000。先 warmup1024周期，测4096周期，再 drain。每个案例硬断言实际 AW/AR 已握手且 B/RLAST 未完成的峰值为128；混合峰值为读64＋写64。

| 场景 | 实测周期 ns | 窗口 ns | W有效byte | R有效byte | 写 GB/s | 读 GB/s | 合计 GB/s |
|---|---:|---:|---:|---:|---:|---:|---:|
| 只写，开放 | 1 | 4096 | 131072 | 0 | 32 | 0 | 32 |
| 只读，开放 | 1 | 4096 | 0 | 131072 | 0 | 32 | 32 |
| 混合，开放 | 1 | 4096 | 131072 | 131072 | 32 | 32 | 64 |
| 混合，W背压/R产生节流50% | 1 | 4096 | 65536 | 65536 | 16 | 16 | 32 |
| 只写，半WSTRB | 1 | 4096 | 65536 | 0 | 16 | 0 | 16 |
| 混合，500MHz | 2 | 8192 | 131072 | 131072 | 16 | 16 | 32 |

六个案例均有 `PERF_PASS`，整个脚本输出 `PERF_REGRESSION_PASS`。SV计数与独立VCD解析的周期、窗口、AW/AR/B/RLAST、W/R拍数、WSTRB字节、停顿周期及带宽全部一致；最终无 UVM_ERROR/FATAL 或 `$error/$fatal`。VCS保留一条 `INTFDV` 接口VCD导出警告；采用整个top导出，所有必需信号均存在，六个波形复算均成功，未屏蔽此警告。最终波形每案例约11–18MB，仅保存在scratch，不提交二进制产物。

开放场景 W/R 每个启用方向4096拍。半速对照 W/R各2048拍，其中W握手停顿2048周期；RREADY一直为高，读下降来自slave减少新RVALID产生，因此`r_stalls=0`符合其定义。半WSTRB仍有4096个W握手，但仅65536有效byte。

每笔读返回的16拍DATA256、RID、RESP、LAST全部核对；写在slave逐有效byte核对。数据pattern混入地址四个byte，能够区分512byte burst的前后8拍，避免原始低8位地址模式的重复。最后逐笔检查completion `done/status==OK`，并将总提交数与全部地址/响应握手、有效字节对账：只写/只读完成447笔；混合开放和500MHz各完成383读＋383写；混合半速各完成223读＋223写。测量窗口之外的warmup和drain均不计入带宽分子或分母。

## 时钟与测试环境自检

- 时钟提交：`6baf36e6cd2c2ec96fc5c709370a38f6bc9fdccd`。默认demo仍10ns；`+AXI_CLK_PERIOD_NS=1.0`实测1ns。完整top内置10周期实测标记，独立脚本检验10/1/2ns及7个非法参数。最终clock日志：`/fastone/users/shibin.lu/axi06_clock_final_20260916_ocl5u2/results`。
- monitor预定10周期，48写byte＋64读byte；两次W停顿不计字节，SV与实际VCD一致。目录：`/fastone/users/shibin.lu/axi06_units_20260916_S19KV9/monitor`。
- slave最终pattern自检：开放窗口256个W/R握手；2/4节流叠加RREADY/BREADY背压为W128/R119；最终64写＋64读，各1024数据拍，payload/ID/LAST/响应保持全部通过。目录：`/fastone/users/shibin.lu/axi06_final_20260916_2Z9bpG/slave_results`。此用例使用直接信号刺激，仅是测试环境自检。
- VCD解析器自检：2个正例、9个拒绝例，覆盖posedge更新前采样、半WSTRB、停顿排除、alias/timescale、非法窗口、计数不符等。

## 依赖、文件与复现

已使用完成提交：01 `a79654a`、02 `76bec13`、03 `0614fda`、04 `1eac55b`；性能联合checker使用05核心 `e7d3d0c`＋`cf82966`＋timeout修复`9e5bfdf`。05联合验证脚本`781d079`、`9fcded1`也已导入；它们不改变本次性能编译源文件。下游若已有相应依赖，只需cherry-pick本功能的clock和perf两个聚焦提交。

修改范围：`tb/tb_top.sv`时钟块；新增本目录的性能top/sequence/slave/monitor、独立JSON profile、VCS运行脚本、VCD复算器、自检与说明。不修改driver、通用Makefile/filelist或生产服务器工程。07负责最终通用接线、完整回归和部署。

机器可读实测、源文件SHA256、原始日志/波形路径和每个VCD的SHA256见 [evidence/validation_results.json](evidence/validation_results.json)。这里记录的SV和脚本hash已逐项核对本工作区文件，不采用上次PASS日志替代本次证据。使用入口与统计口径见 [README.md](README.md)。

16拍/512byte、128读/写/总限额是明确的测试假设；需求中最大burst、128及24GB/s口径、实际地址映射仍未确认。本测试地址仅为合成4KB页面，不是实际NoC slave map。

原工作簿始终未修改，前后SHA256均为：

`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`
