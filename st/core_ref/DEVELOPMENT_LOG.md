# Bach Core Reference Development Log

## 2026-09-16 — Pre-Sim integration and no-JSON compatibility

### Changed

- Connected `scene_generator/generate.py` to verify_tools case-list execution and published per-scene programs, task metadata, stimulus and reference logs.
- Added a single-task fallback when `TASK_INFO_PATH` is absent, with explicit plusarg overrides for DSA type, PC and task metadata.
- Kept JSON mandatory for multi-task and multi-Core execution so topology is never guessed.

### Verification

The fallback executed the generated scene_101 VU program through `TASK DONE` and `REFERENCE EXECUTION PASS` with zero UVM errors/fatals. The JSON-driven multi-task flow remains the formal path.

## 2026-09-09 — Functional identity and verify_tools runtime

### Changed

- Replaced numeric/global core logs with eager per-identity execution/request logs.
- Governed ref_sim through `case_lst`, `env_cfg`, `verify_tools/script/single`, and `sim_single/`.
- Renamed `reference_generation_test` to `reference_execution_test`.
- Classified `vc_hdrs.h` as a cleanable VCS DPI artifact.

### Reason

Expose stable functional identity and reuse repository runtime conventions while separating maintained inputs from generated results.

### Verification

Single VU/MU/DTE, Three-Core, multi-image and external VU cases compiled and ran with zero UVM errors/fatals. Configured logs existed without cross-identity pollution; RV-only req logs were empty.

### Remaining

Architectural MU/DTE TCM bases and DSA-specific instruction models remain pending.

## 2026-09-09 — Task-array Reference Execution

### Changed

- Made `reference_execution_test` reuse `test.sv` core construction, global address ownership, task dispatch and program execution instead of maintaining a single-VU copy.
- Added `TASK_INFO_PATH` Task[] input and repeated `MEM_INIT<n>` VMEM[] input.
- Added empty/duplicate task validation, task-id ordering, identity-derived one/three-core construction and sequential task execution without memory reload/reset.
- Preserved both VMEM conventions explicitly: byte-addressed framework fixture and word-addressed inst_generator/reference input.
- Added cases for Single-Core Single-Task, Single-Core Multi-Task and Multi-Core Multi-Task.

### Reason

The existing Multi-Core mechanisms were already implemented and self-tested. The missing piece was a formal upper input contract that can express multiple tasks without encoding task data into one set of plusargs.

### Verification

- `reference_single_core_single_task`: one VU task, PASS, zero UVM errors/fatals.
- `reference_single_core_multi_task`: two input tasks supplied out of order; execution logs show task 1 then task 2 on the same VU core, PASS, zero errors/fatals.
- `reference_multi_core_multi_task`: four input tasks supplied out of order; execution order is VU task 1, MU task 2, DTE task 3, VU task 4, PASS, zero errors/fatals.

### Remaining

- Keep negative duplicate-task coverage outside the normal passing case list unless regression policy changes.
- Add a maintained negative case for duplicate `task_id` if regression policy requires negative tests in the normal case list.
