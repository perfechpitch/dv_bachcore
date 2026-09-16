# DSA MMIO Reference Model Development Log

This log records semantic changes to the MMIO generator and its generated
runtime behavior. It is not a copy of every repository commit.

## 2026-09-15 — Error context, ECC injection and NaN/Inf replacement

### Changed

- Added current macro user/event-stream tracking and first-error context handling.
- Added explicit RF/CM ECC error-injection APIs for software-visible verification without claiming a physical ECC model.
- Added NaN/Inf replacement values, replacement counters and profile-clear integration.
- Preserved trigger reserved-bit behavior and original-stream reporting required by the 0915 definition.

### Boundary

Real ECC detection/correction, IRQ behavior, dispatch-stop policy and cycle timing remain outside this reference model.

## 2026-09-11 — MMIO status and profile-counter behavior

Commit: `e79113e` (`Improve VU execution, MMIO status and MXFP8 reference tests`)

### Changed

- Added description-level `reserved_zero` handling to mask undefined bits on
  generated reads and writes.
- Added register-level `software_write_ignore` handling for hardware-maintained
  status, error, snapshot, and counter registers.
- Added `profile_counter` validation and conditional generation of
  `_profile_clear_auto.svh`.
- Connected VU `PROFILE_CTRL.clear` to the generated counter-clear operation.
- Updated the VU description to use the new behavior controls.

### Impact

Software can no longer overwrite VU hardware-maintained status and profile
state through the reference MMIO model. Reserved-bit behavior is closer to the
architectural register definition, and profile counters have a common generated
clear path.

### Verification recorded by the commit

Whitespace, Python AST, JSON syntax, and affected VMEM format checks passed.
The commit explicitly records that a full simulation was not rerun.

## 2026-09-07 — Semantic MMIO request logs

Commit: `e307655` (`Enhance DSA MMIO execution logs`)

### Changed

- Generated per-register read and write description functions.
- Added decoded non-reserved field values to successful MMIO request logs.
- Added array indices to logs for repeated registers.
- Integrated semantic logging into VU, MU, and DTE MMIO sets.
- Removed duplicate raw address/data messages from normal DSA instruction logs.

### Impact

Requests can be debugged using register and field names instead of manually
decoding every address and value. Invalid addresses still use the existing
error path.

## 2026-09-02 — Move to `core_ref`

Commit: `66a65b7` (`Rename sim_rtl to core_ref and add RTL sim skeleton`)

The generator moved from `st/sim_rtl` to `st/core_ref` without a functional
change.

## 2026-09-02 — Initial generator

Commit: `5e87e35`

### Added

- JSON parsing and validation for MMIO registers, fields, state, and execution
  parameter relationships.
- Generated declarations, resets, read/write address decoding, and dynamic or
  static execution-parameter resolution.
- Initial VU, MU, and DTE MMIO generation subsystem used by the ST reference
  simulation.
