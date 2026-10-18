# VD-01-P2 full performance measurement

Current embedded pack `38ea36e5dfbc702510228a940bbd0d3feb60f920db527d2aac56a6263791c2e0`. Current host AMD Ryzen7 5800H / GTX1650; not the required i5-8400/1050Ti reference. Balanced power scheme; effective power/OS foreground not independently observed; RAM query unavailable. Compatibility1920x1080, VSync0, uncapped, Dummy diagnostic audio. All six captures:30active seconds warmup +120active seconds measurement; release; valid populations. No other graphical test was run concurrently with either measurement set; light document/file work occurred.

| workload | seed | p50 ms | p95 ms | p99 ms | max ms | budget |
| --- | --- | --- | --- | --- | --- | --- |
| M4 | 101 | 21.596 | 28.018 | 29.357 | 74.506 | FAIL |
| M4 | 202 | 21.990 | 28.257 | 29.302 | 33.667 | FAIL |
| M4 | 303 | 22.165 | 28.442 | 29.650 | 36.219 | FAIL |
| P02 | 101 | 16.478 | 17.955 | 23.699 | 76.643 | FAIL |
| P02 | 202 | 16.442 | 17.744 | 18.513 | 29.425 | FAIL |
| P02 | 303 | 16.489 | 17.965 | 18.838 | 29.018 | FAIL |

Each seed requires p95<=16.67ms AND p99<=25ms. Valid capture does not mean budget acceptance. No reference-machine or physical latency pass claimed. Current measurements are not causally attributed to the text fix; compare workload/host/runner conditions and raw data before drawing that inference.

P02 preserves the inherited population targets and verifies >=30 actual new base arcs, >=100 actual new friendly basic stars, >=1 matched new actor and separate fallback counts. Real effect lifetimes remain unchanged. Matching retained-before fixture SHA256 is checked. Original M4 and P02 are independent workloads; values are never pooled.

Raw current data: [M4 results/OS memory metadata](perf/results.json), [M4 host](perf/host.json), [P02 host](perf-visual/host.json), per-seed JSON/CSV/logs in both folders. Zero release static-memory monitor means unavailable; M4 process CSV records OS memory. No external profiler/video device was attached.

Retained original before results and prior f187 measurements remain in [the previous performance ledger](../performance.md); no historic sample was relabeled. P02 before fixture hash remains frozen; no claim that the source-only short diagnostic is full acceptance.
