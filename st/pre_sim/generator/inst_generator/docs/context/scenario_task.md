# Scenario and Task

## Responsibility

Document verification-intent planning, task representation, per-core state, scenario selection, and the boundary between scenario and executor.

## Current Implementation

`scenario_base_seq` is the planning/API layer. Its subclass owns task count, globally unique task IDs, core assignment, optional start PCs, directed/random kind, and—on random tasks—AUTO or a scenario-local PLAN expressed with `WEIGHT_DISABLE/LOW/MEDIUM/HIGH` preferences.

`scenario_base_vsequence` is the execution layer. It selects a scenario from one of two registries, validates/builds the plan, groups generation by core, binds a per-core register pool, switches each task's PC, invokes directed content or random sequences, and writes task metadata/output files.

```text
testcase (starts common executor)
    -> +random_scenario_name or +directed_seq_name
    -> registry creates scenario
    -> scenario.configure_tasks()
    -> validate plan
    -> for core MU/VU/DTE
         -> bind core register pool and LS context
         -> for each task belonging to core
              -> switch_task(task_id, start_pc)
              -> random: AUTO/PLAN sequence execution
                 directed: scenario.generate_task(...)
              -> TASK_DONE termination
              -> task_info.log entry
```

## Key Files

- `uvm_tb/scenario_seq/scenario_base_seq.sv` — task types and author API.
- `uvm_tb/vseq/scenario_base_vsequence.sv` — selection/execution and outputs.
- `uvm_tb/registry/{random,directed}_scenario_registry.sv` — scenario lookup.
- `scenario/random/mu/mu_random_scenario_seq.sv` — random plan example.
- `scenario/directed/workload/multicore_directed_scenario_seq.sv` — directed multi-core example.
- `uvm_tb/inst_gen/inst_generator.sv` — core stream/task PC primitives.

## Key Classes / Packages

- `scenario_task_info`: `task_id`, `rv_core`, `kind`, `use_start_pc`, `start_pc`, `seq_num`, selection mode and plan.
- `scenario_seq_plan_item`: allowed sequence category plus scenario-level preference enum.
- `scenario_base_seq`: protected plan and public planning methods.
- `scenario_base_vsequence`: common UVM executor.
- `task_info_config`: legacy non-scenario task count/log configuration; retained but not the scenario plan.

## Important Interfaces

- `configure_tasks()` — subclass defines all task layout.
- `add_directed_task(id, core, start_pc)`.
- `add_random_task(id=SCENARIO_AUTO_TASK_ID, core=HART_MU, seq_num=SCENARIO_AUTO_SEQ_NUM, use_start_pc=0, start_pc=0)` — returns the resolved task ID. Omitted IDs are randomly allocated in `0..15` and kept unique within the current plan. Omitted sequence counts are resolved by the executor from the randomized `inst_gen_case_config.seq_num`; `+seq_num` overrides that config value.
- `random_task_num()` — returns a random task count in `1..8`; `+scenario_task_num` overrides and is range-checked. All current MU random scenarios use this common helper.
- `set_task_seq_weight(id, seq_type, preference)` — overrides one category with `WEIGHT_DISABLE/LOW/MEDIUM/HIGH` and changes the random task to PLAN mode. Unlisted categories keep their platform-randomized defaults; `seq_num` remains the total number of sequence calls.
- `set_task_subseq_weight(id, seq_type, subseq_type, preference)` — configures the direct child selector of a SAFE, LS, or BRANCH category. Supported children are SAFE instruction groups, LS RAND/LINEAR/MEMCPY, and BRANCH SINGLE/LOOP/JALR. Unlisted siblings retain their platform-randomized defaults; only explicit entries override or disable a child for that task. A parent explicitly disabled by the task cannot have child overrides.
- `inst_gen_case_config::apply_scenario_seq_weights(task_info)` — restores platform defaults, maps preferences to runtime weights `0/1/4/10`, validates capability gates, and updates the shared `inst_seq_type_cfg` handle.
- `inst_gen_case_config::apply_scenario_subseq_weights(task_info)` — restores lower-level defaults, validates parent/capability relationships, and updates the shared SAFE/LS/BRANCH config handles for one task.
- `generate_task(task_info, ...)` — directed content callback.
- `build_task_plan(default_core)`, `get_task_count`, `get_task` — executor-facing API.
- `begin_core_stream`, `switch_task`, `rand_pc_in_current_task` — generator execution primitives.

## State and Address Rules

- Task ID uniqueness is global and checked.
- Explicit start PC must be 2-byte aligned.
- A random task without explicit PC begins at the current PC of its core stream.
- Address-space overlap is the scenario author's responsibility.
- A core has one register pool shared by its tasks; different cores use independent pools.
- Normal LS addresses come from `ls_addr_generator`: per-core DTCMs are physically independent while using the same numeric window, and Share Memory uses a common window. The legacy shared `addr_space_generator` remains for PMA/PMP/PTE and exception/link data; LS generator hart/base context is switched per core.
- Instruction boundaries are recorded in `inst_pc_history`; task instruction count is history-size based.

## Outputs

Each run truncates/creates `mu_test.S/.vmem`, `vu_test.S/.vmem`, and `dte_test.S/.vmem`; unused core files remain empty. `log/task_info.log` records task ID, core, start/end PC and instruction count. Legacy `test.S/test.vmem` are opened by case configuration but scenario execution redirects generator output to per-core files.

## Dependencies

Scenario API depends on instruction and sequence packages. Registries compile scenario files. The environment exposes generator components through `inst_gen_vsequencer`. Tests only configure and start `scenario_base_vsequence`.

## Current Status

- Random and directed scenario directories/registries are independent.
- Both testcase types start the same common executor.
- Random scenarios can choose AUTO or a per-task preference set. PLAN selection is executed by the normal `inst_seq_type_generator`; unlisted categories retain platform-randomized weights and only `WEIGHT_DISABLE` assigns zero runtime weight.
- Numeric sequence weights are owned and logged by `inst_gen_case_config`, not by scenario or vsequence.
- Scenario-local direct-child preferences use the same four weight levels. C, FLUSH and EXCEPT currently have no scenario-level child selector; deeper LS instruction mix and branch target/loop-opcode knobs remain platform configuration.
- Directed task execution restores default sequence weights and does not apply scenario random preferences.
- Current random examples target MU; current directed example spans MU/VU/DTE.

## Future / Planned Architecture

No separate future architecture is implemented beyond the current scenario-as-planner model. Potential future work—only if explicitly designed—includes a narrower facade for task content, overlap checking, or replacing legacy `task_info_config`.

## Known Limitations

- Cross-core task execution order is fixed by core grouping, not plan insertion order.
- `build_task_plan` silently creates one default directed task when a subclass adds none.
- No overlap/size reservation checking between configured tasks.
- Legacy `task_info_config` and single-stream outputs coexist with scenario output plumbing.
- `scenario/README.md` is stale regarding inheritance, separate vsequences, termination placement, and random list naming.

## Recommended Read Scope

### Add or modify scenario task layout

Read:

1. `uvm_tb/scenario_seq/scenario_base_seq.sv`
2. The one scenario subclass
3. Relevant scenario list only when registering a new class

### Change task/core/start-PC execution

Read:

1. `uvm_tb/vseq/scenario_base_vsequence.sv`
2. `uvm_tb/scenario_seq/scenario_base_seq.sv`
3. `uvm_tb/inst_gen/inst_generator.sv` task/core methods

### Change per-core register or LS state

Read:

1. `scenario_base_vsequence.sv` (`bind_core_register_pool` and core loop)
2. `inst_gen/register_pool.sv`
3. `inst_gen/ls_addr_generator.sv` only for LS state

## Do Not Read By Default

Do not read every instruction class, all concrete sequences, MMU/PMP/PMA logic, full build scripts, or unrelated scenarios for a task-layout change.

## Expansion Conditions

- Read a concrete sequence only when a task's sequence behavior changes.
- Read instruction generator internals only when task switching changes PC/output/history.
- Read environment/build files only when the public executor/package interface changes.
- Read address-space files only for actual cross-core/shared-memory allocation changes.

## Last Verified

Repository state: commit `4723233`, dirty working tree, analyzed 2026-09-10.

Verified areas: task plan API, scenario-local weighted PLAN selection, registry selection, random/directed execution, per-core state/output.

Needs re-verification if scenario/task types, core grouping, output ownership, or legacy task configuration changes.
