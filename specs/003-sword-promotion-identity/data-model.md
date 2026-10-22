# Data Model — 003

2026-10-21 · 待实施设计。新增只涉及表现Resource、内存状态及验证文件；profile schema v3不变。

## SwordVisualIdentity（VisualSet扩展）

| 字段 | 约束与关系 |
| --- | --- |
| sword_identity | StringName：空／single／dual／long，默认空；三剑系内嵌Resource赋后三值，其他职业空值走原路径 |
| silhouette / palette | 保留既有字段与枚举兼容；颜色只辅助身份 |
| idle / move / attack / hurt / death | 保留既有标识；不定义真实伤害时点 |

校验拒绝未知身份及三剑系资源错配。英雄通过profession.visual_set关联，不按名字分支。Resource不可存当前HP／攻击次数或被预览改写。

## SwordPose（纯绘制输入）

字段：identity、state、aim、active_tick、attack_age、moving、palette、is_companion、owner_marker。state唯一且death > hurt > attack > move > idle；位置方向取值副本，绘制器不持有可写run／profile。32px主体与身份标记保留；绘制取整不修改物理坐标；attack_age不控制AttackExecutor。

## SwordArcVisual（弧表现元数据）

| 字段 | 约束 |
| --- | --- |
| generation / source_id / activation_id | 当前远征、来源actor、原实际发动次数；不新造计数 |
| profession_id / identity | 真实职业及VisualSet身份 |
| arc_kind | base／primary／secondary／spin／echo |
| born_tick / expires_tick | 原创建tick／tick＋10 |
| origin / direction / reach / angle | 直接取实际hit参数；有限向量、非负有限reach、真实弧角 |

每个弧仍对应原一次create_arc；一次发动可以多弧。Echo保留原发动身份和原due，不取得新的发动或治疗资格。元数据只进显示路径；非剑系默认空。不持有可写hit引用；若使用嵌套集合需逐层冻结。

## BranchHealApplied（新只读事实）

| 字段 | 约束 |
| --- | --- |
| generation / tick | 当前远征及实际结算主动tick |
| source_id / is_companion | 存活的实际恢复者 |
| activation_id / request_id | 原发动与触发接受命中的请求ID |
| actual_heal | float、有限且>0；heal后current减heal前current，不预取整 |
| source_position | 值副本，用于诊断；显示仍按恢复者当前位置跟随 |

DamageService原分支治疗块生产；CombatFeedback与只读测试消费。标量／值字段在Dictionary.make_read_only后发送，不触发新heal、攻击或音效。每个(generation, source_id, activation_id)最多一次。

原activation_heals的source:activation键属于玩法：合法治疗尝试后照常写true，包括满血0增量；它不因是否显示反馈而改变。

## HealFeedbackRecord（内存）

generation、source_id、activation_id、actual_heal、born_tick、expires_tick。按source_id索引，最多3个队员记录、36主动tick；新同源成功替换旧记录，不累加量。去重仅存每来源最后已接收activation_id，随run清空。

显示`+%.1f`，按实际增量四舍五入。真实正值<0.05可显示+0.0及回流，不虚增为0.1；显示与原值误差≤0.05，测试仅容许浮点epsilon。

状态：有效事实→显示→主动时间到期／恢复者死亡离场→移除；暂停停龄；终局／generation变化→全部清理。拒绝旧generation、非正值及重复事实；无墙钟驱动、无随机数、无补播。

## PromotionPreviewSession（独立示例）

| 字段 | 生命周期／约束 |
| --- | --- |
| hero_id / branch_id | 仅显示身份及只读配置来源 |
| session_id | 页面本地代号，不使用真实run generation |
| tick / cycle_ticks | 本地60Hz；360tick循环，与Engine.time_scale无关 |
| now_usec | 只读单调微秒时钟Callable，生产默认Time.get_ticks_usec；仅逻辑夹具可注入，不暴露玩家开关，不用于真实播放验收 |
| activation_index | 0–5；30／90／150／210／270tick递增；下一tick示例结算，360重置 |
| sample_max_hp / sample_hp | max来自分支基础值（当前250）；初始max−10；第五次取min(max, hp＋max×heal_fraction)，显示after−before（当前5.0） |
| focused / visible / host_occluded / stopped | 独立生命周期；普通页host_occluded来自DEV overlay显隐，DEV内页不使用该遮盖源；不修改树暂停或run token |
| pose / arcs / heal_record | 剑圣最多3弧、深渊1弧；每示例最多1治疗记录 |

页面拥有两Session，不引用真实health／RNG／可写payload；目标是绘图状态，无AI／奖励／DamageService。配置读取为快照，不能给共享Resource写入状态。branch_previews仍有两个原分支键，剑系值可替换为Control。

状态：create→running；初始失焦或失焦／隐藏→frozen；回焦可见→原tick继续（重置单调时间基准）；确认提交／离页→stopped→释放。每循环清弧、重置示例HP／计数。重开新建实例，取消不写数据；正常页被DEV遮挡时暂停其示例，DEV内自己的示例仍可运行。

## ValidationSession（证据，不是游戏存档）

记录run_id、engine、source_manifest、build_hash、fixture_hash、protocol、seed、hero／profession／party、starting_profile_hash、inputs、choices、environment、outcomes、failures、limitations。

- 自然九局（2026-10-21授权延期验收、不阻塞实施）：固定9条Integrated真人输入；1级／基础职业／无同伴／腐化0；首命中／首杀／首升级主动tick，缺失与死亡明确失败。
- 比较：两个版本分别核验manifest，相同输入和选择；逐tick玩法投影保留原全部玩法字段、伤害／治疗与发动／冷却、RNG、波次／升级／事件及终结状态。投影固定为sword-gameplay-v1，只将版本／catalog身份、effects.color及effects／followups内新增sword_visual移至诊断区；原几何／expires／due／damage等仍逐字段比较，未知字段变化失败。具体白名单和负例见contracts/validation.md的V3。
- 人工：P01–P05原话、盲测顺序、图像hash、答案、死亡／疲劳／重试意愿；另存12段灰度片段的原始首答／普通与第五次分组得分及10张密集截图得分，分别判定，不自动生成回答。
- 性能：前后逐帧CSV、实际负载、30秒预热／120秒样本、设备／焦点／音频／后台观察范围、p95／p99及失败原因；另存12个600tick窗口的起止tick、双斩／旋斩／长弧／正治疗计数、缺血输入、实际HP差及候选四类表现的真实渲染帧关联。缺任一窗口／计数不足即capture_valid=false，完整下限和队伍见contracts/validation.md V5。
- 真实预览：build／host／speed／size、时钟来源、各循环有效播放微秒／失焦时间、开关次数、内部150秒／外层180秒截止及部分失败记录；注入时钟的逻辑结果不得标为真实播放。

旧记录只读；缺失／失败／无设备／无人操作不记pass。
