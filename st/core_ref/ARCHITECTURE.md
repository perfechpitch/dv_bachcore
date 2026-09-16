# Bach Core Reference Architecture

## Scope and Navigation

This file is the Reference code-navigation source of truth. Usage is in `README.md`; semantic history is in `DEVELOPMENT_LOG.md`.

- Core: `uvm_tb/core_ref/core_ref.sv`, `core_reference`.
- Config/task types: `core_ref_config.sv`, `core_ref_define.svh`, `task_info_s`.
- Instructions: `uvm_tb/inst_lib/inst_library.sv`, `inst_queue_gen()`, `do_inst()`, and `inst_set/`.
- DSA MMIO/request trace: `uvm_tb/dsa_mmio_lib/dsa_mmio_library.sv`, `dsa_mmio_library`.
- Memory: `uvm_tb/mem_lib/mem_library.sv`, `mem_library`.
- Self-test/execution: `ref_sim/test.sv::test`, `ref_sim/reference_execution_test.sv::reference_execution_test`.
- Runtime: `ref_sim/case_lst/case.lst`, `env_cfg/*.cfg`, repository `verify_tools/script/single`, generated `sim_single/`.

## Shared and Private State

Three-Core construction is owned by `test::build_phase()`. SM, atomic memory and `dsa_mem_library` handles are shared. ITCM, DTCM, GPR/core state, CSR and each identity's `dsa_mmio_library` remain private. `core_reference::build_phase()` fixes VU/MU/DTE identity; `set_task_info()` applies PC/CSR context.

## Reused Execution Mechanism

`reference_execution_test extends test` and directly reuses:

- `configured_dsa_type()` — virtual identity selection;
- `find_core()` / `dispatch_task()` — task-to-core routing and `set_task_info()`;
- `tcm_owner()` — global-address owner;
- `load_mem_file()` / `init_ref_memory()` — VMEM[] initial state;
- `execute_program()` — retire/execute loop;
- `build_phase()` / `reset_phase()` — core/shared/private construction and logger setup.

`test::vmem_uses_word_address()` is virtual. Framework fixtures keep their existing byte-address `@` convention; `reference_execution_test` overrides it to word-address because inst_generator writes `@ = byte_address >> 2`.

`check_topology_and_dispatch()`, hard-coded tasks/program injection and topology/result assertions remain self-test-specific and are not invoked by formal Reference Execution.

## Formal Reference Execution

`reference_execution_test::parse_task_info()` normally reads `TASK_INFO_PATH`, maps `execute_unit` to the existing DSA enum, rejects empty Task[] and duplicate task IDs, sorts by `task_id`, and derives one-core versus fixed three-core construction. Without `TASK_INFO_PATH`, it creates one explicitly bounded compatibility task (VU and ITCM-base PC by default, with optional plusarg overrides); it never infers a multi-task topology. `main_phase()` loads all `MEM_INIT<n>` files once, then dispatches and executes every task in order. Task switch does not reset or reload state.

```text
VMEM[] --word address--> global decode --> address owner --> memory state
Task[] --> validate unique task_id --> sort --> dsa_type dispatch
       --> set_task_info --> execute_program --> next task
```

Current cases cover one-core/one-task, one-core/multi-task, and three-core/multi-task. In the last case the VU core executes two tasks, proving that multi-core and same-core task switching coexist.

## Logger Ownership

`core_reference::open_log()` owns the identity execution log; `dsa_mmio_library::open_req_log()` eagerly creates exactly one corresponding request log. Shared DSA memory has its own `shared_dsa_mem.log`. All are under `sim_single/log/`.

## Remaining TODO

- Confirm architectural MU/DTE TCM bases (`TODO(memory-map-confirm)`).
- Confirm/implement MU/DTE DSA-specific instructions beyond common MMIO operations.
