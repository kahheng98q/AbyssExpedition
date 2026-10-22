# Milestone 1 development

## 003 任务分解 — 2026-10-21

已按[剑系转职设计](../specs/003-sword-promotion-identity/plan.md)生成[54项未执行任务](../specs/003-sword-promotion-identity/tasks.md)：Setup 4、Foundation 8、US1 11、US2 9、US3 12、最终验收10。包含自然九局硬门槛、改前版本冻结、固定玩法投影正负例、三故事独立测试、每阶段Godot／文档检查点及真实Debug／Release回归。后续按用户批准修订I1／U1／A1：逻辑注入时钟＋独立真实播放150／180秒预算、性能12窗分支与实际治疗／渲染守卫、灰度12段独立判分；54项编号和未执行状态保留。自然九局仍待人工验收，代码与美术未实施；002其他开放项及需求质量清单未改勾选。仅做文档静态校验，未运行游戏、导出、人工或性能测试。见[生成检查记录](validation/sword-promotion-identity/task-generation-20261021.md)、[分析修订记录](validation/sword-promotion-identity/analysis-remediation-20261021.md)。

## Phase 7实施 — 2026-10-20

恢复固定4.5元数据，补齐最终玩法快照/完整精度JSON、终结后计数和目标机/两轮设备性能守卫，增加负例并取得red/green；T065/T066/T074/T075已完成；16组9,232断言、源码/实际Debug/Release受控图形通过。新WASAPI录音8声部、削波0；当前Release真实性能开/关各30+120主动秒采集完成，开启p95 15.172ms/p99 19.647ms、max76.035ms。两轮逐帧focus均无失焦，电源方案一致；进程观察范围不含完整主机后台负载，T073保持部分完成。无真人自然轨迹、五人答案或物理烟测结果，相关项继续开放。逐项结果与实际命令见[实施证据](validation/combat-pacing-audio/phase7-20261020/results.md)。

## Game Polish 收敛核查 — 2026-10-20

活动002：核对12 FR/7 SC/13场景、64既有任务、14计划约束和8项宪法原则，发现11项partial（HIGH7/MEDIUM4），仅追加Phase7 T065–T075，原64任务字节前缀/spec/plan/应用源码均保留。新增重点：最终玩法快照遗漏状态、终结前计数、性能目标机/设备一致性守卫；续办自然九局/九对、试听、五人理解/盲听及物理DEV。

实际执行固定4.5的 `tools/run_validation.ps1 -M4 -Graphical -DummyAudio`：16组9,178断言，0失败/跳过；源码M1–M4三尺寸、音频/focus15、DEV118受控图形通过。当前源码摘要与昨日v4构建/录音/性能不同，`project.godot`含4.7元数据；Benchmark前置hash拒绝已实际验证。没有改配置、导出、录音、跑性能或代填人工结果。旧证据按原构建保留；后续由implement核对配置并重建/重测。见[完整发现与命令](validation/combat-pacing-audio/convergence-20261020/results.md)、[当前矩阵](validation/combat-pacing-audio/acceptance.md)。

## 002 首波可见性 — 2026-10-19

固定seed303复核发现一个首波预警被计时HUD部分遮挡。保留原候选/安全/RNG，仅把现有首波Telegraph放到远征的世界跟随CanvasLayer2，高于HUD、低于弹窗/DEV。新增层级与图像橙色中心检查；seed303截图已观察。旧性能与Release保留，最终构建重新验证，见[可见性修复](validation/combat-pacing-audio/final/visibility.md)。

## 002 音频与收口 — 2026-10-19

7原创PCM、8预建播放器、事实信号、升级FIFO、token冻结/离场清理与真实WASAPI回环工具已实现。完整M4/源码图形/实际Debug图形/Release拒绝通过；专门DEV导出也通过。旧图片写入失败已改为本轮独立目录并恢复历史图片。自然九局与九对未录制；五人试玩/盲听、物理DEV保持开放。当前Release目标机真实音频开关对照已完成，开启p95 13.453ms/p99 14.073ms；全程前后台未独立监督，不关闭历史参考机目标。见[US3结果](validation/combat-pacing-audio/us3/results.md)、[矩阵](validation/combat-pacing-audio/acceptance.md)、[最终检查](validation/combat-pacing-audio/final/results.md)。

## 002 近场/编排 — 2026-10-19

已实现安全近场首波、完整reservation生命周期和五段固定四槽/腐化额外Thrall；默认后段/存档/数值/DEV保留。US1/US2逻辑与受控图形通过，真实首波PNG已检查。九局真人记录缺操作者，SC001/002/005不判通过。音频下一阶段实施；工具Audio/Benchmark当前明确拒绝。见[US1](validation/combat-pacing-audio/us1/results.md)、[US2](validation/combat-pacing-audio/us2/results.md)。

## 002 基础层 — 2026-10-19

用户授权跳过未勾选评审清单门禁，清单保持只读。T001–T008完成：旧实现基线通过，建立范围/验收矩阵，新增暂停变更只读快照、App focus token与回放版本检查，默认pacing/combat_feedback回归。red与green均有真实日志；本次原生断言与限制见[证据](validation/combat-pacing-audio/foundation/results.md)。图形焦点、真实音频、自然九局、真人与性能仍待执行；保留旧构建/档案/DEV单例。


## Developer Debug Panel protection — 2026-10-18

原有面板由App长期持有，未发现被切场景删除。实际入口漂移：Play Debug.cmd仍指向10月15日旧构建，Q1默认EXE为禁用调试的Release。现改为固定引擎运行当前源码；原按钮改为常驻DEV，F9登记InputMap，挂载函数幂等。保留全部28动作、沙盒存档与暂停所有权，不改玩法。

常规验证强制debug_panel，Graphical覆盖点击/键盘/切换/暂停/重开；Export加入debug导出与真实release禁用探针。完整13组5,297原生断言通过；源码及实际新Debug图形各118项、新Release禁用41项通过。首次4551失败保留；重新导出的实际Debug/Release已成功运行。图形复跑发现M4/M1旧PNG覆盖失败，现M1–M4均独立输出证据目录。真人物理键鼠烟测待做。见[本轮证据](validation/debug-protected-20261018.md)与[使用/人工烟测](developer-debug-panel.md)。AGENTS已永久保护本功能。以下保留历史开发记录。

Current implemented scope: M1 combat, M2 progression/promotions/companions, M3 recruitment/gacha, M4 corruption/events/chapter, and developer tools. Human acceptance and reference-hardware targets remain open; M4 stress measurements miss the frame budgets. See [visual dashboard](game-development-dashboard.html), [Chinese overview](IMPLEMENTATION_OVERVIEW.md) and [M4 evidence](validation/m4-gate.md). The notes below are historical deliveries; statements that M3/M4 were absent describe those earlier checkpoints.

2026-10-15 full verification: corrected project.godot features metadata from 4.7 to the planned/pinned 4.5. Both baseline and post-fix `tools/run_validation.ps1 -M4 -Graphical -Export` completed successfully. Post-fix native coverage is 1,654 primary + 69 debug assertions, zero failures/skips. All 142 shipping/test scripts, 29 scenes and 51 Resources load. Source and actual release start headlessly; three-size source/release checks, current M4 prior-flow release regressions, F9 source/export/release restrictions and competing-writer/crash recovery pass. Content digest and starter victory ticks are unchanged. See [full commands, raw logs, new stress captures and unexecuted checks](validation/verification-2026-10-15.md). No gameplay logic/balance or acceptance checkboxes changed; ordinary human/reference-machine/latency gates remain open.

2026-10-15 implementation continuation: the user authorized proceeding despite the unchecked gameplay checklist. Revalidation passed 633 native assertions, source graphical checks at all three required sizes, and Windows competing-writer/crash-recovery probes. No new gameplay implementation was started because T115 remains open. Retained M1/M2 executable hashes match the original deliveries. See [current evidence and remaining prerequisites](validation/2026-10-15-implement.md) and the updated [run guide](../specs/001-abyss-expedition-mvp/quickstart.md).

2026-10-14: prerequisite resolver located specs/001-abyss-expedition-mvp. All 16 requirements checklist items pass. No extensions.yml or AGENTS.md exists. Workspace is not a Git repository.

Tool verification before configuration changes: connector reports 4.5.stable.official.876b29033; the installed Windows console at C:/Users/kahhe/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe actually reports 4.7.2.stable.official.ed1daf0bf. Obtaining a workspace-local 4.5 binary to preserve the design pin. Export template availability will be verified separately. Do not treat the connector's version as a verified local executable.

Acceptance evidence is in docs/validation. Human enjoyment, ordinary victory duration, reference-hardware performance and displayed input latency require separate measurement and remain unverified until performed.

## Verified toolchain and commands

`ABYSS_GODOT_EXE=C:/Users/kahhe/Desktop/Project/new-game-project/tools/godot-4.5/Godot_v4.5-stable_win64_console.exe`.
Official 4.5 release binary and matching export templates were downloaded into tools. Version/help were executed. Templates use explicit workspace-local paths in export_presets.cfg. The release has embedded PCK data; the optional .console.exe wrapper provides diagnostic stdout.

Use tools/run_validation.ps1 -Graphical -Export. This sets APPDATA only for its child Godot processes, avoiding sandbox cache/log writes to the user's real profile. First attempts without an explicit log path failed creating user://logs; one crashed. A later graphical attempt couldn't create a shader cache directory. Scoped writable runtime data and explicit logs resolved these tooling failures. No application profile service was added.

## Implemented slice and architectural choices

App owns the validated catalog, screens, modal host and exactly one expedition. Expedition owns ActorState/health, fixed active clock, pause tokens, seeded streams, simulation stages, damage registry, spawning, attacks, XP and choices. Actor definitions remain shared; effective stats are derived on independent runtime copies. Geometry-based hurt checks and swept projectiles use stable registered actors instead of asynchronous Area2D damage callbacks. Controller/health/status/attack responsibilities are small services rather than separate ticking scene components.

Physics movement stays continuous at 60 Hz. Damage batches precede outcomes; active-hero death beats boss death. XP suspends the coordinator at stage 3, so chained levels never repeat pickups or advance the world. Source snapshots preserve attacks after their source dies. Deferred routing also checks run generation. All later services/content directories remain absent.

Original placeholder art is procedural drawing code with documented asset entries, rather than bitmap sprite sheets or AnimationPlayer tracks. UI descriptions preview attack behavior; fully animated selection previews and polished animation sheets are not part of this prototype. The twelve upgrade Resources hold effects/caps/descriptions. AI warning/rush/distance constants are currently small controller defaults; more granular AI tuning Resources would improve designer iteration.

## Tuned numeric hypotheses

These replace only the data model's unspecified starting proposals; specification-fixed waves, XP, caps, upgrade amounts, immunity and boss arrival remain unchanged.

| Content | Current prototype values |
| --- | --- |
| Swordsman | HP 250, damage 36, frequency 1.2/s, movement 96, reach 48, arc 100° |
| Archer / Mage | HP 150, damage 36, frequency 1.2/s, movement 96, reach 160, shot speeds 240 / 180 |
| All starters | Defense 0, pickup 24, knockback 80; no M2 passives |
| Thrall | HP 35 / damage 3 / speed 30 |
| Brinejaw | HP 30 / damage 5 / speed 34; warned 45 ticks, committed speed 185 for 30 ticks, recovery 90 |
| Cantor | HP 30 / damage 3 / speed 28; warned 45 ticks, projectile 110, cooldown 180 |
| Husk | HP 70 / damage 5 / speed 22; incoming multiplier 0.65; knockback/slow resistant |
| Broodmother / broodling | HP 70 / 15; damage 4 / 2; speed 20 / 45; mother interval 360 ticks, child cap 3 |
| Hierophant | HP 1200; contact 20; cone radius 150 / angle 70° / windup 60; circle radius 48 / windup 75; both damage 24, recovery 150 |

Initial automated bots showed excessive attrition under the first tuning. The current values permit progression into the boss encounter. Accelerated runs are diagnostic; bot policy and physics scheduling affect results and are not the twenty human baseline victories.

## Validation honesty

The damage formula was checked against a parse-valid missing implementation: three assertions failed, then passed after implementation (red-combat.log). Other suites were built and executed as regression coverage; the requested full phase-by-phase red-first sequence was not followed. Checkpoint evidence was consolidated after integration rather than claiming a separate manual playtest at every historical phase. Human/reference-machine gates remain open, so M2 remains blocked.

Final validation: 314 native assertions pass, no failures/skips; content/import/parse, source and exported graphical checks, negative suite/seed checks and release export pass. Upgrade IDs are explicitly compared as Strings for lexicographic sorting, with an assertion covering the order. All starters win the final one-physics-frame-per-step automated seed-101 runs: Aren 9:22.57, Lia 9:13.43, Milo 9:11.33. The Windows release is retained at builds/windows/m1/AbyssExpedition.exe. See m1-gate.md for the hash, exact evidence and open acceptance tasks.

## Milestone 2 — 2026-10-14

The user explicitly authorized M2 after the implement checklist gate was reported. M1 manual/hardware gates remain open; M3/M4 remain unimplemented. The original M1 executable hash is unchanged.

Implemented versioned JSON profiles, exact payload hashes, atomic native lock acquisition, immutable generations with current/prior retention, same-candidate Retry, explicit recovery/incompatibility and saved selection/settlement/promotion. Runtime state is excluded from profiles. Passive/branch/party starting identity is recorded in immutable replay snapshots.

Permanent stats derive from promoted/base Resources and level; run upgrades derive from independent starting-stat copies. Six policy modules change arcs, piercing, ricochet, elemental impacts and finite zones. Each actor owns independent branch/passive activation counters. Three character-specific passives remain attached after promotion. Up to two followers have separate health/immunity, follow-only formation, safe recovery, half outgoing damage, full healing/defense, shared upgrades only while living, and participant rewards even when downed.

Roster/promotion/save-error UI is available before launch. A one-shot promotion UI command and stable operation ID prevent repeated spending. Results continuation waits for saved rewards and shows changed starting progression. Long promoted descriptions required widening/tightening selection layout; source/export graphical checks enforce logical viewport bounds.

Use tools/run_validation.ps1 -M2 -Graphical -Export, tools/check_m2_lock.ps1 and tools/run_m2_benchmarks.ps1. Final native totals and detailed evidence are in docs/validation/m2-gate.md. Three full benchmark captures on Ryzen 7 5800H/GTX 1650 miss the p95 target; measurements and limitations are in docs/benchmarks/m2.md. Manual phase gates and full ordinary release acceptance remain open.

## Developer Debug Panel — 2026-10-14

User-requested developer tooling is separate from the milestone roadmap. No M3/M4 work was added. The app mounts scenes/debug/debug_panel.tscn only under the native debug feature. A CanvasLayer with four scrollable tabs processes while paused and owns one pause token. DebugActionService reuses progression, promotion, actor factory, stat derivation, damage/death, warned spawning, party, profile validation and SaveCoordinator APIs; UI only emits commands and renders state.

First F9 clones the loaded profile into a unique user://tests/developer-* session and switches router writes/settlements to that writer. The normal writer remains unchanged. Ending the sandbox restores it. Temporary branch previews and party edits modify only current runtime state; there is no new respec or revival system. Profile commits precede live stat refresh. Keyboard focus stays within the debug overlay when deferred level-up modals are created, then returns on close.

No previous battle speed controller existed. A single debug controller adjusts time scale and physics rate together, retaining fixed 1/60 simulation steps. It restores prior settings on exit. Health invincibility and follower AI flags independently ignore debug overrides in release. Command entry points reject release invocation even with forged UI/service state.

Validation/run/export commands, source/export graphical sizes, actual-release denial evidence, limitations and full file list are in docs/developer-debug-panel.md and docs/validation/debug-panel.md. Existing M1/M2 exports are retained; new debug/release builds live in builds/windows/debug-panel/.

## Milestone 3 — 2026-10-15

The user explicitly activated M3 only. Earlier unchecked human/hardware acceptance remains open; checklist files were left untouched. M4 is absent. The guild now routes expedition, owned roster/party/promotion and earned-ticket recruitment/history. Exactly three starter owners preserve access to Swordsman, Archer and Mage without draws.

Added Sera's independent minute-four rescue and radius-96/1800-active-tick defense, plus Guiding Light, Brann/Bastion and Nyra/Far Sight. Rescue uses ChoiceCoordinator pause ownership and normal scheduled enemies; recruits remain next-run selections. Settlement grants the exact five-minute/victory/repeat-rescue ticket rewards, or first Sera on successful rescue followed by victory/defeat. Abandonment grants nothing.

Draws use Resources with equal integer weights, 1/10-ticket costs and sequential in-batch duplicate conversion. A separate saved RNG stream/index is never seeded by expeditions. Complete cost/outcomes/ownership/tokens/RNG/history/awaiting reveal commit before display; Retry reuses frozen bytes. Five-token exchange and reveal acknowledgment share the durable writer. Pure v1→v2 migration initializes zero recruitment balances and no extra heroes, preserves source generations and blocks on failure. JSON stores 64-bit seed/state as decimal strings.

New services are under scripts/collection/, Resources under data/gacha/ and data/events/, UI under scripts/ui/ and scenes/ui/, and migration in scripts/persistence/profile_migrations.gd. Native tests cover rescue/reward matrices, all six passives before/after promotion, statistical draws/batches, exact duplicate/exchange outcomes, migration and persistence interruptions. Procedural rescue/UI provenance is recorded in assets/provenance.md.

Latest evidence: 1139 main native assertions plus 69 debug regression assertions pass, with no failures/skips; all three source graphical harnesses pass. Statistical sampling uses 200,000 draws plus 8,192 ten-pull candidates. A first M3 export passed its release graphical harness. The final export succeeds but Windows Application Control blocks launch (4551), so final executable runtime and ordinary manual acceptance remain open. See docs/validation/m3-gate.md and m3-release-playtest.md for hashes, exact commands, logs and distinctions. Earlier M1/M2 exports are unchanged.


## Milestone 4 — 2026-10-15

The user explicitly activated only M4 and approved proceeding while reviewer-owned gameplay checks and earlier unmet human/hardware gates remain open. No checklist markers were modified; there are no extension hooks or AGENTS.md files. No Git checkout is present.

Implemented corruption and exact positive/negative thresholds, future-wave snapshots, stored gem XP/temporary coins, corrupted enemy variants and fully warned second boss eruption. Contracts offer damage/frequency against health/corruption costs; all deductions validate atomically and buffs survive later upgrades. Compact HUD and C summary expose the consequences.

Three seeded event kinds now occur at 2/4/6 minutes. The event_offers stream is independent. Unowned Sera remains guaranteed at minute four; owned Sera now follows the explicitly specified equal-third schedule instead of M3's always-minute-four offer. Each owned rescue opportunity can settle a repeat ticket. Level/event/manual/terminal ownership is preserved; held confirmation cannot spend a new event.

The Aetheran Coast has original procedural tidal shelves/cult stones, corrupted crests and a single-eyed tentacled Hierophant. Schema v3 adds chapters.coast; migrations preserve all v1/v2 progression, recruitment history and RNG/source generations. Chapter completion joins the atomic victory reward candidate, is displayed after commit, survives reopen, and never bypasses the next run's boss.

Use tools/run_validation.ps1 -M4 -Graphical -Export, tools/check_m2_lock.ps1 and tools/run_m4_benchmarks.ps1. All twelve primary suites plus debug regression and source/release graphical checks pass; all three seed-101 starters win with real contract choices in the simulated full-loop policy. Earlier no-contract Aren autoplayer lost against increased waves; choosing an available contract resolves that fixture without changing specified enemy/class balance. Ordinary human fun/duration/comprehension and reference hardware/latency remain open. Detailed results and final totals are in docs/validation/m4-gate.md.


## Documentation dashboard — 2026-10-15

Documentation-only audit added the offline visual dashboard and Simplified Chinese implementation overview. Current source/Resource/scene wiring was checked against the requirements, task gates and retained evidence. The pinned 4.5 engine reran content validation and all 13 native suites: 1,723 assertions, zero failures/skips. No gameplay source, data, scenes or task checkboxes changed. Browser policy blocked the local file preview; static links and script behavior are checked separately. See [documentation audit](validation/documentation-dashboard.md) for exact scope and limitations.


## Phase 14 convergence fixes — 2026-10-15

实施收敛审计新增的 T176–T191，保留原有 reviewer 检查表及人工/硬件 gate。当前实现、red/green 日志和最终验证边界记录于 [收敛修复报告](validation/convergence-2026-10-15.md)。引擎和既定玩法数值保持固定；腐化提前母体是落实原规格。旧 M4 构建与截图已另存，旧性能记录保留。


### Phase 14 validation — 2026-10-16

完成 T176–T179、T184–T189 与 T191，共11项；原26项及新增5项人工/硬件/性能验收保持开放。腐化提前母体、档案异常恢复、实际封顶XP、隔离测试、Resource校验/说明、边角阵位、输入回放和实战外观预览均有执行证据。大trace从永久receipt移除；首次救援Sera的回放条件提示已补。测得无敌期无效hit分配后加前置拒绝，保留45tick边界和Bastion规则。

最终单次13组5,239原生断言全过，145脚本/29场景/51Resource递归加载通过；源码和实际M4 EXE的M2/M3/M4三尺寸受控图形、F9开发97/发布20通过，多进程锁通过。先前4551失败保留为历史；当前EXE已实际启动。最终自动运行用Dummy audio隔离本机WASAPI设备错误，项目音频未改。

发布版三seed实际工作负载捕获有效，但p95为27.571/27.670/29.259ms，预算未达。参考机、显示反馈延迟、十人体验、二十次普通胜利、自然操作会话与阶段人工观察均未完成。最终报告、构建/采样hash、原始CSV和失败记录见[当前收敛修复报告](validation/convergence-2026-10-15.md)。未把通过数或任务勾选当作全MVP收敛。

## Q1 战斗品质 — 2026-10-18

用户授权在已有核心内自主打磨。新增只读hit_confirmed信号和独立CombatFeedback批量绘制：最多48条、36主动tick，实际扣血后触发，无敌不触发，不写游戏随机流。角色/首领、扫斩/弹体、海岸遗迹与分区HUD重新设计；伤害、波次、拾取、职业、保存格式和输入规则保持不变。第一次实机检查发现HP/XP文字与条重叠，已调整行位后复查。

14组5,249原生断言通过；源码M1–M4与新EXE的M2–M4三尺寸受控图形、开发F9 97项/发布禁用20项通过。固定seed101三角色725tick前后状态完全相同。使用Dummy audio，无真人乐趣/听感/显示延迟结论。独立构建为builds/windows/quality-20261018/AbyssExpedition.exe，旧M4保持保留。详见[前后截图、压力比较与全部限制](validation/quality-20261018.md)。

Q1性能复查发现首版静态地形导致大量绘制调用，已离线烘焙成两张原创贴图并按腐化混合，地形1341→2 calls。保留原绘图和烘焙工具；7帧缓存前后最大通道差1/255，记录了量化容差与首次严格比较失败。最终性能以Q1报告中的新构建采样为准。

Q1追加敌人图集缓存：在仅地形缓存仍未达到性能目标后，将7类敌人×8状态烘焙为同源图集，动态预警/血条保留。静止探针总调用降至723。图集后再次执行scene_smoke/content、反馈/debug原生及源码/实际EXE全部图形回归，结果通过；最终压力数据见报告。首版与仅地形缓存的EXE均独立保留，正式交付目录保持quality-20261018/。

Q1最终压力结果：同机seed101实际release，30秒预热＋120主动秒，11,745帧，p95=13.768ms/p99=14.345ms；工作负载与奖励守恒有效，该样本预算通过。旧M4对照15.224/23.155ms，未缓存首版39.482/56.845ms，仅地形缓存27.867/29.033ms均保留。不以单seed通过关闭T180或参考机/人体验gate。

## 002 任务生成 — 2026-10-19

文档工作：依据002 spec/plan、research、data-model、两份合同及quickstart生成[任务清单](../specs/002-combat-pacing-audio/tasks.md)。共64项，US1近场开局13项、US2遭遇编排12项、US3音效22项，共用基础/收口17项；均未勾选。MVP为Setup+Foundational+US1，后续按故事增量交付。每阶段包含固定4.5验证、DEV保护回归与规定文档同步；真人九局录制、真实音频、5人理解/盲听和新版Release压力验收独立记账。

本次只改任务与文档导航；未改游戏源码、Resource、场景或旧001任务状态，未运行Godot、录音、图形或性能测试。setup_tasks.py首次受Windows stdout cp1252编码限制失败，以PYTHONIOENCODING=utf-8重跑后成功识别002及任务模板。执行前后未发现.specify/extensions.yml，无before_tasks/after_tasks hooks可执行。文档检查范围及实际结果见[任务生成检查](validation/combat-pacing-audio/task-generation-20261019.md)；功能与SC001–007仍未验证。

### 002 分析修订 — 2026-10-19

用户确认后应用G1/I1/A1/I2的文档修订：SC004原20道盲听题中的5道攻击题增加职业评分，至少4人各自同时满足类别≥16/20、职业≥4/5且每职业至少1题正确；AttackCommitted统一source_id/weapon_mode及字段类型；CombatAudio唯一拥有升级去重/FIFO，VoiceAllocator维护声部与合并窗口；T038先注册音频suite并记录red，T047完成集成green。spec、plan、research、data-model、audio合同、quickstart、tasks及文档导航同步。64项任务编号与未勾选状态保留，评审清单标记未改。本轮仅改文档，功能未实现、游戏验收未执行；复核范围见[分析修订检查](validation/combat-pacing-audio/analysis-remediation-20261019.md)。

## 003 剑系转职规划 — 2026-10-21

仅文档：完成[实施计划](../specs/003-sword-promotion-identity/plan.md)、研究、数据模型、战斗表现／预览／验证三份契约及[验证指南](../specs/003-sword-promotion-identity/quickstart.md)。采用职业Resource驱动共享程序像素绘制、原治疗点实际差值事实、隔离静音示例；保留伤害时序、音频六字段、存档与DEV合同。功能未实现、未生成tasks；当前Git分支未切换。

FR-012当前版自然九局是实施前门槛，仍待满足；其他002自然／人工／完整环境项目继续独立开放。宪法八原则规划前后审查合规，无例外。扩展hooks执行前后均无extensions.yml。更新dashboard、overview、README入口并保留既有实施证据；静态检查10份文档、192个本地引用无缺失，21张dashboard图均有alt；未运行Godot／图形／导出／自然游玩／性能检查。

## 003 实施预检 T001 — 2026-10-21

用户确认越过未勾选需求质量清单后，完成[T001环境／版本核对](validation/sword-promotion-identity/baseline/environment.md)、[FR／SC验收矩阵](validation/sword-promotion-identity/acceptance.md)与ValidationSession空模板；54项仅T001完成，余53项未完成。固定Godot 4.5版本查询退出0，204个源码／资源文件的合并hash与002现有phase7构建manifest一致，Release／console文件hash也匹配；身份清单不等于T003冻结构建或重新通过历史回归。

递归证据检查只找到3份工具负例Record manifest，无协议与当前hash匹配的完整真人九局。[T002自然门槛](validation/sword-promotion-identity/baseline/natural-gate.md)未满足，按FR-012与任务依赖止于证据准备，没有实施T003之后的代码／美术／比较工具。未改游戏／Resource／场景／测试／引擎配置／旧构建或需求清单；未运行游戏suite、自然操作、图形、导出、录音、性能或物理DEV。同步图鉴／概览／README／plan／quickstart及实际任务状态；文档检查见[本轮记录](validation/sword-promotion-identity/preflight-20261021-v1/docs-check.json)。本轮前后未发现extensions.yml，无实施hooks可派发。002开放项继续独立保留。

## 003 实施顺序修订 — 2026-10-21

用户明确授权[自然九局延期验收、先同步规格与任务依赖并实施](validation/sword-promotion-identity/authorization-20261021.md)。FR-012及关联文档已同步；T002仍未勾选，不再阻止T003之后。先冻结当前未改动源码／构建，再跑旧行为回归和比较基础；不代填真人结果，不关闭002开放项。

### 003 Setup检查点 — 2026-10-21

[T003／T004](validation/sword-promotion-identity/baseline/results.md)：冻结原版204文件无变化；固定4.5完整M4 16组9,232断言、新Release实际调试拒绝与Debug导出通过，当前窄测7组879通过。未跑Graphical／自然操作／性能，T002延期未验。进入Foundation前保留完整manifest／日志。

### 003 Foundation阶段进展 — 2026-10-21

[证据](validation/sword-promotion-identity/foundation/results.md)：51工具检查0失败、54组基线完整状态及自比较0差异、7组891原生断言通过；外部测试副本不改冻结玩法。首轮性能捕获因守卫无效，保留失败并诊断；新剑系表现尚未实施。自然九局继续延期待验。

### 003 Foundation收口 — 2026-10-21

[实际证据](validation/sword-promotion-identity/foundation/results.md)：52工具检查通过，7组891断言、改前真实图形及Release压力有效。首两轮因误拾取2枚掉落物使原守卫失败；仅调整测试布局并冻结前后共同偏移，第三轮奖励／12窗／原总负载有效，p95 13.593／p99 15.618ms。保留失败，改后／完整主机环境与真人验收仍开放；开始US1测试先行。

### 003 US1实装 — 2026-10-21

[阶段证据](validation/sword-promotion-identity/us1/results.md)：Resource驱动single／dual／long，共享纯绘制与真实弧元数据；原攻击／治疗／音频／保存不变。行为red后逻辑、剑系542受控图形及原DEV检查通过，固定完整初始档的54组前后状态0差异。初版比较正确拒绝了起始抽卡RNG差异，已固定夹具并完整重采，失败保留；未排除该字段。US2／US3未实现，真人辨识、物理DEV和改后性能未验。

### 003 US2实装 — 2026-10-21

[证据](validation/sword-promotion-identity/us2/results.md)：原heal前后实际差值只读事实，独立最多3条／36主动tick提示，1位小数误差≤0.05，满血消费原键且无成功提示。Red后6组1,096断言、扩展640图形（含真实升级／事件／重开）及54组跨版0差异通过；原48伤害记录、音频事实、治疗／计数不变。US3待实施，人工／改后性能保持未验。

### 003 US3逻辑／布局 — 2026-10-21

[结果](validation/sword-promotion-identity/us3/results.md)：两独立Session、共享绘制、单调时钟与焦点／遮盖／退出清理已接线。8组1674断言、676快速图形通过；真实播放独立150／180秒探针正在执行，保持原suite时限。原资格／保存失败Retry、非剑系和单例DEV保留，人工／改后性能未验。

### 003 自动收口与主机阻塞 — 2026-10-21

完整M4原生16组9917断言、源码M1–M4／DEV／音频／剑系图形及四组合生产时钟十轮通过。完整导出命令在新Release实际启动CreateProcess4551处退出1；同版复测／另一目录重导出仍失败，原始失败保留，未改系统安全策略。新Debug原DEV118／剑系676实际图形通过，四组合真实时钟通过。候选Benchmark在严格manifest守卫前置拒绝，未采新帧时，T047／T049保持开放。真人九局T002／五人T050–051／物理T052仍待验。

[材料v2](validation/sword-promotion-identity/human/prepared-20261021-v2/README.md)：18段原始／无名彩色、12段灰度、10密集图，3250hash、每人固定随机题序、无答案首答页；0名真人回答。早期工具SceneTree继承解析原生崩溃记录及自包含修复保留，v2真实连续tick材料捕获通过。


## 003 Phase 7 · 2026-10-21

收敛T062先修复文档门禁：允许追加Convergence，保护原54项描述和ID顺序；10项正负例通过（旧逻辑3失败），详见[本轮证据](validation/sword-promotion-identity/convergence-20261021-v1/results.md)。T055流程覆盖继续实施，Release／性能／自然九局／五人辨识／物理DEV保持开放。评审清单只读，沿用此前继续实施授权；无新增依赖或游戏规则修改。

T055补充夹具已通过10项非空守卫测试；候选v2 Capture取得54战斗＋6流程，均实际出牌／事件／结算一次并回读40XP。对照尚待冻结基线与变体完成；原投影白名单、54组矩阵及生产玩法源码未改。标准隔离窄测integration_m2／replay／DEV共307断言通过；直接check-only的引擎signal11失败保留，未冒作通过。

T055完成：三组各60样本零差异；12流程守卫测试、54工具检查、26投影检查通过，原白名单不扩大。T056本轮新Release实际启动及拒绝探针通过，正在完成导出图形／真实时钟；此前4551历史保留，未改安全策略，不将原因推断为已修复系统问题。

T047／T056补验完成：全M4图形导出命令退出0，16组9917断言，Release实际41禁调试／655剑系图形、Debug118／676、源码4＋Debug4＋Release1真实十轮全通过。新构建convergence-release-20261021-v1；生产文件hash未变，旧4551和首次独立解析signal11保留。候选Benchmark正在实际采样，未提前记帧时结论。

T049／T057候选Release实际采样有效但失败预算：30＋120主动秒／8016帧，12窗四类真实攻击／治疗／渲染及完整负载通过，p95=16.732ms>16.67、p99=17.927ms≤25。保留首次样本，不重跑挑成功值；未定位瓶颈，按非并行失败规则停止后续实现。CIM权限不足，Godot实测5800H／GTX1650／NVIDIA546.30、WASAPI48k及有限后台观测如实记录。T055／T056／T062及原T047完成，52／62任务行完成；性能和四类真人验收仍开放。
