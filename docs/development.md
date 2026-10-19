# Milestone 1 development

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
