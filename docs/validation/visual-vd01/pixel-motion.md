# Pixel / event sampling · 2026-10-17

Actual frames: screenshots/visual-vd01/after/release-r3/motion/frame-000..059.png; source-r3 equivalent. Offline runtime-gallery plays the60 native engine frames at30FPS,2seconds, then masks. These are controlled run-tick samples, not ordinary wall-clock video. Bodies remain unrotated; only horizontal mirror and independent foot shadow. Four cardinal arcs rotate as approved; native nearest cells/anchors loaded without import errors. No atlas bleed was observed in inspected cardinal frames.

Automated integration coverage: first observation mid-attack, attack→hurt→same attack resume, skip beyond expiry, valid enemy dead_at, lethal hero hurt_until−8, synthetic death final pose,2tick feedback,45tick warning independent of hurt, paused tick freeze, skipped/debug-speed tick sampling, four fixed mirrored anchors, basic/upgraded arc and basic/promoted/hostile star selection. Red/green moving-Thrall mirror regression retained. Existing enemy24tick cleanup logic is byte-for-byte unchanged; animation never owns removal, damage or results.

Limits: current visual sequence manually steps projectiles/poses at render sample intervals; it is not physics-path/latency evidence. Actual120tick old/new simulation logs verify paths separately. Complete wall-clock death/pause/speed/interrupted clips and physical-window2×/3×/1371 letterbox/shimmer examination remain pending. Native captures do not establish displayed latency or human recognition.

## VD-01-P2 follow-up

The previous paragraph describes f187's earlier evidence. [Elapsed-clock player](../../visual-design/wallclock-gallery.html) now preserves actual source163/release134/retained-before137 viewport frames at recorded microsecond timestamps. Four input-action directions, idle, manual pause/resume use the ordinary physics loop; pause segments show0 tick advancement. Source-only existing debug2x records86ticks/0.717s, followed by reset1x25ticks/0.417s. Render sampling is not fixed-FPS movie mode. Injected observer attack→2tick hurt→resume, late visible attack frame>0, expired-event no replay, warning independent of hurt, death and actual registered-enemy24tick cleanup are separately named in the manifest. These tests do not introduce registered companions or change gameplay callbacks. Full details/hashes/limits in [current report](completion-r1.md) and [timeline manifests](completion-r1/wallclock-summary.json). The initial source capture is retained but the matched-harness canonical source is wallclock-source-r2.

Actual Window final transforms confirm2x/3x/2x and1371 margins46/30/45/29. They are engine measurements, not physical-window pictures. Physical display shimmer/latency and a complete natural human session remain open; no claim of physical input measurement.


VD-01-P3 / 2026-10-18：[当前本机收尾](completion-r2.md)与[逐项执行映射](completion-r2/review-trace.md)补充本轮绘制缓存、原生像素/字形/真实时钟、完整性能及答卷工具证据；此前记录保留为对应版本历史。当前77/87，性能5组失败/1组达标，真实窗口/设备/人群/完整人工部分继续pending。
