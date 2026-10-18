# Visual approval register

## 当前执行规则 · 2026-10-18

**Autonomous Implementation with Continuous Documentation**：按[AGENTS.md](../../AGENTS.md)、
[当前规格](../../specs/002-2d-art-direction/spec.md)与宪章v1.1.0，G0/G1/G2为版本化方向/证据检查点，
不再要求例行视觉、阶段或计划/tasks签批。自动测试修复、逐阶段同步文档；缺少人工/设备验证保持pending，
继续无关范围内工作。reviewer清单只读；只记录实际收到的owner决定，不自批、不重设失败基线。
G3扩展仍在当前八件范围之外。本次只更新工作流文档/配置，没有新增owner验收或游戏测试。

**以下为历史审批记录**：原“等待批准/STOP/未决定阻断”不再约束例行实施；既有决定、证据与未达标状态保留。


Package **VD-01-M1** · 2026-10-16 · **G0/G1已批准；owner已验证f187视觉参考，P2收尾已自动复核；量化/外部验收仍开放。**

下方原提交中的pending表保留为历史；当前owner决定见本文末节。

| Gate | Revision / scope | Reviewer | Decision date | Decision | Remaining restrictions |
| --- | --- | --- | --- | --- | --- |
| G0 direction | VD-01文字方向、比例/颜色/预算 | user / project owner | 2026-10-16 | approve | 接受当前书面替代；不声称比较过缺失原图 |
| G1 mockups | VD-01-M1八件概念、共享Theme及pause seed披露 | user / project owner | 2026-10-16 | approve | 本修订八件概念及列明P01–03/协议/替换方案接受；本轮未开始原生实施，G2/G3开放 |
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


## 当前owner决定 · 2026-10-16

Reviewer：user / project owner。直接回复：`approve`。对象是上一条交付的**VD-01-M1**，提交package SHA256：`3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49`。

批准内容：G0整体方向及缺失Concept2/3的当前书面替代、G1八件概念与UI规则、P01边缘重排/视口上部身体裁切、P02补充30新版基础剑弧+100新版友方基础星、P03近对称明暗/独立脚影/预算内语义校正、当前识别fixture/答案协议及列明八件替换计划范围。P01仍须保留脚锚/危险可读；P02不减原负载、不降低门槛、不增加Aren技能；批准概念不等于接受未知未来生产清稿。

记录：[机器可读决定](../validation/visual-vd01/owner-approval-2026-10-16.json)。原提交package及其源/图片/视频/评审文档已按hash核对并存入[归档索引](../validation/visual-vd01/approved-submission/docs/visual-design/mockups/vd01/package.json)。现有package.json保留原提交内容与旧状态，不能重生成后冒充同一个获批hash；当前状态以此决定为准。

T015/T030完成，Phases1–3共30项交付关闭。原请求仅实施Phases1–3，本次仅登记设计批准，T031–T087没有开始。下一实施阶段按已列明范围从备份和before基线启动。G2实机/人工/延迟/性能、生产交付检查及G3扩批仍开放；不改现有视觉运行基线或玩法验收。

本轮[审批校验](../validation/visual-vd01/approval-checks-2026-10-16.json)：原提交hash和134项样稿文件不变，156个提交文件归档已核对，202个本地链接无缺失；未重跑Godot或浏览器交互。发现`project.godot`的features现在为4.7，与原审计4.5不同；233个其余受保护文件和5张历史截图与原hash一致。本轮没有写入该配置，保留差异；后续引擎检查须处理此差异后再建立before基线。

## 继续实施授权 · 2026-10-16

Owner随后直接回复`approve all`，授权按已批准八件及支持范围继续第4–6阶段，见[授权记录](../validation/visual-vd01/implementation-authorization.json)。原“本轮仅登记批准”是前一轮状态，不再限制本轮实施。G2未来实机候选及人工/性能/延迟结果仍须实际证据与owner审阅，不能提前标为通过；G3仍不授权。






## G2候选交付 · 2026-10-17

VD-01-P1候选 `f187bd763fe92b69069722432c4534178c32206be6cf76a59ba9fe8fe7e95d42`；嵌入发布EXE `c6d626b275117e8f5ec8c476ed6cc8574792a8b53bd3dab55927d8e565d98bfe`。原G1提交hash保持不变。八件已接入，实际来源/自动检查/逐项差异/未过门槛详见[同版评审包](../validation/visual-vd01/review-package.md)与[REAL对照](runtime-gallery.html)。性能测量已完成，结果不等于验收；十人辨识/UI答卷、物理延迟、参考机和完整窗口/长值/手动检查未验收。地标布局/腐化符号移植和实际P01边缘裁切需owner观看判断。

| G2字段 | 当前状态 |
| --- | --- |
| Reviewer / date / decision | pending / — / pending |
| New visual baseline | pending，未授权替换 |
| Reference budgets / displayed latency | 未通过或未测，不以旧版超标豁免 |
| Human recognition/UI |0参与者；CSV仅表头 |
| G3 |未授权 |

当前停止于可审阅候选。既有`approve all`仅授权范围内实施，不能提前成为这个未来候选的G2验收。可记录视觉反馈，但未满足的性能/人工条件继续保留。

2026-10-17后续`proceed`：继续未完成的自动检查。[原生UI边界复核](../validation/visual-vd01/ui-boundary.md)新增102项源码/发布观测；两项合成长名称/标题限制保留。生产候选/EXE/G1哈希未变。没有收到指定候选的艺术反馈或新基线决定，不把继续检查视为十人、延迟、性能或G2/G3已通过。

## Owner验证与当前切片收尾 · 2026-10-17

Owner直接回复 **“verified proceed the rest”**，随后明确选择 **“完成当前切片的剩余工作”**。[原始文字、版本与范围](../validation/visual-vd01/owner-verification-2026-10-17.json)。这关闭了“尚未收到owner视觉反馈”的状态：f187/c6d6版本作为owner已验证的视觉参考保留在[归档](../validation/visual-vd01/owner-verified-f187/evidence/candidate-files.json)。没有提供逐项人工方法或十人答卷，不能推断硬件、量化门槛或完整产品验收。

当前VD-01-P2只修复同批长名称/标题，并追加原生/真实时钟验证；[当前候选与结果](../validation/visual-vd01/completion-r1.md)。原G1包不变。G2视觉反馈已收到；整体验收仍受未达性能、缺少物理延迟/十人结果及完整自然操作条件限制。G3没有授权，不再重复询问本批实施许可。
