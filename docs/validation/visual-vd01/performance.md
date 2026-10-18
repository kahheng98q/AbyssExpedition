# Performance · VD-01-P1 · 2026-10-17

**父版本历史账本。** 当前VD-01-P2已完成两组完整三seed复测，六次采样有效但均未达预算；见[当前结果与原始数据](completion-r1/performance.md)。下列旧版/f187值保留其原始版本，不作为P2测量。

完整测量已保存；预算结果见下表，参考机验收仍未完成。

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
| 101 | 19.308 | 28.552 | 30.308 | 33.404 | True | False |
| 202 | 19.524 | 27.734 | 29.324 | 33.677 | True | False |
| 303 | 19.894 | 28.879 | 31.055 | 36.843 | True | False |

## Approved P02 · retained before, final instrumentation

| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | 23.816 | 31.689 | 33.554 | 51.942 | True | False |
| 202 | 23.586 | 31.650 | 33.228 | 36.537 | True | False |
| 303 | 23.295 | 31.482 | 32.759 | 48.736 | True | False |

## Approved P02 · final release

| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | 26.815 | 31.719 | 33.030 | 35.758 | True | False |
| 202 | 26.493 | 31.872 | 34.054 | 69.667 | True | False |
| 303 | 26.526 | 31.660 | 33.368 | 54.705 | True | False |

P02 adds30 actual base48/100 arcs +100 moving friendly base homing stars, at original lifetimes, without reducing ordinary enemies/boss/companions/gems/corruption or altering the inherited workload validators. after mode requires≥30 new arcs,≥100 new stars,new actors present. Actual new/fallback minima/maxima are in JSON; raw frame CSV and logs retained. before expects no new art. Final P02 instrumentation additionally reports fallback counters; to avoid mixing versions, before was rerun in perf-visual-r1 with the same frozen fixture. Earlier before/perf-visual is retained as historical diagnostic evidence. Intermediate04a8 after/perf and after/perf-visual results are retained separately; they precede the prop-region fix and do not represent this final pack.

Original M4 raw CSV/OS process memory monitors are retained in before/perf and after/perf-r1. P02 uses Godot monitors; a missing/zero release static-memory counter is unavailable, not zero memory. No external profiler or physical latency device was attached. No attacks/counts were removed, no gameplay optimization or frame-target relaxation was performed.

Release pack before965f0e7b9a6254fc3ac5ecd5d92ec87a682410a44a604edc7c8c3c79703ff17b → afterc6d626b275117e8f5ec8c476ed6cc8574792a8b53bd3dab55927d8e565d98bfe. The .console.exe thin launcher hash is not the embedded game hash. Raw before host metadata preserves the original export location; retained before/build/AbyssExpedition.exe matches its recorded hash.

```powershell
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory docs/validation/visual-vd01/after/perf-r1
./tools/run_visual_stress.ps1 -Mode before -Executable <retained-before-exe> -EvidenceDirectory docs/validation/visual-vd01/before/perf-visual-r1
./tools/run_visual_stress.ps1 -Mode after -Executable <final-release-exe> -EvidenceDirectory docs/validation/visual-vd01/after/perf-visual-r1
```

Displayed≤100ms feedback and human recognition are unmeasured. Existing before budget misses do not waive the candidate target; G2 remains pending.


VD-01-P3 / 2026-10-18：[当前本机收尾](completion-r2.md)与[逐项执行映射](completion-r2/review-trace.md)补充本轮绘制缓存、原生像素/字形/真实时钟、完整性能及答卷工具证据；此前记录保留为对应版本历史。当前77/87，性能5组失败/1组达标，真实窗口/设备/人群/完整人工部分继续pending。
