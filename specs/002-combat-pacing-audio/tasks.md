# Tasks: First 2 Minutes Combat Pacing & Audio Polish

**Input**: [plan.md](plan.md)、[spec.md](spec.md)、[research.md](research.md)、[data-model.md](data-model.md)、[pacing contract](contracts/pacing.md)、[audio contract](contracts/audio.md)、[quickstart.md](quickstart.md)。
**Governance**: [constitution](../../.specify/memory/constitution.md) v1.0.0、[AGENTS.md](../../AGENTS.md)。
**Generated**: 2026-10-19。实施已启动，完成状态见逐项checkbox与独立证据。SC001–007尚未验收；既有001任务/历史通过记录不作为002通过证据。

**分析修订 · 2026-10-19**：已应用G1/I1/A1/I2的文档修订：双层盲听判分、统一AttackCommitted字段、声音状态唯一所有者、T038先注册测试并记录red。64项编号与未勾选状态保持不变；文档修订不表示实现或游戏验收完成。

**Tests**: spec明确要求逻辑、复放、图形、真实音频、人工及性能检查；宪法要求可行逻辑自动化。测试任务先于对应实现，先确认预期失败（red），再实现至green。测试装载失败不能代替行为失败；新类型尚不存在时先用动态加载/失败断言。
**Organization**: Setup → Foundational → US1(P1) → US2(P2) → US3(P3) → Polish。每故事独立可验证；推荐按优先级增量交付。

## Format and path conventions

所有任务为 `- [ ] Tnnn [P?] [USn?] 描述与文件路径`。路径相对仓库根目录；新文件是待创建目标，不表示已存在。`[P]`只表示下文明确同批、不同文件且无彼此前置依赖的工作，不授权实际启动子代理。

固定Godot `tools/godot-4.5/Godot_v4.5-stable_win64_console.exe`（4.5.stable.official.876b29033），不安装新依赖，不运行历史 `tools/create_m1_content.ps1`。证据统一放 `docs/validation/combat-pacing-audio/<run-id>/`，构建放 `builds/windows/combat-pacing-audio/<run-id>/`；每次用新目录，保留失败及旧构建。以下命令中占位目录执行时必须替换。

## Phase 1: Setup — 当前基线与隔离环境

**Purpose**: 复用已存在工程，不重建项目、不修改玩法或真实档案。

- [X] T001 核对 `project.godot`、`export_presets.cfg`、`tools/run_validation.ps1` 的引擎/模板、现有构建保留规则及新证据路径；记录版本、实际分支/无Git状态、文件hash和设备可用性到 `docs/validation/combat-pacing-audio/baseline/environment.md`，不切分支或把旧EXE算作本版。
- [X] T002 使用 `tools/run_validation.ps1 -OnlySuites @('unit','integration_m1','replay','integration_m4','combat_feedback') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/baseline/regression` 执行旧实现基线，保留import/parse/content、强制debug_panel和参数拒绝结果；将失败/阻塞与Dummy限制写入 `docs/validation/combat-pacing-audio/baseline/results.md`，修复阻塞后再进入后续实现。
- [X] T003 在 `docs/validation/combat-pacing-audio/acceptance.md` 建立FR001–012/SC001–007证据矩阵和范围锁：不改伤害、经验门槛/奖励、敌人属性/行为、操作与存档schema v3；记录正常/测试/DEV隔离、人工/设备缺失处理及每阶段文档同步清单，初始全部未验证。

**Checkpoint**: 固定引擎基线有真实结果，隔离/保存路径明确；工具不可用记阻塞，不宣称通过。

## Phase 2: Foundational — 主动时间与可复验基础

**Purpose**: 三故事共用的暂停通知、独立focus所有权、trace协议和测试入口。不得把战斗模拟节点改为Always。

- [X] T004 在 `tests/integration/test_choice_pause.gd`、`tests/integration/test_m2_app.gd` 增加PauseCoordinator变更通知、只读快照、无效释放不通知、focus重复获取/仅释放自身token、开局已失焦/离场/重开用例；叠加manual/level/event/debug保持原优先级，先记录red。
- [X] T005 在 `scripts/core/pause_coordinator.gd` 增只读changed通知（成功acquire/release及实际cancel_all变更），在 `scripts/core/app_router.gd` 持有独立focus_token并处理焦点、mount/leave/重开；满足“音频由快照派生，不释放token”和“失焦只获取一次、重获焦点只释放该token”，保留原DEV/F9单例和所有暂停所有权。
- [X] T006 在 `tests/integration/test_replay.gd` 用构造记录测试版本/字段序列化、稳定生成编号、玩法快照相等及音频诊断排除规则（实际生成终结接线留给T014）；在 `scripts/core/replay_trace.gd` 定义增量trace格式并提高SIMULATION_VERSION，保留movement-changes编码与四个玩法RNG流，拒绝不匹配版本/hash，禁止用Node instance ID或播放墙钟做玩法记录。
- [X] T007 在 `tests/run_tests.gd`、`tools/run_validation.ps1` 注册非空 `pacing` suite及现有 `combat_feedback` 的默认完整回归（先复用现有波次/暂停/复放fixture，后续任务逐步扩展）；更新 `tests/script_manifest.gd`，保留OnlySuites也强制debug_panel及未知参数/seed拒绝，不提前引用尚不存在的audio fixture。
- [X] T008 用 `tools/run_validation.ps1 -OnlySuites @('pacing','integration_m2','replay','combat_feedback') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/foundation/regression` 验证基础设施；在 `docs/validation/combat-pacing-audio/foundation/results.md` 记录red/green和focus验证限制，同步 `docs/game-development-dashboard.html`、`docs/IMPLEMENTATION_OVERVIEW.md`、`README.md`、`docs/development.md` 与本文件实际状态。

**Checkpoint**: 暂停/trace基线green且文档同步；其他故事才可进入实现。实际生成生命周期在US1接入，不把协议存在算作SC005通过。

## Phase 3: User Story 1 — 迅速完成首次战斗与成长 (P1) · MVP

**Goal**: tick0四个近场预警，保留完整安全机制和自动攻击，使正常接敌拾取形成首个成长闭环。
**Independent Test**: 测试夹具保留旧全Thrall组成并关闭声音；Aren/Lia/Milo × 101/202/303共9局自然开局，首hit≤300tick、首kill≤600tick、首次升级UI实际挂载≤1800tick；四预警可见，44tick不激活、45tick可安全激活。失败样本保留。

### Tests first

- [X] T009 [P] [US1] 在 `tests/unit/test_content_contract.gd` 增FieldDefinition缺字段/非法类型/非有限半径、上下界/尝试数坏Resource负例，精确验证opening 128–160、16候选、45tick/96距离约束，不接受静默回退。
- [X] T010 [P] [US1] 在 `tests/unit/test_waves.gd` 增初始位置与tick0移动位置分离、四象限/两次RNG采样、边界起点/全队占位、16次失败永久跳过、tick44/45、激活闯入取消、99敌+1预警及100cap用例；后续场边、幼体24距离/母体死亡取消、首领重试和无补刷回归保持有效。

### Implementation

- [X] T011 [US1] 在 `scripts/data/field_definition.gd`、`data/encounters/coast_field.tres` 增opening_radius_min=128.0、opening_radius_max=160.0、opening_attempts=16及校验；落实“数值必须有限且符合本切片合同；spawn_warning_ticks=45、separation=96，场地bounds不变”，不新增导航/内部障碍。
- [X] T012 [US1] 在 `scripts/core/run_manager.gd` 创建主角后、首次模拟tick前调用SpawnDirector.initialize_opening，在 `scripts/combat/spawn_director.gd` 保存opening_origin；落实“不是存档或随玩家移动更新的值”，不改变模拟阶段顺序。
- [X] T013 [US1] 在 `scripts/combat/spawn_director.gd` 为tick0按slot_index mod 4采样初始中心128–160半径候选，每次角度/半径各消费一次spawn_positions，最多16次；按当前所有存活队员≥96及可走矩形检验，失败不回退场边/搬迁/补刷，tick≥600沿原edge_candidate。
- [X] T014 [US1] 在 `scripts/combat/spawn_director.gd`、`scripts/core/run_manager.gd`、`scripts/core/replay_trace.gd` 接入稳定reservation_id、scheduled_tick、slot_index、source（“opening/edge/summon/boss”）与修正快照；实现“planned → cap/unsafe”或“planned → warned → activated/canceled”，45主动tick及容量含预警，取消reason为“unsafe_at_activation/parent_dead/boss_boundary/run_end”；记录逐次候选/尝试和run_end终结，不存Node/声音时间，停止旧generation追加；保留幼体及boss特殊规则。
- [X] T015 [US1] 新建 `tests/fixtures/pacing_session.gd`、`tests/fixtures/pacing_observer.gd`：使用真实App/Run并记录accepted hit、enemy death、UI已挂载level、生成终结及起始snapshot/输入/实际选择ID/暂停；最终比较HP/位置/冷却/状态/kills/成长/敌人弹体奖励剩余/四RNG状态；操作者正常档隔离且不用test作弊，自动复放用test_mode，不注入350XP/无敌/加速。
- [X] T016 [US1] 新建 `tools/validate_pacing_audio.ps1` 的Record/Replay模式与隔离子进程入口，连接 `tests/fixtures/pacing_session.gd`；Record固定九样本顺序/首次120秒事件免费退出/第一个合法升级、最多7260tick，冻结输入及engine/simulation/catalog/build/fixture hash；Replay仅播放已录输入，不重新寻路；接受-InputDirectory/-EvidenceDirectory，未知/缺参明确失败，不静默Dummy，Audio/Benchmark尚未实施时明确拒绝。
- [X] T017 [US1] 在 `tests/integration/test_pacing.gd` 测试会话元数据/session_id/hero/seed/永久等级职业同伴腐化/driver设备、首次事实tick及planned/warned/activated/canceled计数、失败分类的保存；验证“死亡/未发生记明确失败，不用null当0秒”、hash变更/缺样本拒绝、真实档案不写入；将新fixture加入 `tests/run_tests.gd`、`tests/script_manifest.gd`。
- [ ] T018 [US1] 用 `tools/validate_pacing_audio.ps1` 配合仅测试夹具的旧全Thrall组成与声音关闭，按quickstart协议录制并复放9局至121主动秒（提前死亡也保留）；证据存 `docs/validation/combat-pacing-audio/us1-natural-v1/`，检查≤5/10/30秒及四预警可见/自动攻击，无安全阻塞正常局超时仍失败；不改数值凑目标，重录必须完整9局另建版本。
- [X] T019 [US1] 在 `specs/001-abyss-expedition-mvp/spec.md`、`specs/001-abyss-expedition-mvp/contracts/systems.md` 加仅首波位置被002 FR002覆盖的精确链接说明，保留旧原文与历史证据；前两分钟组成覆盖留给US2，不声称尚未实现的规则已生效。
- [X] T020 [US1] 用 `tools/run_validation.ps1 -OnlySuites @('pacing','unit','integration_m1','replay','integration_m4','combat_feedback') -Graphical -EvidenceDirectory docs/validation/combat-pacing-audio/us1/regression` 执行import/content/原生与DEV图形回归；在 `tests/graphical_check.gd` 补三尺寸近场预警可见性检查并保存真实截图，安全负例与自然时限分开报告，设备失败明确阻塞。
- [X] T021 [US1] 在 `docs/validation/combat-pacing-audio/us1/results.md` 汇总FR001–003/006/010–012与SC001部分证据/失败/未执行项；同任务更新 `docs/game-development-dashboard.html`、`docs/IMPLEMENTATION_OVERVIEW.md`、`README.md`、`docs/development.md`、`docs/validation/combat-pacing-audio/acceptance.md` 和本文件，声明US1独立验证模式不能代替US2集成后九局验收。

**Checkpoint**: 首波安全与真实时限有证据；若时限失败先分析接敌/拾取距离，禁止改伤害/XP/敌人数绕过。缺真人录制或图形设备则该验收项保持开放。

## Phase 4: User Story 2 — 两分钟内经历不同走位挑战 (P2)

**Goal**: 固定四槽逐步引入冲刺/射击、回收与组合；保留腐化、存活威胁、120秒事件与9分钟首领。
**Independent Test**: 夹具可保留旧场边首波、关闭声音；验证12波48基础槽（40T/4B/4C），实际rush<2700tick/hostile_shot<4500tick，90/100秒新基础全T、110秒TTBC。时限最终还须在集成后的固定9局检查。

### Tests first

- [X] T022 [P] [US2] 在 `tests/unit/test_waves.gd`、`tests/unit/test_content_contract.gd` 增五opening_segments的缺字段/非法类型/缺口重叠/600对齐/未知enemy ID/错误槽数和精确组成负例；断言12波48槽、40T/4B/4C、54波408基础槽、7200恢复原主阶段与32400停止普通生成。
- [X] T023 [P] [US2] 在 `tests/integration/test_corruption_combat.gd` 覆盖五开局段×腐化0/24/25/49/50/75/99/100：ceil数量额外槽100%Thrall、B/C槽不增加、不被母体替换；固定整数roll阈值及份额验证、brood开关相同抽样次数、120秒后旧权重及伤害/XP快照保持。
- [X] T024 [P] [US2] 在 `tests/integration/test_choice_pause.gd`、`tests/integration/test_m4_chapter.gd` 增1800/3600/5400/6600/7200边界前/同tick/后manual、level、focus、debug、event叠加暂停，断言stage/预警冻结、恢复不跳时/补刷、7200腐化→全部升级→事件→唯一6槽波、存活旧敌继续行为。

### Implementation

- [X] T025 [US2] 在 `scripts/data/wave_schedule.gd` 增opening_segments及查询/校验，落实start/end“半开主动tick范围，600对齐，无缝覆盖0–7200”和slots“恰4个已登记enemy ID，固定顺序，不是权重”；composition保持原签名/五主阶段，先复制4槽→追加Thrall到N=ceil(4×count)→每槽抽[0,10*T−1]，仅brood且Thrall且roll<N替母体（T为追加后Thrall数），后段原算法不变，不接受玩家强度参数。
- [X] T026 [US2] 在 `data/encounters/coast_waves.tres` 配置0–1800 TTTT、1800–3600 TTTB、3600–5400 TTTC、5400–6600 TTTT、6600–7200 TTBC；在 `scripts/data/content_catalog.gd` 校验全部opening enemy引用并接入现有content gate，不以未知ID静默替代。
- [X] T027 [US2] 在 `tests/integration/test_m2_party.gd` 增单人/双同伴、基础/高永久等级/已转职的同seed计划压力比较，使用无容量阻塞夹具断言波次组成/敌人属性不随强度变化；现场容量跳过独立计数，不能要求不同队伍击杀/位置完全相等。
- [X] T028 [US2] 在 `tests/fixtures/pacing_observer.gd`、`scripts/combat/brinejaw_behavior.gd`、`scripts/core/run_manager.gd` 接入只读实际rush开始与hostile_shot观察点（保留既有行为/数值），记录首次tick及存活行为；不能用enemy_spawned替代SC002威胁证据。
- [X] T029 [US2] 在 `tests/fixtures/pacing_session.gd`、`tests/integration/test_pacing.gd` 增仅夹具的旧场边首波对照与预先固定受控输入，关闭声音独立验证US2；旧全Thrall/旧首波开关只用于测试，不增加发行设置/UI，不把该模式计入集成自然九局。
- [X] T030 [US2] 在 `specs/001-abyss-expedition-mvp/spec.md`、`specs/001-abyss-expedition-mvp/contracts/systems.md` 补002 FR004/005只覆盖前120秒全Thrall默认的说明，链接新合同，保留原五阶段/腐化/幼体/首领规则及历史记录；同步旧断言描述避免把覆盖当回归错误。
- [X] T031 [US2] 用 `tools/run_validation.ps1 -OnlySuites @('pacing','unit','integration_m1','replay','integration_m2','integration_m4','full_run','combat_feedback') -Graphical -EvidenceDirectory docs/validation/combat-pacing-audio/us2/regression` 检查开局/后段/暂停/DEV，保存 `docs/validation/combat-pacing-audio/us2/results.md`；不得通过删除54波408槽或降低负载解决失败。
- [ ] T032 [US2] 用 `tools/validate_pacing_audio.ps1` 在US1+US2实际配置、声音关闭下完整录制并冻结9局于 `docs/validation/combat-pacing-audio/integrated-natural-v1/`，复放并检查SC001/002全部时限、48基础计划与取消明细、120秒事件一次；保留US1组及所有失败，不替换单个seed/路线，不满足则分析且保持未通过。
- [X] T033 [US2] 将US2结果/独立对照/九局输入hash及阻塞同步到 `docs/validation/combat-pacing-audio/acceptance.md`、`docs/game-development-dashboard.html`、`docs/IMPLEMENTATION_OVERVIEW.md`、`README.md`、`docs/development.md`、本文件和 `specs/002-combat-pacing-audio/quickstart.md` 的实际可用命令状态，保留历史证据。

**Checkpoint**: 编排与腐化/后段合同green，真实rush/shot及九局自然时限各有状态。没有额外名额、清场、自动平衡或数值改动。

## Phase 5: User Story 3 — 听懂自动战斗的结果 (P3)

**Goal**: 原创三攻击/命中/击杀/升级/受伤声音准确对应真实事实，固定8声部、升级保留、暂停与重开无残留，不干扰玩法。
**Independent Test**: 使用旧波次/首波夹具亦能验证三职业、无目标、接受/拒绝/致死、同伴、连选、叠加暂停、结束重开；真实播放、录音/盲听和音频开关九对复放分别出证据，Dummy不算听感通过。

### Tests first

- [X] T034 [P] [US3] 新建 `tests/unit/test_voice_allocator.gd`，测试固定8槽/0号升级专用、free最小index、严格低优先级最旧serial抢占/同序最小index、hero_hurt同优先兜底、独立hit/kill 3tick及mode+role攻击4tick窗口（从实际开始播放计）、低优先级不排队，忙/暂停槽也计数；验证诊断accepted/dropped/stolen/cue_started、Allocator唯一维护last_merge_tick及0号播放/释放接口，升级去重/FIFO由T036测试CombatAudio。
- [X] T035 [P] [US3] 新建 `tests/integration/test_audio_facts.gd`，覆盖三基础攻击/所有分支mode、多弹体/穿透/echo只一次activation、无目标/同伴AI关闭不响、无敌/拒绝/重复/死后请求无伤害音、同帧过量致死/范围多杀/DoT、hero与companion身份及旧hit_confirmed视觉合同；断言AttackCommitted固定字段/类型、source_id映射稳定actor_id、weapon_mode取提交时actor.weapon.mode（arc/straight/homing），发布与消费两端使用同一schema。
- [X] T036 [P] [US3] 新建 `tests/integration/test_combat_audio.gd`，用真实App测试当前generation+offer匹配且挂载后才播、refresh/确认/旧deferred不重复、快速连续选择FIFO不截断/不拒绝升级；所有token组合冻结/恢复剩余片段、暂停signal拒绝、audio disabled不积压、finish/leave/rebind/exit清理及跨run无声音。
- [X] T037 [P] [US3] 新建 `tests/unit/test_audio_content.gd`，测试7键/本地非空可导出WAV、单声道非循环PCM、峰值/时长/非有限gain、bus缺失/错误路由、priority/merge/voice_count非法配置拒绝；预留真实导入资源与无声后端两类测试，缺设备不能自动变成音频通过。

### Implementation

- [X] T038 [US3] 前置T034–T037完成；先在 `tests/run_tests.gd` 注册combat_audio（含这四项已创建fixture），在 `tools/run_validation.ps1` 纳入默认完整回归并保留pacing/combat_feedback/强制debug_panel，在 `tests/script_manifest.gd` 登记已存在脚本；用 `tools/run_validation.ps1 -OnlySuites @('combat_audio') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/us3/red` 记录预期断言失败，解析/装载错误不代替行为red，缺失接口以可加载最小接口支撑测试且不勾实现完成。随后新建标准库离线合成 `tools/generate_combat_audio.py` 并生成 `assets/audio/attack_arc.wav`、`assets/audio/attack_straight.wav`、`assets/audio/attack_homing.wav`、`assets/audio/hit.wav`、`assets/audio/kill.wav`、`assets/audio/hero_hurt.wav`、`assets/audio/level.wav`；落实“源音样峰值≤0.5；level时长≤0.160s”及mono 44.1kHz/16bit非循环，attack 0.06–0.12s/hit≤0.08s/kill≤0.14s/hero_hurt≤0.12s；固定私有合成seed，记录参数/hash/原创来源至 `assets/provenance.md`，运行时不合成/下载。
- [X] T039 [US3] 新建 `scripts/data/combat_audio_definition.gd`，落实id“唯一、已注册”、cues“7键：attack_arc、attack_straight、attack_homing、hit、kill、hero_hurt、level”、stream“本地可导出，非空、非循环、mono PCM；无下载URL”、gain“有限且≤合同初始峰值预算；改值须重测混音”；校验priority“companion_attack 10、hero_attack 20、hit 30、kill 40、hero_hurt/level 50”、companion_offset=−6“严格低于主角同类”、独立merge 3/3与攻击4“以weapon.mode+主角/同伴分组”、voice_count/level_reserved=8/1“总8；每player单声部；不可配置为更高”。
- [X] T040 [US3] 新建 `data/audio/combat_audio.tres`、`default_bus_layout.tres`，配置level −12dB/hero_hurt −16/kill −20/hit −24/hero_attack −26/companion再−6；落实“level为ChoiceSFX，其余CombatSFX；本地bus layout路由Master，均0dB且无增益效果”（不静音）；在 `scripts/data/content_catalog.gd`、`tests/validate_content.gd`、`tests/script_manifest.gd` 接入资源/脚本/export引用校验，不静默回退未知bus。
- [X] T041 [US3] 新建 `scripts/audio/voice_allocator.gd` 实现T034纯策略及只读诊断；唯一维护8项VoiceSlot（slot_index/busy/cue/priority/start_serial/generation）、有界last_merge_tick、共享优先级仲裁及诊断计数，不持有offer_id或升级队列；0号由CombatAudio提交播放/释放且不参与共享抢占，stop/steal直接释放，不等finished，重置时清槽与合并时钟。
- [X] T042 [US3] 在 `scripts/combat/attack_executor.gd`、`scripts/core/run_manager.gd` 增attack_committed事实，成功activation所有分支提交后恰一次；固定字段为generation: int、tick: int、source_id: int、is_companion: bool、weapon_mode: StringName、activation_id: int，source_id取攻击者稳定actor_id、weapon_mode取提交时actor.weapon.mode（arc/straight/homing），不另发同义事件字段；不按显示名分支，不修改攻击/冷却/随机流程。
- [X] T043 [US3] 在 `scripts/combat/damage_service.gd`、`scripts/core/run_manager.gd` 增damage_accepted事实，只在health.receive接受后发布generation/tick/request_id/target_id/target_role/actual_damage/fatal；target_role显式hero/companion/enemy/boss，敌人致死只kill、存活hit、主角受伤hero_hurt、同伴受伤可省略；保留hit_confirmed签名、伤害/奖励/免疫判定。
- [X] T044 [US3] 新建 `scripts/audio/combat_audio.gd`，预建8个AudioStreamPlayer、max_polyphony=1并接入allocator/Resource；AudioSession保留generation/enabled/allocator实例/last_level_offer_id/upgrade_fifo/disposed，唯一拥有升级去重/FIFO，按generation+单调offer_id仅收实际显示未播放ID，不建无界历史集合，不复制Allocator的last_merge_tick；负责呈现、暂停及终局清理，0号经Allocator提交播放/释放，终局清升级状态并重置Allocator；所有入口检查phase/generation/token，声音与完成回调不写玩法或RNG，不每hit建节点、不全树搜索、不引入随机音高/配乐/效果。
- [X] T045 [US3] 在 `scripts/core/run_manager.gd` 创建/绑定远征唯一CombatAudio子节点，接真实攻击/伤害与PauseCoordinator.changed，节点可Always但模拟不改；任何token冻结共享声音、仅level允许升级、其他任一token冻结升级/FIFO；恢复剩余播放不补战斗声，finish/leave/rebind/exit立即stop并清槽/FIFO/合并时钟/连接/旧generation。
- [X] T046 [US3] 在 `scripts/core/app_router.gd` 的show_choice先校验deferred generation/当前offer/options，成功挂载后调用present_level；同generation只接收大于last_level_offer_id的ID，slot0忙时FIFO顺序播放、不截断/漏播；保持 `scripts/ui/screen.gd` 原180ms输入保护与合法升级操作，不为音频增加等待。
- [X] T047 [US3] 在 `tests/integration/test_combat_audio.gd` 执行真实AudioStreamPlayer pause/finished/stop/steal/换stream路径、8声部及CombatAudio唯一拥有的连续offer去重/FIFO生命周期；核对 `tests/run_tests.gd`、`tools/run_validation.ps1` 已在T038注册并默认执行combat_audio，运行该suite至green且保留pacing/combat_feedback/强制debug_panel；更新 `tests/script_manifest.gd` 的最终实现脚本清单，关联T038的red与本次green证据。
- [X] T048 [US3] 在 `tests/integration/test_replay.gd`、`tests/fixtures/pacing_observer.gd` 检查音频开/关及音色变化不消费四玩法RNG、不改变waves/reservation终结/offers/decisions/events/完整最终状态，音频日志与玩法相等字段分开；补旧波次条件下US3独立验证夹具及旧generation迟到signal负例。
- [X] T049 [US3] 扩展 `tools/validate_pacing_audio.ps1` Replay为冻结九样本每条同snapshot/输入/选择的真实模拟音频开/关成对运行，逐项玩法差异与首hit/kill/level/rush/shot时限输出JSON；拒绝版本/hash不符、漏样本/换seed/重新寻路和无实际激活结果的trace，不把旧无敌/350XP capture_movement作为自然证据。
- [X] T050 [US3] 在 `tools/validate_pacing_audio.ps1`、新建 `tests/fixtures/audio_capture.gd` 实施Audio模式：三职业正常/8声密集、规定负例/暂停/重开，保存真实设备未经归一化PCM、driver/设备/系统音量/采样率与事件时间对照/削波分析；录音失败明确阻塞，禁止静默Dummy或仅凭事件数报无削波。
- [X] T051 [US3] 新建 `tests/pacing_audio_graphical_check.gd` 并接入 `tools/validate_pacing_audio.ps1` 相应受控检查，验证真实App升级挂载/刷新/旧deferred、focus与DEV/F9跨屏/暂停/重开及单实例，保存真实截图/输出；保留 `scenes/debug/debug_panel.tscn` 和action service既有控件/沙盒，物理键鼠按 `docs/developer-debug-panel.md` 另记人工项。
- [ ] T052 [US3] 用 `tools/validate_pacing_audio.ps1 -Mode Replay` 对当前版本冻结9局执行音频开/关9对；版本不同则按协议新建目录完整重录9局而非硬改hash，结果存 `docs/validation/combat-pacing-audio/us3-replay/`；输出SC001/002/005逐局结果及失败，另执行边界叠加暂停回归，不把音频时长列入玩法比较。
- [ ] T053 [US3] 用 `tools/validate_pacing_audio.ps1 -Mode Audio` 保存三职业/密集/负例真实录音至 `docs/validation/combat-pacing-audio/us3-audio/`，检查fatal无hit双响、无敌假音、每次升级可听、主角受伤优先/同伴较轻、无削波及跨run残音；无法录音或试听则SC004相应项未验证，修gain/音样后须重测。
- [X] T054 [US3] 保留旧构建后执行 `tools/run_validation.ps1 -M4 -Graphical -Export -EvidenceDirectory docs/validation/combat-pacing-audio/us3/regression` 和常规回归后的 `tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/combat-pacing-audio/us3-debug -EvidenceDirectory docs/validation/combat-pacing-audio/us3-debug`；覆盖v1/v2/v3存档/正常测试DEV隔离/单满队/结算重试、源码与实际Debug图形/实际Release拒绝，导出失败不算通过，Dummy仅诊断。
- [X] T055 [US3] 汇总FR007–012/SC004–006分项证据至 `docs/validation/combat-pacing-audio/us3/results.md` 与 `docs/validation/combat-pacing-audio/acceptance.md`，同步 `docs/game-development-dashboard.html`、`docs/IMPLEMENTATION_OVERVIEW.md`、`README.md`、`docs/development.md`、本文件及 `specs/002-combat-pacing-audio/quickstart.md` 的可用命令；人工盲听/性能未执行继续开放，不沿用旧通过数。

**Checkpoint**: 自动事实/仲裁/生命周期green，九对玩法一致；真实音频/人工/设备/导出各自独立状态。音效服务不拥有战斗、保存或DEV面板。

## Phase 6: Polish & Cross-Cutting Concerns — 验收收口

**Purpose**: 在当前新版Release上完成性能/人工验收；无可用人员或设备时可整理证据，但不得勾未执行项或宣称全部完成。

- [X] T056 在 `tests/unit/test_benchmark_contract.gd`、`tests/performance/benchmark_capture.gd` 增真实音频压力启用/禁用与实际cue/声部峰值采样、奖励守恒及有效性拒绝；维持100常规+1首领/双同伴/≥30效果/100活动弹体/500宝石/腐化100、30主动秒预热+120主动秒采样，不使用自然时限夹具替代压力夹具，先red后green。
- [X] T057 在 `tools/validate_pacing_audio.ps1` 实施Benchmark模式及 `tests/performance/benchmark_capture.gd` 对接，要求-ReleaseExecutable指向本切片新Release console绝对路径、真实driver、seed101、1920×1080/VSync off/无调试器；拒绝debug build、假静音对照/无实际播放cue、负载不足/提前结束/时间不足/错误设备；输出逐帧CSV、p50/p95/p99/max及host/build/fixture hash，不改旧 `tools/benchmark_quality.ps1` 的历史标签。
- [X] T058 将当前源码用固定引擎/匹配模板独立导出至 `builds/windows/combat-pacing-audio/acceptance-release/`，保存hash/日志并实际探测Release拒绝DEV；用 `tools/validate_pacing_audio.ps1 -Mode Benchmark` 在Ryzen7 5800H/GTX1650同机真实声音开/关各一轮，保存 `docs/validation/combat-pacing-audio/performance/` 的负载、环境/电源/前台/后台/设备及原始采样，启用p95≤16.67ms且p99≤25ms才判该机样本达标，保留失败，不关闭历史参考机/多seed gate。
- [ ] T059 依据 `specs/002-combat-pacing-audio/quickstart.md` 对5名未接触本版玩家进行SC003自然试玩，记录匿名P01–P05在30秒/2分钟后无提示回答及空档/死亡/疲劳到 `docs/validation/combat-pacing-audio/human/gameplay.md`；至少4人说明移动接敌/自动攻击/拾取升级及两类应对才通过，不替参与者编造回答，人员不可用保持待人工验收。
- [ ] T060 用 `assets/audio/` 当前音样开展5人×20随机音样盲听（攻击/命中/击杀/升级各5，攻击固定剑2/弓2/法1并同时记录职业）；预先冻结题序/音样hash/答案表，测试中隐藏标签且不反馈答案，原始回答与两个分数/各职业正确数存 `docs/validation/combat-pacing-audio/human/listening.md`；至少4人须各自同时满足类别≥16/20、职业≥4/5且每职业至少1题正确，职业题仅在类别及职业均正确时计分，不能用不同参与者凑门槛；结合T053录音判SC004，无法盲听保持开放，改音样后重测识别与混音。
- [ ] T061 按 `docs/developer-debug-panel.md` 执行物理鼠标DEV/F9、菜单/公会/选择/战斗/暂停/结果/重开、全控件与隔离档案人工烟测，在 `docs/validation/combat-pacing-audio/human/debug-smoke.md` 逐项记录实际结果；未执行不借受控图形结果代填，保持Play Debug.cmd启动当前源码。
- [X] T062 在最后一次代码/资源修复后仅重跑必要受影响检查并执行 `tools/run_validation.ps1 -M4 -Graphical -Export -EvidenceDirectory docs/validation/combat-pacing-audio/final/regression`，核对pacing/combat_audio/combat_feedback均默认执行且debug_panel不能绕过；最终验收Release若与T058性能/录音hash不同必须重测受影响证据，保留旧结果于 `docs/validation/combat-pacing-audio/final/results.md`。
- [X] T063 核对 `docs/validation/combat-pacing-audio/acceptance.md` 的FR001–012/SC001–007、逐局自然/九对复放/安全负例/录音/盲听/性能证据及未执行项，更新 `specs/002-combat-pacing-audio/quickstart.md`、`docs/development.md` 与本文件checkbox；状态区分已实现并验证/已实现未验证/部分完成/未实现/待人工验收，不关闭001历史人工目标。
- [X] T064 更新 `docs/game-development-dashboard.html` 的简短What's New及真实图像/验证状态、`docs/IMPLEMENTATION_OVERVIEW.md` 的≤600汉字主摘要与紧凑表格、`README.md` 文档/启动/验证链接；保留原布局，检查全部离线相对链接/资源和alt，无CDN/假截图/完成率；将实际检查范围/结果写入 `docs/validation/combat-pacing-audio/final/docs-check.md`。

## Dependencies & Execution Order

```text
Phase 1 T001–T003
       ↓
Phase 2 T004–T008
       ├── US1 T009–T021 ──┐
       ├── US2 T022–T033 ──┼── integrated nine sessions → US3 nine pairs
       └── US3 T034–T055 ──┘
                            ↓
                  Phase 6 T056–T064
```

- 推荐顺序US1→US2→US3，尽量不同时修改共享文件。US2/US3核心逻辑不依赖其他故事规则，可在基础设施完成后通过独立夹具验证；这不等于无文件冲突。
- US1：T009/T010 → T011 → T012 → T013 → T014；T015/T016/T017接线完成后T018，T019/T020验证，T021收口。T018录制依赖操作者；缺人可继续代码/自动验证，但保持该项未完成。
- US2：T022/T023/T024 → T025 → T026 → T027/T028/T029；T030/T031检查后T032→T033。T029及T032依赖US1会话工具；若US2先做，可先用已有run_fixture测试组成，不能跳过最终集成九局。
- US3：T034/T035/T036/T037可同批编写；全部完成后T038先注册suite并记录red，再生成音样→T039→T040提供导入资源；T041及T042/T043之后T044→T045→T046→T047集成green/T048；T049/T050/T051各自接线后T052/T053→T054→T055。T052依赖T032冻结会话或当前版本完整重录组。
- T004–T008基础暂停与trace是全部故事前置；US1 T014生成生命周期是最终SC005前置；音频无声策略与真实播放器测试分开，不用设备缺失豁免自动逻辑测试。
- 最终T056→T057→T058，T059/T060/T061可在稳定验收构建后独立安排，T062→T063→T064收口。任何实现后修复若改变被测行为/hash须重测相关证据。无人/无硬件项不能勾完成，但不阻止继续其余有条件工作。
- 本文件未授权额外玩法、依赖、存档迁移、线上服务或部署。上述并行是任务排程示例，实际调用子代理仍需用户/适用指令明确授权。

## Parallel examples per user story

| 故事 | 允许同批（前置已完成） | 共享文件/后续串行限制 |
| --- | --- | --- |
| US1 | T009 content负例与T010 waves安全测试 | T011–T014共享Field/Run/Spawn，按序合并；T015/016会话协议要先统一 |
| US2 | T022 waves/content、T023 corruption、T024 choice/chapter测试 | T025模型先于T026资源；T031后才跑T032完整自然组 |
| US3 | T034 allocator、T035 facts、T036 App、T037 content测试 | 测试批次后T038串行注册/red；T042/T043均改RunManager须串行；T038/T040/T047 manifest/runner需统一；新音样后才测录音 |

不要跨故事并行编辑 `scripts/core/run_manager.gd`、`scripts/core/app_router.gd`、`scripts/combat/spawn_director.gd`、`tests/integration/test_replay.gd`、runner/manifest或dashboard。每个检查点只有一份文档汇总。

## Implementation strategy

1. **MVP first**：Phase1+2+US1（T001–T021），交付可验证的安全近场开局；无需音效/新遭遇组成。首hit/kill/level九局不达标则保留失败，不用禁止数值改动绕过。
2. **Incremental delivery**：US2独立组成/边界测试后合入US1，冻结本版本完整九局；再加US3事实/资源/仲裁/真实播放，用同输入九对确认声音不干扰玩法。
3. **Acceptance**：完整回归+新Release性能+5人理解/盲听+物理DEV烟测，逐项给证据。自动化通过不等于好玩、可听或参考机性能通过。
4. **Documentation at every checkpoint**：T008/T021/T033/T055/T063–T064明确同步规定文档；每次代码阶段提交均保留日志、seed/hash、red/green、失败与未执行项。

## Coverage and independent completion criteria

| 范围 | 主任务 | 独立可验收内容 |
| --- | --- | --- |
| US1 · FR001–003/006 · SC001 | T009–T021 | 四近场安全预警、45tick/100cap、三职业九局≤5/10/30秒，无注入XP或新操作 |
| US2 · FR004–005/010–011 · SC002/005边界 | T022–T033 | 12波48槽、额外全T再腐化替换、rush<45s/shot<75s、90/100/110/120边界及后段保持 |
| US3 · FR007–011 · SC004/005 | T034–T055 | 真事实音色/致死互斥、8声/FIFO、暂停/重开、真实录音、九对玩法相同；盲听由T060补齐 |
| Shared · FR010/012 · SC006 | T004–T008/T020/T024/T051/T054/T061/T062 | focus与token所有权、存档/沙盒、DEV单例跨屏、Debug图形及Release拒绝，人工独立记账 |
| SC003/004人工与SC007 | T056–T060 | 5人理解≥4通过；盲听≥4人各自同时类别≥16/20、职业≥4/5且每职业至少1题正确；真实音频新Release有效负载p95/p99门槛 |

任务数：64；Setup 3、Foundational 5、US1 13、US2 12、US3 22、Polish 9。三个故事共47项，其余17项为共用/收口。所有任务初始化未勾选；人工/设备阻塞只记录状态，不以生成任务代替完成。


### 2026-10-19 实施证据

[基础层](../../docs/validation/combat-pacing-audio/foundation/results.md)、[US1](../../docs/validation/combat-pacing-audio/us1/results.md)、[US2](../../docs/validation/combat-pacing-audio/us2/results.md)。T018/T032需真人自然录制，保持开放；没有因缺人勾选。Record/Replay接线通过夹具检查，完整实际Record会话尚待操作者执行。US3已创建可加载最小接口和四组red测试；最小接口不算音效实现。


### 最终执行状态 · 2026-10-19

57项执行完成；7项未勾：T018/T032/T052自然记录与9对、T053人工试听、T059/T060五人试玩/盲听、T061物理DEV烟测。T053真实录音部分已完成，人工部分未执行。T058同机Release真实音频开关各30+120秒已执行、有效负载/奖励守恒且本机样本达标；全程前后台未独立监督，SC007及历史参考机/多seed验收仍开放。T064实际离线链接/资源检查结果见最终docs-check，不按任务勾选推断验收通过。

[最终证据](../../docs/validation/combat-pacing-audio/final/results.md) · [性能](../../docs/validation/combat-pacing-audio/performance/results.md) · [矩阵](../../docs/validation/combat-pacing-audio/acceptance.md)。没有代填38项评审清单或任何真人答案。


## Phase 7: Convergence

2026-10-20 · `tasks_appended`。核对当前002 spec/plan、T001–T064、源码与本轮源码回归；[收敛报告](../../docs/validation/combat-pacing-audio/convergence-20261020/results.md)。以下为剩余工作的续办任务，不代表旧任务完成；原7项开放任务保持未勾选，重叠验收可复用同一份真实证据，但必须分别满足各自条件。执行顺序：T065/T066/T074/T075修复验证工具与构建基线，再录自然会话/复放及受影响音频/性能；人员项目独立推进。本阶段不授权额外玩法或修改验收门槛。

- [X] T065 [HIGH] 核对并修复 `project.godot` 的4.7 feature/新增兼容设置与计划Godot4.5锁定的偏离，保留用户已有修改的意图；当前源码工具摘要 `d004aa755f204f6bc94584137e424f8bcbf74334aa18a89fcdb8a8706695b9d2` 不同于acceptance-release-v4的 `bb5eee5d1ce6ac3566bdb7e3a60da143184eb26bff57a50109980e0fc152b791`，不得硬改manifest/hash。用固定4.5执行完整 `tools/run_validation.ps1 -M4 -Graphical -Export` 并指定全新BuildDirectory/EvidenceDirectory，保留旧构建，实际验证Debug图形及Release拒绝；按行为变化重做受影响录音/性能/会话证据并同步当前构建导航与完整性报告 per plan: Technical Context engine/storage constraints; T001/T062; FR012 (partial)
- [X] T066 [HIGH] 扩展 `tests/fixtures/pacing_observer.gd` 的最终玩法快照及 `tests/integration/test_pacing.gd`、`tests/integration/test_replay.gd` 的比较负例：覆盖SpawnDirector预留/序号/首领状态、`run.boss_hits` 与其warning的可序列化判定字段，以及仍能影响后续模拟的其他遗漏状态；不序列化Node/音频墙钟。分别只改一个遗漏字段时必须报告明确差异，真实音频开/关/音色变体仍相同；保留旧快照证据，协议/hash变化时完整重录九局而不改旧hash per FR011/SC005; T015/T048 (partial)
- [ ] T067 [HIGH] 完成仍开放的T018与T032：先确认修复后的会话工具/版本，按 `specs/002-combat-pacing-audio/quickstart.md` 分别录制US1旧全Thrall组与Integrated组的三职业×101/202/303自然九局，冻结完整输入与失败样本，保留5/10/30秒及45/75秒实际行为、48基础槽/取消明细和120秒事件一次的逐局结果；无人输入保持待人工验收，失败先分析接敌/拾取，不改禁止数值或挑选成功样本 per SC001/SC002; US1/AC1–3; US2/AC1–5; T018/T032 (partial)
- [ ] T068 [HIGH] 在T067集成完整九局且版本/hash相符后完成仍开放的T052，使用 `tools/validate_pacing_audio.ps1 -Mode Replay` 执行同起始状态/冻结输入/选择的音频开/关九对，逐项保存trace/完整最终状态和SC001/002/005结果；重跑30/60/90/110/120秒边界叠加暂停，不以现有无敌/350XP或零输入夹具替代自然验收 per FR011/SC005; T052 (partial)
- [ ] T069 [HIGH] 完成T053剩余人工试听并按T065结果重录受影响场景：对当前构建三职业正常/密集/负例原始录音逐段核对致死无hit叠响、无敌无假音、每个实际升级短句可听、主角受伤优先、同伴较轻及暂停/重开无残音，保存事件时间对照、真实试听记录与未经归一化PCM/削波分析；设备或试听不可用时保持相关项未验证 per FR007/FR009/SC004; US3/AC1–5; T053 (partial)
- [ ] T070 [HIGH] 完成仍开放的T059，按冻结协议收集5名未接触本版玩家的30秒/两分钟无提示原话、空档/死亡/疲劳观察至 `docs/validation/combat-pacing-audio/human/gameplay.md`，至少4人满足全部玩法理解条件才通过；无真实参与者保持待人工验收 per SC003; T059 (partial)
- [ ] T071 [HIGH] 完成仍开放的T060，用与当前音样hash一致且预先冻结的隐藏标签题序采集5人×20题真实回答，在 `docs/validation/combat-pacing-audio/human/listening.md` 关联原始JSON及类别/职业/各职业判分；至少4人各自同时满足全部门槛，音样变化另建版本重测，不生成或代填答案 per SC004; T060 (partial)
- [ ] T072 [MEDIUM] 完成仍开放的T061，按 `docs/developer-debug-panel.md` 用物理鼠标/键盘逐项检查DEV/F9跨菜单、公会、选择、战斗、暂停、结果、重开、28动作与正常/沙盒隔离，记录到 `docs/validation/combat-pacing-audio/human/debug-smoke.md`；保留App单例及 `Play Debug.cmd` 当前源码启动，不以受控InputEvent图形检查代填 per FR012/SC006; T061 (partial)
- [ ] T073 [MEDIUM] 补全T058当前开放的环境证据：在T065的新Release及T075比较守卫完成后，按SC007目标机/负载/真实设备重做30主动秒预热+120主动秒声音开/关对照，记录全程前台/电源/后台负载的实际观察及两轮一致性、原始CSV/JSON/hash和p95/p99判定；未观察或设备不符明确保留未验证，不关闭001历史参考机/多seed gate per SC007; plan: Performance Goals; T058 (partial)
- [X] T074 [MEDIUM] 修正 `tests/fixtures/pacing_session.gd` 的finish/report顺序，使 `SpawnDirector.terminate` 添加run_end终结后再从最终trace计算planned/warned/activated/canceled等计数，避免提前退出/预警中死亡/看门狗路径漏计或计数与trace不一致；在 `tests/integration/test_pacing.gd` 增上述路径及每个已预警reservation恰一个终结的负例/回归，不把缺失事实算零秒成功 per plan: reservation lifecycle/AcceptanceSession; T014/T017 (partial)
- [X] T075 [MEDIUM] 加强 `tools/validate_pacing_audio.ps1` Benchmark比较与 `tests/performance/benchmark_capture.gd`、`tests/unit/test_benchmark_contract.gd` 的守卫：SC007目标结果检查 `same_machine_target`，核对两轮CPU/GPU、engine/fixture/build、真实driver/设备/采样率及规定负载和奖励守恒；不能仅靠相同kills/active_seconds判定一致。添加非目标硬件、两轮设备/采样率变化、相同kills但负载不合规的拒绝测试；保留非目标机诊断与SC007通过的明确区别 per SC007; plan: Performance Goals; T057 (partial)


### Phase 7实施状态 · 2026-10-20

T065/T066/T074/T075已完成：固定4.5元数据、新Debug/Release、完整快照/精度、终结计数、性能守卫。16组9,232断言及源码/实际导出图形通过；新WASAPI录音削波0。本机开启p95 15.172ms/p99 19.647ms，max76.035ms保留；可见进程采样不覆盖全主机，T073仍部分完成。T067–T072及旧7项自然/真人验收保持开放。共61勾选、14未勾选，未代勾评审清单。见[本次实施证据](../../docs/validation/combat-pacing-audio/phase7-20261020/results.md)。
