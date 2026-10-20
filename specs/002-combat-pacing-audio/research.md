# Phase 0 Research — Combat Pacing & Audio

> 实施更新 · 2026-10-19：核心已接线，自动与导出/真实输出检查完成；自然/真人/性能完整验收状态见[证据矩阵](../../docs/validation/combat-pacing-audio/acceptance.md)。下列“拟实施/未实施”描述保留为设计阶段历史，不代表当前状态。

日期：2026-10-19。状态：设计决策已定，未实施/未做本切片游戏测试。依据为本地代码、当前规格、旧MVP合同及下列Godot 4.5官方文档。没有新增外部依赖或素材。

## R1 — 固定开局与旧主阶段共存

**Decision**：保留WaveSchedule的五个主阶段，增 `opening_segments`，只在 `[0,7200)` tick 使用固定四槽。顺序为TTTT、TTTB、TTTC、TTTT、TTBC；T/B/C对应现有敌人ID。数量修正后追加Thrall，最后应用腐化替换。7200起原加权/首次引入逻辑原样使用。

**Rationale**：当前 `scripts/data/wave_schedule.gd` 的validate、content负例和其他测试依赖五主阶段；扩充独立子段避免破坏索引。`simulation_coordinator.gd` 已每600tick调度一次，不需另起计时器。总54波/408基础槽仍成立。

**Alternatives considered**：把子段塞进主阶段会连带改动旧结构；按权重抽四槽无法保证每波恰一个特殊敌人；加怪违反FR004；按队伍强度调节违反FR005。

## R2 — 腐化只替换Thrall且保留总份额

**Decision**：四基础槽+额外Thrall得到N槽，其中T个Thrall。开局每槽固定抽一次整数 `[0,10*T-1]`，仅当brood启用、该槽为Thrall且roll<N时替换为母体；其他槽保留。即每个Thrall替换概率N/(10T)，总预期母体数N/10。brood开/关消耗相同次数，保留逐槽对照；120秒后仍走旧算法。

**Rationale**：旧 [MVP spec FR036](../001-abyss-expedition-mvp/spec.md) 要求母体在总组成中增加10个百分点，取代Thrall。旧roll<10分支建立在加权Thrall占前区间的条件上。固定槽后简单给每个Thrall 10%概率会降低母体总份额。例：110秒腐化数量增加后N=5、T=3，抽 `[0,29]` 的0–4可替换，预期0.5个母体；B/C不受影响。该概率不是每波固定四舍五入出一个母体。

**Alternatives considered**：对任意槽10%替换会吞掉B/C；对Thrall独立10%会偏离旧总份额；每波向上取整母体数会显著增加压力。采用精确整数边界测试和固定样本分布复核，不依赖浮点近似或随机测试偶然通过。

## R3 — 首波初始中心与安全

**Decision**：RunManager.start建立主角后、首次模拟前保存opening_origin。首波四基础槽按四象限候选，半径128–160，每候选两次spawn_positions取样（角度、半径），每槽最多16次；额外槽轮用象限。不安全就跳过，无场边回退。后续仍edge_candidate。复用reserve和激活复检、45tick预警、100容量。

**Rationale**：tick0的stage0先移动，stage4才排波；直接读排波时hero.position不符合初始位置要求。场地当前只有矩形边界，装饰均可走；safe检查边界和存活队员，无需引入寻路。半径上限160加预警半径13可落在中心视口的180半高内，仍须验证实际camera和UI可见性。

**Alternatives considered**：立即刷怪、缩短预警或强制贴脸违反安全；任意失败后补刷改变名额和节奏；引入导航对当前场地无必要。幼体继续母体附近24单位分离，不套普通波96限制。

## R4 — 玩法事实与呈现接线

**Decision**：成功的AttackExecutor.try_activate结束时发一次attack_committed；DamageService在health.receive成功后另发含目标身份的damage_accepted；保留旧hit_confirmed视觉信号签名。App.show_choice校验当前generation/offer_id、挂载UI后通知升级呈现，按generation+offer_id去重。

2026-10-19分析修订：AttackCommitted字段统一为generation: int、tick: int、source_id: int、is_companion: bool、weapon_mode: StringName、activation_id: int。source_id取稳定actor_id，weapon_mode取提交时actor.weapon.mode（arc/straight/homing），不另设同义事件字段。

**Rationale**：无目标/冷却返回false，不应发攻击声。一个activation可能有多弹体/echo，不能逐弹重复。现hit_confirmed已在接受伤害后发送，但friendly来自target.is_hero，主角和同伴都为true，不能据此把所有友伤当主角伤。choice_presented通过deferred调用show_choice，早于真正显示；refresh_modal可重建同一选项。

**Alternatives considered**：监听动画/按键会产生假攻击；health或reward两处各发音易重复致死；听choice_presented或每次Screen.ready会抢先或重复。不得为播放声音修改选择等待时间、伤害结果或奖励。

## R5 — 有界声部、暂停和升级短句

**Decision**：远征拥有CombatAudio，预建8个AudioStreamPlayer，max_polyphony=1；1升级专用、7共享。纯策略VoiceAllocator负责优先级和tick限流；同类命中/击杀3tick，攻击按mode/身份4tick。普通战斗无延期队列。升级FIFO仅收真实显示过的新offer；短句≤160ms，正常低于既有180ms输入保护。升级不被抢占，连选依序完成。

状态所有权：CombatAudio唯一拥有last_level_offer_id/upgrade_fifo及Allocator实例；VoiceAllocator唯一维护8个VoiceSlot、last_merge_tick及策略诊断，不持有offer_id或升级队列。0号声部由CombatAudio提交播放/释放，不参与共享仲裁；终局清理两者各自状态，不维护重复队列或合并时钟。

任何pause token冻结已有战斗声音，拒绝新请求；仅level token时升级允许播放。manual/focus/debug/event/rescue/summary等叠加时，升级也冻结。恢复无阻塞可完成旧短尾/FIFO。finish/leave/rebind/exit_tree显式stop并清空，不依赖finished。配置与完整转移规则见 [audio合同](contracts/audio.md)。

**Rationale**：Godot的polyphony达到上限会自动截断最旧音，不能表达所需优先级；stop不发finished，释放必须主动做。暂停节点仍能收信号，不能只靠SceneTree.paused防止新播放。App目前缺失焦暂停，需要独立focus token；PauseCoordinator加状态通知可在树暂停前及时同步声音。

**Alternatives considered**：每次new播放器会无界增长；单个多声部player不能可靠优先级抢占；全局autoload会增加跨远征泄漏风险；把整树设Always会让玩法错误推进；强制延迟确认改变已有操作。

官方依据：[AudioStreamPlayer 4.5](https://docs.godotengine.org/en/4.5/classes/class_audiostreamplayer.html)、[Pausing games and process mode 4.5](https://docs.godotengine.org/en/4.5/tutorials/scripting/pausing_games.html)。本设计的独立节点池、token门控与FIFO是结合API和本地架构作出的工程选择，不是文档声称的自动功能。

## R6 — 原创音样与保守混音

**Decision**：Python标准库wave/math/random离线生成44.1kHz、16bit、mono PCM WAV，固定合成seed，运行时不生成音频也不使用玩法RNG。7种音色：剑噪声扫切、弓弦拨动、法术泛音、短命中、双层击杀、主角受伤变体、上行升级短句。实际生成脚本、参数、文件hash和来源写assets/provenance.md。

**Rationale**：已有仓库没有这一套音频，标准库足够完成短音样。源峰值≤0.5，初始升级−12dB、主角受伤−16dB、击杀−20dB、命中−24dB、主角攻击−26dB，同伴攻击再−6dB。1升级+7最大共享音的线性最坏峰值约0.68，提供余量；真实识别/削波仍需录音验证。

**Alternatives considered**：下载商业素材带来版权/依赖负担；运行时合成增CPU/随机耦合；无节制随机pitch削弱一致识别。先不加pitch变化、空间化、混响、音乐或玩家设置菜单。

## R7 — 证据与复放不能借用旧通过记录

**Decision**：ReplayTrace增加stable reservation_id、预警来源与激活/取消结果，提升SIMULATION_VERSION。验证器记录实际rush、hostile_shot、接受伤害、死亡和升级UI显示；玩法轨迹与音频播放日志分开。自然开局先录9局，再冻结输入/选择和hash复放，不用旧注入XP/无敌夹具代替。

**Rationale**：旧trace只有waves和warned/unsafe/cap，没有实际生成。旧test_replay的capture_movement注入350XP并设置无敌。Q1 benchmark_quality硬编码Dummy和旧build，既不能验证真实声音开关，也不能复用历史帧时作本版结果。

**Alternatives considered**：只看类型出现不能证明45/75秒实际威胁；只看声音事件计数不能证明可听；只比较seed不能证明输入/队伍一致。采用quickstart矩阵和专用证据目录，失败也保留。

2026-10-19分析修订：原20题四类别盲听增加同题职业判分，攻击5题固定剑2/弓2/法1；至少4名参与者各自同时达到类别≥16/20、职业≥4/5且每职业至少1题正确，职业仅在类别及职业均正确时计分。题序/音样hash/答案表预先冻结，隐藏标签、不反馈答案并保存原始回答；这是待执行验收标准。新增combat_audio测试在T034–T037编写后，由T038先注册到正常runner并记录red，T047负责集成green。

## Resolved unknowns / remaining acceptance

技术选择、接口、数据和采样协议已决定，无未解决的规格澄清。自然开局目标可行性、混音可识别性、真实设备/人工可用性和性能结果只能在实施后验证；全部保持未验证，不将研究决策当作验收通过。
