# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [002验收矩阵](validation/combat-pacing-audio/acceptance.md) · [历史M4 gate](validation/m4-gate.md)

Godot 4.5 离线单人原型：走位自动战斗、拾取升级，局外成长、六分支转职、同伴与招募，再以腐化契约挑战海岸首领。M1–M4已接线；人工体验和历史参考机目标仍开放。

**What's New · 2026-10-20**：Phase 7完成完整快照、终结计数、性能守卫和4.5构建修复。16组9,232断言及源码/新Debug/Release图形通过；新录音8声部/削波0，本机开启p95 15.172ms。自然九局/九对、真人试听/五人测试、物理DEV及完整后台环境仍开放。[实施证据](validation/combat-pacing-audio/phase7-20261020/results.md)。

| 范围 | 当前状态 | 待验 |
| --- | --- | --- |
| M1 / 002 Combat | 近场、编排、音频自动检查通过；部分完成 | 自然九局/九对、听感 |
| M2 Progression | 等级1–30、六分支、双同伴、存档已验证 | 自然操作 |
| M3 / M4 | 招募、救援、腐化、事件、章节已验证 | 玩法理解、长局体验 |
| DEV/F9 | 源码及Debug单例、沙盒/跨屏、Release拒绝已验证 | 物理键鼠全控件 |

## 启动与测试

当前发布版：`builds/windows/combat-pacing-audio/phase7-release-20261020/AbyssExpedition.exe`；源码双击根目录 `Play Debug.cmd`，DEV/F9进入隔离沙盒。WASD/方向键移动、自动攻击；1/2/3升级，Esc暂停，C查看腐化。失焦暂停，回焦只释放focus。

```powershell
./tools/run_validation.ps1 -M4 -DummyAudio
./tools/validate_pacing_audio.ps1 -Mode Record -EvidenceDirectory docs/validation/combat-pacing-audio/my-natural-v1
```

第二条需真人完成三职业×三seed；保持首个合法升级与免费事件，不用DEV。Dummy仅诊断。[完整运行指南](../specs/002-combat-pacing-audio/quickstart.md) · [任务](../specs/002-combat-pacing-audio/tasks.md) · [开发记录](development.md) · [历史Q1](validation/quality-20261018.md)
