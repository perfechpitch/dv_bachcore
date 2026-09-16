# DSA MMIO Reference Model

## 目标

`dsa_mmio_lib` 负责 DSA 软件可见 MMIO、Register File state、内部 bypass state，以及 trigger 时产生本次 DSA 宏指令使用的 effective parameter snapshot。

基本边界：

```text
JSON
  描述寄存器、字段、state、static/dynamic关系

Python generator
  机械生成 declaration/reset/read/write/resolve

vu_mmio_set
  MMIO状态
  RF状态
  特殊MMIO行为
  trigger snapshot

vu_inst_lib
  opcode
  operand source语义
  execution
  bypass
  writeback
```

## 0915 寄存器与异常接口

寄存器描述以 `mmio_desc/vu_mmio.json` 为源，运行
`python3 tools/gen_dsa_mmio.py mmio_desc/vu_mmio.json` 可重现全部 VU 生成文件。
静态和动态 `TYPE_VL.NAN_INF_REPLACE_EN` 均位于 bit20，随 MASK bit0 一起选源；
trigger 的 bit7 为保留位，写入忽略、读回零。两个替换值为全局寄存器
`INF_REPLACE_VALUE` (0x1F00) / `NAN_REPLACE_VALUE` (0x1F04)，不随配置组切换。

- `dsa_mmio_library.write(addr, data, user_id=0, stream_id=0)` 保留旧两参数用法。
  Core 调用方传入请求元数据；NOC/debug 使用零默认值。写 trigger 时保存本条宏指令的
  user_id，以及经 override 选择的 Event stream。普通配置写不覆盖当前宏指令的用户。
- `vu_mmio_set.get_current_user_id()` / `get_current_event_stream_id()` 返回当前宏指令的
  用户/有效 Event 标签；空闲时返回零。当前模型仍同步执行，不在此增加事件输出或队列时序。
- `report_error(error_bits, unit=0, user_id_override=0, use_user_override=0)` 使用
  `dsa_mmio_define.svh` 的 `VU_ERR_*` 掩码。默认从当前 trigger 取得用户。
  ERROR_INFO 的 STREAM_ID 按文档保存 trigger 原始字段，非最终 Event 标签。
  ERR_UNIT 使用完整的 [26:23] 和原 0..15 编号，没有重叠的 RESERVED[23]。
- `report_error(VU_ERR_NAN, unit)` 同时维护独立的 NAN_ERR_INFO 首错锁存。
  调用方负责 NaN 的适用范围与替换模式判断。各错误位累积；ERROR_INFO 和各专用上下文
  分别只锁存各自首次错误。先读取上下文，再读 ERROR_CODE；读 ERROR_CODE 将错误码、
  ERROR_FLAG、ERROR_INFO、sticky 快照以及六个专用上下文一起清零。
- `note_replacement(is_nan)` 每替换一个 element 调用一次；仅在 PROFILE_CTRL.RUN=1 时
  累加 NAN_REPLACE_CNT 或 INF_REPLACE_CNT。由归约输出/SU 输入的实际替换点调用，
  不能把原样透传或 LU 转换计为替换。CLEAR 包含这两个新的 64-bit 计数器。

### ECC 验证接口与边界

这里没有 ECC 校验位、检测器或真实 CM ECC 响应；以下函数是显式错误注入接口，
只用于验证软件可见的错误码、上下文、首错锁存与读清行为，不修改 RF/CM 数据：

```systemverilog
// Arguments: RF selector, entry, uncorrectable, explicit user, use current user.
mmio.inject_rf_ecc(2'd0, 9'd3, 1'b1, 16'h1234, 1'b0);
// Arguments: byte address, store direction, uncorrectable, user, use current user.
mmio.inject_cm_ecc(32'h100, 1'b0, 1'b1, 16'h1234, 1'b0);
```

RF 选择 0/1/2 分别为 VRF/MRF/SRF；索引范围为 0..511/0..511/0..63。
`uncorrectable=0` 不产生错误或上下文更新；它不表示模型执行了真实纠错。
默认用当前宏指令的用户，`use_current_macro=0` 时使用显式 user_id；debug/NOC 注入传零。
CM 的 is_store 只记录 DIR 和 LU/SU 单元编号；它不新增硬件写错误响应通道，也不解决
设计文档中该通道的待澄清项。真实 ECC 检测、异常停派发策略、IRQ、并行/周期行为均不在此实现。
