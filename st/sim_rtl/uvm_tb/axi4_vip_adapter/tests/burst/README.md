# 功能02实际 burst 回归

> 功能03接入说明：排队调度替代了02的单事务实现；raw通道hook现明确不支持，使用submit/wait或阻塞burst。错ID/LAST即使protocol检查关闭也会隔离至reset。02测试已适配新语义；当前契约见 `docs/outstanding/README.md`，本页原验证记录是02阶段历史证据。

此目录完全独立于默认 `make` 配置链，不修改 `vip_cfg.xlsx`、默认 JSON 或默认生成 SV 参数。运行前后检查 `docs/vip/workbook_baseline.json` 中的当前授权 SHA-256；08字段迁移说明见 [工作簿字段说明](../../docs/workbook_fields_20260916.md)。历史validation_results保留当时基线。

## 运行

```sh
# 在服务器先加载与Makefile相同的VCS模块，再从工程目录运行。
eval "$(/fastone/softwares/modules/bin/modulecmd sh load vcs/S-2021.09-SP2)"
python3 tests/burst/run_vcs.py --mode checked --work-dir /tmp/axi02_unique_checked
python3 tests/burst/run_vcs.py --mode response_off
python3 tests/burst/run_vcs.py --mode protocol_off
python3 tests/burst/run_vcs.py --mode timeout_off
python3 tests/burst/run_vcs.py --mode zero_timeout
python3 tests/burst/run_vcs.py --mode narrow_enabled
python3 tests/burst/run_vcs.py --mode strobe_disabled
```

省略 `--work-dir` 时使用系统临时目录；可用 `--case positive` 只跑指定case。编译最多240秒，单case最多30秒，bench另有独立仿真watchdog。脚本生成临时JSON及SV包，直接编译所需文件，不使用原filelist或Makefile。接口/旧demo追加检查入口为 `python3 tests/run_interface_checks.py --work-dir /tmp/axi02_unique_legacy`。

## 验收方法

- `burst_tb.sv` 的独立上升沿monitor对五通道计数，并逐byte维护expected memory；它同时核对线上数据和API返回数组，未复用driver的lane计算函数生成期望内存。
- `burst_test_slave.sv` 是测试夹具。支持每方向一笔、可控制各通道延迟和逐拍间隙、保持响应背压payload、ID/响应码/LAST注入。memory为64KB，地址对64KB取模，只用于局部受控测试。
- READY从低到高后的额外保持窗口使重复AW/AR/W握手立即暴露。测试并非依赖“收到首拍后立刻撤READY”的slave来掩盖错误。
- 预期UVM_ERROR由catcher核对ID并计数；预期fatal必须精确匹配ID和完整消息才产生 `EXPECTED_FATAL` 标记。其他错误、超时watchdog或缺少PASS标记均失败。负例的“PASS”表示正确检测错误，不表示坏流量合法。
- target是256/32/8/LEN4、1ns周期、每阶段12周期超时，阻塞1 outstanding。16拍是字段编码能力测试；需求业务最大burst、地址map及128/24GB/s口径仍未知。

## 2026-09-16 VCS结果

服务器：`xingan-login`，VCS `S-2021.09-SP2_Full64`。独立scratch根目录：`/tmp/axi02_burst_20260916_eWZBds`。具体日志路径、源文件SHA及标记见 `validation_results.json`。

| 组 | 实际检查 | 结果 |
|---|---|---|
| checked/positive | 1/2/4/16拍 × 初始READY/低转高保持/逐拍背压；AW等待WVALID；全256位/partial/zero WSTRB；4KB合法页尾；窄单拍高lane；B/R主动背压；旧3个单拍API | PASS，AW=33/W=169/B=33/AR=20/R=99 |
| checked/responses | SLVERR、DECERR、含X的BRESP/RRESP原值保留；全局开关与per-request/raw接口语义 | PASS，11个预期自动响应错误 |
| checked/protocol | 错BID、逐拍错RID、翻转LAST | PASS，9个预期协议错误 |
| checked/illegal | 15项纯函数校验：0/17拍、超SIZE、4KB、对齐、禁用窄多拍、strobe lane、FIXED/WRAP/reserved、LOCK、数组长度、地址顶端边界 | PASS，无任何握手 |
| checked/illegal_api | 实际非法请求入口拒绝 | PASS，精确AXI_ILLEGAL fatal |
| checked/timeout_aw/w/ar/b/r | 五通道分别无法握手 | PASS，精确AXI_TIMEOUT及对应通道消息 |
| checked/reset | AW在途复位 | PASS，精确AXI_RESET fatal |
| response_off/responses | 相同错误码仍原样返回，自动响应错误为0 | PASS |
| protocol_off/protocol | 相同错误ID/LAST原样返回，自动协议错误为0 | PASS |
| timeout_off/delayed、zero_timeout/delayed | 五通道20拍延迟，大于默认测试阈值12 | PASS |
| narrow_enabled | SIZE2四拍跨总线字边界，lane mask依次0f000000/f0000000/0000000f/000000f0 | PASS |
| strobe_disabled | 拒绝partial full/narrow mask；允许完整transfer mask窄单拍 | PASS |
| interface_legacy | 原三参数接口、目标零宽、65bit USER，以及原32位axi4_user_two_regs demo | 4组PASS；demo UVM_ERROR/FATAL=0 |

另有17项本地配置单元测试通过。编译日志无VCS Warning-/Error-或C编译warning/error；默认legacy配置存在预期的 `AXI_CAPABILITY` UVM warning，说明FIXED未实现。

## 边界

本回归未接真实NoC，不证明128 outstanding或24GB/s。旧逐byte sequence的错误lane语义由04修复；本提交的旧单拍接口保持自然对齐full-width语义。协议包长度失步后没有恢复机制，需reset；复位/超时采用fatal终止，不支持降级fatal后继续执行。完整API和后续03调度契约见 `../../docs/burst_api_contract.md`。
