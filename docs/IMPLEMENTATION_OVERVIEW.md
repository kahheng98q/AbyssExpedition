# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [当前证据与限制](validation/convergence-2026-10-15.md) · [M4 gate](validation/m4-gate.md)

Godot 4.5 离线单人原型。走位自动战斗、拾取升级，局外成长、转职、同伴与招募，再以腐化契约挑战海岸首领。M1–M4 已接线；原生成长/战斗/事务和受控图形通过，人工体验与性能仍未验收。美术为原创程序占位，正式精灵表和独立立绘未实现。

| 里程碑 | 已实现并验证 | 待人工验收 |
| --- | --- | --- |
| M1 Combat | 三类攻击、12 升级、五敌人、首领与重试 | 易用性、乐趣、普通时长 |
| M2 Progression | 等级1–30、6分支、双同伴、可靠保存 | 完整自然操作流程 |
| M3 Recruitment | Sera救援、票券招募、代币兑换、历史 | 完整离线手动会话 |
| M4 Abyss | 腐化、三类事件、契约、章节保存 | 契约理解、辨识、性能 |

**What's New · 2026-10-16**：修复早期母体、异常档案恢复、封顶经验、边角阵位；补配置预览、实际输入回放及转职外观。长 trace 不写入永久结算；首次救援后提示回放条件变化。无敌期无效 hit 不再分配记录。

**已实现并验证**：13组原生测试、5,239断言全通过；源码及实际Windows EXE三尺寸受控图形、F9发布禁用、多进程锁通过。角色与分支详见图鉴，数据来自实际 Resource。

**部分完成**：性能工具已补齐；当前release三seed p95为27.571/27.670/29.259 ms，均超预算。**待人工验收**：参考机、显示延迟、十人体验、二十次普通胜利和完整手动流程。本轮11任务完成，5项继续开放，不能判定完全收敛。

## 启动与测试

双击 `builds/windows/m4/AbyssExpedition.exe`。公会选 Expedition；WASD/方向键移动，自动攻击；1/2/3选升级，Esc暂停，C看腐化。9:00首领，击败才胜利。Roster调整成长/同伴；Recruit招募。开发源码战斗中F9进入隔离沙盒，发布版禁用。

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
./tools/run_validation.ps1 -M4 -Graphical -Export
```

验证遇本机音频设备错误时可用 `-DummyAudio` 诊断，不能代替真实音频验收。

[Quickstart](../specs/001-abyss-expedition-mvp/quickstart.md) · [调试操作](developer-debug-panel.md) · [开发记录](development.md) · [Spec](../specs/001-abyss-expedition-mvp/spec.md) · [Plan](../specs/001-abyss-expedition-mvp/plan.md) · [Tasks](../specs/001-abyss-expedition-mvp/tasks.md)
