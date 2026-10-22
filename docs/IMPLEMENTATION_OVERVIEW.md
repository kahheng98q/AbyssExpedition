# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [004规格](../specs/004-run-level-promotion/spec.md) · [当前证据](validation/run-level-promotion/results.md)

**更新 · 2026-10-22**：每局全队从基础职业、RUN Lv1开始，共享经验与升级。RUN Lv15为每名存活队员提供两分支，立即改变攻击与属性；保留被动、局内增益和生命比例。选择仅本局有效，取消后可用HUD按钮重开。局外仅查看分支预览，不再保存永久等级、经验、分支或材料。旧档迁移保留角色归属、票券、招募、章节、种子与队伍。

| 范围 | 当前状态 | 待验 |
| --- | --- | --- |
| 004逻辑／存档 | 17组共10,152断言分批通过 | 核心图形／导出通过；完整命令未全绿 |
| DEV / F9 | 140项单例、沙盒与跨屏检查通过 | 物理键鼠／Fn |
| 实机转职 | 三尺寸36项；源码／Debug／Release图形通过 | 自然Lv15、原生长时钟与可读性 |
| M1–M4 | 自动战斗、同伴、招募、腐化、章节可用 | 体验、性能 |

双击根目录 `Play Debug.cmd` 运行当前源码；新Debug／Release在`builds/windows/run-level-promotion/final-v9/`。WASD移动，1/2/3选升级，Esc暂停，C看腐化；F9进入隔离沙盒，用RUN经验或Lv15资格操作测试转职。旧素材发放ID现为资格别名，不再生成材料。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_validation.ps1 -M4 -DummyAudio -EvidenceDirectory docs/validation/run-level-promotion/new-check
```

seed101三角色自动通关只到RUN Lv10–11，不能作为自然Lv15可达性证据；本版未改经验曲线。完整命令因原生长时钟提前退出／失焦未通过；T016／T018保持开放，人工体验与性能未验。历史003性能p95超预算，不能由当前逻辑测试替代。

[004任务](../specs/004-run-level-promotion/tasks.md) · [开发记录](development.md) · [DEV操作／人工清单](developer-debug-panel.md) · [历史003](validation/sword-promotion-identity/convergence-20261021-v1/results.md) · [历史002](validation/combat-pacing-audio/phase7-20261020/results.md) · [历史M4 gate](validation/m4-gate.md)
