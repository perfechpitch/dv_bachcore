# 功能05：独立协议监视、检查与功能覆盖

`tb/axi4/checker/axi4_protocol_monitor.sv` 是被动 pin-level monitor，不读 driver 私有状态、不驱动 interface，不依赖 UVM。只支持普通 AXI4 INCR；其 decoder 支持 full-width、窄单拍/多拍及非对齐 INCR。默认参数匹配 DATA256/ADDR32/ID8/LEN4。保留已有 driver/API；通用 filelist/top 由功能07接线。

本测试选用最大16拍、读128/写128/总128、1GHz。这是测试假设，不确认需求工作簿中尚未定义的最大 burst、128 口径、地址图或24GB/s口径。原 `docs/vip/vip_cfg.xlsx` 不变。

## 编译及接线

顺序：`axi4_if.sv` → `checker/axi4_checker_pkg.sv` → `checker/axi4_protocol_monitor.sv` → top。无需 adapter package 也可独立编译。默认 target 可这样连接：

```systemverilog
axi4_protocol_monitor #(
  .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
  .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH),
  .MAX_BURST_BEATS(AXI_MAX_BURST_LEN),
  .MAX_OUTSTANDING_READS(AXI_MAX_OUTSTANDING_READS),
  .MAX_OUTSTANDING_WRITES(AXI_MAX_OUTSTANDING_WRITES),
  .MAX_OUTSTANDING_TOTAL(AXI_MAX_OUTSTANDING_TOTAL),
  .READ_TIMEOUT_CYCLES(AXI_READ_TIMEOUT_CYCLES),
  .WRITE_TIMEOUT_CYCLES(AXI_WRITE_TIMEOUT_CYCLES),
  .READY_TIMEOUT_CYCLES(AXI_READY_TIMEOUT_CYCLES),
  .ENABLE_PROTOCOL_CHECKS(VIP_ENABLE_PROTOCOL_CHECKS),
  .ENABLE_X_CHECKS(VIP_ENABLE_X_CHECKS),
  .ENABLE_ALIGNMENT_CHECKS(VIP_ENABLE_ALIGNMENT_CHECKS),
  .ENABLE_STROBE_CHECKS(VIP_ENABLE_STROBE_CHECKS),
  .ENABLE_RESPONSE_CHECKS(VIP_ENABLE_RESPONSE_CHECKS),
  .ENABLE_TIMEOUT_CHECKS(VIP_ENABLE_TIMEOUT_CHECKS),
  .SUPPORT_INCREMENTING_BURST(VIP_SUPPORT_INCREMENTING_BURST),
  .SUPPORT_NARROW_BURST(VIP_SUPPORT_NARROW_BURST),
  .SUPPORT_UNALIGNED_ACCESS(VIP_SUPPORT_UNALIGNED_ACCESS),
  .SUPPORT_BYTE_STROBE(VIP_SUPPORT_BYTE_STROBE),
  .ENABLE_COVERAGE(VIP_ENABLE_COVERAGE),
  .ENABLE_TRANSACTION_COVERAGE(VIP_ENABLE_TRANSACTION_COVERAGE),
  .ENABLE_PROTOCOL_COVERAGE(VIP_ENABLE_PROTOCOL_COVERAGE),
  .ENABLE_ERROR_COVERAGE(VIP_ENABLE_ERROR_COVERAGE)
) protocol_mon(axi_vif);
```

示例须 import `axi4_vip_cfg_pkg::*` 和 `axi4_vip_adapter_pkg::*`。所有维度须匹配实际 interface，否则启动 fatal。逻辑宽0的 QoS/REGION/USER 占位信号不参与 X 或稳定性检查；非零侧带全位宽参与。ADDR 支持12..63、DATA为8..1024的2次幂、ID1..16、LEN1..8。`MAX_TRACKED=4096` 是监视器资源保护；超出它无论检查开关如何都 fatal，不是设计在途限制。

不要直接将旧 workbook 的 `support.fixed_burst=true` 映射为已实现能力。本 monitor 的 `SUPPORT_FIXED_BURST/WRAPPING_BURST/EXCLUSIVE_ACCESS/LOCKED_ACCESS` 默认0，显式置1会启动 fatal；旧 default 的 fixed=true 只是旧配置声明，集成应保持这些 capability 参数0并说明范围。总限额使用 `AXI_MAX_OUTSTANDING_TOTAL`，不能用旧 `AXI_OUTSTANDING` 代替。

## 检查、能力和流量策略

能力/流量策略与 checker enable 是独立控制面。关闭一个检查只抑制该类计数和诊断，仍按握手记账；不会令 driver 产生原本不支持的访问，也不会关闭资源保护。

| 控制 | 实际作用 |
|---|---|
| `ENABLE_PROTOCOL_CHECKS` | 五通道背压下 VALID/payload 稳定；AxSIZE 不超总线；reserved BURST；INCR 4KB；WLAST/RLAST 对照地址拍数；显式结束检查 |
| `ENABLE_X_CHECKS` | 复位和五通道 VALID/READY 的 X/Z；VALID payload 的 X/Z；WDATA仅WSTRB=1字节、RDATA仅当前请求有效字节 |
| `ENABLE_ALIGNMENT_CHECKS` | 仅当 `REQUIRE_ALIGNED_ACCESS=1` 时检查自然对齐；默认0，无凭空的全局对齐限制 |
| `ENABLE_STROBE_CHECKS` | 每拍 WSTRB 是该拍合法 lane 的子集；零strobe合法；非对齐首拍从起始地址到传输对齐块末尾，其余INCR按SIZE递增 |
| `ENABLE_RESPONSE_CHECKS` | B/R VALID 时检查ID存在和响应依赖；B不能早于完整W，R须有先前AR；非OKAY响应按“成功响应策略”报错 |
| `ENABLE_TIMEOUT_CHECKS` | READY等待及未配对W等AW预算；同RID队首R进展预算；AW/W完成且同BID队首B预算；相应cycles=0单独禁用 |
| `ENFORCE_TRAFFIC_POLICY` | 控制policy_errors：支持/允许流量、最大拍数、读/写/总在途限额；独立于protocol enable |
| `SUPPORT_INCREMENTING_BURST/NARROW_BURST/UNALIGNED_ACCESS/BYTE_STROBE` | 能力门控；违反声明能力报告policy错误。byte_strobe=false要求实际WSTRB等于合法lane mask |
| `ALLOW_NARROW_BURST/ALLOW_NARROW_SINGLE/ALLOW_UNALIGNED_ACCESS` | 即便decoder支持，也可禁止相应流量；默认允许，须按具体测试策略设置 |

`narrow_burst` 仅指 SIZE小于总线且拍数>1；窄单拍由独立 `ALLOW_NARROW_SINGLE` 控制。需求 `align none` 不产生额外对齐承诺；真正不支持非对齐的 driver profile 应设置能力/流量策略，不能冒称 AXI 协议本身禁止非对齐。

地址合法性在 VALID 出现时检查，不等待READY；strobe/LAST在AW已知时也检查 stalled W。W可以早于AW，因此未知地址的W样本先缓冲，在AW到达后按全局AW顺序匹配。所有响应先对本拍之前的状态检查，再入队本拍请求握手，禁止首次AR/R或末拍W/B同拍伪匹配。B/R即便被READY背压也接受检查。R按每个ID的队首推进，允许不同ID逐拍交织；B允许不同ID乱序。未知响应不会凭空完成其他ID。

AXI允许SLVERR/DECERR，它们在这里属于响应成功策略失败而非AXI传输语法非法。禁用response检查后仍覆盖这些错误响应、推进合法ID事务。普通访问的EXOKAY同样通过response类报错（本实现不接受exclusive）。READY和响应进展超时均为测试预算，不是AXI协议规定的时间上限。READ预算只给同RID最早未完成读请求计时；WRITE预算只给AW与全部W已握手且是同BID队首的请求计时。成为可服务队首当沿设baseline，等待同ID前序及全局W FIFO的时间不占其响应预算；R握手刷新该队首计时。W传输背压使用READY预算。已接受但尚未配到AW的W也使用READY预算，不混用WRITE响应预算。没有WVALID的任意master等待不额外套用WRITE预算，结束检查可捕获未完成事务。达到预算每个停滞episode只报一次；有效进展重新计时。调用方必须给预算留出自己施加背压的时间。

## 观测、结束和覆盖

`protocol_errors/x_errors/alignment_errors/strobe_errors/response_errors/timeout_errors/policy_errors` 以及 `error_count()` 可由top验收。默认`REPORT_ERRORS=1`用`$error`输出；`FATAL_ON_ERROR=1`立即终止。测试负例用`REPORT_ERRORS=0`并检查准确类别及禁用关系，另有真实fatal smoke证明诊断路径。持续非法VALID或超限状态可能按采样周期多次计数，不把该数值解释为违规事务数。

`aw_count/ar_count/w_count/b_count/r_count` 为已采样握手计数（X控制/ID的非法请求不会进入可关联队列）。`current_reads/current_writes` 按AR/AW握手入队，读在声明的ARLEN拍数消耗完成、写在B握手出队。错误LAST后仍按声明长度恢复；这是负测试的确定性恢复规则，不能把已报错总线当作健康流量。`max_reads_seen/max_writes_seen/max_total_seen`为历史峰值。reset清空在途/等待，不清累计错误/覆盖/峰值；`check_quiescent()` 是无时序 function，也可由 `final` 块调用。正常结束时调用：

```systemverilog
// 在最后一个总线采样沿之后调用，避免active-region竞态。
@(negedge axi_vif.aclk);
protocol_mon.check_quiescent();
if (protocol_mon.error_count()!=0) $fatal(1,"protocol checker errors");
```

三个covergroup按global与各group的enable共同门控。总线事务/背压/响应覆盖不受checker报错enable影响；诊断类别覆盖仅记录实际启用的检查：

- transaction：读写方向、DATA256、1/2/4/16及其它拍数、ID和方向×长度。
- protocol：五通道背压、读/写/总深度0/1/中间/127/128/超限、通道×背压。
- error：诊断类别和总线OKAY/EXOKAY/SLVERR/DECERR。

无需解析vendor覆盖数据库即可检查的累计量：`transaction_samples/protocol_samples/error_samples`，`length_hits[beats]`，`id_hits[id]`，`stall_cycles[AW,W,B,AR,R]`，`response_hits[resp]`，`depth_hits[0..3]`分别为总深度0/1/127/128。covergroup在关闭时不sample，counter也不增加。`check_quiescent`是主动结束检查，不在simulation final自动触发，以免复位中止/负向用例被错误归为失败。

## 已知边界

纯被动AXI总线没有额外序号，无法证明同ID、同长度的两个payload互换，也无法识别两个同ID相同BRESP的B响应交换；需要参考模型/数据签名。当前“同ID顺序”指严格按该ID队首长度/完成条件解释响应，不能声称完整证明payload归属。monitor不检查存储内容、目标地址map、NoC路由或24GB/s业务要求。

上升沿读取pre-NBA总线；driver应在negedge或clocking/NBA驱动，不能在posedge active region竞态改pin。整个DATA信号需在背压期间保持稳定，未使用lane只豁免X检查；不存在“unused lane可任意背压变化”的扩展承诺。

## 运行与依据

```sh
bash tests/checker/run_checker_vcs.sh
```

runner加载Makefile同款VCS模块，每次mktemp新目录，编译/仿真各有限时；不调用make、不生成配置、不改工作簿，退出时验证SHA不变。可用`CHECKER_SCRATCH_PARENT`指定输出父目录。服务器默认csh，请显式`bash`调用。

实现规则依据：[Arm IHI0022H](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf) A3/A5/A6，以及[Arm AXI协议断言指南DUI0534B](https://documentation-service.arm.com/static/5f106bd90daa596235e808ed)的VALID稳定、WDATA/RDATA_X、WSTRB、LAST和响应依赖规则。

## 实际验证记录（2026-09-16）

服务器 VCS S-2021.09-SP2，源码scratch `/tmp/axi05_checker_20260916_5hyv3z`；最终独立运行日志 `/tmp/axi4_checker.t440BqdV`：

- `CHECKER_REGRESSION_PASS scenarios=62 assertions=3341`。合法压力流量零错误；故意违规按类别触发，各组关闭时该组计数为0且其它组不变。
- `CHECKER_REPORT_SMOKE_PASS`：无在途BID触发真实AXI_RESPONSE fatal。
- `CHECKER_CAPABILITY_SMOKE_PASS`：请求实现未支持的FIXED能力，启动时明确fatal。
- 三个编译均无warning/error；负向fatal是预期诊断。VCS默认fatal也可能返回0，因此runner检查确切诊断和缺失错误哨兵，不凭退出码宣称成功。
- protected workbook SHA-256前后均为`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`。

逐场景摘要见 `validation_20260916.txt`。最新超时语义修正后，独立62+6场景/3368断言与2个fatal smoke全部通过，见`timeout_validation_20260916.txt`。功能03驱动的5组联合验证及6组burst/开关联合验证已完成，见`joint_validation_20260916.json`及`tests/checker/OUTSTANDING_INTEGRATION.md`。短预算误报的两次实际复现和保持原预算的修复后计数均已保存。
