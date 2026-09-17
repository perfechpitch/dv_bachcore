# scp_bach_ctrl_m0 集成与安全运行

本工程是可运行的 AXI4 BFM、sequence 和被动 checker，不是已经接入的商业 VIP。目标配置使用 DATA256/ADDR32/ID8/LEN4、普通 INCR。实际 NoC RTL、slave 地址图和系统时钟/复位连接尚未提供；受控 slave 回归不能证明真实 NoC 端到端 24 GB/s。

## 工作簿保护和运行入口

保护文件 `docs/vip/vip_cfg.xlsx` 的当前授权 SHA-256 统一记录在 `docs/vip/workbook_baseline.json`，运行期间固定预期值并前后验证。2026-09-17 按 master 设置 DUT 并实际生成 FINAL 后为：

`2fc6354c5b2b98fbcd362c545c63c83dfc75c5b4ac1035de4554ccc1f1e3811c`

三表仍各70项，BASE参数及锁保持不变；DUT的28项明确值覆盖到FINAL，其余42项继承BASE。当前FINAL为DATA256/ADDR32/ID8/LEN4、INCR，读/写/总上限128/128/128；最大burst继承BASE=1。当前映射、未知值和Git备份见 [09配置记录](workbook_master_activation_20260917.md)。08补字段阶段保留旧值的历史证据见 [工作簿字段说明](workbook_fields_20260916.md)，其工作簿SHA `77bae6bac46a09a385d0543d0e026eb6825527280e25212c002f518466d99700` 是本次迁移前基线。普通测试不能刷新受保护基线。

新增入口不进入 `vip_cfg/seq_gen` 依赖链，不重写 BASE、DUT 或 FINAL，也不重写 sequence 工作簿。每次将源码复制到指定父目录下的唯一子目录，直接从 JSON 生成 SV/filelist，再编译、仿真。副本、有效配置和日志均保留。

默认使用当前 active VIP JSON、`docs/seq/seq_plan.json` 和 IRQ TXT，在副本中重新生成 sequence/IRQ 模板；不依赖生产目录里可能过时的VIP配置包、filelist、sequence模板或IRQ缓存。间隔策略配置 `axi4_seq_cfg_pkg.sv` 沿用生产已有文件；本次未改变它的格式或语义。原始输入文件不改，尚未同步到JSON的工作簿编辑不会被此入口自动应用。

```sh
# 仅准备副本，适合无 VCS 的本地机器。
make isolated_prepare ISOLATED_ROOT=/tmp

# 原32位单拍/IRQ示例，在副本中运行完整top和checker。
make isolated_run SEQ=axi4_user_two_regs IRQ_EN=1 ISOLATED_ROOT=/tmp

# 全部集成回归，串行运行，各suite及模拟器有时间上限。
make regression ISOLATED_ROOT=/tmp

# 完整top：原32位IRQ，以及256位混合burst/IRQ/byte lane，目标时钟1GHz。
make scp_smoke ISOLATED_ROOT=/tmp

# 6种性能流量，启用独立协议checker并逐例复算VCD。
make regression ISOLATED_ROOT=/tmp ISOLATED_ARGS='--only performance'

# 只运行某个suite；名称见 tests/integration/suites.json。
make regression ISOLATED_ROOT=/tmp ISOLATED_ARGS='--only interface'
```

专项表格迁移后可运行 `make regression ISOLATED_ROOT=/tmp ISOLATED_ARGS='--only workbook_python --only migration_python --only workbook_chain'`。`workbook_chain` 在副本A执行完整表格配置链、比对三表语义及生成JSON，再用该JSON在新副本B运行按实际位宽生成的对齐单拍序列和IRQ；当前检查完整256位读写、ID255/254及3/3/3/2/2握手计数，默认时钟仍为10ns。生产表格和生成文件不被测试改写。

服务器默认 shell 为 csh；上述命令需在 bash 中执行。Makefile 使用 VCS S-2021.09-SP2 模块。`ISOLATED_ROOT` 必须在源工程外部。`REGRESSION_RESULT` 输出机器可读记录，包含逐suite命令、日志位置、日志SHA、耗时和结果；失败不会伪装为PASS。

`scripts/run_isolated.py --profile <独立VIP JSON> --plan <独立sequence JSON> --seq <名称>` 可以选择独立目标流量。仅切换 DATA256 profile 而复用原32位示例的 `0x124/stride4` 不会自动获得合法全宽访问；应提供对齐地址/步长或显式 narrow 单拍。不要把测试内存地址当作真实 NoC 地址。

部署保留原generated目录，因此独立测试脚本若直接读取该目录，可能遇到旧配置包/filelist；部署后的测试统一通过上述 `make regression ISOLATED_ARGS='--only <suite>'` 入口准备副本后运行。

原 `make run/SEQ_ALL/seq_gen/vip_cfg` 保留既有工作簿生成行为。它们不是本次回归和部署后冒烟入口。生产 `tb/generated`、用户sequence表、TXT数据和work产物不会被部署工具覆盖；安全入口在副本中生成与新源码一致的配置。

## 完整 top 的连接

`gen_axi_vip_filelist.py` 是编译顺序的来源；接口之后编译 checker 包和 monitor。`tb_top` 通过 `checker/axi4_configured_monitor.svh` 接入所有相关 checker/coverage 配置，并在结束时检查在途是否排空、打印握手计数和峰值。零宽侧带按逻辑不存在处理。

默认时钟仍为10ns；`+AXI_CLK_PERIOD_NS=1.0` 设置1GHz。top会实际测量10个posedge间隔并打印 `AXI_CLOCK_MEASURED`，拒绝非法或不符合1ps精度/50%占空比的周期。独立目标profile开启功能覆盖，混合示例验收1/2/4/16拍计数；它仍只是测试profile，不替换生产配置。

BASE及保留的旧JSON中 `support.fixed_burst=true` 是遗留策略声明；它不会被映射成已实现的 checker FIXED 能力。09工作簿FINAL与独立目标profile均显式关闭这些能力，实际 FIXED/WRAP/exclusive 请求仍明确拒绝。checker 报错或异常提前终止即使 VCS 返回0，也不能通过运行入口验收。

`axi4_simple_mem_slave` 保留原模块参数和 DEPTH 取模地址映射，增加普通 INCR burst、ID回传、partial WSTRB、对齐 narrow 单拍、响应背压保持和reset清理。每方向最多一笔在途，不能拿它证明128深度或峰值带宽。非法burst/size/对齐/4KB/LOCK或WLAST/WSTRB给出诊断与SLVERR；按声明拍数排空，已完成的合法写拍不回滚。reset清空RAM；同址同周期读写返回写入前值。

## 需求口径及仍缺少的输入

- 最大burst beats/bytes仍为空：FINAL运行最大拍数继承BASE=1；独立profile中的16拍、512字节只是LEN4全宽编码测试上限。
- 原需求表的outstanding 128未区分方向；用户2026-09-17补充确认读/写上限各128、总上限128，DUT和FINAL据此设置，`requirements.outstanding_scope=read+write`。
- 24 GB/s未区分读、写或合计：回归分别报告实际W有效WSTRB字节、R有效payload字节及合计，以仿真时间计算十进制GB/s，并注明时钟、窗口和背压条件。
- 实际地址图、业务访问粒度、NoC RTL及连接未提供。09只更新授权工作簿及配套基准；生产active JSON、generated和用户sequence输入保留，更新工作簿不会自动把它们切为256位。

## 部署与回滚

`scripts/deploy_verified.py` 只接受显式manifest：每条包含相对路径、基线SHA（新增文件为null）和候选SHA。部署前全量检查生产是否被用户修改、候选是否与验证内容相同，以及保护工作簿SHA。任何冲突先拒绝，不覆盖用户修改。

正式部署生成时间戳备份、原文件、manifest、逐文件记录、新增文件清单及独立 `rollback.sh`。单文件原子替换；普通失败自动恢复已替换文件。回滚也会检查文件是否仍是本次候选版本，防止覆盖部署后的用户修改。逐次部署路径、验证证据和恢复命令另记在交付记录中。

备份及目录项在修改目标前经过fsync，目标替换后同步父目录；持久化保证以底层文件系统/NFS服务器承诺为边界。回滚冲突检查比较内容SHA，恢复时文件权限使用备份值。

工具自测：`python3 scripts/deploy_verified.py self-test`。它只操作临时夹具，不写生产目录。

普通部署仍拒绝工作簿、`docs/vip` 和 generated 文件。只有显式 `--allow-workbook-migration` 且manifest匹配已审阅的旧→新SHA时，才允许三条精确路径：`docs/vip/vip_cfg.xlsx`、`docs/vip/base_vip_cfg.lock.json`、`docs/vip/workbook_baseline.json`。备份带独立helper和基线上下文；09回滚先恢复08工作簿77bae6…及其基准文件，之后才可依次使用08、07各自保存的回滚工具。部署前应保存关闭写入这些文件的编辑器，哈希检查不能阻止外部编辑器事后重新保存旧版本。
