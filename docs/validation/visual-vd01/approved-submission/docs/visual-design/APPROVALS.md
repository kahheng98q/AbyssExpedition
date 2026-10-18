# Visual approval register

Package **VD-01-M1** · 2026-10-16 · 原创概念样稿可评审，非生产美术批准。

| Gate | Revision / scope | Reviewer | Decision date | Decision | Remaining restrictions |
| --- | --- | --- | --- | --- | --- |
| G0 direction | VD-01文字方向、比例/颜色/预算 | pending owner | — | pending | Concept2/3图片或文字替代须明确批准 |
| G1 mockups | VD-01-M1八件概念、共享Theme及pause seed披露 | pending owner | — | pending | 像素boards/strips/视频已交付；生产清稿/参考替代/P01–03未批准；禁止live替换；仍需计划/tasks批准 |
| G2 playable | 未交付 | pending owner | — | pending | 无新实机/性能/人工证据；不能推广 |
| G3 expansion | 不在本批 | pending owner | — | pending | 每家族单独scope/estimate/mockup |

记录决定时必须填实际reviewer、日期、approve/revise/reject、精确scope、剩余条件与证据路径。拒绝/修订保留旧revision，下一版用supersedes关联，不覆盖历史。规格数值澄清、请求编写计划、自动测试或沉默都不等于G0/G1/G2批准。

## R1 documentation correction — 2026-10-16

首批八件（1+2+1+2+2）；此前九件是算术错误，共享Theme/图标/头像/暂停seed披露是支持项。本次仅获授权修订文档，不是样稿/实施或下列选择的批准。

| G1 decision ID | Candidate / required evidence | Decision |
| --- | --- | --- |
| P01 edge/HUD | 四边四角组合HUD与危险；候选局部紧凑/重排、上部身体边界裁切，脚锚/定位/警示保持可读；不改相机/碰撞。 | pending owner |
| P02 supplemental stress | 候选30新版基础剑弧+100新版基础追踪星，继承其他负载不减；冻结数量/选择器/补充策略/计数，同门槛，独立报告。 | pending owner |
| P03 mirrored shading | 世界左上光，候选近对称角色明暗+独立脚影+预算内语义标记校正；原向/镜像样稿。 | pending owner |

T030冻结以上决定及识别样本/答案协议；未定阻断依赖任务。G0–G3仍pending，本表没有新增owner批准。

## 本次执行授权 / 不等于设计接受

2026-10-16，owner明确要求ONLY Visual Audit、Art Direction、Visual Mockup，完成Phases1–3并STOP；随后以`yes`授权在未勾选清单下继续。按此更新授权制作**待审**概念，覆盖早期任务中“G0后才可开始mockup”的执行排程限制；不推断G0方向、参考替代、G1美术、计划/tasks运行实施批准。没有修改玩法或推进T031。

## G0 / G1 提交评审包 · VD-01-M1

- 入口：[交互预览](preview.html)；[当前审计](../../specs/002-2d-art-direction/visual-audit.md)、[统一方向](ART_DIRECTION.md)、[精灵](SPRITE_SPEC.md)、[动画](ANIMATION_REQUIREMENTS.md)、[UI](UI_DESIGN.md)、[清单/权利](ASSET_INVENTORY.md)。
- 冻结文件索引：[package.json](mockups/vd01/package.json)；其SHA256见[package-sha256.txt](../validation/visual-vd01/package-sha256.txt)。这个hash只标明提交文件集合，不是owner签批；任何美术修订均需新的提交hash。
- 精确8件：Aren且基础swordsman、saltbound_thrall、skittering_brinejaw、现有coast_field神殿视觉、基础reach48/angle100剑弧、现有友方基础homing star、CombatHUD、level_up。其他角色/晋升/敌人/首领生产排除。
- 支持范围：一个共享边框/Theme、六图标、Aren头像crop、现有pause增加seed只读披露；其他屏幕仅继承获批基础Theme，不重排。
- 证据：[阶段1](../validation/visual-vd01/phase-1.md) / [阶段2](../validation/visual-vd01/phase-2.md) / [阶段3](../validation/visual-vd01/phase-3.md)、[识别协议](../validation/visual-vd01/recognition-protocol.json)、[readability限制](../validation/visual-vd01/mockup-readability.md)。原稿/ORA/帧条/51张倍率板/四边四角/13个动作文件均索引在同一包内。

| 待决定 | 当前候选与附件 | owner / 日期 / 决定 |
| --- | --- | --- |
| G0 统一方向与参考 | 接受冷石海岸/可爱单位/金属浅青对紫腐化；Concept2/3仍缺，接受当前书面替代，或提供图后修改 | pending / — / pending |
| G1 八件风格与UI | 接受本修订外观/12px+16/20层级/三卡/原值和save语义；确认正式清稿还需审阅 | pending / — / pending |
| P01 边缘 | 四边四角板；上部HUD下移88px，底部条件条上移58px，允许上部身体在viewport边界裁切；白十字标脚锚 | pending / — / pending |
| P02 补充压力 | 提案30新版基础剑弧+100新版友方基础星；其余原M4负载不减，独立计数/报告与同门槛；不是日常战斗承诺 | pending / — / pending |
| P03 镜像 | 世界左上光；角色近对称明暗+独立脚影，语义标记预算内修正；原向/镜像lineup与视频 | pending / — / pending |
| 识别协议 | 当前固定fixture/答案、两秒/2×/3×/每项目条件独立8/10；无指导、不换容易样本 | pending / — / pending |
| Plan/tasks及运行实施 | [现行计划](../../specs/002-2d-art-direction/plan.md)、[任务](../../specs/002-2d-art-direction/tasks.md)按本次draft制作授权调整；T031+单独批准后才开始 | pending / — / pending |

T015实际G0决定与T030实际G1/P01–03/协议决定仍未完成，任务保持未勾；准备/验证交付可完成，不伪填owner/date。没有新baseline接受、运行验收或扩批授权。当前在Gate A停止，等待owner反馈。
