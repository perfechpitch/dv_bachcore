# Directed Generation

## Responsibility

Describe how a scenario author fixes an instruction name and fields, registers directed scenarios, and reuses random generation where desired.

## Current Architecture

Directed generation is scenario based. A class derived from `scenario_base_seq` declares tasks in `configure_tasks()` and emits task-specific instructions in `generate_task()`. The common scenario executor performs core/task switching and output handling.

```text
+directed_seq_name=<name>
 -> directed_scenario_registry
 -> scenario_base_seq subclass
 -> configure_tasks
 -> generate_task(task_info, inst_gen, inst_seq_gen, inst_seq_type_gen)
 -> individual instruction API and/or reusable random sequence
```

## Key Files

- `uvm_tb/scenario_seq/scenario_base_seq.sv` — directed task/content callback API.
- `uvm_tb/registry/directed_scenario_registry.sv` — name-to-factory registry and macro.
- `scenario/directed/directed_scenario_list.svh` — directed scenario includes.
- `scenario/directed/workload/multicore_directed_scenario_seq.sv` — current working example.
- `uvm_tb/inst_gen/inst_generator.sv` — directed instruction entry points.
- `uvm_tb/inst_gen/inst_gen_define.svh` — format helper macros.

## Key Classes / Packages

- `scenario_base_seq`: API presented to scenario authors.
- `scenario_task_info`: task identity, core, start PC and kind passed to content generation.
- `directed_scenario_registry`: creates a registered scenario by string name.
- `base_inst` and derived instruction classes: encode fixed/random operands.

## Important Interfaces

- `add_directed_task(task_id, rv_core, start_pc)`.
- Override `generate_task(...)`; branch on `task_info.task_id` when one core has different task programs.
- `get_specified_rand_inst(inst_name)`: choose name, randomize its legal operands.
- `get_specified_inst(inst_name, rs1, rs2, rd, imm)`: specify operands; format-aware packing happens in `inst_generator`.
- Direct use of `inst_seq_gen.<sequence>.seq_gen()` is supported by current signatures but couples the scenario to that sequence object.
- Register using ``DIRECTED_SCENARIO_REGISTER(TYPE, "name")`` and include from the directed list.

## Directed/Random Reuse

A directed task may mix fixed-name/random-operands calls, fully specified calls, and existing random sequences. The `multicore_directed` example demonstrates compressed and custom instruction APIs. Random sequence reuse preserves the selected sequence's internal constraints and weights.

## Encoding Variables

The public specified API always accepts `rs1`, `rs2`, `rd`, and `imm`; `inst_format` decides packing. `base_inst::get_specified_inst` merges packed operands under each class's constant mask/value. Instruction-specific overrides exist for compressed and some other formats, so confirm the target class before assuming generic packing.

## Dependencies

Directed scenario files compile inside `directed_registry_pkg`, which imports scenario, instruction, and sequence packages. They must be included after the registry class/macro definition. Execution still depends on `scenario_base_vsequence` and the standard environment.

## Current Status

- Implemented: named registry selection, multi-core/multi-task planning, specified-name/random-operands API, specified operands API, random sequence reuse, per-core outputs.
- Partially implemented: a single generic operand signature covers diverse formats; usability depends on understanding per-format packing.
- Planned/Needs Confirmation: a more declarative instruction builder/API has not been found.

## Known Limitations

- Only `multicore_directed` is presently included in the directed scenario list.
- There is no automatic task address-overlap check.
- Scenario authors can reach deep sequence members, which is practical but not a stable narrow facade.
- Existing `scenario/README.md` describes removed vsequence classes and should not be trusted for current call hierarchy.

## Recommended Read Scope

### Add a directed scenario using existing instructions

Read:

1. `uvm_tb/scenario_seq/scenario_base_seq.sv`
2. `scenario/directed/workload/multicore_directed_scenario_seq.sv`
3. `scenario/directed/directed_scenario_list.svh`
4. Relevant instruction class only to verify operand meaning

### Add/modify a directed instruction API

Read:

1. `uvm_tb/inst_gen/inst_generator.sv` specified APIs
2. `uvm_tb/inst_gen/inst_group/base_inst.sv`
3. Relevant instruction class
4. `inst_gen_define.svh` only if helper macros change

### Reuse a random sequence in a directed task

Read:

1. `scenario_base_seq.sv`
2. The one concrete sequence
3. `inst_seq_generator.sv` only if dispatch is needed

## Do Not Read By Default

Do not read all random scenarios, all instruction classes, address translation, package internals, or unrelated testcase classes when adding a normal directed scenario.

## Expansion Conditions

- Read scenario executor only when task/core/output mechanics change.
- Read register/address helpers only when fixed operands must represent initialized architectural state.
- Read build dependency only when adding a new include/package or compilation fails.
- Read compressed context for a directed compressed control-flow or LS instruction.

## Last Verified

Repository state: commit `4723233`, dirty working tree, analyzed 2026-09-09.

Verified areas: registry, scenario callback, fixed/random APIs, current multicore example.

Needs re-verification if scenario API, specified operand packing, registry macros, or package placement changes.
