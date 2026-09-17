# 功能03：并发提交、在途限额和响应管理

`simple_axi4_bfm_adapter` 现在由一个持续运行的时钟调度器推进五个独立通道。一个调用者可以持续提交请求，随后按任意顺序等待句柄。原 `axi_write`、`axi_write_resp`、`axi_read`、`axi_write_burst`、`axi_read_burst` 保持阻塞完成语义；不同调用者可以并发使用。sequence 包装不再隐式持整笔读写锁。显式 `lock_bus/unlock_bus` 仍供愿意协作串行化的旧调用者使用，异步调度器本身不获取它。

## API

```systemverilog
axi4_burst_request req;
axi4_completion pending[$], h;
axi4_burst_response rsp;

// 完全空闲时设置；三个值均必须为正数。
adapter.configure_outstanding(128, 128, 128);
for (int i = 0; i < 160; i++) begin
  req = new();
  req.id = i % 13;
  req.addr = 'h400000 + i * 512; // 仅测试地址；不是已确认的NoC地址映射
  req.beat_count = 16;
  req.size = 5; req.burst = 1;
  adapter.submit_read(req, h);
  pending.push_back(h);
end
foreach (pending[i]) begin
  adapter.wait_completion(pending[i], rsp);
  if (pending[i].status != AXI_COMPLETION_OK)
    $fatal(1, "Transaction failed: %s", pending[i].detail);
  // rsp.data/rid/rresp/rlast 各有16个元素，completed_beats记录真实接收拍数。
end
```

- `submit_write(req, output h)` 和 `submit_read(req, output h)` 在初始化后零仿真时间入队，深拷贝请求及data/strb数组。提交后可以复用原req。软件队列不设固定深度；长时间业务应使用滑动窗口并及时释放已完成句柄，避免无限占用仿真内存。
- `wait_completion(h, output rsp)` 允许重复等待完成句柄，允许多个等待者；不会重复发送。句柄属于创建它的adapter，跨adapter或null句柄会报fatal。
- `h.serial` 为adapter内单调唯一序号；`done/status/detail/response` 为输出，调用者不得修改。状态为 `AXI_COMPLETION_PENDING/OK/RESET/TIMEOUT/PROTOCOL_ERROR/REJECTED`。`OK`表示AXI事务完成，BRESP/RRESP仍可能为SLVERR/DECERR，须检查结果。
- 初始化后的reset低电平期间提交立即返回RESET。非法请求返回REJECTED并报告AXI_ILLEGAL；隔离期间提交返回REJECTED，detail要求reset。
- `get_outstanding_reads/writes/total()` 只统计**AW/AR已经握手、B/正确末拍R尚未完成**的实际在途数。`get_queued_reads/writes()` 包括软件待发及已经声明VALID但地址尚未握手的槽；不包括已地址握手后等待W的写。统计在时钟采样处理后更新，外部monitor比较请在negedge等稳定时刻采样。
- `configure_outstanding(read_limit, write_limit, total_limit)` 只允许完全空闲修改。缺省来自三个 `AXI_MAX_OUTSTANDING_*` 参数。功能01的total缺省是read+write；历史 `AXI_OUTSTANDING` 只是两方向最大值，不能当总上限。
- 直接使用concrete对象时可 `configure_timeouts(read_cycles, write_cycles, ready_cycles)`，完全空闲时修改，0禁用对应计时。编译配置 `AXI_ENABLE_TIMEOUT_CHECKS=0` 禁用全部超时诊断。

## 通道、顺序和限额

AW/AR在发行VALID前预留credit，因此同周期地址握手也不会超方向或总限额；预留不计实际outstanding。总量只剩一笔时轮转选择读/写。W按AW发行顺序输出且burst间不交织；WVALID不依赖AWREADY，支持W先于AW。正常情况下W可每周期传一拍，RREADY/BREADY持续为高。所有输出在采样沿后NBA更新，背压期间稳定。

BID/RID查找各自ID最早未完成事务；允许不同ID乱序以及不同RID逐拍交织。B须在AW和WLAST握手之后出现，R须在AR握手之后出现；校验使用采样沿前状态。相同ID响应必须遵循协议FIFO。相同ID同长度事务的内部交换无法仅靠ID识别，需要外部数据scoreboard。

`AXI_ENABLE_RESPONSE_CHECKS && req.check_response` 控制非OKAY响应码报告（AXI_RESPONSE），不影响实际响应保存/完成。用于可靠路由的未知ID、早B和错误RLAST保护始终启用，不能通过关闭protocol checker变成错配。完整独立checker/coverage由功能05提供。

功能02提供的raw `send_aw/send_w/send_ar/receive_b/receive_r` hook不再由这个调度adapter实现；调用会在驱动信号前报AXI_UNIMPLEMENTED。所有请求应使用阻塞burst或异步API，不能同时有另一个master控制同一interface。

## reset、超时及服务生命周期

reset异步清空本epoch软件队列、通道槽和在途状态，所有未完成句柄完成为RESET；旧句柄不会被新同ID请求复用。

超时采用当前阶段无进展语义：AW/AR/W只对当前VALID槽或W拍计时；B只对同ID最早且AW/WLAST均完成的写计时；R只对同ID最早读计时，每拍握手重新计时。软件排队及同ID后继等待不计响应超时。阈值边界先接受握手，再判断超时。

未知ID、早B、错误RLAST或超时会报告一次AXI_BFM_PROTOCOL/AXI_BFM_TIMEOUT，把全部未完成句柄设为相应失败状态并隔离至reset。停止发行新请求/新W拍，拉低BREADY/RREADY。已声明AW/AR/W VALID仍保持payload直到一次握手，然后撤销；该迟到地址握手仍增加真实在途，**不会把失败句柄伪装成物理事务已完成**。发生失步后的实际在途仅由reset清除。阻塞API没有返回status参数，因此遇到非OK完成以AXI_BFM_ABORT fatal结束；需要可恢复reset/timeout处理的调用者应使用异步句柄。

`axi4_adapter_sequencer.build_phase` 登记service owner，`run_phase`拥有engine；sequence.kill/stop_sequences只取消等待者，不取消已提交的AXI请求。测试应保持UVM objection直到请求处理结束。纯module测试在长期initial进程先调用 `adapter.init()`；不要从会被kill的临时worker首次初始化。检测engine意外终止时明确fatal，不静默重新启动可能留下旧请求的总线。

## 独立验证与需求边界

```sh
# 已加载VCS的环境；只生成临时配置，不调用make。
OUT_DIR=/tmp/axi03_unique bash tests/outstanding/run_vcs.sh
# 可选子集
CASES='positive poison_cleanup lifecycle' OUT_DIR=/tmp/axi03_subset bash tests/outstanding/run_vcs.sh
```

`profile.json` 使用DATA256/ADDR32/ID8/LEN4，16拍是编码能力测试，128/128/128是明确的测试限额选择。Excel没有确认最大burst及128是读、写还是合计；实际NoC地址图与24 GB/s读写口径也未给出。本回归只证明BFM受控激励/响应管理能力，不代表真实NoC端到端性能。原vip_cfg.xlsx保持原SHA-256不变。

最终实际VCS通过35个场景（本功能14、适配burst17、接口/demo4），配置Python测试17项通过。读/写真实在途峰值分别128，混合合计峰值128，停钟reset、取消sequence和故障迟到READY均通过。实际回归计数、日志路径与源码哈希见 `tests/outstanding/evidence/validation_results.json`；设计审查细节见 `design.md`。
