# RV32 Compressed Instructions

## Responsibility

Track RVC class/queue integration, compressed constraints, mixed-width PC/output, and the separate LS and branch paths.

## Current Architecture

RVC instruction identifiers live in `inst_gen_e.sv`; instruction classes and RV32/RV64 creation macros live in `inst_group/c_inst.sv`. `inst_queue_gen()` gates creation with RVC and XLEN. Compressed instructions use a 32-bit container whose low 16 bits are written; `inst_print()` detects length from bits `[1:0]` and advances by 2 or 4.

## Key Files

- `uvm_tb/inst_gen/inst_group/c_inst.sv` — classes, encoders, constraints, creation macros.
- `uvm_tb/inst_gen/inst_generator.sv` — queue integration, PC/history and vmem packing.
- `uvm_tb/inst_seq_gen/seq/c_inst_seq.sv` — compressed-only random sequence.
- `uvm_tb/inst_gen/register_pool.sv` — compact-register and x2/SP base handling.
- `uvm_tb/inst_gen/ls_addr_generator.sv` — compressed LS and C.ADDI16SP address state.
- `uvm_tb/inst_seq_gen/seq/branch_seq/{single_branch_seq,loop_seq,jalr_seq}.sv` — compressed control-flow integration.

## Key Classes / Packages

- `c_base_inst` and per-instruction derived classes.
- `c_inst_sequence`: explicitly selected compressed-only sequence.
- `c_lw_gen`, `c_sw_gen`, `c_lwsp_gen`, `c_swsp_gen`: compressed LS encoders.
- `c_j_gen`, `c_cb_gen`, `c_jr_base_gen`: compressed control-flow bases.
- `ls_addr_generator`, `register_pool`: legal address/register state.

## Capability Status

| Capability | Status | Evidence/notes |
|---|---|---|
| Queue creation under RVC | Implemented | RV32/RV64 macros selected by XLEN |
| C.ADDI4SPN, C.NOP, C.ADDI, C.LI, C.ADDI16SP, C.LUI | Implemented | classes/macros and queue entries |
| C.SRLI/SRAI/ANDI/SUB/XOR/OR/AND/SLLI/MV/ADD | Implemented | constrained raw encoders |
| C.LW/C.SW | Implemented | compact base register plus legal word offset |
| C.LWSP/C.SWSP | Implemented | x2 metadata plus SP word-offset helpers |
| C.J/C.BEQZ/C.BNEZ | Implemented in branch path | delta is measured in bytes from real PCs |
| C.JR/C.JALR | Implemented in indirect branch path | target register initialized with exact boundary |
| C.EBREAK | Implemented in queue/exception name selection | not in compressed-only safe sequence |
| C.JAL | RV32 only | added only by `C_RV32_ONLY_INST_CREATE` |
| Mixed 16/32-bit PC | Implemented | length detection and byte increment in `inst_print` |
| Mixed vmem packing | Implemented | halfwords merged into word-addressed records; word may be re-emitted |
| Random compressed-only scenario | Implemented | MU C scenario selects `C_INST_SEQ` explicitly |

`c_inst_sequence` deliberately contains non-control compressed instructions including C.LW/C.SW and SP forms, but excludes C.J/C.B*, C.JR/C.JALR and C.EBREAK. Those use branch/exception paths because they need target/control semantics.

## Compressed Registers and Addressing

C.LW/C.SW require x8–x15 bases/destinations as applicable. The register pool ensures a usable compact LS base exists. C.LWSP/C.SWSP obtain a separately tracked x2 base. C.ADDI16SP updates both architectural SP metadata and the bound-address record so consecutive operations see synchronized state.

Compressed LS helpers generate 4-byte-aligned unsigned offsets within both encoding range and bound memory window. Fixed-immediate paths validate before use and otherwise regenerate a legal offset.

## PC and Branch Targets

`inst_print` computes `inst_bytes = 2` unless low bits are `11`; it records the current PC, writes one/two halfwords, then increments virtual/physical PC by the actual byte length. Direct branches use recorded target PC minus current branch PC. Indirect branches select only entries in `inst_pc_history`, preventing a target in the middle of a 32-bit instruction.

## Dependencies

Compressed classes depend on generic generator objects and register/address helpers. Compressed-only random execution depends on `C_INST_SEQ`, which has zero AUTO weight and must be requested through a scenario PLAN. Control-flow forms depend on branch sequences rather than `c_inst_sequence`.

## Current Status

RV32C queue and basic random/direct generation are integrated and have passed targeted C scenario simulation in the current working tree. RV64C creates the common set but no RV64-only compressed instruction classes are currently listed.

## Known Limitations

- Compressed-only random sequence excludes control-flow and EBREAK by design; testing them requires branch/exception scenarios.
- `fetch_space_avail` and truncation reserve/write a 4-byte task terminator; this is intentional today but still contains legacy fixed-width comments.
- `vmem_write_word` emits an address/data record again when the second half arrives; downstream loader must keep the last value for an address.
- RV64C coverage is not established; RV64-only C instructions are not defined.
- No coverage model proving every compressed instruction was generated was found.

## Recommended Read Scope

Choose exactly one of the following scopes; do not combine LS and branch scopes unless shared PC/output behavior is the explicit subject.

## Compressed LS Recommended Read Scope

Read:

1. `uvm_tb/inst_gen/inst_group/c_inst.sv` relevant LS class only
2. `uvm_tb/inst_gen/ls_addr_generator.sv` compressed helper only
3. `uvm_tb/inst_gen/register_pool.sv` compact/SP base methods
4. Relevant LS sequence only if sequence behavior changes

## Do Not Read By Default

## Compressed LS Do Not Read By Default

Do not read branch sequences, branch constraints, scenario executor, all normal load/store classes, MMU/PMP/PMA, or unrelated compressed ALU classes.

## Compressed Branch Recommended Read Scope

Read:

1. `c_inst.sv` relevant C.J/C.B*/C.JR/C.JALR class
2. The one affected branch sequence
3. `inst_name_generator.sv` branch constraints
4. `inst_generator.sv` PC-history methods only if target-boundary behavior changes

## Compressed Branch Do Not Read By Default

Do not read LS address generation, compressed LS register logic, all scenarios, MMU/PMP/PMA, or unrelated instruction encoders.

## Expansion Conditions

- Read `c_inst_sequence.sv` only when compressed-only random membership changes.
- Read scenario files only when adding/changing targeted RVC validation.
- Read vmem/PC output only for instruction-length or consumer-format changes.
- Read build files only when adding/moving a source or package dependency.

## Last Verified

Repository state: commit `4723233`, dirty working tree, analyzed 2026-09-09.

Verified areas: class/macro inventory, queue gating, compressed-only membership, LS/SP paths, direct/indirect targets, PC/vmem output.

Needs re-verification if RVC classes, register-base APIs, PC history, branch sequences, or vmem format change.
