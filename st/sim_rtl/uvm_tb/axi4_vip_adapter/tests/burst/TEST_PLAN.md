# 功能02：INCR burst 验证计划

本目录仅使用独立 JSON/SV 配置和独立编译目录，不运行会改写工作簿的 make 目标。
目标测试：DATA256 / ADDR32 / ID8 / LEN4，1 ns 时钟周期。16 拍仅用于验证 LEN4 编码上限；需求中的最大业务 burst beats/bytes 尚未给定。本阶段阻塞事务串行，不宣称 128 outstanding 或实际 NoC 带宽达标。

| 测试 | 必须观察的结果 |
|---|---|
| 1/2/4/16 拍写后读 | 每笔 AW/AR/B 各握手一次，W/R 各 N 次，LAST 仅末拍，ID 保真 |
| READY 初始低后持续高 | AW/W/AR 不重复握手，无额外拍 |
| 地址和逐拍数据背压 | VALID 及完整 payload 保持稳定，计数只依上升沿握手推进 |
| 响应延迟与主端 B/R 背压 | B/R 仅在 READY&&VALID 时采样；返回完整数组 |
| 256 位数据 | 逐 byte 独立模式，最高 byte 非零，不能只验证低32位 |
| partial WSTRB | 稀疏/全零 strobe；仅相应 byte 更新；高位 lane 被覆盖 |
| narrow 单拍 | size=0/2，非零 lane 地址，data/strb 按总线 lane 放置 |
| 非法事务 | 0/17 拍、超过配置 max、超 size、WRAP/FIXED、LOCK、unaligned、跨4KB、地址溢出、数组长度或 strobe 越界；无总线请求 |
| 4KB 临界合法 | burst 最后 byte 恰在页尾；不错误拒绝 |
| 响应错误 | SLVERR/DECERR 保留原值，response checker 开关有效；错 ID / RLAST 由 protocol checker 检出 |
| 超时 | AW/W/AR READY，B/R VALID 停顿均有限超时；timeout 开关关闭及阈值0时允许延迟完成 |
| 复位 | 在途复位明确终止，不把复位期间输入当成功响应 |
| 旧单拍调用 | axi_write/axi_write_resp/axi_read 保留签名及阻塞返回语义 |

实现后的实际结果、运行命令及证据见 README.md；本计划本身不代表通过。
