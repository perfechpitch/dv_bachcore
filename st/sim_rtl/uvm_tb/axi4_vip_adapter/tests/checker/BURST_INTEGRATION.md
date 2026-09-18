# Feature 02 / 05 integration

After loading VCS, run `python3 tests/checker/run_burst_integration.py` from the
adapter directory. Python 3.6 is supported. The default modes are `positive`,
`narrow_enabled`, and `strobe_disabled`; `--mode` may be repeated to select modes.
`--prepare-only` generates isolated inputs without compiling or simulating.

The runner reads feature 02's completed bench and creates a temporary copy with
an independent `axi4_protocol_monitor` instance and final acceptance checks.
It generates its own JSON/SV configuration. It does not modify the original
bench, slave, driver, Makefile, filelist, generated configuration, or workbook;
before/after source hashes and commands are recorded in `manifest.json`.
The injection anchors must match exactly once, so an incompatible upstream
bench change stops preparation instead of silently omitting the monitor.

Each simulation must retain the original `BURST_TEST_PASS` marker and produce
`MONITOR_DRIVER_PASS` with zero monitor errors, nonzero handshakes on all five
channels, counts matching the controlled slave, no pending transactions, and
actual coverage samples. Unexpected simulator/checker fatal/error messages
reject the run even if VCS returns process status zero.

The driver keeps its original 12-cycle per-stage timeout. The independent
monitor uses a 1000-cycle inactivity budget, configurable with
`--monitor-timeout-cycles`: AW-to-W/B and AR-to-R monitor intervals cover
different intervals from the driver's staged waits. This combined run checks
absence of false positives during legal driver traffic. Timeout boundaries
and checker enable/disable isolation remain covered by the separate raw-pin
regression; this script does not rerun that regression.

Optional `--mode response_off` is explicitly a **known-response variant** of
the upstream `responses` case. Only in the temporary bench, its X response
sample is replaced with EXOKAY, alongside the original SLVERR/DECERR samples.
X/protocol checks remain enabled. The main monitor has response checking off
and must report zero errors; a second monitor with response checking enabled
must report response errors and no other category. Coverage must observe all
three known response codes. This does not claim that the original X-bearing
response test passed: unknown-response behavior is a separate test dimension.

This profile tests DATA256/ADDR32/ID8/LEN4, 16 beats maximum, and the existing
blocking APIs at 1 GHz. The burst maximum is an explicit test assumption.
Feature 03's 128-outstanding scheduler and actual NoC throughput require their
own combined regression; these results must not be presented as that proof.

## 实际验证（2026-09-16）

VCS S-2021.09-SP2，02驱动提交`76bec13`，05 checker `e7d3d0c`+`cf82966`。
服务器隔离结果：`/tmp/axi05_burst_joint_20260916_FWgstG/results`。
四模式均`MONITOR_DRIVER_PASS error_count=0`且原`BURST_TEST_PASS`通过，编译无Warning-/Error-：

| mode | AW / W / B / AR / R实际握手 | 结果 |
|---|---|---|
| positive | 33 / 169 / 33 / 20 / 99 | 原scoreboard与独立monitor计数一致，1/2/4/16拍、背压和partial/zero strobe零误报 |
| narrow_enabled | 1 / 4 / 1 / 1 / 4 | 跨bus-word的窄四拍零误报 |
| strobe_disabled | 2 / 2 / 2 / 2 / 2 | full与narrow-single完整lane mask零误报 |
| response_off | 6 / 10 / 6 / 5 / 9 | 已知响应变体；response-off计数0，对照response-on计数15，其它错误0 |

manifest记录`source_files_unchanged=true`；工作簿SHA仍为
`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`。
这是02阻塞burst API与05的联合验证，128并发仍待03完成后的独立联合验证。

## 功能03替换驱动后的重验及超时开关

2026-09-16，正式03提交`0614fda`导入后，同一四模式在
`/tmp/axi05_outstanding_joint_20260916_2XUbbr/burst_results`全部再次PASS。
这次使用03并发engine及其已适配burst bench，不复用02历史日志。

追加入口：

```sh
python3 tests/checker/run_burst_integration.py --mode timeout_off --mode zero_timeout
```

两模式调用上游`delayed`测试（各通道20周期延迟）：`timeout_off`的driver原预算12、monitor预算4但enable关闭；`zero_timeout`两者预算均为0而enable开启。两个模式都另实例化budget4、enable开启的witness。

在`/tmp/axi05_outstanding_joint_20260916_2XUbbr/final_burst_results`实际VCS结果：

| mode | 关闭/零阈值的timeout计数 | witness timeout计数 | AW/W/B/AR/R |
|---|---:|---:|---|
| timeout_off | 0 | 11 | 1/4/1/1/4 |
| zero_timeout | 0 | 11 | 1/4/1/1/4 |

两组`MONITOR_DRIVER_PASS delayed error_count=0`，witness除timeout外没有其它错误，编译无Warning-/Error-。原始文件及工作簿hash不变。manifest按mode记录预算，不能把延迟访问完成误称timeout检查仍开启。

最终checker修复`9e5bfdf`后，六模式在`final_burst_results`全部重新编译/运行通过。timeout witness最新计数为11（修正前的15包含不应计入的W前序等待），两关闭路径仍为0；其它4模式握手与结果不变。
