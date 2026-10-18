# Visual slice validation quickstart

当前工作流（2026-10-18）：Autonomous Implementation with Continuous Documentation。自动连续执行已授权任务、测试修复、逐阶段同步文档；人工/设备不可用则记录pending并继续无关工作；reviewer清单只读。仅真实阻塞、高风险行动或平台权限需介入。本次仅配置/文档；以下旧规划的“待制作”状态以[最新执行证据](../../docs/validation/visual-vd01/completion-r1.md)为准，不是重新开工或审批要求。


**本轮仅规划；下列Godot命令没有在本轮执行。** 本文用于获批实施，不代表新版美术已经可玩。当前游戏仍使用程序占位。

## Prerequisites and launch

在项目根PowerShell运行；固定tools/godot-4.5/的4.5.stable.official.876b29033，Windows export templates匹配export_presets.cfg。按[AGENTS.md](../../AGENTS.md)和宪章v1.1.0，在已授权八件范围内按技术依赖自主推进，无任务/阶段/视觉例行签批；每阶段自动测试修复并同步文档。视觉校验使用tests独立profile；手动验证先建立明确隔离测试profile，不能改真实永久档。

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
```

公会→Expedition→Aren；WASD/方向键移动，自动攻击，1/2/3升级、Esc暂停、C腐化。魔法另选Milo或现有效果fixture演示；不可给Aren新魔法。F9仅开发沙盒；发布版不得出现。查看设计可直接打开 `docs/visual-design/preview.html`，无需服务器。

## Existing executable checks

以下脚本/参数已读源码确认存在。先窄检查、集成结束再全量，不重复运行无关检查。每次选新证据目录，不覆盖旧结果。

```powershell
# 角色/效果/场景阶段：脚本同时做engine pin、import、parse、content、负输入检查。
./tools/run_validation.ps1 -M4 -OnlySuites @('unit','scene_smoke','replay','abilities','integration_m1') -EvidenceDirectory 'docs/validation/visual-vd01-i2'

# UI/最终候选：包括progression/persistence/recruitment/M2/M3/M4。
./tools/run_validation.ps1 -M4 -Graphical -Export -EvidenceDirectory 'docs/validation/visual-vd01-g2'
./tools/run_debug_validation.ps1 -SkipRegression
./tools/run_m4_release_regressions.ps1 -EvidenceDirectory 'docs/validation/visual-vd01-release'

# 先before、后after，各使用对应构建；必须顺序独占图形运行。
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory 'docs/validation/visual-vd01-before-perf'
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory 'docs/validation/visual-vd01-after-perf'
```

重要：EvidenceDirectory不重定向所有截图；当前图形/debug/release脚本还写固定screenshots文件名，debug脚本也写固定日志。**执行前归档受影响旧截图/日志到独立revision目录，并记录hash；实施阶段为视觉专用harness增加revision输出目录后再采新图。** 不能直接用命令覆盖历史图。此输出隔离是未来验证任务，不是在本轮更改工具。before/after不能对同一最终构建跑两次冒充差异。

通过条件：进程预期退出、无SCRIPT ERROR/ERROR、真实suite断言全通过，所有新Resource/场景可加载。scene integrity还需检查无孤立UID/丢纹理、Presentation确实挂AnimatedSprite2D、Theme实际赋给HUD、旧角色fallback有效、Field墙未丢。现有测试并不覆盖全部新视觉，不能仅靠旧scene_smoke判完整接线。

## Future focused tests (not yet implemented)

- 数据合同：sheet region合法、帧最低数/唯一格上限、anchor整数、缺SpriteFrames回退；Aren限定映射与Brann/晋升回退；Actor碰撞/field边界不变。
- 状态测试：hurt/attack/death中断、pause/倍速、普通敌24tick删除、Brinejaw45tick警示、基本与升级reach的准确边线/程序回退。视觉不改变hit列表/目标/伤害/cooldown/spawn order/projectile path。
- UI输入：1/2/3、click、arrows+Enter、首焦点、held/repeat/fresh-input、升级队列、Esc拒绝跳过、manual与event暂停叠加；不让卡片直接发奖励。长文本/大HP/XP/六owned/十条draw/长save path/disabled理由复核。
- 改组件后harness定位可能改变，保留原断言语义；所有保存失败/恢复/招募/晋升/F9隔离回归仍有效。

## Matched graphical evidence protocol

G1样稿与G2实机分目录。主视觉seed101；固定saved run-start snapshot、输入/choice sequence、模拟tick、camera、party/progression、enemy placement/state、corruption、renderer/effect settings；记录before/after build和content hash。外观Resource改变digest是预期版本变化，不关闭replay版本保护；在各自构建重放相同测试输入，比较规范化玩法观测。

| Capture matrix | Required evidence |
| --- | --- |
| Native/world scale | 640×360原始viewport PNG；另拍真实source/release窗口1280×720、1920×1080、1371×779（包括黑边），不能把native图放大当窗口证据 |
| Combat | 正常/密集、两敌、主角与同伴、腐化0/100、boss重叠警示；截图对应确切tick |
| Combined HUD | boss+两同伴（含倒地）+rescue active+100腐化；再拍success/failed/declined，测所有UI矩形union≤25% |
| Motion | 上下左右移动/攻击、idle/move/attack-warning/hurt/death、flip/atlas边缘、camera移动；clip检查shimmer与时序 |
| UI | 升级三卡/焦点/长效果、queued fresh input、pause seed/腐化详情、所有受Theme影响screen关键状态 |
| Readability | 黑剪影/灰阶、painted/unlit对比；ownership、危险和可走区域在高腐化仍清楚 |

现有graphical harness是起点，尚未提供本合同完整矩阵，需在后续实施阶段扩展。图形可运行时必须产生并人工查看**实际游戏**source/release截图和片段；不能只跑headless。不可用时记录错误/缺失环境及待验项，G2保持未验证，不能以HTML代替。

对齐成对图做overlay/diff；登记expected change regions（单位、神殿、两UI、批准特效），逐处审查变化；要求0未审查区域、0丢关键cue、0意外几何变化、0关键UI裁剪。新画面不要求与旧图像素全等。候选baseline须记录版本/证据/预期变化与理由，与实际owner接受的参考分开保留；无需例行签批，禁止重设失败基线掩盖问题。

## Performance and human acceptance

负载不变：100普通敌、1boss、2同伴、≥30攻击效果、100运动弹体、500宝石、腐化100；seeds101/202/303，各30**active**秒warm-up+120**active**秒capture，独占图形。正式reference：Win11/i5-8400/GTX1050Ti4GB/16GB/SSD，1920×1080/60Hz Compatibility release，uncapped/VSync off测工作量；另用正常显示状态测端到端延迟。不要用Smoke短采样做验收。

保存raw CSV/JSON、实际计数范围、采样时长、p50/p95/p99/max、CPU/physics/render timing、draw calls、node/texture memory、PID匹配OS内存、机器/驱动/电源/窗口与VSync观察。若工具未提供细分数据，补Profiler采集或明确缺失；不编数字。每seed都须p95≤16.67ms、p99≤25ms，不能三seed平均掩盖失败。before/after差值用于定位，不是绝对预算替代。

历史最新release p95 **27.571/27.670/29.259ms** 已超标，见[既有报告](../../docs/validation/convergence-2026-10-15.md)。这不是本轮结果；不得用“无回归”替代性能接受。失败时先减少本批可选装饰；进一步玩法优化/放宽目标不在当前范围；失败保持失败并继续无关范围内任务，G3不自动授权。

显示输入/命中≤100ms：用高帧率视频或合适测量设备记录物理输入/命中事件到可见反馈，披露采样误差；无设备则pending，不能以模拟tick或FPS推断。十人review：每个normal/dense/max-corruption、2×/3×的2秒片段至少8人正确识别hero/两敌/剑向/友方法术/危险；逐条件记录。UI五秒任务至少8/10定位HP、区分Hero Lv/Run Lv、指出focused upgrade；promotion成本/永久性在后续G3同样验收。准确成本/保存状态零遗漏。自动测试不证明美术质量或乐趣。

只读比对[reviewer视觉清单](checklists/visual-acceptance.md)，不改文件/markers；发现与待验项另写docs/validation，实际决定写[APPROVALS](../../docs/visual-design/APPROVALS.md)，实际命令/结果写docs/validation，文档更新与每阶段实施同时完成。

## R1 verification contracts — future, unexecuted

- test_visual_contract.gd → unit; test_visual_ui.gd → scene_smoke; test_visual_slice.gd → integration_m1. Existing -OnlySuites includes them; logs must identify actual fixture execution.
- actor_overrides.tres maps hero aren+swordsman / enemy saltbound_thrall / enemy skittering_brinejaw to expected SpriteFrames. Normal missing-resource failure and injected fallback success are separate.
- Timing uses attack_until−12 / valid dead_at or lethal-receive hurt_until−8 / warning deadline−45; single-pose hurt lasts only until actual hurt_until; test late observation, skipped expiry and attack→hurt→same-attack continuation.
- Old background/new subtree are mutually exclusive with full fallback and unchanged walls; inspect final Z and warning visibility.
- P01: area and edge/corner occlusion separately checked against approved plates. Upper-body cropping remains a candidate; no camera/physics fix authorized.
- P03: original/mirror comparisons and budgeted mark correction; world upper-left light, actor shading follows the versioned P03 record; no routine approval stop.

### Supplemental P02 workload

Inherited M4 harness unchanged: reach16 filler arcs and non-homing filler shots cannot establish new-sprite coverage. After G1 freezes P02, T032 creates proposed tests/performance/visual_slice_stress.gd and tools/run_visual_stress.ps1 with before/after build inputs and isolated outputs. The fixture/runner now exist; actual executions are recorded in the latest completion report. This configuration update ran neither command.

Candidate only:30 new reach48/angle100 arcs and100 new friendly basic homing stars, retaining100 ordinary enemies/1boss/2companions/500gems/corruption100. G1 freezes counts/selectors/replenishment; use actual effect lifetimes, not extended gameplay lifetimes, and do not give Aren magic. This capacity probe is not a normal gameplay promise. Before mode runs the same stimuli on original visuals; after mode requires new-path populations. Record requested/observed total/new/fallback counts and ranges; fillers cannot satisfy new-path checks.

Measure separately with identical reference hardware/renderer/window/three seeds/30+120 active seconds and p95≤16.67ms/p99≤25ms. Pair retained before/final builds, keep original M4 raw data separate. Missing reference evidence remains pending; versioned P02 decisions do not require routine sign-off; failed population or budget checks remain failed, not accepted.

### Recognition protocol

T013 creates recognition-protocol.json before T022 clips; T030 records the versioned G1 protocol without a routine approval stop. Freeze total/visible actor/effect counts, both enemy identities, positions/distribution/overlap, camera/corruption, sizes and cardinal answer keys. Normal/dense populations must explicitly differ and represent the intended workload. Keep mockup fixture and runtime equivalent; do not select easier clips after failure.

Show two-second excerpts without coaching. Score hero, Thrall, Brinejaw, sword direction, friendly magic and danger individually per normal/dense/max-corruption×2×/3×, every cell≥8/10. Archive raw answers and protocol/clip hashes. Sample revisions require affected re-review. UI/promotion acceptance retains existing scoped G1/G2/G3 rules.
