# 功能01：接口与配置约定

本文保留功能01交付时的设计与验证记录。集成版本已实现burst、128并发调度、sequence、独立checker和可配置时钟；demo slave现支持INCR burst及ID回传。当前运行方式和能力边界以 [集成说明](integration.md)、[并发API](outstanding/README.md) 和 [checker约定](checker/README.md) 为准。下文“尚未实现”“后续功能”等字样仅描述01阶段。

本功能建立接口/配置基础，不实现 burst、并发调度、sequence、通用 checker 或带宽测量。默认 JSON 和 `vip_cfg.xlsx` 未改变；默认生成 SV 包仅同步新参数/安全类型，仍为 DATA32/ADDR32/ID4/LEN8。工作簿 SHA-256 必须保持 `b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`。

## 参数和类型

`axi4_if` 参数顺序为 `ADDR_WIDTH=32, DATA_WIDTH=32, ID_WIDTH=4, LEN_WIDTH=8, QOS_WIDTH=4, REGION_WIDTH=4, AWUSER_WIDTH=0, ARUSER_WIDTH=0, WUSER_WIDTH=0, RUSER_WIDTH=0, BUSER_WIDTH=0`。原三参数调用保持兼容。新增调用请用具名参数。

`axi4_vip_adapter_pkg::axi4_vif_t` 是包含所有配置位宽的 canonical virtual interface 类型。BFM、monitor 和 `uvm_config_db` 的 set/get 应统一使用它。top 实例须同时传 LEN 和可选侧带参数，不能继续在目标 profile 下仅传前三个参数。编译顺序仍为配置包、sequence 配置包、接口、adapter 包、BFM；无需新增 filelist 文件。

- DATA 必须为 8..1024 中的 2 次幂；STRB = DATA / 8。ADDR/ID 必须正数。
- LEN 为 1..8，目标为 4；线上的 AxLEN 为 beats−1。`max_burst_len` 是拍数，不能超过 `2**LEN_WIDTH`，default 不得超过 max。接标准 8 位 AxLEN 端口时零扩展；接项目 LEN4 端口时直接连接。LEN4 是项目受限 AXI4 端口，不代表完整 AXI4 最大 burst 能力。
- AXI4 固定 SIZE3、BURST2、LOCK1、CACHE4、PROT3、RESP2；生成器拒绝其他值。
- QoS/REGION 为 0 或 4；各 USER 为非负宽度。逻辑宽度 0 时物理 SV 存储为 1 bit，`$bits` 返回 1，不能用它推断逻辑存在性。内部采用 `max(width,1)`，不生成 `[-1:0]`。
- DUT 不带可选端口时，省略该连接；将 interface 的未连接输入 `buser/ruser` 显式接 `'0`。master 的 absent `awuser/aruser/wuser/awqos/arqos/awregion/arregion` 由 BFM 默认驱动 0。若 DUT 保留四位 QoS/REGION 而 profile 宽度为 0，wrapper 的 DUT 输入显式接 `4'b0`，不能让一位 placeholder 决定外部端口位宽。checker 按逻辑宽度跳过 absent 字段。
- USER 非零时按配置位宽完整连接；AW/AR/W 默认值为相同位宽的 packed 参数，不再通过 32 位 `int` 截断。B/R USER 只提供接口传递，本功能不实现其业务语义或响应 API。

BFM 初始化现在消费 `AXI_DEFAULT_ID/LOCK/CACHE/PROT/QOS/REGION/AWUSER/ARUSER/WUSER`，地址侧带整笔保持默认。LOCK 仅接受 0，不支持 exclusive。默认 CACHE=2 与现有配置一致；真实 DUT 所需属性由其集成配置决定。demo slave 的 BID/RID 仍固定 0，不能用它验证非零 ID 响应管理；本功能的非零 ID 检查使用专用连接夹具。

## 校验和尚未实现的能力

生成器拒绝非 AXI4、非 INCR 默认类型、exclusive/locked/unaligned/WRAP enable、关闭 INCR、非零 default_lock、非法位宽、溢出的字段默认值、超出 LEN 的拍数和未知 section 字段。宽度为 0 的可选字段只允许默认值 0。

为保持原工作簿兼容，`support.narrow_burst=true` 和 `support.fixed_burst=true` 仍接受，但 CLI 和生成包注释明确标记为旧策略声明；当前驱动只发 full-width INCR。`byte_strobe=false` 同样明确标记尚无行为控制。checker/coverage 开关、burst/outstanding 参数仍需下游实现消费者，生成成功不表示其功能已完成。02/03/05 实现后应同步更新能力说明。

新增 `axi.max_outstanding_total` → `VIP_AXI_MAX_OUTSTANDING_TOTAL` → `AXI_MAX_OUTSTANDING_TOTAL`。缺省为 read cap + write cap，即不比两方向独立上限额外收紧；可以显式设置更小总量。所有上限必须为正的 signed-int 可表示值。旧 `outstanding` 输入仍作为未显式设置的 read/write cap 的兼容别名；旧 `VIP_AXI_OUTSTANDING` 仍等于两方向最大值，**不是总量上限**。本功能尚无运行限流，03 必须实现三类 cap。

## 独立目标 profile 与运行

`tests/configs/scp_bach_ctrl_m0.json` 指定 DATA256/ADDR32/ID8/LEN4、QoS/REGION/USER0、INCR；16 拍/512 字节只是 LEN4 编码测试上限，读128/写128/合计128只是测试限额口径。需求中的 burst 上限、outstanding 和 24 GB/s 统计口径、实际地址范围仍未确认。1 GHz 时钟和24 GB/s激励/测量由后续任务实现，profile 不伪造已生效的时钟参数。

不要运行默认 make 配置目标来做此检查（它们会重写工作簿）。以下命令不需要读取或写入工作簿配置链：

```sh
python3 scripts/gen_vip_cfg.py --cfg tests/configs/scp_bach_ctrl_m0.json --out /tmp/scp_bach_ctrl_m0_cfg_pkg.sv
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_vip_cfg.py' -v
# 先加载 VCS；输出目录必须尚不存在。
PYTHONDONTWRITEBYTECODE=1 python3 tests/run_interface_checks.py --work-dir /tmp/axi01_unique_results
```

HDL runner 每次编译最多180秒、仿真最多30秒，串行运行三种配置及原默认 demo。运行目录与生产工程隔离；不依赖旧 PASS 日志。连接夹具只是组合回显，不是 AXI slave，不用于证明协议时序。

## 实际验证记录（2026-09-16）

本地 `test_vip_cfg.py` 的17项 unittest 全部通过，包含非法参数矩阵、LEN边界、zero-width、65位USER、旧输出不截断、unknown keys、方向/合计限额和工作簿前后SHA。

VCS S-2021.09-SP2，服务器独立目录 `/tmp/axi01_iface_20260916_RJSpA3/results`：

| 测试 | 结果 |
|---|---|
| 默认32/32/4/LEN8，原三参数 virtual interface | `INTERFACE_CHECK_PASS` |
| 目标256/32/8/LEN4，QoS/REGION/USER0 | `INTERFACE_CHECK_PASS` |
| 目标侧带变体，QoS4、AWUSER65、ARUSER33、WUSER64、RUSER17、BUSER9，非零默认ID/侧带 | `INTERFACE_CHECK_PASS` |
| 原 `tb_top` / `axi4_user_two_regs` | `DEFAULT_DEMO_PASS`；UVM_ERROR=0、UVM_FATAL=0 |

连接检查实际覆盖 config_db set/get 和 BFM init、LEN4最大编码、256位数据及32位STRB高位、ID8高位、非零 USER 默认值以及 modport B/R回传。四个编译日志未发现 VCS Warning-/Error- 或编译器 warning/error。它不证明 burst 握手、128 outstanding 或 NoC 端到端性能。
