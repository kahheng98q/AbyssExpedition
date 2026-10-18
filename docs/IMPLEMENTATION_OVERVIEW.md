# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [当前候选/验证](validation/visual-vd01/completion-r2.md) · [历史M4门槛](validation/m4-gate.md)

Godot4.5离线单人原型：走位自动战斗、拾取升级，局外成长/转职、双同伴、救援招募与腐化契约。M1–M4已接线；人工乐趣/普通通关/参考机性能仍待验收。

**What's New · 2026-10-18**：[自主实施与持续文档](validation/workflow-2026-10-18.md)已持久化；无例行签批，自动测试修复、逐阶段更新文档；人工未验项仍pending，reviewer清单只读。本次仅配置/文档，未运行游戏测试。

**最近游戏更新 · 2026-10-17**：八件原创视觉切片已接入，owner已验证父版本；当前修复长名称/升级标题，保留完整数值与暂停详情。12组5,278＋debug69断言通过；源码/发布图形、F9限制、真实时钟动作及长路径/四角提示检查通过。玩法数值未改。两组完整基准仍超预算；参考机、十人评审、物理显示与完整自然操作验收仍开放。

[当前收尾/证据](validation/visual-vd01/completion-r2.md) · [离线答卷](visual-design/review-session.html) · [真实时钟动作](visual-design/wallclock-gallery.html)。长名称/标题压力样本现已通过；其余角色、晋升、敌人与屏幕不扩展。

| 范围 | 当前可玩 | 验收状态 |
| --- | --- | --- |
| M1 Combat | 三类自动攻击/12升级/首领 | 自动验证；人工待验收 |
| M2 Progression | 等级1–30/6分支/双同伴 | 自动验证；自然流程待验收 |
| M3 Recruitment | 救援/票券招募/兑换/历史 | 自动验证；完整手动待验收 |
| M4 Abyss | 腐化/事件/契约/章节保存 | 自动验证；体验/性能待验收 |
| VD-01-P3 | 八件/长文/绘制缓存/完整回退 | 本机自动验证；77/87任务，量化/人工开放 |

双击 `builds/windows/m4/AbyssExpedition.exe`。公会→Expedition；WASD移动、自动攻击，1/2/3升级，Esc暂停，C腐化。9:00首领，击败才胜利。开发源码F9为隔离沙盒，发布版禁用。

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
./tools/run_validation.ps1 -M4 -Graphical -Export -DummyAudio
```

[概念+实机预览](visual-design/preview.html) · [素材/缺口](visual-design/ASSET_INVENTORY.md) · [审批](visual-design/APPROVALS.md) · [开发记录](development.md) · [Spec](../specs/001-abyss-expedition-mvp/spec.md) · [Plan](../specs/001-abyss-expedition-mvp/plan.md) · [Tasks](../specs/002-2d-art-direction/tasks.md)
