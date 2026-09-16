# Bach Core Reference 使用说明

`core_ref/ref_sim` 使用仓库 `verify_tools` 完成编译和运行。正式 Pre-Sim 流程由 `st/pre_sim/generator/scene_generator/generate.py` 临时构造 case list、暂存 VMEM，并将 Core Ref 日志发布到对应场景的 `ref_log/`。

## 运行

推荐从 Pre-Sim 入口执行一个场景：

```sh
python3 st/pre_sim/generator/scene_generator/generate.py \
  --scene <scene_name> --mode full
```

只生成程序时使用 `--mode inst-gen`；仅校验并更新 `directed.lst` 使用 `--mode sync`。需要独立调试 Core Ref 时，可自行提供包含 `reference_execution_test` 的临时 case list，再调用 `verify_tools/script/regression cmd=single`。`ref_sim/clean` 清理 `sim_single/` 和 generated flist。

## Core identity

- VU Core = RV + optional VU DSA
- MU Core = RV + optional MU DSA
- DTE Core = RV + optional DTE DSA

Identity 由 `core_ref_config::dsa_type` 固定。每个 core 都能执行 RV instructions；`core_reference::set_task_info()` 设置该 task 的 PC 和 metadata CSR，并拒绝与 core identity 不匹配的 task。

## 正式 Reference Execution 输入

`reference_execution_test` 统一接收：

- `MEM_INIT0`, `MEM_INIT1`, ...：一个或多个 inst_generator 格式 VMEM，`@` 值是 32-bit word address；
- `TASK_INFO_PATH`：可选的 pre_sim `task_info.json` 格式 Task[]。

未提供 `TASK_INFO_PATH` 时进入兼容模式：只构造一个 VU task，默认 PC 为 VU ITCM base，各 ID 为 0；可用 `CORE_DSA_TYPE`、`TASK_START_PC`、`TASK_ID`、`STREAM_ID`、`UID`、`PID`、`VCID` 覆盖。该模式不推断多任务或多 Core 关系。

每个 task 使用现有字段：`task_id`、`execute_unit`、`start_pc`、`stream_id`、`uid/user_id`、`pid/path_id`、`vcid/vc_id`。`execute_unit=vu|mu|dte` 映射到现有 `dsa_mmio_type_e`。

执行规则：

1. 所有 VMEM 在 execution 开始前加载一次，共同组成 initial memory state；
2. VMEM file 没有 core identity，global address 决定 address owner 和目标 private TCM/shared memory；
3. Task[] 不得为空，`task_id` 必须唯一；
4. Reference 按 `task_id` 从小到大执行；
5. 全部 task 的 `dsa_type` 相同时构造对应的一个 identity core；出现多个 identity 时构造固定 VU/MU/DTE 三个 core；
6. 每个 task 通过 `dispatch_task()` 和 `set_task_info()`，从自己的 `start_pc` 执行；
7. task switch 不 reload VMEM、不 reset memory/core state；同一 core 的 task program 地址不得重叠。

三个维护型 demo 位于 `st/pre_sim/input/pre_sim_test/`，分别覆盖单 Core 单 Task、单 Core 多 Task和多 Core 多 Task。程序、`task_info.json` 与日志属于生成结果，发布到 `st/pre_sim/output/scene_NNN/`，不作为 Core Ref 固定 fixture 维护。

## 日志与 generated output

所有输出位于 `ref_sim/sim_single/`。`compile.log`/`sim.log` 是 build/test result；Reference 日志在 `sim_single/log/`：

| Core | Execution | Request |
| --- | --- | --- |
| VU | `vu_core_ref.log` | `vu_req.log` |
| MU | `mu_core_ref.log` | `mu_req.log` |
| DTE | `dte_core_ref.log` | `dte_req.log` |

Configured core 在 reset 时固定创建自己的日志；RV-only req log 为空但存在。没有全局 `core_ref.log` 或 numeric core log。`shared_dsa_mem.log` 属于共享 DSA memory model。`vc_hdrs.h` 是 VCS DPI generated artifact，不是 source。

## 当前 Pending

- 确认 MU/DTE 的最终 TCM 地址映射。
- 补齐 MU/DTE 超出通用 MMIO 操作的 DSA-specific instruction model。
- `task_info.json` 缺失兼容模式仅支持显式单任务；多任务或多 Core 必须提供 JSON。
