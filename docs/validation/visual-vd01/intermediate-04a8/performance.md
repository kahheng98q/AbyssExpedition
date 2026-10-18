# Performance · VD-01-P1 · 2026-10-17

最终顺序测量进行中；pending不是通过，完成后刷新本文件。

Each full run uses30 active seconds warmup +120 active seconds capture; Compatibility1920×1080, VSync off, uncapped. Seeds101/202/303 run sequentially; original M4 fixture is unchanged. Target per seed p95≤16.67ms,p99≤25ms. Capture validity and budget status are separate. Current host self-reports AMD Ryzen7 5800H / GTX1650 / Windows10.0.26200; it is **not** the required i5-8400/GTX1050Ti reference machine. RAM/CIM queries were unavailable; no capacity is guessed. Light documentation/file audits occurred, no concurrent graphical jobs during full runs. This is not an exclusive reference-machine acceptance session.

## Original M4 · retained before

| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | 22.087 | 28.086 | 29.075 | 31.387 | True | False |
| 202 | 22.256 | 28.401 | 29.774 | 37.092 | True | False |
| 303 | 21.874 | 28.029 | 29.038 | 38.590 | True | False |

## Original M4 · final release

| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | 19.910 | 28.877 | 31.229 | 36.421 | True | False |
| 202 | 19.554 | 27.831 | 30.287 | 62.465 | True | False |
| 303 | pending | — | — | — | — | — |

## Approved P02 · retained before, final instrumentation

| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | 23.816 | 31.689 | 33.554 | 51.942 | True | False |
| 202 | 23.586 | 31.650 | 33.228 | 36.537 | True | False |
| 303 | 23.295 | 31.482 | 32.759 | 48.736 | True | False |

## Approved P02 · final release

| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | pending | — | — | — | — | — |
| 202 | pending | — | — | — | — | — |
| 303 | pending | — | — | — | — | — |

P02 adds30 actual base48/100 arcs +100 moving friendly base homing stars, at original lifetimes, without reducing ordinary enemies/boss/companions/gems/corruption or altering the inherited workload validators. after mode requires≥30 new arcs,≥100 new stars,new actors present. Actual new/fallback minima/maxima are in JSON; raw frame CSV and logs retained. before expects no new art. Final P02 instrumentation additionally reports fallback counters; to avoid mixing versions, before was rerun in perf-visual-r1 with the same frozen fixture. Earlier before/perf-visual is retained as historical diagnostic evidence.

Original M4 raw CSV/OS process memory monitors are retained in before/perf and after/perf. P02 uses Godot monitors; a missing/zero release static-memory counter is unavailable, not zero memory. No external profiler or physical latency device was attached. No attacks/counts were removed, no gameplay optimization or frame-target relaxation was performed.

Release pack before965f0e7b9a6254fc3ac5ecd5d92ec87a682410a44a604edc7c8c3c79703ff17b → after04a8a4e4f45410c945c42098e2a7742b5554d661fb16a03b708ee28ec5a962c4. The .console.exe thin launcher hash is not the embedded game hash. Raw before host metadata preserves the original export location; retained before/build/AbyssExpedition.exe matches its recorded hash.

```powershell
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory docs/validation/visual-vd01/after/perf
./tools/run_visual_stress.ps1 -Mode before -Executable <retained-before-exe> -EvidenceDirectory docs/validation/visual-vd01/before/perf-visual-r1
./tools/run_visual_stress.ps1 -Mode after -Executable <final-release-exe> -EvidenceDirectory docs/validation/visual-vd01/after/perf-visual
```

Displayed≤100ms feedback and human recognition are unmeasured. Existing before budget misses do not waive the candidate target; G2 remains pending.
