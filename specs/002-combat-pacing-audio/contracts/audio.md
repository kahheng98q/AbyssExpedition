# Contract — Combat Audio Presentation

日期：2026-10-19；设计合同，现已接线；自动/导出通过，游戏验收状态见[矩阵](../../../docs/validation/combat-pacing-audio/acceptance.md)。覆盖FR007–012和SC004–007。没有网络接口；这是玩法事件→声音呈现、UI首次显示→升级反馈的本地合同。

## Ownership and facts

RunManager在start时创建一个CombatAudio子节点并bind当前generation；不放App全局autoload或可替换Screen。App仍独占原有DebugPanel。音频只读事实，不调用伤害、奖励、升级、存档、时钟或玩法随机数API。

| 发布点 / 拟接口 | 发布条件 | 必需信息 / 消费行为 |
| --- | --- | --- |
| AttackExecutor / run.attack_committed | try_activate真正成功、所有分支提交后一次 | generation: int、tick: int、source_id: int、is_companion: bool、weapon_mode: StringName、activation_id: int；weapon_mode为arc/straight/homing |
| DamageService / run.damage_accepted | health.receive返回true后 | generation、tick、request_id、target_id、target_role、actual_damage、fatal；每接受请求一次 |
| App.show_choice / audio.present_level | 当前generation有效、offer_id仍匹配且界面已挂载 | generation、offer_id；相同或旧ID重复请求无效果 |
| PauseCoordinator.changed / audio.sync_pause | token集合实际改变 | 当前只读reason快照；音频从不释放token |
| run.finish / App.leave_run / node exit | 终局或离场、重绑定前 | stop_all并使旧generation失效，所有连接/音频状态释放 |

旧hit_confirmed(point,direction,amount,fatal,friendly)保留，不能为声音改变Q1视觉接线。target.is_hero对同伴也为true；新role必须显式区分。敌人/首领存活用hit、致死只用kill；主角无论是否致死用hero_hurt，不播奖励kill；同伴受伤可省略（本切片无同伴伤音要求）。无敌/重复/无目标/未命中/死亡后请求不发有效伤害音。

攻击事件的source_id取攻击者现有的稳定actor_id，weapon_mode取攻击提交时的actor.weapon.mode；事件字段名固定为source_id/weapon_mode，不另发actor_id或嵌套weapon字段。攻击以activation为单位，多弹体、穿透、echo、分支追击不重复基础攻击声；其真实接受伤害仍可产生hit/kill，再由声音策略限流。全部职业分支复用其现有weapon.mode，不按角色显示名分支。

## Voices, arbitration and mixing

预建8个AudioStreamPlayer，每个max_polyphony=1：slot0专供升级，slot1–7共享。占用/暂停中的声音都计入8上限。无每hit创建节点、无实时合成、无全树查找。使用明确本地bus `CombatSFX` / `ChoiceSFX` → Master，无混响、增益效果或配乐；bus与Master初始0dB、muted=false。验证bus存在，不能默默退回未知混音配置。

| Cue | 优先级 | 初始gain dB | 合并/限流 |
| --- | ---: | ---: | --- |
| level | 50，独占slot0 | −12 | 不合并、不丢弃；FIFO逐条 |
| hero_hurt | 50，共享池最高 | −16 | 不套普通hit限流；接受伤害次数受原免疫规则约束 |
| kill | 40 | −20 | 独立3主动tick窗口 |
| hit | 30 | −24 | 独立3主动tick窗口 |
| 主角attack | 20 | −26 | 每mode+role独立4主动tick窗口 |
| 同伴attack | 10 | −32 | 每mode+role独立4主动tick窗口 |

请求在发生时即时仲裁；从该类最近**实际开始播放**tick计算窗口，不延长窗口来挤掉之后的合法声音。低优先级可直接省略，不排队到恢复后播放。free槽取最小index；没有free则抢占优先级严格更低的最旧start_serial（同序选最小index），没有可抢占者丢弃新请求。升级永不被共享声音抢占。hero_hurt若共享池极端全为同优先，则取代最旧hero_hurt，保留最新实际受伤；不影响slot0。

每个音样峰值≤0.5，mono 44.1kHz/16bit非循环WAV。上述增益与独占结构在同相最坏线性叠加时峰值约0.68，仍须真实设备录音查削波。任何加增益/效果/随机音高均须重测；先不加入这些功能。攻击音0.06–0.12s、命中≤0.08s、击杀≤0.14s、受伤≤0.12s、升级≤0.160s。

## Upgrade exactly once

CombatAudio唯一拥有last_level_offer_id和upgrade_fifo，负责呈现去重、升级排队、暂停及终局清理。VoiceAllocator维护8个声部的占用状态、共享声部优先级仲裁、last_merge_tick合并窗口和诊断计数，不持有offer_id或升级队列。0号声部由CombatAudio提交播放及释放，不参与共享声部抢占；CombatAudio不复制Allocator的合并时钟。终局由CombatAudio清除自己的升级状态并重置Allocator。

1. App.show_choice先校验deferred携带generation以及当前offer_id与options；已过期显示请求无音效。
2. UI挂载成功后提交present_level。同一generation中只接受大于last_level_offer_id的新ID；刷新、停留、确认、重建均不产生新的记录。
3. slot0空闲就播放，否则仅把新ID放升级FIFO；当前短句结束后依序播放，不重叠、不被攻击抢占、不截断当前短句。该FIFO只保留实际呈现过的升级，不是战斗积压队列。
4. 正常短句≤160ms，现有Screen输入保护180ms保持原样。程序化连续确认负例可产生FIFO，需验证每条一次、无漏音；不为音频延迟/拒绝合法升级操作。
5. 同一run恢复活动时允许已呈现升级FIFO/短尾自然完成；终局优先，finish立即停止并清空，禁止跨results/retry残留。

## Pause and lifecycle state table

| 运行状态 | 共享战斗声 | 升级声/FIFO |
| --- | --- | --- |
| active且无token | 接受真实事实，现有播放正常推进 | 已呈现短尾/条目可完成 |
| 只有level token | 现有stream_paused=true；新战斗请求拒绝 | 可播放，只响应真实新界面呈现 |
| manual/focus/debug/event/rescue/summary任一token（含叠加level） | 冻结；新战斗请求拒绝 | 当前短句及FIFO冻结，不新开播放 |
| 解除部分token | 依据剩余token继续冻结/允许 | 不从头重放，不复制FIFO |
| results/disposed/generation变化 | stop、清槽/合并时钟、断开旧信号 | stop、清FIFO/去重/旧generation；不可再开始 |
| audio disabled / 无输出设备 | 不输出，可保留测试诊断 | 不输出；玩法持续，听感不判通过；禁用期间不累积待启用补播 |

CombatAudio和播放器可以Always处理，以显式stream_paused表达token语义；禁止把战斗模拟节点改为Always。PauseCoordinator变更同步通知，不只等下一帧App设置tree.paused。暂停节点仍可能收到signal，所有入口都检查phase/generation/token。stop、抢占、换stream后立即重置槽；不能等待stop不发送的finished。

失焦：App记录窗口焦点状态，活跃远征失焦获取独立focus token，重新聚焦只释放自己的token；start时若已失焦应先加token。菜单无run时不建战斗token。结束/重开清旧token引用；不要修改DEV/F9或level/manual所有权。

## Determinism and negative cases

- 音频不读取wave_types/spawn_positions/upgrade_offers/event_offers，不使用全局随机。合成随机只在离线工具中使用固定私有seed。
- 音频开/关同版本、同初始状态、同输入/选择的9对会话必须产生完全相同的玩法trace和最终状态；墙钟播放完成时间不用于任何玩法分支。
- 必测：无目标攻击、同伴禁用AI、无敌/拒绝伤害、同帧过量致死、范围多杀/持续伤害、多弹体/echo、重复offer、旧deferred显示、快速连选、8槽压力、暂停期间signal、多个token、finish及重开。
- 真设备录音检测无削波/残音、升级可听、同伴不过主角；5人×20随机音样（攻击/命中/击杀/升级各5），攻击题固定剑2/弓2/法1并同时记录职业判断。至少4人各自同时满足类别≥16/20、职业≥4/5且每职业至少1题正确；职业题仅在类别及职业均正确时计分。预先冻结题序、音样hash和答案表，保留原始回答，隐藏标签且不反馈答案。纯headless或Dummy不构成这些结果。

## Validation interfaces (implementation work)

VoiceAllocator暴露只读active_count、accepted/dropped/stolen计数、cue_started日志及纯策略入口，方便测试；不新增发布版调试UI。测试可注入无声后端，真实AudioStreamPlayer接线、pause/finished/stop另以集成测试验证。音频测试必须纳入正常验证runner，保留其强制debug_panel gate。
