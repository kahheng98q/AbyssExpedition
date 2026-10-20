# First 2 Minutes Combat Pacing & Audio Polish

2026-10-18 · **提案，未实现／未验收**。依据 [Q1 报告](../validation/quality-20261018.md)及相关代码静态检查；本轮未运行游戏或试听。时间均为进入战场后的主动时间，暂停不计入。

## Current Problems

1. **首波已出现，首次接敌仍无保证。** tick 0 已排入 4 个敌人，预警 0.75 秒后在场边生成；主角从中央出发，近战射程仅 48。需要检验的是走到攻击范围的空档，而非取消一个不存在的开场倒计时。
2. **前两分钟行为单一。** 基础配置每 10 秒生成 4 个 Thrall；Brinejaw 冲刺、Cantor 远程分别到 120、240 秒才引入。HUD 的 EVENT 倒计时不能替代即时遭遇变化。Q1 的受控截图测试不能证明自然开局有趣。
3. **视觉反馈已有，听觉链路缺位。** 已有真实命中／致死事件与升级选项事件；所检查的运行脚本、场景未见音频播放接线。Q1 使用 Dummy audio，未新增音效或验收听感。

## Proposed Improvements

参考研究（开发者官方页面，2026-10-18 查阅；下列应用是本项目设计推论，并非竞品开局秒表或听感实测）：

| 参考 | 可核实的设计 | 本轮借鉴 |
| --- | --- | --- |
| [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) | 极简操作；官方入门提示强调拾取宝石、集中升级武器 | 尽早完成“接敌→击杀→拾取→升级”的可理解闭环 |
| [Brotato](https://store.steampowered.com/app/1942280/Brotato/) | 默认自动开火；20–90 秒短波次，波间用材料成长 | 给连续战斗安排短压力段与回收段；本轮不引入商店或波间切屏 |

**① 开局接敌与首次成长（最高优先）。** 首波仍为 4 个 Thrall，改为有预警的近场安全落点候选，优先距离初始主角 128–160 的可走位置；保留对所有队员 ≥96 的安全距离、45 tick 预警、激活复检与失败跳过。只调整首波位置，不加敌人、不改攻击输入；用自然击杀与拾取争取 30 秒内第一次升级，先不改全局 XP 公式。

**② 用现有行为编排两分钟。** 保留每 10 秒 4 个名额；特殊敌人替换 Thrall 名额，不叠加刷怪，也不依玩家强弱调难度。初版编排如下，未列波次仍为 Thrall：

| 主动时间 | 编排 | 玩家需要做什么 |
| --- | --- | --- |
| 0–29 秒 | 追击敌人，完成首次成长 | 接近、自动攻击、拾取 |
| 30／40／50 秒波次 | 每波 1 个 Brinejaw | 看冲刺预警，横移后反打 |
| 60／70／80 秒波次 | 每波 1 个 Cantor | 躲射线、调整接近路线 |
| 90／100 秒波次 | 回到纯 Thrall | 减少新增特殊威胁，回收宝石；不清除存活敌人 |
| 110 秒波次 | 各 1 个 Brinejaw、Cantor | 组合运用刚学会的走位 |

基础总量仍为 `[0,120)` 内 48 个计划名额；腐化修正照常。保持 120 秒事件、后续主阶段和 9 分钟首领时点；复查 120 秒衔接，不能靠堆血量制造高潮。全程沿用自动索敌与既有预警，不加手动攻击键或强制教程弹窗。

**③ 原创、分层、有限并发的战斗音效。** 制作剑扫／弓弦／法术三种攻击音色，配短促命中、较重击杀、独立升级短句。攻击音在实际发动时触发；命中／击杀消费已接受伤害事件，致死音替代该次普通命中；升级音在每次升级选项首次展示时播放一次。优先级为升级／玩家受伤＞击杀＞命中＞攻击，同伴声更轻；同类短窗合并、初始并发上限 8，拥挤时优先丢弃低优先级声音。表现层不得消耗玩法随机流；暂停不积压战斗声音，离场释放。只借鉴设计原则，所有音频原创，不采样竞品素材。

## Expected Player Experience

前几秒听见并看见有效攻击；30 秒内理解击杀、拾取与成长。随后依次经历躲冲刺、接近射手、回收奖励和混合小考验。玩家仍主要做走位与升级选择，敌人变多之前，先出现不同的行动理由。

## Acceptance Criteria

以下为**拟定验收目标，全部待验证**：

- **开局：** 独立测试档、永久等级 1、无同伴、初始腐化 0；剑／弓／法三角色 × seeds 101／202／303，共 9 局。正常进入战场，不用调试刷怪；主动接敌并拾取，记录输入。每局首个有效命中 ≤5 秒、首次击杀 ≤10 秒、首次升级选项 ≤30 秒；未达标先检查距离、击杀与拾取轨迹，不用额外刷怪补救。
- **节奏：** trace 验证上述替换与 48 个基础名额；预警、安全复检、100 上限及无补刷保持有效。在安全位置有效的固定轨迹中，45 秒前遇到冲刺、75 秒前遇到远程射击；90–110 秒不新增特殊敌人。相同版本／seed／输入可重放；暂停不推进波次，队伍强度不改变计划压力。
- **听感：** 真实音频设备录制并试听三职业与密集战斗；空挥／拒绝伤害不响命中音，同次致死不重复叠音，升级每个 offer 仅响一次；暂停恢复／重开无补播或残留。测得并发 ≤8、无削波，升级不被战斗盖住。Dummy audio 仅可用于逻辑回归。
- **人工：** 5 位未接触本版的试玩者中至少 4 位在 30 秒内理解自动攻击，在两分钟后说出冲刺与射手各自的应对；对随机播放的攻击／命中／击杀／升级音样辨认正确率 ≥80%。记录无事可做的时段与听觉疲劳，不以自动化通过替代好玩验收。
- **回归：** 实现时用固定 Godot 4.5 执行 `./tools/run_validation.ps1 -M4 -Graphical -Export`，补充开局与音频事件测试。保留 App 单实例 DEV／F9、暂停操作、沙盒隔离和实际 release 拒绝。按 Q1 同机同负载对照音频开／关帧时，目标 p95≤16.67ms、p99≤25ms；不减少压测敌人数量。

## Relevant Files

| 用途 | 文件 |
| --- | --- |
| 依据与规范 | [Q1 报告](../validation/quality-20261018.md)、[spec.md](../../specs/001-abyss-expedition-mvp/spec.md)、[systems.md](../../specs/001-abyss-expedition-mvp/contracts/systems.md) |
| 首波与编排 | [coast_waves.tres](../../data/encounters/coast_waves.tres)、[wave_schedule.gd](../../scripts/data/wave_schedule.gd)、[spawn_director.gd](../../scripts/combat/spawn_director.gd)、[simulation_coordinator.gd](../../scripts/core/simulation_coordinator.gd) |
| 复用行为 | [brinejaw_behavior.gd](../../scripts/combat/brinejaw_behavior.gd)、[cantor_behavior.gd](../../scripts/combat/cantor_behavior.gd) |
| 音频事件接点 | [attack_executor.gd](../../scripts/combat/attack_executor.gd)、[damage_service.gd](../../scripts/combat/damage_service.gd)、[run_manager.gd](../../scripts/core/run_manager.gd)、[choice_coordinator.gd](../../scripts/core/choice_coordinator.gd)；拟新增独立音频表现服务与原创资源 |
| 成长与验证 | [run_progression.gd](../../scripts/progression/run_progression.gd)、[test_waves.gd](../../tests/unit/test_waves.gd)、[test_combat_feedback.gd](../../tests/unit/test_combat_feedback.gd)、[test_replay.gd](../../tests/integration/test_replay.gd)、[run_validation.ps1](../../tools/run_validation.ps1) |

实施前需将本切片纳入 Spec Kit：①近场首波与现有“仅场边”规则冲突，②提前引入敌人需同步修订 FR-004 默认表、系统合同、`WaveSchedule.validate()` 的五阶段硬编码及对应测试期望。保持其他阶段边界；本提案不等于已批准修改规范。本次仅新增本文，不改变代码、任务完成状态或既有验收证据。

2026-10-19：已按本轮 Spec Kit 调用形成 [功能规格草案](../../specs/002-combat-pacing-audio/spec.md)及[需求质量检查表](../../specs/002-combat-pacing-audio/checklists/requirements.md)，明确上述局部规则变更；尚未实施或执行游戏验收。
