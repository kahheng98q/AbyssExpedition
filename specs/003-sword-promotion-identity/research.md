# Research — 003 剑系转职可感知差异

2026-10-21 · Phase 0完成。两项只读研究分别覆盖战斗／治疗和转职／保存／DEV；未运行游戏测试。以下Decision为待实施设计。

## R1 · 原创程序像素与共享绘制

**Decision**：VisualSet增加可选`sword_identity`，由三剑系职业内嵌Resource配置；抽出`sword_presentation.gd`供实战与示例使用，只重构剑系绘制。

**Rationale**：[VisualSet](../../scripts/data/visual_set.gd)承载表现，[ActorPresentation](../../scripts/combat/actor_presentation.gd)三剑系目前共用sword主体。按资源选择single／dual／long同时覆盖Aren、Brann和同伴。先归一death／hurt／attack，避免现有draw_hero仅看attack_until而在受伤时仍取攻击姿态。[美术约定](../../docs/art-direction.md)允许原创程序像素：32px、nearest、绘制取整，实战12tick攻击姿态／10tick弧不改变结算。未来精灵表仍沿用idle 4帧/6FPS、move 6/10FPS、attack 4/12FPS、hurt 2/12FPS、death 6/8FPS，本切片不制作精灵表。

**Alternatives considered**：仅改颜色不满足灰度；重画所有职业／引入动画包超范围；复制Actor和RunManager进UI扩大副作用。Godot支持通过自定义绘制及queue_redraw更新视觉，本设计只用其绘制能力，不由绘制推进玩法。[Godot 4.5官方绘制文档](https://docs.godotengine.org/en/4.5/tutorials/2d/custom_drawing_in_2d.html)。

## R2 · 视觉信息随真实几何传递

**Decision**：既有弧路径附加只读视觉元数据，区分主弧／次弧／旋斩／Echo；不扩现有音频事实，不新增攻击模拟。

**Rationale**：[SwordBranchAttacks](../../scripts/combat/sword_branch_attacks.gd)同次创建主弧与+20°次弧，第五次加360°旋斩；深渊基础reach64，实际取actor.stats。[SimulationCoordinator](../../scripts/core/simulation_coordinator.gd)正常stage4发动排队、下一tick stage1结算；不能为视觉挪动此顺序。[音频测试](../../tests/integration/test_audio_facts.gd)要求attack_committed恰好六字段，直接增加字段会破坏合同。完整范围边界随创建同时显示，后续扫刃不暗示延迟第二次伤害。

**Alternatives considered**：新增通用事件总线无必要；延时真实第二刀改变玩法；UI重算射程会与升级／被动漂移。可选元数据只影响渲染，非剑系走原默认路径。

## R3 · 恢复量取原结算点实际差值

**Decision**：保留ActorHealth.heal签名；DamageService原治疗调用前后读HP，增量>0发只读branch_heal_applied。原activation_heals标记无论增量是否为0都照常写。

**Rationale**：[DamageService](../../scripts/combat/damage_service.gd)在接受命中及致死目标mark_dead之后处理恢复，存活攻击者可以从致死命中回血。同伴伤害0.5与治疗不折半是不同规则。满血合法命中也消费该次机会；去重若移入正增量分支，会错误允许之后受伤补回血。无目标不发动，Echo不自带治疗标记。

**Alternatives considered**：观察HP变化不能辨别其他被动／升级治疗；显示理论maxHP×2%会夸大近满血收益；改heal返回值扩大其他调用影响。

## R4 · 有界、跟随恢复者的成功提示

**Decision**：原48条伤害burst保持；治疗单独最多3个记录，每队员1个、36主动tick；新增同源事件替换旧记录，不累加金额。原浮点仅在显示时四舍五入一位小数。

**Rationale**：[CombatFeedback](../../scripts/combat/combat_feedback.gd)目前只接hit_confirmed且用ceili显示伤害，不能用于治疗精度。独立小预算避免密集伤害挤掉唯一成功反馈；恢复者ID解析当前位置，死亡／离场／换generation清除。≤0.05显示误差以浮点epsilon辅助断言。

**Alternatives considered**：无限浮字造成增长；多次恢复合并失去单次归因；重做全部伤害队列属于后续全局密集画面切片。

## R5 · 演示只持独立状态

**Decision**：轻量promotion_preview Control管理固定360tick示例，共享实战绘制器，读取配置快照，不调用真实战斗／保存服务。30／90／150／210／270tick发动，下一tick示例结算，第五次显示分支效果。明确标注“演示／示例数值／节奏示意”。

**Rationale**：[promotion.gd](../../scripts/ui/promotion.gd)现有branch_previews是静态hero，只有不推进的独立RunClock；setup后仅换profession，stats仍可能是基础职业值，不能沿用这种隐式示例数值。新示例maxHP读取分支基础值（当前250），初始缺10，按heal_fraction计算实际示例增量（当前5.0）；每循环重置。六秒演示不代表真实攻速。scene_smoke仅检查branch_previews字典大小2，保留键和原页面信号／public字段即可替换剑系值；非剑系静态展示不变。

**Alternatives considered**：完整RunManager带来奖励／声音／随机污染面；复制完整战斗算法形成第二套规则；固定视频不能随当前Resource与绘制更新。

## R6 · 普通与DEV宿主的生命周期

**Decision**：画布直接绑定所属Window的focus_entered／focus_exited，并在创建时读has_focus；本地单调时间差转60Hz，独立于Engine.time_scale，失焦／隐藏停钟，恢复重置时间基准不补播。离页清理并断开连接。

**Rationale**：App当前focus只处理active run；DEV是暂停树的ALWAYS面板且复用promotion页，不能依赖App已有run通路或全局paused。直接Window绑定让两个宿主共用相同逻辑；已失焦时创建也必须冻结。普通页由App注入现有debug_panel.overlay，监听visibility_changed并初始化遮盖状态；关闭被拒绝时overlay仍可见，不能提前恢复。DEV内页不绑定这个遮盖源。Godot提供这些焦点接口及暂停处理模式。[Window 4.5](https://docs.godotengine.org/en/4.5/classes/class_window.html) · [Node 4.5](https://docs.godotengine.org/en/4.5/classes/class_node.html)。旧72×58预览区域容不下64reach长弧，需调整为有界画布和整数尺度，普通／DEV面板均≤640×360。

**Alternatives considered**：全局解暂停破坏DEV；用真实RunClock污染远征；依赖缩放delta让1×／4×调试速度改变示例时长；仅路由转发需额外维护两个创建／退出通路。

## R7 · 原转职及保存保护

**Decision**：保留confirmed(hero, branch, revision)、canceled、submitted及PromotionService资格；保存失败继续由App／SaveCoordinator处理。预览不发confirm、不重试保存。

**Rationale**：原等级15、1道具、永久一次、保留等级／被动、revision与冻结pending结果已有测试；DEV另经action service沙盒。页面新增展示不能改变这些权限。DEV首次ensure_session会有意建立沙盒并切换writer；零变化检查在其成功之后取基线，另检查normal_writer持续不变。

**Alternatives considered**：预览直接改payload／调用promote会破坏取消无副作用；另建提交路径重复已有原子保存逻辑。

## R8 · 前后版本与性能证据

**Decision（2026-10-21用户授权修订）**：自然九局延期验收，实施前先冻结改前源码／构建及输入，优先采完整玩法状态和Release性能；环境缺失只阻塞对应验收，可用冻结旧版补采；拟新增Compare入口核验每版本自身manifest，再比较同输入玩法与环境匹配的性能记录。

**Rationale**：[002工具](../../tools/validate_pacing_audio.ps1)的Replay仅接受同build hash，Benchmark也要求源码／Release／fixture一致，不能绕过守卫让改后源码验证旧EXE。SC-005须另覆盖同英雄15级独立档及分支、同伴、其他职业、预览访问／表现开关。SC-006按Q1负载；现有benchmark可能只用基础职业，需在实施时加入剑系负载夹具并先在改前版采同一负载，不改变敌人／弹体／宝石数以达标。

**Alternatives considered**：关闭hash校验破坏可信度；重新生成不同输入不能证明等价；headless耗时不能代表实机渲染。环境／人工缺失继续待验。

**交叉复核补充**：pacing_observer当前会采集effects.color和全部followups，ReplayTrace.start.catalog也随VisualSet变化。选定固定sword-gameplay-v1投影，将明确的颜色／新增sword_visual及各版本身份移入诊断区，其余原玩法字段全部比较；不删除整个effects或followups。另验证所有非VisualSet玩法配置一致，加入视觉变更可通过、同容器damage／due／几何变更必失败的测试。比较合同列出完整排除白名单。

## Resolved Questions

**2026-10-21分析修订**：原生runner只有55秒，真实10个六秒循环不能放入该suite。选定生产默认单调时钟、逻辑夹具注入同一状态机、独立真实播放脚本及150／180秒双层截止；不提高所有测试超时。旧压力夹具满血并长期防伤，新增固定600tick缺血输入和12窗分支／正治疗／候选渲染守卫，详见验证合同V5；该输入只属于Benchmark场景，不改变玩法规则。灰度分支识别单列12段题材与≥10/12、普通／第五次各≥5/6的五人判分，原密集预警测试保持。以上是设计修订，尚无执行结果。

已确定程序绘制、Resource字段、弧元数据、治疗事实、有界反馈、隔离演示、焦点／DEV、保存及前后比较方案。无剩余技术澄清项。FR-012自然九局和其他人工验收仍是未满足证据，研究不代替验证。
