# 功能04：主机激励与 sequence 兼容

高级流量使用独立 JSON，不修改 `docs/vip/vip_cfg.xlsx` 或 `docs/seq/seq_table.xlsx`。
本例使用测试内存地址；实际 NoC 地址映射尚未提供。16 拍是 LEN4 编码能力测试假设，
128 使用读/写/合计限额均为 128 的测试配置，不代替确认原需求的 outstanding 统计口径。

## 生成入口

从工程目录执行：

```sh
python3 tests/sequence/cases.py --case burst128 --out /tmp/axi04-plan.json
python3 scripts/gen_axi4_seq.py --plan /tmp/axi04-plan.json \
  --out /tmp/axi04-generated/axi4_generated_seq_pkg.sv --seq-dir /tmp/axi04-generated/seqs
```

`cases.py` 创建四组连续提交 128 笔的流量：128 写、128 读、64 读+64 写、128 读检查。
写/读 burst 混合 1/2/4/16 拍，使用多个 ID（也包含同 ID 多笔）。`await_all` 位于每组末尾，
提交语句之间不等待响应。最后一组将 64 个刚写入地址各读两次。

`--case lanes` 生成 256 位高字节、32 位单拍 lane 28、byte lane 31、跨总线字边界的
旧 byte 模式、稀疏 WSTRB 和读回检查。

可直接传给生成器的两个示例也保存在 `docs/examples/sequence_256_lanes.json`
（`SEQ=axi4_lane_seq`）及 `docs/examples/sequence_256_mixed.json`
（`SEQ=axi4_mixed_burst_seq`）。后者在 `0x1000..0x207f` 测试内存中混合
1/2/4/16 拍和单拍读写，适合单窗口 demo slave；不要求响应积压至 128。

## JSON 约定

顶层写出 `axi_data_width/axi_addr_width/axi_id_width/axi_len_width/max_burst_len`。
生成的 sequence 会检查编译时位宽，避免使用过期的 32 位 plan 驱动 256 位接口。

```json
{
  "axi_data_width": 256,
  "axi_addr_width": 32,
  "axi_id_width": 8,
  "axi_len_width": 4,
  "max_burst_len": 16,
  "sequences": [{
    "name": "register_example",
    "steps": [
      {"op": "submit_write", "addr": "0x501c", "id": 7, "size": 2,
       "beats": 1, "data": ["0x89abcdef"], "strb": ["0xf"]},
      {"op": "await_all"},
      {"op": "submit_read", "addr": "0x501c", "id": 9, "size": 2,
       "beats": 1, "expect": ["0x89abcdef"]},
      {"op": "await_all"}
    ]
  }]
}
```

- `size` 是 AXI AxSIZE 编码；每拍字节数为 `1 << size`，DATA256 的全宽 SIZE 为 5。
- `data/expect` 每项是**右对齐的本次传输 payload**，`strb` 是传输内的 byte mask。
  上例在总线上自动产生 `WDATA[255:224]=0x89abcdef`、`WSTRB=0xf0000000`。
  不要在 JSON 中提前左移；底层 02/03 request 的 bus-lane 数组语义与此便利 API 不同。
- `data/strb/expect/expect_mask` 是逐拍数组，长度必须等于 `beats`。
  `strb` 缺省为该 SIZE 全 byte 有效；`expect_mask` 缺省为该 SIZE 全 bit 有效。
- 读不填 `expect` 时仍检查完成状态和每拍响应。`expect_resp` 缺省为 OKAY(0)，可设 0..3。
- 地址按本笔 SIZE 对齐，只支持 INCR。校验拍数、ID/地址/数据位宽、4KB边界、溢出、WSTRB。
  aligned narrow 单拍可用；多拍 narrow 需设置支持开关，默认拒绝。
- `await_all` 只等待本 sequence 提交的 handle；sequence 结束时也会等待剩余 handle。
  同址写后读应插入 `await_all`；读写通道独立，单纯按源码顺序 submit 不保证写先完成。
- 生成器和运行时均校验事务。超过实际 driver 能力或配置的请求会明确报错。

## SystemVerilog API

需要直接使用 bus-lane request 的持续流量，可调用以下无额外锁的转发 API：

```systemverilog
axi_submit_write(input axi4_burst_request req, output axi4_completion handle);
axi_submit_read(input axi4_burst_request req, output axi4_completion handle);
axi_wait_completion(input axi4_completion handle, output axi4_burst_response rsp);
```

它们保留功能03的 completion 状态/响应语义，调用者负责处理失败状态。

sequence 基类提供 `axi_submit_write_payload`、`axi_submit_read_payload` 和返回的
`axi4_completion`；调用 `axi_wait_write_checked`、`axi_wait_read_checked` 检查结果。
可自行保留一个滑动窗口，等待最旧 handle 后立即补发，避免必须整批 drain。
这些便利 API 不持有跨事务总线锁；底层 admission 和通道调度由功能03管理。

旧 `axi_write/axi_write_checked/axi_read/axi_read_checked` 签名保持不变，默认全宽单拍。
`FULL_ADDR_SINGLE_BYTE` 在同一对齐总线字地址上通过 WSTRB 逐 lane 写；
`SINGLE_ADDR_SINGLE_BYTE` 发 SIZE=0 并随 byte 地址选择 lane。旧 alias 名称保留，
`INCR_ADDR_FIXED_STRB` 中的“FIXED_STRB”不再表示有问题的固定 lane0 行为。
`axi_read_by_mode` 为后一模式逐 byte 读回并重组 payload，因此非总线对齐起址也可验证。

原表格中的 `0x120/0x124` 和 range 步长 4 保持 32 位示例语义。
它们在 256 位全宽配置下不合法，会报错；需要小粒度访问时使用上面的显式 SIZE 输入，
或另建合法全宽地址/步长的计划。range 运行时 plusarg 同样检查地址窗口和步长。

## 隔离仿真

加载 VCS 模块后，运行：

```sh
python3 tests/sequence/run_vcs.py --case burst128
python3 tests/sequence/run_vcs.py --case lanes
python3 tests/sequence/run_vcs.py --case mixed
python3 tests/sequence/run_vcs.py --case legacy
python3 -m unittest discover -s tests/sequence -p 'test_*.py'
```

runner 将配置、生成 SV、数据文件副本和仿真产物放入独立临时目录；不调用会更新工作簿的 make 目标。
`burst128` slave 在实际接收 128 笔 AW/AR 后才释放响应；串行阻塞激励会被 watchdog 判为失败。
`legacy` 编译原 32 位计划，运行用户、single、range及两种 byte 模式，并执行原 IRQ handler。
HDL 自检检查实际握手计数、逐拍 LAST/WSTRB/SIZE、返回数据以及真实峰值，不能仅靠提交次数判定128在途。
legacy 还包含 5 个必须拒绝的运行时 plusarg 用例：地址/计数解析溢出、地址窗口溢出、非法步长、
重叠 byte 窗口批量读回。所有失败都要求匹配对应 fatal 文本，不能把任意超时当作预期拒绝。

## 实测结果（2026-09-16）

依赖功能03完成提交 `0614fda5e8cba62a1f6c016aa05f1755c9547611`。
VCS S-2021.09-SP2 / UVM-1.1d：4 次正式编译均无 SV Warning-/Error-，
11 个正向仿真与 6 个预期 fatal 仿真全部通过；22 项 Python 测试通过。

| 场景 | AW / W / B | AR / R | 实际读 / 写 / 合计峰值 |
|---|---|---|---|
| 连续128提交、四批读写 | 192 / 800 / 192 | 320 / 928 | 128 / 128 / 128 |
| mixed 示例 | 8 / 27 / 8 | 8 / 27 | 3 / 3 / 6 |
| 256位 lane、零/稀疏WSTRB、读mask | 67 / 67 / 67 | 37 / 37 | 1 / 1 / 1 |

8 个旧 API 场景包含原 user 两组、single、range、byte single/range、lane range、
独立 range_read 及 byte range_read；每个都执行原 IRQ handler 并核对准确握手次数。
5 个 plusarg 非法输入均命中指定 fatal；运行中 reset 的已提交事务通过 `AXI_SEQ_ABORT`
退出，未被当成成功的空响应。窄单拍测试的 RDATA 非有效 lanes 故意置为全1，检验按 SIZE 抽取数据。

证据及源码 SHA-256：`tests/sequence/validation_results.json`。
远端日志位于 `/fastone/users/shibin.lu/codex_scratch/axi04_sequence_20260916_jSpQ4P/`
下的 `mixed_v1`、`lanes_v1`、`burst128_v1`、`legacy_v2`。
原 `vip_cfg.xlsx` SHA-256 保持
`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`。
未修改生产服务器工程；本任务不验证实际 NoC 端到端吞吐。
