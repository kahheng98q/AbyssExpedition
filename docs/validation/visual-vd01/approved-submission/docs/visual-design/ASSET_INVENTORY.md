# ASSET_INVENTORY · VD-01

2026-10-16 · 基于当前源码与Resource，未执行游戏。当前assets主要是说明文件，**没有生产角色精灵表、地砖atlas或Theme文件**。screenshots是历史证据，不是可切片生产美术。[完整审计](../../specs/002-2d-art-direction/visual-audit.md)保留；[来源登记](../../assets/provenance.md)不改为虚假的新资产记录。

| ID / 范围 | 当前真实来源 / 状态 | 拟替换 / 复用 | 生产缺口 / 审批 |
| --- | --- | --- | --- |
| A01 Aren/base swordsman | scripts/combat/actor_presentation.gd、data/characters/aren.tres；程序占位 | assets/sprites/actors/aren/base_swordsman_vd01.png；13唯一格初稿、24px头像crop | 源稿/PNG/SpriteFrames均缺；G1 pending |
| E01 Saltbound Thrall | data/enemies/saltbound_thrall.tres，程序diamond | assets/sprites/enemies/thrall_vd01.png；6唯一格，attack=NA | 缺；G1 pending |
| E02 Skittering Brinejaw | data/enemies/skittering_brinejaw.tres，程序crab | assets/sprites/enemies/brinejaw_vd01.png；6唯一格、warning复用 | 缺；G1 pending |
| W01 coast shrine | scenes/world/coast_field.tscn、scripts/world/coast_field.gd；程序海岸/祭石/真实墙 | assets/tiles/coast_shrine/；≤16地砖+6模块道具+1腐化overlay family | 源稿/TileSet缺；装饰不加碰撞；G1 pending |
| F01 sword | scenes/combat/melee_arc.tscn、scripts/combat/melee_arc.gd；原几何弧 | assets/effects/slice/sword_arc_vd01.png；2格初稿 | 缺；仅基础参数批准范围；非基础程序回退 |
| F02 star | scripts/combat/projectile.gd、data/weapons/homing.tres；已有友方追踪星 | assets/effects/slice/homing_star_vd01.png；2格初稿 | 缺；单独caster演示，不赋给Aren |
| U01 battle HUD | scenes/ui/combat_hud.tscn、scripts/ui/combat_hud.gd；运行时Control | 共享Theme/ValueBar/Portrait/BossBar/Status；保留全部数值状态 | 原生新UI未实现；G1 pending |
| U02 level_up | scenes/ui/level_up.tscn、scripts/ui/level_up.gd；三准确文本按钮 | 共享ChoiceCard/ActionButton/SkillIcon；本次用户加入切片 | 原生新UI未实现；G1 pending |
| UI shared | scripts/core/app_router.gd、scripts/ui/screen.gd；内建font/flat styles | data/themes/expedition_theme.tres；一套边框、可复用16px图标 | 不做新字体/本地化；只制作批准组件必需图标 |
| 其他5英雄/6晋升/4普通敌人/boss | data/characters、professions、enemies、encounters，程序轮廓 | 重用剑/弓/杖动画家族与当前职业cue | 不在首批，G2后逐家族G3 |
| 其他UI、警示/拾取/救援 | scripts/ui、scripts/combat/telegraph.gd、xp_pickup.gd、rescue_zone.gd | 仅设计覆盖，警示保持准确几何 | 不全量生产或重排；未经批准保持原样 |

动画初稿29唯一格、上限58；地砖16设计、道具6设计，镜像不增设计计数。UI生产量：一套panel/button/border、Aren头像crop、切片实际用到的最多6个共享16px图标；缺图时保留文字而非误用其他游戏图。图标额外于动画格预算，应在G1资产估算中单列；不能用该预算隐藏更多动画。现有M4敌人/首领仍正常生成，不因只展示两类而删除waves。

## Provenance and replacement record

每个交付条目必须补：creator、creation date（实际日期）、source/license或原创说明、可编辑源路径/hash、PNG路径/hash、style revision、state manifest、精确选择器、fallback来源副本、G1/G3 decision、实际接线路径、G2证据。未知留missing，不用“Codex原创”提前填未来作者。

状态列彼此独立：当前placeholder；替换proposed；缺失missing；批准approved（须记录）；接线integrated；执行验证verified；owner视觉验收另列。导入无错不能直接成为verified art quality。

保留原程序源码的revision副本或精确补丁与hash、原Resource及before截图到当批证据目录，直到接受后仍可追溯。没有Git也可用manifest+源副本回退。回退只撤本批表现资源/引用，不碰profile、不删除历史证据；无回退来源不得开始覆盖。

## Real evidence used by preview

- [历史M4 release boss图](../../screenshots/m4-release-boss-double-eruption-1280.png)：原程序海岸、警示/HUD；非新设计、非本轮截图。
- [历史角色选择](../../screenshots/convergence-exe-m2-selection-1280.png)：现有文字选择；不是生产头像。

Concept Images 2/3仍缺失；不能把上面截图换名充当参考。历史规划入口的框图现已补充VD-01-M1原创像素概念稿；单位生产成品与G2实机图仍未交付。

R1：A01/E01/E02/W01/F01/F02/U01/U02共8件；UI shared是支持资产。三份角色VisualSet由actor_overrides.tres精确选择器接线，正常命中与故障回退分开验收。P03镜像与P02额外容量仍待G1，不增加正式家族。

## 当前 / 提案 / 缺失分栏 · VD-01-M1

当前`assets/`恰有4份Markdown说明，无任何PNG、tiles、可编辑母稿；`data/visuals/`目录实际不存在。外观VisualSet内嵌于profession/enemy等`.tres`，不能把拟定目录当成已有资产。现有可复用内容是程序回退、palette/轮廓语义和真实历史截图；截图仅用于对照，不切片成生产精灵。

以下**交付路径确实存在**，均相对于本目录；不是上表拟定的`assets/`生产路径。**权利未知不得approved；不虚构文件**。

| ID / 精确选择器 | 当前/回退 | 当前提案交付 | 仍缺生产项 |
| --- | --- | --- | --- |
| A01 hero `aren` + profession `swordsman` | actor_presentation.gd / aren.tres / swordsman.tres | mockups/vd01/sprites/aren.png；actor-lineup.png；source/actor-lineup.ora | 正式清稿/exports/SpriteFrames；Brann及晋升不命中 |
| E01 enemy `saltbound_thrall` | actor_presentation.gd / saltbound_thrall.tres | sprites/thrall.png（在mockups/vd01/下）；同lineup母稿 | 清稿/exports/SpriteFrames；contact-only |
| E02 enemy `skittering_brinejaw` | actor_presentation.gd / skittering_brinejaw.tres | sprites/brinejaw.png（同目录）；同lineup母稿 | 清稿/exports/SpriteFrames；原45tick警示 |
| W01 现有coast_field | coast_field.gd / coast_field.tscn | mockups/vd01/shrine.png；source/shrine.ora；layers/；terrain-concept.png/props-concept.png在sprites/下 | 16地砖/6模块**概念**已有；正式可拼接atlas/TileSet/覆盖全960×540/碰撞为零的接线仍缺 |
| F01 基础sword reach48/angle100 | melee_arc.gd / run_manager.gd | mockups/vd01/sprites/sword.png；source/effects.ora | 清稿/原geometry接线；非基础参数回退 |
| F02 友方基础homing | projectile.gd / homing.tres | mockups/vd01/sprites/star.png；source/effects.ora | 清稿/原生命周期接线；hostile/晋升不替换 |
| U01 CombatHUD | combat_hud.gd / combat_hud.tscn | mockups/vd01/battle-hud.png、hud-stress.png、edges/；source/battle-hud.ora、hud-stress.ora | Theme/组件/原生布局和seed在pause披露 |
| U02 level_up | level_up.gd / level_up.tscn | mockups/vd01/level-up.png、level-up-states.png；source/level-up.ora | 原生三卡/队列/fresh-input接线与验证 |

每项记录：creator=Codex（本地原创像素几何）、date=2026-10-16、revision=VD-01-M1；未复制第三方图像/角色。Windows系统字体仅被渲染到评审图，不分发字体二进制。源/导出SHA256及真实路径见[package.json](mockups/vd01/package.json)和[manifest](mockups/vd01/animation-manifest.json)。源母稿含可编辑PNG图层；逐帧精灵可编辑且有本地原创绘制源。所有记录approval=pending、wiring=未接线、G2=未执行；原创来源声明不等于owner接受。

实际概念预算：13+6+6+2+2=29不同动画格（不是“29格生产完成”）；16地砖、6道具设计；6个16px图标、一套边框和Aren头像crop为支持项，不计入动画格。身体五状态有条目；Thrall attack=N/A且说明contact；唯一格去重≤58；多帧不得重复同图凑数；锚点在画布内。最终验证见[阶段3](../validation/visual-vd01/phase-3.md)。

尚缺：Concept2/3或文字替代接受、生产清稿和接线、UI/动作/识别十人review、参考机性能与显示延迟。其余五英雄、六晋升、四敌人、首领和其他屏幕只保留设计覆盖，继续G3排期；本次不制作其生产美术。
