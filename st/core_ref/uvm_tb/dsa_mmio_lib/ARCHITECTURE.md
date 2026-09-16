# DSA MMIO Reference Model Architecture

## Scope

This document describes the structure and behavioral boundaries of
`uvm_tb/dsa_mmio_lib`. Usage is documented in `README.md`; semantic history is
recorded in `DEVELOPMENT_LOG.md`.

The library models reference state and software-visible MMIO behavior. It is not
an RTL register generator and does not attempt to reproduce bus protocol timing.

## Source-to-runtime flow

```text
MMIO JSON descriptions
  registers, fields, state, parameter relationships
                |
                v
Python generator
  parse -> validate -> emit
                |
                v
SystemVerilog include files
  declaration / reset / read / write / semantic / resolve / profile clear
                |
                v
Per-DSA MMIO set
  generated behavior + handwritten special windows and side effects
                |
                v
DSA MMIO library
  configured VU, MU, or DTE interface used by the core reference model
```

The JSON descriptions and `tools/gen_dsa_mmio.py` are maintained sources.
Files under `generated/` are derived artifacts and must remain reproducible.

## Generator model

The generator accepts the following object groups:

- `registers`: scalar or strided 32-bit MMIO registers and their fields.
- `custom_windows`: addresses whose detailed access behavior is handwritten.
- `state_arrays`: non-MMIO array state such as register files.
- `internal_states`: non-MMIO scalar state.
- `exec_config`: the configuration-index and dynamic-mask fields.
- `param_groups`: paired dynamic and banked-static parameter registers.
- `static_params`: parameters always selected from a banked register.

Validation rejects missing names, invalid integers, unaligned addresses,
overlapping fields, duplicate MMIO names, incompatible dynamic/static layouts,
and parameter banks that exceed the configuration-index capacity.

## Read and write behavior

Generated read and write blocks use first-hit address decoding through
`mmio_hit`. Register arrays additionally check the base/end range and stride.

For a normal write, both the packed field struct and its 32-bit mirror are
updated. A `software_write_ignore` register still reports a valid MMIO hit but
retains the hardware-maintained value. With `reserved_zero` enabled, undefined
bits are masked on generated reads and writes.

Custom windows are decoded and implemented by the per-DSA class before or
alongside the generated blocks. This keeps register-file access and other
multi-step behavior out of the mechanical generator.

## Trigger snapshot

A register marked `trigger` raises `inst_trigger`. The owning MMIO set then
resolves the current effective execution parameters and marks a pending DSA
instruction.

For each parameter group, the configured mask bit chooses either the dynamic
register or the indexed static-register bank. The result is copied into
`exec_param`, making the instruction use a stable snapshot rather than mutable
MMIO state.

## Semantic request logging

Generated `get_write_desc()` and `get_read_desc()` helpers translate a hit into
a DSA name, register name, optional array index, address, data, and decoded field
values. Fields whose names begin with `reserved` are omitted from the log.
Unknown accesses continue through the handwritten error-reporting path.

## Performance counters

A `profile_counter` must be scalar and `software_write_ignore`. The generator
collects all such registers into `_profile_clear_auto.svh`. VU includes this
file when software writes the clear bit in `PROFILE_CTRL`, then self-clears the
control bit. Counter increments and event selection remain handwritten runtime
behavior because they depend on execution events rather than MMIO structure.

## 0915 error and replacement state

VU keeps the trigger's original stream and current macro user as execution context. `report_error()` accumulates error bits while first-error context registers latch independently; reading `ERROR_CODE` clears the error flag, code, sticky snapshot and specialized contexts together. RF/CM ECC helpers are explicit software-visible error-injection interfaces only: they verify context and clear behavior but do not model ECC bits, detection latency or data correction.

NaN/Inf replacement uses global replacement-value registers and dynamic/static selection for `NAN_INF_REPLACE_EN`. `note_replacement()` increments the matching profile counter only while profiling is enabled and only at an actual replacement point.

## Behavioral boundaries

- Field `access` metadata is parsed but not enforced. Field-level RO, WO, W1C,
  and related policies require generator work or handwritten behavior.
- `reserved_zero` masks holes not covered by declared fields. A field explicitly
  named as reserved is still part of the declared mask.
- Reset values are emitted from JSON directly; descriptions must keep reserved
  reset bits consistent with the architecture.
- Semantic field values are displayed in decimal, while addresses and complete
  register data are displayed in hexadecimal.
- The model represents architectural effects, not MMIO bus latency or ordering.
