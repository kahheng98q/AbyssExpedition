# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [Q1实机前后与验证](validation/quality-20261018.md) · [M4 gate](validation/m4-gate.md)

Godot 4.5离线单人原型。走位自动战斗、拾取升级，局外成长、转职、同伴与招募，再以腐化契约挑战海岸首领。M1–M4已接线；人工体验与性能验收仍开放。

**What's New · 2026-10-18**：重做扫斩、命中/击杀反馈、职业姿态、首领与海岸遗迹；HUD分区显示生命、成长、倒计时和腐化。实机复查修复首版文字遮挡。仍为原创程序像素美术，已有性能用敌人图集，手工角色动画与音效仍待完善。

**DEV保护修复 · 2026-10-18**：[原有面板](developer-debug-panel.md)保留；角落DEV/F9跨界面、暂停、重开可用，启动器改跑当前源码，常规验证强制回归。原生126项、源码及实际Debug图形各118项、实际Release禁用41项通过；物理键鼠烟测待人工验收。[证据](validation/debug-protected-20261018.md)。

| 范围 | 已实现并验证 | 待人工验收 |
| --- | --- | --- |
| M1 Combat / Q1 | 三攻击、12升级、命中反馈、新HUD | 打击感、辨识、长局疲劳 |
| M2 Progression | 等级1–30、6分支、双同伴、保存 | 自然操作流程 |
| M3 Recruitment | 救援、票券招募、代币兑换、历史 | 完整手动会话 |
| M4 Abyss | 腐化、三事件、契约、章节 | 契约理解、性能 |

**验证**：14组5,249原生断言全过；源码和新EXE三尺寸受控图形通过，开发F9及发布禁用通过。三角色固定输入前后状态相同，存档/数值未改。自动通过不代表已证明好玩；参考机、显示延迟、十人体验和二十次普通胜利仍待完成。Q1最终单seed压力p95为13.768ms，达到该样本预算；三seed/参考机验收仍开放，历史失败保留。

## 启动与测试

双击发布版 `builds/windows/quality-20261018/AbyssExpedition.exe`。开发测试双击根目录 `Play Debug.cmd`，用DEV/F9开隔离沙盒；发布版禁用。公会选 Expedition；WASD/方向键移动，自动攻击；1/2/3升级，Esc暂停，C看腐化。Roster调转职/同伴；Recruit招募。

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
./tools/run_validation.ps1 -M4 -DummyAudio
./tools/validate_quality.ps1
```

第二条为功能回归；第三条保存Q1截图、检查三尺寸并单独导出。Dummy audio诊断不能替代音频验收。

[Quickstart](../specs/001-abyss-expedition-mvp/quickstart.md) · [开发记录](development.md) · [Spec](../specs/001-abyss-expedition-mvp/spec.md) · [Plan](../specs/001-abyss-expedition-mvp/plan.md) · [Tasks](../specs/001-abyss-expedition-mvp/tasks.md)
