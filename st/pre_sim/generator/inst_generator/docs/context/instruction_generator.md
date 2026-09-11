# Random Instruction Generator

## Responsibility

Document instruction object creation, queue filtering, selection, operand constraints, encoding, LS/branch generation, and public generation APIs.

## Current Architecture

```text
inst_gen_case_config
  -> inst_gen_config (XLEN, enabled ISA sets)
  -> inst_seq_type_config (SAFE/LS/BRANCH/... weights)
  -> per-sequence configs

inst_generator::inst_queue_gen
  -> creation macros -> instruction objects -> inst_gen_queue

scenario random task
  -> AUTO global weights or PLAN scenario-local allowed set and weights
  -> inst_seq_generator::rand_seq
  -> concrete sequence
  -> inst_generator::get_rand_inst / get_specified_*
  -> name generator -> instruction object -> operand randomization/encoding
  -> inst_print -> PC/history/.S/.vmem
```

## Key Files

- `uvm_tb/inst_gen/inst_generator.sv` — public APIs, queue, dispatch, PC/output.
- `uvm_tb/inst_gen/inst_gen_define.svh` — creation and directed helper macros.
- `uvm_tb/inst_gen/inst_gen_config.sv` — XLEN and enabled instruction sets.
- `uvm_tb/inst_gen/inst_name_generator.sv` — category/name constraints and weights.
- `uvm_tb/inst_gen/inst_group/base_inst.sv` — common random/specified encode path.
- `uvm_tb/inst_seq_type_gen/item/inst_seq_type_item.sv` — category distribution.
- `uvm_tb/inst_seq_gen/inst_seq_generator.sv` — category-to-sequence dispatch.

## Key Classes / Packages

- `inst_generator`: owns `inst_gen_queue`, category-specific name generators, current instruction and output state.
- `base_inst`: combines constant opcode mask/value with generated operand bits.
- `ops_gen_config`: operand equality, immediate, alignment and LS random knobs.
- `inst_seq_type_generator`: randomizes the next sequence category.
- `safe_inst_generator`, `ls_inst_generator`, `branch_inst_generator`: choose instruction names under category constraints.

## Important Interfaces

- `inst_queue_gen()`: creates enabled objects once in `pre_main_phase`.
- `get_rand_inst(inst_type_e)`: random category-name selection and encoding.
- `get_specified_rand_inst(inst_e)`: fixed name, randomized operands.
- `get_specified_inst(inst_e, rs1, rs2, rd, imm)`: fixed name and fields; packing depends on `inst_format`.
- `get_rand_ls_with_imm`, `get_rand_branch_inst`: sequence-controlled immediate paths.
- `inst_print()`: derives length from `inst[1:0]`, writes output, tracks boundary, advances PC.

## Instruction Queue and Capability Filtering

`inst_gen_define.svh` splits I/M/A into common and RV64-only creation groups. `inst_queue_gen()` checks generic RVI/RVM/RVA capability and selects RV32 or RV64 macro by `xlen`. RVC similarly selects RV32C/RV64C. F/D, privilege, CSR, prefetch/CBO, and custom instructions have independent gates.

Default `SUPPORT_INST_SET` is `{RVI, RVM, RVA, RVC, CUSTOM}` and `inst_gen_config.xlen` defaults to 32. `+xlen=32|64` is consumed by `inst_gen_case_config::config_convert`; any other value is fatal.

Each creation macro invokes `INST_GEN_CREATE`, which creates an object, appends it to the queue, records its `inst_e` in `support_inst_name`, and binds output/register/address helpers. Name constraints ultimately require membership in `support_inst_name`.

## Constraint and Randomization Flow

1. `rand_inst_test` creates `inst_gen_case_config` and calls `random_sub_config`.
2. Config objects randomize weights and subordinate settings. `inst_gen_case_config.seq_num` is randomized in `1..100`; a later `+seq_num=<N>` overrides it. A random scenario task whose `seq_num` is omitted uses this value.
3. Scenario AUTO and PLAN both use `inst_seq_type_generator`. For PLAN, `inst_gen_case_config` converts explicit `WEIGHT_DISABLE/LOW/MEDIUM/HIGH` overrides to `0/1/4/10`, restores platform-randomized defaults per task, and changes only listed `inst_seq_type_cfg` weights before `seq_num` selections. Unlisted top-level and direct-child selectors retain their defaults. Optional direct-child plans similarly override SAFE instruction-group, LS RAND/LINEAR/MEMCPY, or BRANCH SINGLE/LOOP/JALR weights.
4. Concrete sequences determine instruction counts/shape.
5. Name generators randomize an `inst_e` within enabled categories.
6. Instruction objects randomize `ops_gen_config` and obtain registers/immediates.
7. Constant mask/value and operands form the final 32-bit container; compressed encodings use its low 16 bits.

`C_INST_SEQ` keeps the platform-randomized default `c_seq_dist`; if that default is zero, a scenario can explicitly assign a nonzero preference when RVC is supported.

## LS Generation

`ls_inst_sequence` initializes or changes bases through `ls_base_config_sequence`, then dispatches LS sub-sequences. `ls_addr_generator` selects a DTCM/share window, produces legal effective addresses, splits base+imm, binds base metadata, and later constrains immediates to window/alignment intersections. AMO uses a zero immediate/effective-address base. Compressed word and SP-relative forms have dedicated immediate helpers.

## Branch Generation

Branch sequences measure actual byte PCs. `single_branch_sequence` records target PC before generating the target block and computes `target - current PC`. `loop_sequence` records each loop target and measures the final delta; BLT/custom LOOP selection is weighted. `jalr_sequence` selects a real boundary from `inst_pc_history`; C.JR/C.JALR first initialize the target register.

## Dependencies

Instruction classes depend on `cpu_set_pkg`, generator enums/macros, `register_pool`, and address helpers. Sequences depend on `inst_gen_pkg`; the environment connects their shared config/state. C-specific paths are detailed in `compressed_instruction.md`.

## Current Status

- RV32/RV64 I/M/A queue filtering is implemented.
- LR/SC are absent from current A creation groups; AMO.W and AMO.D groups remain.
- DSA custom instructions randomize in `SAFE_CUSTOM_DSA`; LOOP is selected only in loop context; TASK_DONE is emitted as task termination.
- Random SAFE/LS/BRANCH/C scenario cases exist for MU.
- Random tasks may configure the direct child selector of SAFE, LS and BRANCH with `set_task_subseq_weight`; defaults are restored at every task boundary and for directed execution, and only explicitly listed children are overridden.

## Single-Instruction Macro API

`uvm_tb/inst_gen/inst_gen_define.svh` exposes shorthand macros for directed
single-instruction generation. Existing integer macros accept explicit
operands. The compressed macros (`c_addi`, `c_lw`, `c_j`, and the other
implemented `c_*` names) select the exact C instruction class but deliberately
leave operands to that class's legal randomization; this preserves compressed
register-subset, SP-state, LS-address and control-flow constraints.

Custom instruction signatures are `dsar(rd, rs1)`, `dsari(rd, imm16)`,
`dsaw(rs1, rs2)`, `dsawi(rs1, imm16)`, `task_done(notify_ts)`, and
`loop(rs1, rs2, byte_offset)`. The LOOP macro accepts a byte offset and applies
the same halfword conversion used by the existing B-type helpers.

## Known Limitations

- Some comments and enum names retain RV64-era terminology.
- `fetch_space_avail()` reserves a fixed 4-byte terminator and uses legacy comments; instruction emission itself is mixed-width.
- Failed queue lookup prints an error string rather than consistently using a UVM fatal.
- No generator-local coverage feedback was found.
- F/D and privilege/MMU paths remain legacy and were not behaviorally revalidated during this context initialization.

## Recommended Read Scope

### Modify normal instruction encoding

Read:

1. Relevant file under `uvm_tb/inst_gen/inst_group/`
2. `uvm_tb/inst_gen/inst_gen_e.sv`
3. `uvm_tb/inst_gen/inst_gen_define.svh`
4. `base_inst.sv` only if common mask/operand behavior changes

### Modify normal instruction constraint or random category

Read:

1. Relevant instruction class
2. `uvm_tb/inst_gen/inst_name_generator.sv`
3. Relevant sequence config/sequence

### Modify queue/capability filtering

Read:

1. `inst_gen_config.sv`
2. `inst_gen_define.svh`
3. `inst_generator.sv` (`inst_queue_gen` only)
4. `bench/define/cpu_set_pkg.sv`

### Modify LS generation

Read:

1. Relevant load/store/AMO instruction class
2. `inst_seq_gen/seq/ls_seq/ls_inst_seq.sv` and affected sub-sequence
3. `inst_gen/ls_addr_generator.sv`
4. `inst_seq_gen/ls_seq_config.sv` only for knobs

### Modify branch generation

Read:

1. Affected file under `inst_seq_gen/seq/branch_seq/`
2. `inst_gen/inst_name_generator.sv` branch class
3. Relevant branch/jump instruction class
4. `branch_seq_config.sv` only for knobs

## Do Not Read By Default

For encoding/constraint work, do not read scenario registries, full environment, unrelated LS/branch code, MMU/PMP/PMA internals, or all instruction groups. For LS work, do not read branch logic; for branch work, do not read LS logic.

## Expansion Conditions

- Read scenario code only if scenario-to-sequence selection changes.
- Read environment only if object wiring/config ownership changes.
- Read compressed context/files only for shared mixed-width behavior.
- Read build files only after a package/include dependency changes or compile failure points there.

## Last Verified

Repository state: commit `4723233`, dirty working tree, analyzed 2026-09-10.

Verified areas: queue creation/filtering, AUTO and scenario-local weighted PLAN selection, operand/encode API, LS address flow, branch target flow, mixed-width output.

Needs re-verification if ISA macros, instruction APIs, sequence categories, address helpers, or PC output change.
