# 功能02：INCR burst / 五通道交接约定

> 功能03接入说明：排队调度替代了02的单事务实现；raw通道hook现明确不支持，使用submit/wait或阻塞burst。错ID/LAST即使protocol检查关闭也会隔离至reset。02测试已适配新语义；当前契约见 `docs/outstanding/README.md`，本页原验证记录是02阶段历史证据；集成运行、demo slave及能力边界见 [集成说明](integration.md)。

实现位于 `tb/axi4/axi4_vip_adapter_pkg.sv` 和 `tb/axi4/simple_axi4_bfm_adapter.sv`，依赖功能01。原工作簿、默认 JSON、通用 Makefile/filelist、top 和 demo slave 均未修改。功能02的阻塞 API 每次只允许一笔事务；128 outstanding 由功能03接管。

## 事务 API

`axi4_burst_request extends uvm_object`：

| 字段 | 含义 |
|---|---|
| `id`, `addr` | 配置宽度的 ID/地址；ID 缺省 `AXI_DEFAULT_ID` |
| `int unsigned beat_count` | 真实拍数；线上的 AxLEN = beat_count−1，缺省1 |
| `int unsigned size` | AxSIZE：每拍字节数为 2**size；缺省全总线宽 |
| `int unsigned burst`, `bit lock` | 仅接受 INCR=1、LOCK=0 |
| `logic [DATA-1:0] data[]`, `logic [STRB-1:0] strb[]` | 写数据/字节使能，数组长度必须等于拍数 |
| `bit check_response` | 缺省1；设0仅取消此事务的自动 OKAY 响应码检查 |

`function string validate(bit is_write)` 无时序/无总线副作用，合法返回空字符串，否则返回原因，便于功能03在提交时复用。`do_copy` 深拷贝动态数组；阻塞 API 在等待锁之前保存快照。原始通道调用的 request 在返回前必须保持不变。

`axi4_burst_response` 的所有总线返回值使用 `logic` 保留 X：`bid/bresp`、逐拍 `rid[]/data[]/rresp[]/rlast[]`，以及 `int unsigned completed_beats`。它不提供异步 completion 状态；协议错误通过 UVM 报告，不应仅凭 API 返回判定测试通过。

```systemverilog
axi4_burst_request req = new("burst");
axi4_burst_response rsp;
req.addr = 'h2000;
req.id = 'ha5;
req.beat_count = 4;
req.size = 5;                 // DATA256: 32 bytes per beat
req.data = new[4];
req.strb = new[4];
foreach (req.data[i]) begin
  req.data[i] = '1;           // Every bit, including the upper 224 bits
  req.strb[i] = '1;
end
adapter.axi_write_burst(req, rsp);
adapter.axi_read_burst(req, rsp);
```

base 和 simple adapter 均声明 `virtual task axi_write_burst(input axi4_burst_request req, output axi4_burst_response rsp)` / `axi_read_burst`。未实现的其他 adapter 会明确报 `AXI_UNIMPLEMENTED`。

## 数据 lane、合法性和兼容边界

data/strb 始终是**总线 lane 格式**，不会隐式左移或右移。例：DATA256、addr=0x124、SIZE=2 的单拍，WSTRB 合法掩码为 `32'h000000f0`，有效数据位于 `[63:32]`；addr=0x13f、SIZE=0 使用 bit31 的 WSTRB 和 `[255:248]`。读返回完整原始总线字，窄传输只保证地址所对应 lane 有意义。`req.lane_mask(beat_index)` 提供合法 byte lane 掩码。

- 拍数必须为1..min(256, 2**LEN_WIDTH, AXI_MAX_BURST_LEN)，不会先截断再检查。
- 地址必须按本次 SIZE 自然对齐；不支持 unaligned、exclusive/locked、FIXED、WRAP。
- burst 不得跨4KB，不得绕回配置地址位宽。最后 byte 恰为页尾是合法的。
- `support.narrow_burst=false` 拒绝窄**多拍**，仍允许自然对齐窄单拍。设true时支持自然对齐的窄 INCR 多拍并按地址推进 lane。
- WSTRB 不得含 X 或超出本次 transfer lane；`byte_strobe=true` 允许 sparse/zero mask；false要求完整 transfer lane mask，窄单拍并非要求全总线 WSTRB 全1。
- 合法性检查不会因 checker 开关关闭而取消；无效事务在驱动前报 `AXI_ILLEGAL` fatal。

旧 `axi_write/axi_write_resp/axi_read` 签名和阻塞语义保持，仍为全总线宽单拍、默认ID。因此必须按全总线宽自然对齐。`axi_write_resp` 返回原始 BRESP，兼容显式预期错误响应的 checked sequence；`axi_write/axi_read` 的自动 OKAY 检查受配置控制。旧 `SINGLE_ADDR_SINGLE_BYTE` helper 原有递增地址但固定低lane的错误由功能04修复；在本提交中这类错误 full-width 未对齐调用会明确被拒绝。

保留旧工作簿 `support.fixed_burst=true` 的配置兼容，生成器注释及 BFM `AXI_CAPABILITY` warning 明确它是遗留许可，实际 FIXED 请求仍拒绝。默认 demo 的 full-width INCR 调用可继续使用。

## 功能03可用的五通道接口

以下接口在 base/concrete 均为 public virtual task，调用者先完成 `init()`，每个通道必须只有一个 owner，不能与阻塞事务 API 混用：

```systemverilog
send_aw(input axi4_burst_request req);
send_w (input axi4_burst_request req); // 整个 burst，不交织 W 数据
send_ar(input axi4_burst_request req);
receive_b(output logic [AXI_ID_WIDTH-1:0] id, output logic [1:0] resp);
receive_r(output logic [AXI_ID_WIDTH-1:0] id,
          output logic [AXI_DATA_WIDTH-1:0] data,
          output logic [1:0] resp, output logic last); // 一拍
```

通道函数不持事务锁；send在地址或最后W拍握手后返回，receive只取下一次有效握手。AXI4没有WID，W整笔顺序必须与AW FIFO顺序一致。ID匹配和期望R拍数/LAST检查位于阻塞聚合层，03可替换为分发器。这里没有地址在途计数、队列或同ID重排管理。

每次先用NBA设置输出，至少等待下一上升沿，仅在 `VALID===1 && READY===1` 时推进，并在该边沿后的NBA撤VALID或切换下一payload；背压期间不修改payload。AW/W并行启动，不等待AW握手再置WVALID。初始化有独立锁，避免首次多通道调用重写活动输出。

`ready_timeout_cycles` 用于AW/W/AR；write/read timeout分别用于B/R。以每个地址/数据/响应阶段的连续未握手边沿计数，W/R每拍重新计数；第N次未握手边沿到达正阈值N时报 `AXI_TIMEOUT` fatal，恰在该边沿握手优先成功。`enable_timeout_checks=false` 或对应阈值0禁用检查。

`enable_response_checks` 控制自动非OKAY检查（含X）；`enable_protocol_checks` 控制BID/RID/RLAST匹配。自动错误ID分别为 `AXI_RESPONSE` / `AXI_PROTOCOL`。全局X、alignment、strobe等**总线监视器**属于05；这里的事务合法性属于driver能力边界。

在途复位报 `AXI_RESET` fatal并撤活动输出；本功能没有可恢复abort协议。真实early RLAST且后续拍消失将报协议错后超时；late RLAST/多余R拍也不提供残留清理。协议出错后需reset，不能继续复用返回值宣称恢复成功。fatal不可被降级后继续用本驱动；03负责队列级故障隔离/复位恢复。

## 需求和测试假设

目标 tests 使用 DATA256/ADDR32/ID8/LEN4、1ns周期、受控memory slave；16拍只验证LEN4编码，并非已确认业务最大burst。真实NoC、地址映射、128读写/合计口径及24GB/s口径不由本功能确认。测试slave只有每方向一笔窗口，不能用作128在途或性能达标证据。

实际运行入口及结果见 `tests/burst/README.md`。
