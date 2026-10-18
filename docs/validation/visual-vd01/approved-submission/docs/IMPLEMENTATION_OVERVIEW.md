# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [当前证据与限制](validation/convergence-2026-10-15.md) · [M4 gate](validation/m4-gate.md)

Godot 4.5 离线单人原型。走位自动战斗、拾取升级，局外成长、转职、同伴与招募，再以腐化契约挑战海岸首领。M1–M4 已接线；原生成长/战斗/事务和受控图形通过，人工体验与性能仍未验收。美术为原创程序占位，正式精灵表和独立立绘未实现。

| 里程碑 | 已实现并验证 | 待人工验收 |
| --- | --- | --- |
| M1 Combat | 三类攻击、12 升级、五敌人、首领与重试 | 易用性、乐趣、普通时长 |
| M2 Progression | 等级1–30、6分支、双同伴、可靠保存 | 完整自然操作流程 |
| M3 Recruitment | Sera救援、票券招募、代币兑换、历史 | 完整离线手动会话 |
| M4 Abyss | 腐化、三类事件、契约、章节保存 | 契约理解、辨识、性能 |

**What's New · 2026-10-16**：[VD-01-M1离线预览](visual-design/preview.html)已交付审计、规范与八件原创像素概念；可切战况/灰阶/倍率、试选升级、对照历史实机。29概念动画格、51张倍率/边缘板、13个动作示意。[素材缺口](visual-design/ASSET_INVENTORY.md) · [检查记录](validation/visual-vd01/phase-3.md)。G0/G1、参考替代及边缘/容量/镜像[待批准](visual-design/APPROVALS.md)；生产清稿/原生集成未实现，Godot未改。

**历史玩法验证**：13组原生测试、5,239断言、源码/EXE受控图形、F9发布禁用与多进程锁通过，见上方当前证据。本轮只做样稿文件与离线浏览器检查。

**部分完成**：历史release三seed p95为27.571/27.670/29.259 ms，均超预算。**待人工验收**：参考机、显示延迟、十人体验、普通胜利和完整手动流程；不能判定完全收敛。

## 启动与测试

双击 `builds/windows/m4/AbyssExpedition.exe`。公会选 Expedition；WASD/方向键移动，自动攻击；1/2/3选升级，Esc暂停，C看腐化。9:00首领，击败才胜利。Roster调整成长/同伴；Recruit招募。开发源码战斗中F9进入隔离沙盒，发布版禁用。

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
./tools/run_validation.ps1 -M4 -Graphical -Export
```

验证遇本机音频设备错误时可用 `-DummyAudio` 诊断，不能代替真实音频验收。

[Quickstart](../specs/001-abyss-expedition-mvp/quickstart.md) · [调试操作](developer-debug-panel.md) · [开发记录](development.md) · [Spec](../specs/001-abyss-expedition-mvp/spec.md) · [Plan](../specs/001-abyss-expedition-mvp/plan.md) · [Tasks](../specs/001-abyss-expedition-mvp/tasks.md)
