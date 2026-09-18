# Independent checker regression

Run from any directory with VCS available:

```bash
bash /path/to/axi4_vip_adapter/tests/checker/run_checker_vcs.sh
```

The runner creates a unique `axi4_checker.*` scratch directory, preserves logs,
checks the workbook hash before/after, and invokes no configuration generator or
default Makefile target. On the project server it loads the VCS module using
`modulecmd sh` if VCS is absent from `PATH`. Use an explicit `bash` command through
SSH because the server login shell is csh. `CHECKER_SCRATCH_PARENT`,
`CHECKER_COMPILE_TIMEOUT` (default 180 seconds), and `CHECKER_RUN_TIMEOUT`
(default 90 seconds) may be overridden. The bench also has a simulation-time
watchdog. Run this script only in an isolated checkout/scratch copy, never in the
production server project.

`tb_axi4_protocol_monitor.sv` directly drives the interface at falling edges;
it does not depend on or trust the adapter driver. Its 62 scenarios cover:

- Legal independent 128-read, 128-write, and combined 64+64 limits, exact
  handshake counts, reverse completion across IDs, and same-ID FIFO selection
  observable through distinct read lengths.
- W before AW, 1/2/4/16-beat INCR, all five channels stalled, unaligned/narrow
  accesses, zero strobes, a transfer ending exactly at the 4KB boundary, and
  unknown unselected data bytes/absent sideband storage.
- Invalid 4KB crossings, size/burst encoding, early/missing LAST, per-beat
  WSTRB lanes, invalid/early IDs and responses, same-edge response dependencies,
  payload/VALID changes during stalls, and X on active payload/control.
- Address, WSTRB and WLAST errors detected while READY remains low, 129-deep
  read/write/combined overflow, read/write/ready/unpaired-W inactivity timeouts,
  progress refreshing timers, unpaired-W timeout rearming after partial pairing,
  and reset with outstanding traffic.
- Each checker category disabled separately, unrelated checker counts
  unchanged, all checkers disabled, capability/traffic/alignment policies
  independent, and coverage master/group enables plus key bin counters.

Expected violations use `REPORT_ERRORS=0` and assert diagnostic counter deltas.
The counters and coverage survive reset; each case snapshots them after reset.
The separate `tb_axi4_checker_report.sv` uses `FATAL_ON_ERROR=1` and must terminate
with `Fatal:` from the monitor and `AXI_CHECK[AXI_RESPONSE]` for a BID without
an outstanding write, proving reporting reaches VCS.
VCS may return process status zero even after `$fatal`; the runner requires the
exact fatal diagnostic, rejects timeout and the missing-error sentinel, and
records the observed status without requiring a nonzero exit code.
`tb_axi4_checker_capability.sv` separately enables the unimplemented FIXED
capability and requires its exact startup fatal diagnostic, demonstrating that
unsupported capability settings are rejected before stimulus begins.

The test profile is DATA256/ADDR32/ID8/LEN4 at 1 GHz, maximum 16 beats, independent
read/write limits of 128 and combined limit of 128. These are explicit test
assumptions: the original requirement does not resolve maximum burst size or
whether “128 outstanding” means read, write, or combined. Error responses are
legal AXI response encodings, but deliberately increment this monitor's enabled
response-error checker. A passive bus monitor cannot distinguish swapped
same-ID responses with identical observable attributes; semantic payload/order
checking needs the request/data scoreboard. These tests establish monitor
behavior against raw pins, not NoC throughput or integrated BFM behavior.

The runner also executes `tb_axi4_checker_progress.sv`: six directed cases with
READ/WRITE=4 and READY=16 distinguish legitimate same-ID/W ordering delays from
real head-of-ID response stalls. They verify fresh budgets when a successor
becomes eligible, W-before-AW uses READY, and timeout-disable remains independent.
The complete raw-pin run passed 62 cases/3341 assertions plus 6 cases/27 assertions
and both reporting/capability fatal smoke tests after the eligibility correction.
