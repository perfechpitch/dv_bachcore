# 功能06：时钟与有效载荷带宽

本目录验证 **VIP 向受控 AXI slave 持续发包与测量的能力**。未连接实际 NoC、17 个目标 slave 或真实地址映射，不能据此宣称 NoC 端到端 24 GB/s 已通过。

最终六场景实测及证据见 [VALIDATION.md](VALIDATION.md)：1GHz开放读/写各32GB/s，协议监视与独立VCD复算通过。

## 配置与口径

- `tb/tb_top.sv` 默认周期仍为 10 ns（100 MHz）。直接运行编译后的 `simv +AXI_CLK_PERIOD_NS=1.0` 可设为 1 GHz。周期单位为 ns，50% 占空比；非法值、非正值、不能以 1 ps 精度表达的半周期均拒绝。完整top在第11个posedge后输出实测10周期的 `AXI_CLOCK_MEASURED period_ns=1.000000 samples=10`，并检查与配置一致。
- 性能 top 的默认周期为 1 ns，编译配置为 `perf_profile.json`：AXI4 rw、DATA256、ADDR32、ID8、LEN4、INCR、SIZE=5、每拍32字节、16拍/512字节 burst。
- **16拍/512字节是测试假设**：需求表未定义最大 beats/bytes。使用测试地址，不代表项目实际地址映射。
- **128 是本测试的读写合计提交窗口及总限额**，读、写上限也各配置128；混合流量按读写交替提交。监测器另外报告全程真正地址已握手且 B/RLAST 尚未完成的峰值在途数，并硬断言达到128。提交窗口本身不等同于实际总线上同时在途128笔。
- **24 GB/s 的读/写/合计口径未由需求确认**，回归分别测只写、只读和混合，分别报告读、写及两者之和。全开放案例检查每个启用方向均至少24 GB/s。因此任何单方向或合计口径都可明确阅读，而不是暗选一个口径。
- WSTRB 默认32位全1；半 strobe 对照使用16位1。写入是 sink，并逐有效byte校验地址pattern；读取返回同一确定性地址pattern且由sequence检查。该 slave 不实现写后读存储。

## 测量

复位后启动真实 `simple_axi4_bfm_adapter` 与 sequence wrapper，持续提交并维持滑动完成窗口，避免整批 drain 后重新填充。先 warmup 1024 cycles，再测4096 cycles，最后停止提交并 drain 全部响应、核对总字节、地址和响应数。

测量区间 `[开始negedge, 结束negedge)` 恰好包含4096个 posedge。只在 `VALID && READY` 的采样沿计数：写字节为 `$countones(WSTRB)`，读字节为32。监测器拒绝非 full-width INCR；任何非OKAY响应使本性能测试失败。AW/AR请求数、B/RLAST完成数另外统计，均不作为payload字节。

写带宽表示W通道已接收的有效payload，不是该时刻B响应确认的事务带宽；最终drain核验全部B均OKAY。窗口边界允许穿过burst，因此窗口内AW与B、AR与RLAST数量可以不同，只有全程结束对账要求匹配。

使用十进制 GB/s：`带宽 = 有效字节 / elapsed_ns`。读写合计是同时运行的两个数据通道之和，不能当成单通道能力。每个采样沿实测时钟周期；结束后从 VCD 独立核对周期、窗口、握手、WSTRB、计数和公式。VCD 后处理在时钟上升时读取该时间戳更新前的总线值，避免把 slave 的 posedge NBA 更新误记为当前握手。

## 运行

先在独立 scratch 中放置完整已集成01–04、06的工程副本；仅需要 Python >=3.6 标准库与 VCS。不要运行会重生成工作簿的默认 make 链。服务器默认 shell 为 csh，以下命令在显式 bash 中执行：

```bash
eval "$(/fastone/softwares/modules/bin/modulecmd sh load vcs/S-2021.09-SP2)"
python3 tests/perf/run_perf.py --out /tmp/axi06-perf-unique-run
```

`--out` 必须尚不存在。生成的 SV 配置、filelist、simv、日志、波形和 JSON 全放在该目录；脚本在运行前后校验原 `docs/vip/vip_cfg.xlsx` 的 SHA256。

六个案例：只写开放、只读开放、混合开放、混合50%节流、只写半WSTRB、混合500MHz。开放场景 slave 不主动阻塞 W/R；节流按每2周期开放1周期控制 WREADY 和新 R beat 产生，已呈现的 RVALID 保持到握手。主机正常持续接收响应。对照检查节流吞吐降到开放场景约一半、500MHz吞吐约一半、半WSTRB写有效字节约一半。

每案例保存 `sim.log`、`perf.vcd`、`result.json`、`wave_check.json`；整个回归保存 `summary.json`、`workbook_sha256.txt`、`source_sha256.json`和编译命令。`PERF_REGRESSION_PASS` 只在全部案例、波形复算及目标/对照断言通过后输出。VCS的`$fatal`有时仍返回0，因此脚本同时检查日志和成功标记。

05合并后可添加 `--checker`，编译 `tb/axi4/checker` 并在性能 top 启用 `AXI_PERF_CHECKER`。通用 Makefile/filelist 集成归功能07。

## 测量环境自检

这些用例只验证测试环境本身，**不作为 VIP 达标证据**：

```bash
python3 tests/perf/run_clock_checks.py --out /tmp/axi06-clock-unique-run
python3 tests/perf/run_slave_checks.py --out /tmp/axi06-slave-unique-run
python3 tests/perf/run_monitor_checks.py --out /tmp/axi06-monitor-unique-run
python3 tests/perf/check_perf_vcd.py --self-test
```

时钟脚本提取实际 `tb_top` 时钟代码块，用独立 harness 检验默认10ns、1ns、2ns和非法参数。slave自检直接驱动信号，核对满拍接收、节流、R/B背压保持、ID/LAST及pattern。monitor自检则用预定的10周期窗口检查48写字节、64读字节和两个不计入带宽的W停顿周期，并用实际VCD再复算。`r_stalls`只表示`RVALID && !RREADY`，slave节流造成的无RVALID周期不属于此项。

工作簿 SHA256 必须在运行前后匹配 `docs/vip/workbook_baseline.json` 中的当前授权基线。08新增字段的基线迁移见 [工作簿字段说明](../../docs/workbook_fields_20260916.md)；历史VALIDATION记录保留当时的原始hash。
