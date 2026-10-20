# Contract — Opening Pacing and Spawn Safety

日期：2026-10-19；设计合同，现已接线；自动/导出通过，游戏验收状态见[矩阵](../../../docs/validation/combat-pacing-audio/acceptance.md)。覆盖本切片FR001–006、FR010–012及SC001/002/005/006。继承[旧系统合同](../../001-abyss-expedition-mvp/contracts/systems.md)，仅替代首波场边和前120秒全Thrall默认。

## Scheduling and composition

`WaveSchedule.composition(tick, wave_types_rng, modifiers) -> Array[StringName]` 保留调用形态，不接受玩家等级、职业强度或同伴数量。调用者仍仅在每600tick调度。`phase_at`继续返回原主阶段；新增开局段查询供composition使用。

| 主动秒 | 主动tick | 四基础槽 |
| --- | --- | --- |
| 0/10/20 | 0/600/1200 | TTTT |
| 30/40/50 | 1800/2400/3000 | TTTB |
| 60/70/80 | 3600/4200/4800 | TTTC |
| 90/100 | 5400/6000 | TTTT |
| 110 | 6600 | TTBC |

T=`saltbound_thrall`、B=`skittering_brinejaw`、C=`lantern_cantor`。无腐化修正且未扣安全/容量名额，12波48槽，合计40T/4B/4C。下列步骤顺序不可交换：

1. 复制固定4槽。
2. 计算N=ceil(4×既有count倍率)，追加N−4个T。25+的1.1及100的1.2均得到5槽；不按比例追加特殊敌人。
3. 根据旧FR036执行腐化母体替换：令T为此时Thrall数量，每槽抽一次 `[0,10*T-1]`。brood=true且该槽是Thrall且roll<N时将其替换为reef_broodmother。brood=false也消费相同抽样但不替换。B/C不改变；期望总母体份额为10%，不是每波保证固定母体数量。详见[研究R2](../research.md)。
4. 将最终类型数组记入wave trace，然后独立做位置/容量判断。不能因安全跳过而改类型再试其他名额。

`tick>=7200` 完全沿用原主阶段加权、数量倍率及introduce处理；tick32400停止普通波和幼体生成。整个九分钟前仍54波408基础槽。角色强弱可改变击杀/现场容量，不能改变计划组成/属性。

## Opening candidate and reservation

`SpawnDirector.initialize_opening(origin)` 在RunManager.start创建主角后、第一模拟tick前调用一次。`opening_origin`不随移动改变。首波tick0每个槽使用象限`slot_index mod 4`，该象限内角度和128–160半径各取一次spawn_positions RNG；按槽、尝试次序采样。重试最多16次，顺序/次数写trace。后续tick>=600使用原edge_candidate，仍每次两次取样。

候选必须在当前可走矩形内（现safe使用Rect2(8,8,944,524)），对每个存活队员距离≥96。当前场景无内部障碍，装饰可走；实施时不新增导航或障碍系统。无法放置永久跳过，不能缩距离、取消预警、场边回退、移走玩家或积压补刷。

`reserve`成功占用容量并显示现有橙色警告，due=scheduled_tick+45；普通敌人含幼体与未激活普通预警合计≤100，首领独立于常规cap。同一名额最多一个warning与一个最终结果。

首波使用同一个Telegraph实例及世界坐标，由远征的OpeningWarnings（CanvasLayer2、follow_viewport_enabled=true）显示在HUD之上，低于App弹窗20与DEV100；避免seed303预警被计时HUD遮挡。不加入模拟、存档或trace字段。

激活前再检查当前存活队员与位置；不安全就取消并销毁warning，不能搬到其他位置后立即激活。冻结主动时间也冻结预警；恢复完成剩余时间。母体幼体继续使用原母体附近/24单位队员分离/最多3幼体与母体死亡取消规则；首领沿既有保留请求重试规则。

## Time and 120-second boundary

沿用SimulationCoordinator阶段：移动/已有行为→接受伤害与终局→腐化分钟增量、奖励拾取→升级→事件/救援→预警激活/本波排程/攻击→tick前进。暂停保留当前stage，不从stage0重新开始，也不补墙钟时间。

tick7200：先本分钟腐化，再全部升级选择，再原2分钟事件，解决后只排一次原第二主阶段6基础槽波。110秒以前的敌人（包括Cantor）持续活动；90/100秒只是减少新特殊敌人，不清场或禁用存活行为。9分钟首领不变。

## Observable contract / acceptance

- 操作仍WASD/方向键、自动索敌攻击及原升级选择，没有新增攻击键或强制提示。
- 安全、无容量阻塞的正常开局四个预警在可见近场；首次接受伤害≤5秒、首次击杀≤10秒、首次实际显示升级≤30秒，分别记录主动tick和UI挂载时的主动时间。
- 不能以生成B/C冒充遭遇：分别记录Brinejaw实际进入冲刺、Cantor实际发射hostile_shot；要求45/75秒前。用既有预警/行为，不提前解锁伤害或改射程。
- 3角色×3seed固定9样本。安全负例单独统计，不能把普通失败改标无效；失败不更换seed。不用开发工具达成这些时限。
- 生成与音频各用独立状态；波次、位置、升级等4个玩法RNG流不能被声音消费。

## Changed tests and legacy contracts

| 现有位置 | 实施时更新 | 保留 |
| --- | --- | --- |
| wave_schedule.gd validate / ContentCatalog | 开局覆盖/类型/4槽/敌人引用及坏Resource负例 | 原五主阶段校验 |
| test_waves.gd | 12波逐槽、48总数、首波128–160、后续场边 | 45tick、复检、100cap、54波408、幼体规则 |
| test_corruption_combat.gd | 全5开局段×0/24/25/49/50/75/99/100；额外100%T、精确替换阈值与份额 | 120秒后旧权重、腐化伤害/XP快照、分钟先于排波 |
| test_choice_pause / test_m4_chapter | 1800/3600/5400/6600/7200前一tick、同tick中断、后一tick恢复 | 原选择优先顺序和无补刷 |
| test_replay / test_m2_party | 新生成终结trace、音频开/关9对、单人/满队与强弱计划一致 | 相同状态/seed/输入确定性 |
| 旧MVP spec与systems合同 | 实施时标注002覆盖首波及前两分钟，不将旧文档自动重写成新验收结果 | 后段规则、历史报告、存档与DEV证据 |

新trace区分warned与activated/canceled；没有实际激活结果即不足以验证SC005。完整验证流程见[quickstart](../quickstart.md)。
