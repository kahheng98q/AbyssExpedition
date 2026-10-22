# Contract — Sword Combat Presentation

2026-10-21 · 设计合同；当前实装与验收以[实际矩阵](../../../docs/validation/sword-promotion-identity/acceptance.md)为准。补充[001系统合同](../../001-abyss-expedition-mvp/contracts/systems.md)，不替代其玩法规则。字段定义见[数据模型](../data-model.md)。

## C1 · 真实攻击与显示

- AttackExecutor继续在存活、冷却就绪且有合法目标时增加一次activations；一次双弧／旋斩／Echo不额外计数。新远征归零。
- 普通剑圣两弧按原方向及+20°同时创建，原伤害倍率／射程／角度不变；第五次额外360°弧读取profession.effect_radius；第六次回普通双弧。深渊读取实际actor.stats.reach／weapon.arc_angle，装饰不得越界暗示有效伤害。
- create_arc接收可选SwordArcVisual；无元数据走原路径。渲染只读hit几何副本，不重选目标、不新enqueue_hit、不移动请求或消耗RNG。Echo携带原发动身份，保留原due，不传播heal_source。
- 弧边界在原创建tick同时显示；正常stage4发动排队，下一tick stage1结算。完整轮廓与可见挥刃不得制造第二次延时伤害；受伤／死亡覆盖主体姿态不取消已排队的原伤害。
- attack_committed六字段、damage_accepted与hit_confirmed现有参数保持。新增视觉数据不能顺带改音频或其他职业。

## C2 · 唯一真实治疗来源

原DamageService分支治疗块必须满足：请求属于当前generation、receive接受命中、来源仍存活、带第五次治疗标记、原source:activation键未消费。沿原顺序调用heal并标记消费，然后按after−before产生事实。

| 情况 | 治疗／提示合同 |
| --- | --- |
| 受伤第五次有效命中 | 原治疗量，actual_heal>0，恰好一条事实与一次回流 |
| 接近满血 | 取生命上限裁剪后的实际增量；显示一位小数 |
| 满血合法第五次 | 原去重键仍消费；0增量，无成功提示；之后受伤不补发 |
| 第4／第6次、无目标未发动、被拒绝或无实际伤害 | 不新增分支恢复或成功提示 |
| 致死命中 | 目标mark_dead不取消存活来源的原合法恢复 |
| 来源已死／不存在 | 不恢复、不复活、不提示 |
| 同次多目标／双弧／额外斩击 | 原一次治疗限制；Echo不带新资格，最多一条成功事实 |
| 同伴 | 按该同伴真实最大HP与原规则恢复，治疗不因0.5伤害倍率折半；提示跟随该同伴 |

不修改ActorHealth.heal签名或其他治疗调用；不从总HP变化推断分支成功，不重复应用事实。

## C3 · 表现边界

每来源最多一个36主动tick治疗记录，总数≤3，独立于既有48条伤害记录；同源新事件替换旧显示，金额不相加。只接当前generation、递增activation_id和正actual_heal；重复／旧事实无提示。来源死亡／移除、终局或重开清除；run暂停时停龄，恢复不追赶、不补播。新信号不得驱动音频。

提示读当前来源位置，显式区分主角／同伴；数值四舍五入至一位，误差≤0.05。小正数可显示+0.0与回流，不能强制显示+0.1。事实中的原始浮点不修改。

## C4 · 视觉身份与敌我语义

纯绘制器不持有写玩法接口；single／dual／long在idle／move／attack均有几何差别。保持32px主体、最近邻与整数绘制坐标，death > hurt > attack > move > idle。单剑／双刃／长刃不靠颜色唯一辨识，主角浅金标记与同伴较弱标记保留。

友方旋斩不用敌方橙色预警／红色危险语义；完整细轮廓及短扫刃不遮HUD、主角或最近危险。无需新摄像机震动、全屏闪光或时间缩放。实际判定边界与视觉边界、灰度、密集遮挡由真实图形检查及人工辨识证明，不由headless断言代替。

## C5 · 验证对应

FR-001–004／008–011、SC-002／003／005：扩展abilities、combat_feedback、combat_audio、replay，覆盖两剑系英雄及主角／同伴、高攻速、4／5／6次、满血后受伤、多目标／致死／拒绝／死亡、暂停／重开、表现开关的完整状态一致性。所有新增验证尚未执行。
