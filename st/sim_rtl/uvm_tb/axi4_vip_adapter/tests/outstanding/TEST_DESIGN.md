# Outstanding regression design

The controlled slave and test top are isolated from the demo slave/top and do
not invoke the normal Makefile configuration regeneration. All generated JSON,
SV packages, compiler products and logs belong in a unique scratch directory.
`docs/vip/vip_cfg.xlsx` must retain SHA-256
`b7fd8821f7f3625a5c6b643344114733ada212626a18bf7a4b24c9d4e1eb8994`.

DATA256, ADDR32, ID8, LEN4 and a 1 ns period are the regression profile. Burst
lengths 1, 4 and 16 are test choices within the LEN encoding, not a confirmation
of the unspecified project maximum burst. Read/write/total caps are separate
test settings; 128 is not interpreted as a confirmed cap for each direction.

## Independent checks

`controlled_slave.sv` derives live and peak outstanding from AW/AR acceptance
and B/final-R retirement. Software request queue occupancy is never counted.
It fails immediately if a read, write or total cap is exceeded. The model
checks W data, WSTRB and WLAST against the accepted AW address and beat index,
uses AW order for W association, preserves same-ID response order, and chooses
later requests of other IDs first. Read response selection switches IDs on
individual beats. Bus counts and response-order/backpressure coverage are
printed with the `BUS_EVIDENCE` marker.

The top must independently check each completed request handle: returned ID,
status, exact read length, every RDATA/RRESP beat, and one completion per
submission. It must compare cumulative completion totals to bus counters and
require all software queues, actual outstanding counts and model queues to
drain. Each request gets a unique aligned address and address-derived payload;
reused IDs therefore cannot hide a swapped transaction.

## Required scenarios

| Scenario | Setup | Mandatory result |
|---|---|---|
| Read128 | caps R/W/T = 128/128/128, queue 160 reads, hold R | Exactly 128 AR handshakes, 128 actual live reads and 32 unissued software requests; no 129th AR while held; after release 160 final responses, correct data, zero live |
| Write128 | same caps, queue 160 writes, hold B | Exactly 128 AW handshakes, W payload/last validated, 128 actual live writes; no 129th AW while held; release yields 160 unique B completions |
| Mixed128 | caps 128/128/128, queue reads and writes, hold both responses | Both directions make progress; combined actual peak exactly 128, never 129; release drains all traffic |
| Asymmetric | caps 3/5/7, mixed flow with independently held B/R | Actual R<=3, W<=5, total<=7 every edge; reach each directional cap in separate phases and total7 in a mixed phase |
| Multi-ID | repeated IDs across unique addresses, mixed 1/4/16-beat bursts | Cross-ID reordered B and final R completions, same-ID FIFO, multiple interleaved R bursts, exact payload/response mapping |
| Independent backpressure | prime-period AW/W/AR stalls and B/R service gaps | Each address/data accepted once, stalls observed on all request channels, no dropped/repeated W beats or deadlock |
| AW waits for W | `awready_requires_wvalid=1`, accept W before AW; then independently hold AW | WVALID does not wait for AWREADY; buffered W matches subsequent AW in FIFO order; `earlyW>0` and no deadlock |
| Old APIs | legacy single read/write and blocking burst APIs | Correct payload/response and completion; blocking API returns only after response |
| Concurrent callers | two producers per direction, old blocking plus asynchronous submissions | No initialization race, lost requests or global read/write serialization |
| Reset | queue beyond caps, hold responses, interrupt with reset | Every old handle completes with reset status once; outputs become idle; late/stale responses cannot match a new epoch; post-reset request succeeds |
| Timeout | separate AW, W, B, AR and R withheld runs | Bounded diagnostic/status for stalled channel; all affected handles resolve; channel state does not silently reuse ambiguous IDs |
| Bad response | unexpected BID/RID, early/missing RLAST, early B | Diagnostic identifies channel/ID/length; request is never silently credited to a different ID or same-ID successor |
| Timeout coincident with transfers | Anchor read AR or write AW/WLAST, budget8, present AW/AR/nonfinal W at deadline | Exact AW/W/AR handshake counts at fault edge, all7 handles TIMEOUT, no next W/address, live stays3; late B/R cannot retire or rewrite status; reset recovers |
| Error response | SLVERR and DECERR, including one read beat among OKAYs | Exact B/R response returned to caller; completion and cap retirement remain correct |

The testbench watchdog bounds every positive scenario. Negative scenarios
should be separate simulator invocations and must match their intended
diagnostic/status, not merely accept any failed run. A compile-only result or
unrelated historical PASS log is not evidence for these cases.
