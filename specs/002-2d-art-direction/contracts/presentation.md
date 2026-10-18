# Presentation integration contract — proposed

本合同定义表现读取与原生UI输出，没有外部API，不新增后端。所有改变必须等待G1与计划/tasks批准。

## Actor / simulation boundary

- 输入只读：definition.id、profession.id/visual_set、health.current/maximum/dead/hurt_until/invulnerable_until、velocity/aim、attack_until、dead_at、ai_state/deadline、corrupted/resistant、is_hero/is_companion、run.clock.tick。
- 输出只限SpriteFrames选帧、flip、整数显示offset、颜色、ownership/状态环、影子和HP条。模拟Actor根、CollisionShape、aim、速度、deadline、damage、cooldown不修改。
- 选择器只有Aren+base swordsman、Thrall、Brinejaw命中批准sprite；失败保留完整程序fallback。不按名字判断，不全局替换swordsman。
- 五状态优先death>hurt>attack/warning>move>idle；窗口由模拟给定。动画frame事件/完成事件禁止触发伤害、随机、保存、掉落、actor删除或结果页。
- 显示snap不回写物理位置；不消费SeedStreams。暂停与倍速按run tick，外观更新不改变模拟顺序。

## Environment / effect boundary

- 保留CombatWorld各host路径、Field四面墙、960×540、camera限制/zoom；TileMapLayer与props无碰撞/nav，神殿不创建交互。
- 腐化只接set_corruption(value)显示0..100；既有怪物/宝石数值不回写；两端保持可走区域相同。
- telegraph.geometry/radius/direction/angle/expires与contains为权威；橙边仍对应实际危险。装饰不遮挡，不能通过贴图尺寸改变判定。
- 剑仅改draw，基础reach48/angle100使用批准sheet，其他参数程序回退并明确记录；命中发生于原有时刻。星只改批准的基础友方homing表现，不改目标/速度/碰撞/生命周期，不给Aren技能。
- 无per-actor灯、动态阴影、全屏后处理/新增粒子。可选shader/light须修订G1和测量。

## Native UI boundary

- HUD保留bind_run与state_changed→refresh，数值来自现有run；bar clamp只影响显示。seed移至现有pause后才从HUD删；腐化精确信息保留C入口。
- Level-up保持confirmed(offer_id:int, upgrade_id:StringName)、实际options顺序、effect_preview与stack，正好三选一；不在UI计算资格/收益。
- screen.gd保留180ms armed_at输入保护、panel/column兼容；router/ChoiceCoordinator/PauseCoordinator拥有模态生命周期。装饰不接管输入/保存/确认。
- 既有键鼠、fresh-input、队列、Esc规则和保存gate不变。F9仅shared styling，debug-only/profile isolation保持。
- Theme本身不授权其他屏幕布局替换。新增组件后的测试可换定位路径，不能删除行为断言。

## Regression / rollback

比较matching snapshot/seed/input/choices/tick的hit、HP、cooldown、target、spawn order、projectile path、升级/保存结果。记录美术引起的expected content digest变化，不削弱replay跨版本校验。保留旧源码/Resource备份或精确补丁+hash、before图；回退仅本批视觉文件/引用，profile不变。

## R1 · Wiring and verification

- actor_overrides.tres显式引用aren_vd01/thrall_vd01/brinejaw_vd01；hero匹配aren+swordsman，enemy匹配两获批definition ID，其他身份/职业完整回退。正常接线缺预期sprite失败，故障回退另测。
- 事件起点：attack_until−12、有效dead_at或致死receive的hurt_until−8、warning时deadline−45；受击单姿闪烁截至实际hurt_until。中断恢复同事件不重播首帧；迟到/跳tick不补播过期事件，idle/move可独立循环；不写模拟。
- 程序背景/新子树互斥，资源完整选择新背景，否则完整回退；四墙始终保留。容器最终Z0，地面−30/腐化−20/道具−10/Actors0/Pickups与救援5/攻击10/Telegraphs20，记录实际父Z/相对Z。
- P01的四边四角避让/裁切由G1冻结；面积与英雄/警示可读性独立验收，上部裁切提案不自动批准。
- test_visual_contract→unit，test_visual_ui→scene_smoke，test_visual_slice→integration_m1；日志证明实际执行，不只注册。
- 原M4基准不改；额外容量P02先G1批准，再独立fixture记录新sprite/回退数，未命中新路径不得声称覆盖或性能通过。

死亡时钟限制：mark_dead不给主角/同伴填dead_at；该类读取致死ActorHealth.receive留下的hurt_until−8，不能用−1起点。没有有效事件时间的人工故障状态直接终止姿态并记录缺项，不写模拟。hurt只用单姿闪烁直到真实截止，兼容2tick抗性反馈；不普遍用hurt_until−8推断所有受击来源。

## VD-01-P2 · authorized text containment correction

Owner requested remaining work on the existing slice after verifying f187. Long hero names may elide only the name, retaining exact Hero Lv and the full name in the existing read-only pause details. Compatibility snapshot text stays exact. ChoiceCard wraps the complete Resource heading inside the original button and uses existing scroll/focus handling; no truncation of upgrade effects, IDs, stacks or rewards. Cache heading measurement until name/level changes. No new screen, gameplay rule, modal ownership, save action or G3 screen redesign is introduced. [Executed evidence](../../../docs/validation/visual-vd01/completion-r1.md).


## VD-01-P3 · retained rendering commands

Unchanged cue/arc inputs may retain existing CanvasItem commands. Presentation transforms and sprite sampling still update from current state; no simulation writes, animation completion callbacks, new assets or lifetime changes. _process is the only changed function in ActorPresentation/MeleeArc; source/release exact-pixel and forced-redraw references validate invalidation. [Local evidence](../../../docs/validation/visual-vd01/completion-r2.md); physical display and complete manual acceptance remain pending.
