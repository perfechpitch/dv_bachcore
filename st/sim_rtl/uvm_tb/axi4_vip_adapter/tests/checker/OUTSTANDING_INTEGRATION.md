# Feature 03 / 05 integration

After loading VCS, run `python3 tests/checker/run_outstanding_integration.py`.
Python 3.6 is supported; `run_burst_integration.py` supplies shared preparation
helpers and must be present beside the runner. Default cases are `positive`,
`lifecycle`, `clock_reset`, `progress`, and `w_before_aw`. Repeat `--case` to choose a subset, or use
`--prepare-only` to inspect the temporary inputs without invoking VCS.

The runner copies the completed upstream `tests/outstanding/profile.json` into
scratch, generates a local configuration package, and injects monitor instances
and acceptance checks into temporary bench copies. It preserves all original
stimulus and scoreboards. Original sources, profile, generated configuration,
Makefile, filelist, and workbook hashes must remain unchanged. A manifest records
their hashes, compile commands, and results. Ambiguous/missing injection anchors
stop preparation.

The positive bench intentionally generates SLVERR/DECERR, including response
patterns used to verify same-ID completion order. Its main monitor has only
response checking disabled. A second monitor enables response checking with
reporting suppressed: its response-error count must become nonzero and all
other diagnostic counts must remain zero. The main monitor must retain zero
total errors and sample both response-code coverage bins. No X checks or
protocol checks are disabled, and no original response stimulus is changed.

Every held plateau compares independent monitor read/write counts against the
controlled slave, verifies the requested total, and checks read/write/total
against the slave's current limits. Final cumulative maxima must be exactly
128 reads, 128 writes, and 128 total, with nonzero coverage at depth 128.
The monitor's configured ceilings remain 128/128/128. The bench's runtime
3/5/7 and other lower limits are additionally checked at plateaus; continuous
lower-limit enforcement remains the original driver/slave scoreboard's job.
This does not claim that the passive monitor dynamically adopts those limits.

Each drain and simulation finalization checks quiescence and compares independent
handshake counts against the slave. Monitor counters are cumulative across reset;
the runner injects a snapshot on every falling edge of reset, then compares
per-epoch differences to slave counters. This also handles resets outside
`setup()` and resets while the AXI clock is stopped. Aborted pre-reset traffic
does not need to produce normal responses after reset.

Lifecycle and paused-clock reset use all checker categories enabled and require
zero monitor errors, quiescence, nonzero handshake/coverage evidence, and their
original PASS marker. Module `final` functions perform acceptance even when
UVM's `run_test()` ends simulation internally. The Python runner rejects any
fatal/checker failure even when VCS returns exit status zero.

The broad 128-pressure/lifecycle/reset cases use 10000-cycle budgets. Two
additional directed cases preserve short budgets and expose queue-wait false
positives rather than masking them:

- `--case progress`: only the original `progressing_timeout_case()`, with both
  driver and monitor READ/WRITE=4, READY=16; 12 reads and 12 writes, each 16 beats.
- `--case w_before_aw`: only `independent_aw_w_case()`, both driver and monitor
  READ/WRITE=4, READY=40; W completes while AW is blocked for 20 cycles.

Both cases reproduced false timeouts before checker fix `9e5bfdf`. The corrected
monitor starts R timing only for the oldest same-ID read, B timing only for the
oldest same-ID write after AW and W completion, and gives newly eligible heads a
fresh baseline. Unpaired W waiting for AW uses READY, not WRITE. The short
budgets remain unchanged in the passing regression. The separate six-case raw
bench also proves real head stalls still time out and successor timing restarts.

DATA256/ADDR32/ID8/LEN4, 16 maximum beats, and 128 read/write/combined limits are
test assumptions. No actual NoC RTL, address map, or end-to-end bandwidth is
validated by this controlled-slave regression.

## 实际联合结果（2026-09-16）

VCS S-2021.09-SP2，03 driver `0614fda`，checker修复`9e5bfdf`；五组均PASS，编译无Warning-/Error-。最终日志位于`/tmp/axi05_outstanding_joint_20260916_2XUbbr/after_fix`，机器可读摘要在`../../docs/checker/joint_validation_20260916.json`。

| 组 | 独立monitor证据 |
|---|---|
| positive | 峰值读128、写128、总128；混合R66+W62；8次plateau和16次drain/结束核对全部通过；3/5/7与total1流量完成 |
| progress | 4/4/16预算，AW12/W192/B12/AR12/R192，错误0 |
| w_before_aw | 4/4/40预算，AW8/W32/B8/AR0/R0，错误0 |
| lifecycle | 取消3个等待者后6个句柄正常完成；AW3/W12/B3/AR3/R12，错误0 |
| clock_reset | 8次停钟复位、32次waiter唤醒；恢复epoch为AW1/W4/B1/AR1/R4，错误0 |

positive保留故意错误RESP：main response-off计数0，response-on witness计数32，SLVERR/DECERR实际各16；其它checker全部开启且零错误。跨reset累计AW与B可不同（被reset终止的事务），每个排空epoch按差值验收，不能将累计差值误称丢事务。

原始源码和`vip_cfg.xlsx`哈希均未变。工作簿保持`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`。
