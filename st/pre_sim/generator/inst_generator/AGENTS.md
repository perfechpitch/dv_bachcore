# Project Context Router

## Project Overview

This directory contains the BachCore UVM-based static RISC-V instruction-stream generator. Its current default profile is RV32 with I/M/A/C plus custom instructions; legacy RV64, floating-point, privilege, and address-translation code remains present.

Unless a path is repository-rooted, paths in the context documents are relative to this `inst_generator` directory.

## Architecture Overview

```text
testcase + plusargs
        -> scenario registry -> scenario task plan
        -> scenario_base_vsequence
        -> sequence-type selector / instruction sequence
        -> inst_generator -> instruction object queue
        -> per-core .S/.vmem + task/config logs
```

Random and directed scenarios share the same executor. A scenario owns task IDs, cores, start PCs, and either directed contents or random sequence-category plans.

## Context Routing

| Task type | Read first |
|---|---|
| Overall architecture or responsibility change | `docs/context/architecture.md` |
| Random selection, encoding, constraints, queue, LS or branch generation | `docs/context/instruction_generator.md` |
| Directed instruction/scenario API | `docs/context/directed_generation.md` |
| Scenario, task, per-core stream, start PC | `docs/context/scenario_task.md` |
| RVC instruction, 16/32-bit PC, compressed LS or branch | `docs/context/compressed_instruction.md` |
| Package/include/filelist/test compile failure | `docs/context/build_dependency.md` |

Do **not** read all context documents for every task. Read multiple documents only for a demonstrated cross-module dependency.

## Future Task Workflow

1. Read this file.
2. Classify the task and read only the routed context document.
3. Follow that document's `Recommended Read Scope`.
4. Inspect only directly related source files.
5. Preserve the dirty worktree; check status/diff before editing.
6. Modify only necessary files.
7. Run a targeted compile/test, not a full regression by default.
8. Update context only when stable architecture, interfaces, dependencies, support status, or limitations changed.

## Read and Search Rules

- Do not scan the entire repository by default.
- Search only inside the recommended scope for a named class/function/symbol.
- Prefer recorded stable knowledge over re-deriving the architecture.
- The server may not have `rg`; use `find` and `grep` when needed.
- Do not expand scope merely because a file might be related.

Before reading outside the recommended scope, state:

```text
Read Scope Expansion
File: <path>
Reason: <why it is needed>
Dependency: <direct dependency on the task>
```

## Validation Rules

- Prefer affected-package compilation and one targeted `single` case.
- Use `rsim/case_lst/random.lst` for random scenarios and `directed.lst` for directed scenarios.
- Do not guess a test command; consult `docs/context/build_dependency.md`.
- Run a full compile/regression only when explicitly requested or the change is genuinely global.

## Context Maintenance

Update only the relevant context document when stable knowledge changes. Do not record local variable edits, formatting, transient debugging, or small implementation details. Keep context concise enough that a normal task needs this file, one context document, and roughly 2–5 source files.
