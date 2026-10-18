# ASSET_INVENTORY · VD-01-P2

2026-10-17 · 八件齐备。Owner已验证f187视觉参考；P2只修复三份UI显示脚本，精灵/动画/环境/特效源与像素未变。[当前来源/哈希](../validation/visual-vd01/completion-r1/asset-delivery.json) · [当前结果](../validation/visual-vd01/completion-r1.md) · [原始审计](../../specs/002-2d-art-direction/visual-audit.md) · [实机对照](runtime-gallery.html)。十人/物理显示/参考机门槛仍开放，不以owner反馈代替量化结果。原设计提交[归档](../validation/visual-vd01/approved-submission/docs/visual-design/ASSET_INVENTORY.md)保留。

| 八件交付 | 当前实际文件 / 接线 | 提案与批准 | 缺失 / 验收 |
| --- | --- | --- | --- |
| Aren/base Swordsman | [PNG](../../assets/sprites/actors/aren/base_swordsman_vd01.png) · [ORA](../../assets/source/visual-vd01/aren.ora) · [VisualSet](../../data/visuals/aren_vd01.tres) | 只匹配 `hero aren+swordsman`；13独创格 | 文件齐全；owner已验证参考，量化门槛开放 |
| Saltbound Thrall | [PNG](../../assets/sprites/enemies/thrall_vd01.png) · [ORA](../../assets/source/visual-vd01/thrall.ora) · [VisualSet](../../data/visuals/thrall_vd01.tres) | `enemy saltbound_thrall`；6格，contact-only attack=N/A | 文件齐全；owner已验证参考，量化门槛开放 |
| Skittering Brinejaw | [PNG](../../assets/sprites/enemies/brinejaw_vd01.png) · [ORA](../../assets/source/visual-vd01/brinejaw.ora) · [VisualSet](../../data/visuals/brinejaw_vd01.tres) | `enemy skittering_brinejaw`；6格，warning复用 | 文件齐全；owner已验证参考，量化门槛开放 |
| Coast shrine | [地砖](../../assets/tiles/coast_shrine/terrain_vd01.png) · [道具](../../assets/tiles/coast_shrine/props_vd01.png) · [腐化](../../assets/tiles/coast_shrine/corruption_vd01.png) · [ORA](../../assets/source/visual-vd01/shrine.ora) · [场景](../../scenes/world/visuals/coast_shrine.tscn) | 16地砖槽、6道具、1overlay family；960×540，最后28px裁剪 | 文件齐全；原生边缘检查完成，十人辨识待完成 |
| Sword arc | [PNG](../../assets/effects/slice/sword_arc_vd01.png) · [Frames](../../data/visuals/sword_frames_vd01.tres) · [共用ORA](../../assets/source/visual-vd01/effects.ora) | 2格；仅reach48/angle100 | 文件齐全；其他参数完整程序回退 |
| Friendly homing star | [PNG](../../assets/effects/slice/homing_star_vd01.png) · [Frames](../../data/visuals/star_frames_vd01.tres) · 同effects.ora | 2格；现有友方基础法术，不给Aren新技能 | 文件齐全；晋升/敌弹程序回退 |
| Battle HUD | [脚本](../../scripts/ui/combat_hud.gd) · [场景](../../scenes/ui/combat_hud.tscn) | 6组条件面板、原值、P01避让 | 原生/长值检查通过；完整人工验收开放 |
| Level-up | [脚本](../../scripts/ui/level_up.gd) · [ChoiceCard](../../scenes/ui/components/choice_card.tscn) | 原Resource三卡/顺序/队列/暂停/180ms/fresh input | 自动原生输入通过；完整手动会话待完成 |

共享支持：一份[Theme](../../data/themes/expedition_theme.tres)、7个实际使用的原生组件、[Aren 24px裁剪](../../assets/ui/aren_portrait_vd01.png)、[6个16px图标](../../assets/ui/slice_icons_vd01.png)、[UI ORA](../../assets/source/visual-vd01/ui.ora)及现有暂停页seed只读披露。升级卡使用前4个图标区域；金币/腐化图标已交付但当前HUD保留文本，不冒称全部图标已展示。

## 原创来源 / 状态与动画

作者Codex，以本地逐像素原创几何制作；概念日期2026-10-16，生产导出2026-10-17。只使用获批VD-01-M1原始像素，无第三方图像或字体二进制复制。固定画布、透明RGBA、无缩放/trim、lossless/nearest/无mipmap。清稿检查保留已批准轮廓，没有虚称另聘画师或新增姿势。G1概念批准不等于G2成品质量验收。

| 角色 | idle / move / attack或warning / hurt / death | 独创格 / 固定锚点 |
| --- | --- | --- |
| Aren | 2 / 4 / 3 / 1复用 / 4 | 13 · 32×48 / (16,40) |
| Thrall | 1 / 2 / N/A接触伤害 / 1复用 / 3 | 6 · 32×48 / (16,40) |
| Brinejaw | 1 / 2 / 1复用warning / 1复用 / 3 | 6 · 32×32 / (16,24) |

合计29（13+6+6+2+2），上限58。五状态均有条目；Thrall attack明确N/A。每个适用多帧状态实际RGBA不重复；复用不凑独创格。源/导出哈希、regions和复用理由见各[manifest](../../assets/source/visual-vd01/)及[实际交付审计](../validation/visual-vd01/asset-delivery.json)。神殿ORA含三张原生atlas独立图层，无合并缩略图；可编辑层与原PNG均保留。6份ORA源不进入发布包。

## 回退与生产缺口

[精确映射表](../../data/visuals/actor_overrides.tres)不修改职业/敌人战斗定义。缺帧/无映射/故障注入时保留完整程序绘制；资源正常加载与故障回退分别测试。晋升Aren、Brann、其他英雄、4种其余普通敌人及首领都保留程序外观，尚缺独立生产美术，属于未授权G3扩批。其他UI仅继承基础Theme，不做重排。

原始源码、嵌入PCK的旧EXE、旧截图与日志保存在[before](../validation/visual-vd01/before/rollback-manifest.json)。回退不碰profile、不删除历史证据。新PNG不是从历史截图裁切；PROPOSED图与REAL受控引擎捕获分开标记。Concept2/3未提供，owner已接受书面替代，不能声称复刻未见参考。

## 验证与审批

[Phase4](../validation/visual-vd01/phase-4.md) · [Phase5](../validation/visual-vd01/phase-5.md) · [最终评审包](../validation/visual-vd01/review-package.md) · [APPROVALS](APPROVALS.md)。已实现/自动验证与待人工验收分列；未知权利不得approved，不虚构文件、不填参与者或性能结果。


VD-01-P3 · 2026-10-18：本轮仅缓存未变化的绘制指令，八件生产像素、源稿、许可、帧数及全部未替换回退均不变；不新增G3资产。[当前两文件/构建索引](../validation/visual-vd01/completion-r2/candidate-files.json) · [当前本机结果/缺口](../validation/visual-vd01/completion-r2.md)。
