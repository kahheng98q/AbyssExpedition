# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [002验收矩阵](validation/combat-pacing-audio/acceptance.md) · [历史M4 gate](validation/m4-gate.md)

Godot 4.5 离线单人原型：走位自动战斗、拾取升级，局外成长、六分支转职、同伴与招募，再以腐化契约挑战海岸首领。M1–M4已接线；人工体验和历史参考机目标仍开放。

**What's New · 2026-10-21**：003剑系三轮廓、双斩／旋斩、实际恢复与静音转职演示已实现。Phase 7三组各60样本零差异，含真实升级／事件／结算；任务校验10例通过。新Release／Debug完整图形及九组合真实时钟通过，性能样本有效但p95 16.732ms超目标，真人待验。用`Play Debug.cmd`运行源码。[收敛实施](validation/sword-promotion-identity/convergence-20261021-v1/results.md) · [验收矩阵](validation/sword-promotion-identity/acceptance.md)。

**历史002证据 · 2026-10-20**：Phase 7修复通过16组9,232断言及源码/新Debug/Release图形；新录音8声部/削波0，本机开启p95 15.172ms。自然九局/九对、真人测试、物理DEV及完整环境仍开放。[历史实施证据](validation/combat-pacing-audio/phase7-20261020/results.md)。

| 范围 | 当前状态 | 待验 |
| --- | --- | --- |
| M1 / 002 Combat | 近场、编排、音频自动检查通过；部分完成 | 自然九局/九对、听感 |
| M2 Progression | 等级1–30、六分支、双同伴、存档已验证 | 自然操作 |
| M3 / M4 | 招募、救援、腐化、事件、章节已验证 | 玩法理解、长局体验 |
| DEV/F9 | 源码及新Debug单例、沙盒/跨屏已验证 | 物理键鼠 |

## 启动与测试

003当前双击 `Play Debug.cmd`，新Debug／Release在`builds/windows/sword-promotion-identity/convergence-release-20261021-v1/`，均已实际启动。旧002发布版保留，DEV/F9进入隔离沙盒。WASD/方向键移动、自动攻击；1/2/3升级，Esc暂停，C查看腐化。失焦暂停，回焦只释放focus。

```powershell
./tools/run_validation.ps1 -M4 -DummyAudio
```

自然九局须从冻结原版完整补录，不用DEV；五人理解／辨识、物理DEV仍待真人。性能p95未达标；003不能代填旧版结果。Dummy仅诊断。[完整运行指南](../specs/002-combat-pacing-audio/quickstart.md) · [任务](../specs/002-combat-pacing-audio/tasks.md) · [开发记录](development.md) · [历史Q1](validation/quality-20261018.md)
