# 功能03 实际验证证据

`validation_results.json` 记录基线提交 `0614fda5e8cba62a1f6c016aa05f1755c9547611` 源码的远程VCS运行结果、每个场景的实际握手计数、原始日志路径、编译诊断和12个输入源码SHA-256；记录保存前已核对本地/远程源码完全一致。

服务器独立scratch：`/tmp/axi03_outstanding_20260916.IZPP60`。没有修改生产工程。

| 验证 | 结果 |
|---|---|
| 功能03独立VCS场景 | 14 PASS：正向综合、五通道timeout、五种非法响应、poison迟到READY、UVM生命周期、停钟reset |
| 02适配burst回归 | 17 PASS，含检查开关关闭、0 timeout、窄访问和strobe策略 |
| 01接口与原默认demo | 4 PASS，原demo UVM_ERROR/FATAL均为0 |
| 配置Python单元测试 | 17 PASS |
| 原vip_cfg.xlsx | SHA-256仍为b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994 |

核心物理证据：独占读积压AR=128/RLAST=0，独占写积压AW=128/B=0；释放后读AR/RLAST=160、R拍=1114，写AW/B=160、W拍=1114。混合积压AW=62/AR=66，总live=128，最终读写各96事务/672拍收敛。3/5/7各方向与合计边界、total=1读写严格交替也通过。same-ID数据和响应码区分、跨ID乱序、读交织均有独立scoreboard。停钟reset的8个epoch共32次等待返回且停钟期间没有时钟沿；sequence.kill/stop_sequences后累计6句柄仍完成。

运行入口：在VCS环境执行 `OUT_DIR=/tmp/axi03_unique bash tests/outstanding/run_vcs.sh`。请区分以下早期slave模型自测与最终driver回归。

`slave_model_smoke.txt` is the captured summary from an actual VCS
S-2021.09-SP2 run on xingan-login, using the committed feature01 interface
`a79654a79e81db1c6f2aa43afe537fde2cd6b12a`, this directory's
`../controlled_slave.sv` and `../slave_model_smoke.sv`. The remote source and
full compile/simulation logs are in
`/tmp/codex_outstanding_slave_20260916_qo3PMX`.

Command after loading `vcs/S-2021.09-SP2` in that isolated directory:

```sh
timeout 90 vcs -full64 -sverilog -timescale=1ns/1ps axi4_if.sv controlled_slave.sv outstanding_slave_smoke.sv -top outstanding_slave_smoke -o simv -l compile.log
timeout 15 ./simv -l sim.log
```

The source was copied to scratch as `outstanding_slave_smoke.sv` (its module
name is unchanged). This verifies the test slave's bus queues, independent
AW/W behavior, same-ID ordering, cross-ID reorder and R interleaving. It is
**not** evidence that the feature03 driver has passed its regression. Driver
evidence comes only from `run_vcs.sh` with `outstanding_tb.sv` and the final
feature03 adapter implementation.

## 同沿timeout补充回归

`timeout_same_edge_results.json` 记录后续仅测试补丁的实际VCS证据，driver/API包未修改。新增`timeout_edge_r`、`timeout_edge_b`均通过，并重跑原`positive`通过；编译无VCS警告/错误。两个case均从物理握手沿计算8cycle预算，在故障沿同时发生AW、AR、非末拍W各一次握手。R场景实际AW/W/AR=1/1/2，B场景=2/2/1；B/R均未完成，实际live=3，7个句柄均TIMEOUT。之后保持READY且提供迟到响应12cycle，没有新W拍/地址，没有错误退休，也没有失败状态被改为OK。reset后正常读写恢复。

复现：`CASES='timeout_edge_r timeout_edge_b' OUT_DIR=/tmp/axi03_edges bash tests/outstanding/run_vcs.sh`。默认runner也包含这两个新case；原35场景证据加新增2场景，独立功能03默认集合从14增至16。
