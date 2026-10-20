# Phase 1 Data Model

> 实施更新 · 2026-10-19：核心已接线，自动与导出/真实输出检查完成；自然/真人/性能完整验收状态见[证据矩阵](../../docs/validation/combat-pacing-audio/acceptance.md)。下列“拟实施/未实施”描述保留为设计阶段历史，不代表当前状态。

日期：2026-10-19。以下均为拟实施增量，不是已存在字段的声明。配置由ContentCatalog加载/校验，运行时不修改共享Resource；沿用profile schema v3，无新永久数据。

## 1. WaveSchedule / OpeningSegment

在现有 `data/encounters/coast_waves.tres` 增 `opening_segments: Array[Dictionary]`；现有phases/interval/stop_tick/cap保留。

| 字段 | 类型 | 约束 |
| --- | --- | --- |
| start / end | int / int | 半开主动tick范围，600对齐，无缝覆盖0–7200 |
| slots | Array[StringName] | 恰4个已登记enemy ID，固定顺序，不是权重 |

| start–end tick | slots简称 |
| --- | --- |
| 0–1800 | T,T,T,T |
| 1800–3600 | T,T,T,B |
| 3600–5400 | T,T,T,C |
| 5400–6600 | T,T,T,T |
| 6600–7200 | T,T,B,C |

T=`saltbound_thrall`；B=`skittering_brinejaw`；C=`lantern_cantor`。校验缺字段、非法类型、重叠/缺口、槽数、未知ID和精确FR004组成；错误为content gate失败，不能静默回退。

关系：WaveSchedule→OpeningSegment→EnemyDefinition。组合输出为新数组：四基础槽→追加Thrall到ceil(4×数量倍率)→腐化Thrall替换。后段phases仍由既有校验约束。

## 2. FieldDefinition / OpeningOrigin

现有FieldDefinition增加 `opening_radius_min=128.0`、`opening_radius_max=160.0`、`opening_attempts=16`。数值必须有限且符合本切片合同；spawn_warning_ticks=45、separation=96，场地bounds不变。

运行时SpawnDirector持有 `opening_origin: Vector2`，由RunManager.start在首次模拟前传入；不是存档或随玩家移动更新的值。首波类型与后续波都使用当前存活队员位置进行安全检验。

## 3. SpawnReservation / SpawnTrace

沿用reservation的id(enemy ID)、point、due、parent、boss、warning、modifiers快照；增加稳定 `reservation_id`、`scheduled_tick`、`slot_index`、`source`（opening/edge/summon/boss）。序号只由生成服务递增，不用节点instance ID。

状态：`planned → cap/unsafe` 或 `planned → warned → activated/canceled`。warned必须等待45主动tick；取消记reason（unsafe_at_activation/parent_dead/boss_boundary/run_end），无迁移、重排或延迟补刷。母体/首领沿既有特殊生命周期，不用首波候选规则。

trace按发生顺序记录稳定ID、tick、类型、候选坐标、尝试数、修正快照和最终结果；不存Node引用或声音播放时间。run_end清理也产生终结记录，随后停止追加旧generation记录。

## 4. CombatAudioDefinition Resource

拟新增 `scripts/data/combat_audio_definition.gd` 和 `data/audio/combat_audio.tres`。

| 字段 | 类型 / 默认 | 校验 |
| --- | --- | --- |
| id | StringName combat_audio | 唯一、已注册 |
| cues | Dictionary | 7键：attack_arc、attack_straight、attack_homing、hit、kill、hero_hurt、level |
| cue.stream | AudioStreamWAV | 本地可导出，非空、非循环、mono PCM；无下载URL |
| cue.gain_db | float | 有限且≤合同初始峰值预算；改值须重测混音 |
| cue.priority | int | companion_attack 10、hero_attack 20、hit 30、kill 40、hero_hurt/level 50 |
| cue.bus | StringName | level为ChoiceSFX，其余CombatSFX；本地bus layout路由Master，均0dB且无增益效果 |
| companion_attack_offset_db | float = −6 | 严格低于主角同类 |
| hit_merge_ticks / kill_merge_ticks | int = 3 / 3 | 独立分类窗口 |
| attack_merge_ticks | int = 4 | 以weapon.mode+主角/同伴分组 |
| voice_count / level_reserved | int = 8 / 1 | 总8；每player单声部；不可配置为更高 |

源音样峰值≤0.5；level时长≤0.160s；建议attack 0.06–0.12s、hit≤0.08s、kill≤0.14s、hero_hurt≤0.12s。预检采样时长/峰值/无效数值，ContentCatalog和脚本manifest纳入新增Resource/脚本及export资源引用。

## 5. Presentation facts and voice state

| 记录 | 字段 / 关系 |
| --- | --- |
| AttackCommitted | generation: int、tick: int、source_id: int、is_companion: bool、weapon_mode: StringName、activation_id: int；成功activation一次 |
| DamageAccepted | generation、tick、request_id、target_id、target_role(hero/companion/enemy/boss)、actual_damage、fatal；仅接受的伤害 |
| LevelPresented | generation、offer_id；App确认当前选项已实际挂载后发送 |
| VoiceSlot | slot_index、busy、cue、priority、start_serial、generation；固定8项，归VoiceAllocator所有，0号升级专用 |
| VoiceAllocator | 8项VoiceSlot、last_merge_tick按类别有界字典、诊断计数；不持有offer_id或升级队列 |
| AudioSession | generation、enabled、allocator实例、last_level_offer_id、upgrade_fifo、disposed；归CombatAudio所有，不复制last_merge_tick |

AttackCommitted.source_id取攻击者现有的稳定actor_id，weapon_mode取攻击提交时的actor.weapon.mode，有效值为arc/straight/homing；事件字段名不使用actor_id或嵌套weapon。

CombatAudio唯一拥有last_level_offer_id和upgrade_fifo，负责呈现去重、升级排队、暂停及终局清理。VoiceAllocator负责8声部占用、共享仲裁、合并窗口及诊断；0号声部由CombatAudio提交播放及释放，不参与共享抢占。终局由CombatAudio清除自己的升级状态并重置Allocator。

offer_id在同一generation单调递增，以最后已接收ID去重，不保存无界历史集合。升级FIFO只存真实已显示且尚未播放的offer_id；不复制选项和整个trace，完成即移除，终结全部清空。其数量不超过该远征实际已呈现的未播放升级数，正常160ms短句/180ms输入保护下不堆积；注入连选负例验证逐条播放与清理。

声音状态：free→playing→paused→playing→free，另有steal/stop直接free。FIFO只有升级例外，战斗请求无队列。声音enabled、完成回调、设备状态均不能写玩法或RNG。具体仲裁见[audio合同](contracts/audio.md)。

## 6. Pause state

保留PauseCoordinator.tokens（token→reason/owner）与serial，新增只读changed通知；acquire/release成功/cancel_all后发送。音频由快照派生，不释放token。App持有focus_token，失焦只获取一次、重获焦点只释放该token；退出远征清引用。manual/level/event/rescue/summary/debug的所有权保留。

## 7. AcceptanceSession（测试证据，不是玩家存档）

记录字段：session_id、engine/simulation/catalog/build/fixture hash、hero、seed、永久等级/职业/同伴/腐化、音频开关/设备/driver、tick输入变化和选择、暂停动作、首个accepted hit/敌人death/已显示level/rush/hostile_shot的tick、planned/warned/activated/canceled计数、最终战斗状态、录音路径、失败分类。

输入日志保持60Hz active tick；墙钟时间只用于录音/暂停观察，不参与模拟。玩法相等比较排除录音时长、播放器状态和性能计时；包括HP、位置、冷却、状态、kills、成长、敌人/弹体/奖励剩余及四个玩法RNG状态。运行截止7200边界事件解决并验证一次后再推进到7260tick（121秒），不足则记录提前结束原因，不伪造完成。

正常档案保持不动；自动夹具test_mode与子进程APPDATA隔离；真人会话用独立正常初始档，不开开发无敌/速度/刷怪。证据manifest引用输入hash，拒绝静默换seed或删除失败。
