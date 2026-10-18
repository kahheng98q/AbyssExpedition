# Visual acceptance checklist — VD-01

所有框均为**未来待验**，不是规划交付清单；本轮不勾选视觉/运行验收。执行时记录证据路径、reviewer/date、结果及限制。自动通过不能代替owner审美批准。

## G0 / G1 — design approval before live edits

- [ ] FR-002/003：来源审计真实；Concept2/3已提供或owner明确批准文字替代。
- [ ] FR-004/007、SC-001：VD revision、owner/date/decision/scope齐全，计划/tasks获批后才改游戏。
- [ ] FR-005–009：HEX角色、材质2–3阶、上左光、近俯视/像素密度、英雄1/3头比例、两敌黑剪影清晰。
- [ ] FR-011/012 + 本次补充：Aren基础、两敌、海岸神殿、剑、既有星、HUD、level-up都有reviewable像素样稿；魔法不赋给Aren，其他waves未删除。
- [ ] FR-013/015、SC-005：640×360、2×/3×/1371、normal/dense/0与100/combined HUD、painted/unlit、灰阶、四向与锚点/身体框、动画strip齐全。
- [ ] FR-014：有效最低帧与NA/复用依据，≤58唯一动画格、16地砖、6道具；3帧attack适配12tick的15FPS提案获批。
- [ ] FR-019：字体/间距/focus/disabled/error/pending页；文字4.5:1、关键边界3:1测量及实际底图review。
- [ ] FR-021/022：每资产source/provenance/license/fallback/state/revision齐全，原始占位源码/截图可回退。

## Implementation / automated gates

- [ ] FR-001、SC-007：Godot4.5 import/parse/content/scene load无错，SpriteFrames/Theme实际接线，无丢资源。
- [ ] FR-001/008：Aren外观选择不误换Brann/晋升/其他角色；未替换资产仍完整表现。
- [ ] FR-010：默认动态灯/阴影/全屏shader/装饰粒子=0；任何可选效果另有批准与成本证据。
- [ ] FR-012/014：原碰撞/field范围/reach/警示geometry和45tick时序不变；动画不触发伤害/保存/移除。
- [ ] FR-017/020：真实键鼠、1–3/Enter/click、180ms fresh-input、升级队列/暂停reason、scroll、确认/禁用原因均通过。
- [ ] FR-016：seed在现有pause可查、C精确修正保留；HP/XP当前最大、Hero/Run Lv、同伴/救援/金币均未丢。
- [ ] SC-007：matching snapshot/seed/input/tick的玩法观测相同；美术digest变化被记录，replay保护未弱化。
- [ ] FR-001/020：受影响M1–M4、progression/save/recruitment、source/release/F9隔离与发布禁用回归通过。

## G2 — actual runtime and manual acceptance

- [ ] FR-023：真实source与Windows release三尺寸+native截图和motion clips，图形可用时不得省略。
- [ ] SC-004：combined boss/双同伴/rescue/max-corruption测得UI矩形union≤25%；0裁剪/不可达/色彩唯一cue。
- [ ] FR-023：integer pixel blocks、无不当blur/atlas bleed、脚锚/flip/运动shimmer、灰阶/无光逐项人工检查。
- [ ] SC-002：十人、每条件至少8人正确识别六项，逐条件原始答案记录。
- [ ] SC-003：十人五秒UI任务至少8人通过；首批HP/等级/升级通过，promotion等后续screen任务仍明确待G3。
- [ ] SC-006：参考机三seed完整负载/30+120 active秒，分别p95≤16.67ms与p99≤25ms；旧失败独立披露。
- [ ] FR-023、SC-006：显示输入/受击≤100ms有测量证据；没有设备则未验证。
- [ ] SC-007：paired overlays/diffs中0未审查变化/丢cue/意外几何/裁剪；预期区域有批准。
- [ ] FR-004：owner对G2 revision明确接受，审美判断与自动结果分列；性能未达不可宣告全面接受/扩大生产。

## G3 / documentation

- [ ] 非切片角色/晋升/屏幕家族另有样稿、估算、审批和回归；不从G2推断全量授权。
- [ ] 每阶段dashboard/overview/README/development/validation/tasks保持准确；旧证据保留，离线链接有效。
- [ ] 所有未执行、失败、缺硬件/人群项明确pending；更新视觉基线有owner scoped decision，非自动覆盖。

## R1 additions — all pending approval/execution

- [ ] I1：八件清单与支持项区分；三种角色VisualSet实际接线。
- [ ] I2：新旧背景互斥/缺资源回退，实际最终Z正确，四墙/路径不变、危险清晰。
- [ ] U1/P01：G1冻结四边四角避让/裁切；实机面积与英雄/危险遮挡分别验，不改相机/物理。
- [ ] U3：权威事件起点，中断恢复/迟到/跳tick/暂停/倍速不重播过期打击或延长清理。
- [ ] U2/G2：三资源命中与故障回退分开测；unit/scene_smoke/integration_m1日志证明新fixture实际执行。
- [ ] G1/P02：额外负载数值获G1批准，新表现/回退计数有效；before/after与原M4独立报告，同门槛且原基准不改。
- [ ] A1/P03：镜像明暗获G1批准，原向/镜像与标记校正符合预算。
- [ ] A2：T013在制作前冻结协议，G1批准样本/答案；十人逐项目×条件×尺寸8/10，原始记录齐全。
