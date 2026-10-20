# Implementation Plan: First 2 Minutes Combat Pacing & Audio Polish

> 实施更新 · 2026-10-19：核心已接线，自动与导出/真实输出检查完成；自然/真人/性能完整验收状态见[证据矩阵](../../docs/validation/combat-pacing-audio/acceptance.md)。下列“拟实施/未实施”描述保留为设计阶段历史，不代表当前状态。

**Feature / setup BRANCH**: `002-combat-pacing-audio` | **Date**: 2026-10-19 | **Spec**: [spec.md](spec.md)

**实际 Git 分支**：`feature/visual-art-direction—v3`。setup 的 BRANCH 是活动特性标识，不代表创建了同名分支。本轮不切换分支。

**状态**：Phase 0 研究与 Phase 1 设计完成；功能未实现，游戏验收未执行。本轮只改规划/导航文档，不创建 tasks.md，不执行实现。

**后续文档修订 · 2026-10-19**：上句及末尾Planning verification记录原规划轮次；现已生成[tasks.md](tasks.md)，并按分析G1/I1/A1/I2修订。SC004在原20题内增加剑/弓/法职业判分；AttackCommitted统一source_id/weapon_mode字段与类型；CombatAudio唯一拥有升级去重/FIFO，VoiceAllocator维护声部/合并窗口；T038先注册音频测试并记录red，T047完成集成green。任务仍64项且全部未执行，功能状态未变。

## Summary

复用既有 Godot 4.5 单人远征，按三个独立增量改善核心循环：tick 0 近场安全预警、前120秒固定四槽遭遇编排、真实攻击/伤害/击杀/升级的原创音效。保留战斗数值、腐化规则、存档和 App 单例 DEV/F9 面板。

WaveSchedule 保留五个主阶段，另加五个开局子段；首波位置以进入战场时的主角位置为中心。音频由远征拥有的 presentation service 和固定8个播放器管理，玩法发布事实，不等待音频。本地 Resource 配置混音，原创 WAV 离线合成。依据见 [research.md](research.md)、[data-model.md](data-model.md)、[节奏合同](contracts/pacing.md)、[音频合同](contracts/audio.md)。

## Technical Context

| 项目 | 已确定设计 |
| --- | --- |
| Language/Version | GDScript / Godot `4.5.stable.official.876b29033`；工具用已有 PowerShell、Python 标准库 |
| Primary Dependencies | 现有 SceneTree、Resource、AudioStreamPlayer/AudioServer；无新插件、音频库或在线服务 |
| Storage | 配置在 data/、音样在 assets/audio/；运行状态仅在内存。沿用 profile schema v3，不加存档字段或迁移 |
| Testing | tests/run_tests.gd、content校验、tools/run_validation.ps1；实施时增 pacing/audio suites、自然轨迹录制/复放和真实音频性能入口 |
| Target Platform | Windows桌面键鼠，Compatibility renderer；固定引擎和匹配导出模板 |
| Project Type | 原创纯离线2D survivor-like游戏增量 |
| Performance Goals | SC007：Ryzen 7 5800H / GTX 1650，1920×1080，VSync off，实际Release、无调试器；100常规敌人+1首领、双同伴、≥30效果、100活动弹体、500宝石、腐化100；预热30主动秒、采样120主动秒，真实音频开/关对照。启用时p95≤16.67ms、p99≤25ms，不缩减负载 |
| Constraints | 60主动tick/s；波间600tick、预警45tick、常规敌人+预警≤100、每槽≤16候选；声音≤8；不改伤害、经验、奖励、敌人行为/属性 |
| Scale/Scope | 12波/48基础槽；Aren/Lia/Milo×101/202/303共9自然开局、9对复放；5人理解/盲听；三攻击音+命中+击杀+升级+主角受伤变体 |
| Art | 继承 [art-direction](../../docs/art-direction.md)：640×360逻辑、整数缩放/最近邻，16px地形、32px角色、64px首领；idle 4帧/6FPS、move 6/10、attack 4/12、hurt 2/12、death 6/8的替换约定。现有橙色预警/命中图形不重做，声音不驱动判定 |

研究前未知项：固定槽如何继承腐化10个百分点、初始位置捕获、可靠事实事件、暂停/失焦、原创资源/混音上限、验证工具覆盖。均已在research.md决定；时限、听感、性能属于待执行验收，不是待定规格。

## Constitution Check

依据宪法v1.0.0。以下是设计合规结论，不是游戏验收结果。

| 原则 | Phase 0 前检查 | Phase 1 后复核 |
| --- | --- | --- |
| I Gameplay First | 合规：只改善核心循环，US1→US2→US3 | 合规：真实计时、行为、试玩分别验证；不扩展名册/商业系统 |
| II Modular | 合规：复用生成、伤害、选择协调边界 | 合规：配置/玩法事实/音频分离；UI只确认实际呈现，不判伤害 |
| III Original IP | 合规：无外部素材需求 | 合规：本地原创WAV保留生成源码/hash/来源，不采样竞品 |
| IV Testable | 合规：12 FR、7 SC及负例明确 | 合规：逐项验证矩阵、9局冻结轨迹、真实录音/盲听；Dummy不冒充听感 |
| V Pixel Art | 合规：沿用既有像素与动画约定 | 合规：近场四预警需实机可见，不增加教程/UI改版 |
| VI Performance | 合规：SC007环境/数量/帧时明确 | 合规：8预建播放器、有界合并、无实时合成/全树搜索；声音不读玩法RNG |
| VII Scope | 合规：首波、两分钟编排、音效 | 合规：后段/保存/DEV保护保留；补失焦token满足本规格暂停语义 |
| VIII Incremental | 合规：各故事独立检查 | 合规：每个实施检查点验证并更新规定文档，失败不得视为通过 |

**Gate**：研究前PASS；设计后PASS，无例外。若目标只能靠改伤害/奖励/名额达成，须回到规格审批，不能以调优扩大范围。

## Project Structure

### Documentation (this feature)

```text
specs/002-combat-pacing-audio/
├── spec.md                      # 已有规格，本轮不改
├── plan.md
├── research.md
├── data-model.md
├── contracts/
│   ├── pacing.md
│   └── audio.md
├── quickstart.md
└── tasks.md                     # 后续speckit-tasks产物，本轮不创建
```

### Source Code (repository root; 新增项均为拟实施)

```text
data/encounters/{coast_waves,coast_field}.tres
data/audio/combat_audio.tres          # 新增：混音与音样
default_bus_layout.tres               # 新增：CombatSFX/ChoiceSFX到Master
assets/audio/                        # 新增：7个原创短WAV
assets/provenance.md
scripts/data/{wave_schedule,field_definition,content_catalog}.gd
scripts/data/combat_audio_definition.gd  # 新增配置类型
scripts/combat/{spawn_director,attack_executor,damage_service}.gd
scripts/audio/{combat_audio,voice_allocator}.gd  # 新增呈现与可测策略
scripts/core/{run_manager,replay_trace,pause_coordinator,app_router}.gd
tests/unit/                          # 波次、内容、声音仲裁
tests/integration/                   # 实际接线、暂停、复放、存档/DEV
tests/fixtures/                      # 新增自然轨迹与验收观察器
tests/performance/benchmark_capture.gd
tools/                               # 新增WAV生成、002会话/性能验证入口
```

**Structure Decision**：沿用现有目录，不引入服务器、网络API或通用事件总线。contracts描述游戏内服务和UI行为。音频不放入可替换Screen，不移动受保护DebugPanel。

## Phase 0 — Research

完成两项并行只读研究：生成/腐化/旧断言，以及音频/暂停/官方4.5 API。主流程核查验证命令、复放与文档。结论见research.md；不重复全仓审计或竞品研究。

## Phase 1 — Design and implementation checkpoints

以下是后续交付顺序与门槛，不是本轮实现记录；详细任务由speckit-tasks生成。

| 检查点 | 实施范围 | 进入下一步前的证据 |
| --- | --- | --- |
| P1 首波 | 初始位置快照、近场候选、预警生命周期trace；不改后续组成 | import/content/unit、首波安全/上限/45tick、自然计时；冻结9条轨迹含失败 |
| P2 编排 | 开局子段、额外Thrall、腐化份额、后段保留；旧合同覆盖说明 | 12波48基础槽、全程54波408槽、逐段腐化、30/60/90/110/120边界、真实rush/shot、强弱队伍不缩放 |
| P3 声音 | 原创资源、事实信号、8声部、显示后升级去重、暂停/失焦/清理 | 单元及App接线、伤害负例、9对音频开关复放、图形及实际export DEV保护、真实设备录音 |
| P4 验收收口 | 新Release性能对照、5人理解/盲听、证据整理 | SC001–007逐项状态；人工/硬件不可用保持待验收，不关闭MVP历史开放目标 |

每个实施检查点均更新dashboard、overview、README链接、development、validation和实际tasks；保留历史报告。独立开关仅放测试夹具：P1可使用旧全Thrall组成，P2可使用旧场边首波，音频可禁用输出；不新增发行设置界面。

## Compatibility and affected expectations

- 只覆盖旧MVP首波场边、前120秒全Thrall默认。实施时在旧spec/contract加精确增量链接，保留历史原文/报告；本轮不改已实现规则。
- 扩展WaveSchedule.validate、ContentCatalog开局ID校验、test_content_contract、test_waves、test_corruption_combat；54波408名额及幼体24单位分离仍有效。
- ReplayTrace缺实际激活/取消结果，需补齐并提高SIMULATION_VERSION；音频日志不并入玩法相等字段，不因此升级存档schema。
- 旧replay夹具使用无敌及注入350XP，不能证明SC001。benchmark_quality强制Dummy且固定旧构建，不能证明SC007。
- App尚无失焦暂停：加focus token，恢复仅释放自身token；PauseCoordinator增状态通知供声音及时冻结，模拟顺序保持不变。

## Risks and acceptance boundaries

128–160首波距离不保证5/10/30秒达标；失败先检查接敌/拾取路线，不改禁止数值。生成Brinejaw/Cantor不代表实际冲刺/射击，必须记录实际行为。混音初值和离线峰值不能代替设备录音/盲听。历史Q1单seed性能通过不代表本切片通过。

## Complexity Tracking

无宪法违规或例外。固定播放器池直接满足8声上限；不引入动态池框架、导航、ECS、音频中间件或自动平衡。

## Planning verification and hooks

本轮执行setup_plan、源代码/合同核查和规划文档完整性/链接检查：6份必需产物齐全、无未解决模板标记，165个本地链接/资源引用有效，dashboard的21个图片标签均有alt，无远程运行资源引用；未创建tasks.md。检查范围是规划产物及README/overview/dashboard，不是浏览器响应式视觉验收。

未运行游戏测试、录音或基准。执行前和完成时均未发现.specify/extensions.yml，因此没有before_plan/after_plan hooks可执行。下一步为speckit-tasks。
