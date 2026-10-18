# Implementation Plan: Abyss Expedition — 2D Visual Art Direction

**Feature**: 002-2d-art-direction · **Date**: 2026-10-16 · **Revision**: VD-01-P2 / workflow 2026-10-18
**Branch**: 未创建分支；setup_plan.py 返回的是功能标识，并非 Git 分支证据。
**Input**: [spec.md](spec.md)；[constitution v1.1.0](../../.specify/memory/constitution.md)。

## Summary

**当前工作流 · 2026-10-18**：**Autonomous Implementation with Continuous Documentation**。
遵循[AGENTS.md](../../AGENTS.md)与宪章v1.1.0；所有已授权范围内任务按依赖自动推进，
不要求任务间、阶段间或视觉设计的例行批准。自动测试、修复实施错误，每阶段同步文档。
人工/参考机/物理显示检查无法执行时记录pending并继续无关工作；reviewer清单只读。
仅真实阻塞、高风险行动或平台权限需要用户介入。本轮只改文档/配置，不执行后续实施。
八件切片已接入；最新玩法与视觉证据仍为[2026-10-17记录](../../docs/validation/visual-vd01/completion-r1.md)，
未新增游戏测试或人工验收。下方有日期的旧轮次记录保留为历史，例行审批停点已废止。

在现有 Godot 4.5 表现层交付一个可审阅、可回退的小切片：Aren 基础剑士、Saltbound Thrall、Skittering Brinejaw、海岸腐化神殿、战斗 HUD、升级选择 UI、剑弧和已有友方追踪星。环境是暗黑幻想像素遗迹与紫色腐化；单位采用可爱、易识别的收藏角色比例。保持纯 2D 近俯视，不重构玩法架构。

原规划轮次仅交付文档；后续样稿、原生UI与八件切片已按末节历史记录实施。G0/G1保留实际决定，G2量化/人工状态分别记录；G3仍超出范围。工作流更新不代表新的美术或人工验收。

**本次明确范围补充**：按用户要求，将 level_up 重设计加入首批范围（FR-011 补充，行为由 FR-017/020 约束）。按资产计为 8 件：1 英雄 + 2 敌人 + 1 环境 + 2 UI + 2 效果。动画预算不增；其他角色/屏幕仅做设计覆盖，不能从本计划推断全量实施授权。

## Technical Context

| 项目 | 决策 / 事实 |
| --- | --- |
| Language / version | GDScript；Godot 4.5.stable.official.876b29033；固定 tools/godot-4.5/ |
| Dependencies | 现有 Godot 原生 Resource、SpriteFrames、AnimatedSprite2D、TileMapLayer、Control/Theme；Compatibility renderer；无新增运行依赖 |
| Storage | 本地 PNG、.tres、.tscn、可编辑美术源；不改 profile v3、迁移/保存协议 |
| Testing | 现有内容/场景/单元/集成/回放、受控图形、Windows release/F9、M4 基准；视觉合同测试随范围内实施同步执行 |
| Platform / type | Windows 桌面离线 2D 游戏，键鼠 |
| Viewport | 640×360、Camera2D (1,1)；1280×720/1920×1080 是2×/3×；1371×779内容1280×720，左右45/46、上下29/30黑边 |
| World / pixels | 960×540；32×32制作地砖；连续模拟坐标，仅显示取整；nearest，无mipmaps/有损压缩 |
| Scope | 8件切片；≤58独创动画格、≤16基础地砖、≤6模块道具；范围外家族继续占位 |
| Performance | p95≤16.67ms、p99≤25ms，显示输入/受击≤100ms；默认新增动态灯/阴影/全屏后处理/装饰粒子全为0 |
| Reference machine | Win11、i5-8400、GTX1050Ti 4GB、16GB RAM、SSD、1920×1080/60Hz、Compatibility release；异机仅补充 |

P01边缘处理、P02额外负载及P03镜像明暗按已记录的G1版本执行；后续范围内修订需版本化并验证，无需例行重新签批。真实资产、来源许可和技术前置条件仍是依赖；缺少参考机、人工反馈或原图比较仅使对应验收pending。

## Constitution Check

研究前已阅读宪章；研究和设计后再次检查。此处合规指计划，不代表实现验收。

| 原则 | 研究前 | 设计后 / 依据 |
| --- | --- | --- |
| I Gameplay First | 合规 | 合规：小切片优先，警示/反馈优先；既有人工与性能缺口保留 |
| II Modular Architecture | 合规 | 合规：表现读取状态；不改controllers、services、RNG、模拟；contracts锁定边界 |
| III Original IP | 合规 | 合规：原创源稿/权利登记；参考图不视为导入授权；AI概念非动画表 |
| IV Testable Development | 合规 | 合规：quickstart+清单+成对截图+回归；自动测试不证明艺术质量 |
| V Consistent Pixel Art | 合规 | 合规：明确尺寸/比例/调色板/锚点/时序，G1证据/预算明确后生产，无例行签批 |
| VI Performance | 合规 | 合规：完整负载、参考机、三seed；历史超预算保留，不降低目标 |
| VII Scope Control | 合规 | 合规：只加入用户明确要求的升级UI；无新玩法/地图/全阵容美术 |
| VIII Incremental Delivery | 合规 | 合规：每阶段验证+文档；阻断错误先修复；未运行保持pending |

## Architecture and minimum integration surface

| 当前路径与事实 | 范围内最小改动 / 不变量 |
| --- | --- |
| scripts/core/app_router.gd；公会路由、Theme、模态管理 | 载入共享Theme，保留路由/保存gate，不新增启动菜单 |
| scenes/world/expedition.tscn；CombatWorld下Field/Pickups/Telegraphs/Actors/Projectiles/Effects，Actors已Y-sort，HUD为CanvasLayer | 保留节点名、路径和职责，只加表现子节点/明确层级 |
| scripts/combat/actor_presentation.gd；程序轮廓、环、受击/死亡/护甲/敌人HP | 可选AnimatedSprite2D，缺资源完整回退；保持角色原点/碰撞与所有关键状态提示 |
| scripts/combat/actor.gd、scripts/data/content_catalog.gd；英雄取profession.visual_set，catalog覆盖character.visual_set为基础职业 | 表现层按definition.id+profession.id查外观覆盖，英雄只命中Aren/base swordsman，另以enemy kind+definition.id匹配两种批准敌人；actor_overrides.tres显式引用三份VisualSet，不全局换swordsman误改Brann/晋升Aren |
| scripts/data/visual_set.gd；当前无SpriteFrames | 可选表现字段，旧默认/validate继续合法；data/visuals/存外观，不改战斗定义 |
| scripts/world/coast_field.gd；_ready创建四面真实墙 | 保留墙/960×540/set_corruption；新旧背景互斥及完整回退，最终Z见ART_DIRECTION；TileSet无collision/nav，神殿不堵路 |
| scripts/combat/melee_arc.gd、projectile.gd；绘制与几何/弹道同文件 | 只换绘制子节点；contains/simulate/命中/寿命不改；效果判定见contracts |
| scripts/ui/combat_hud.gd、level_up.gd、screen.gd；tscn多为壳，布局运行时生成 | 改布局/组件工厂，保留bind_run/refresh及confirmed(offer_id,upgrade_id)、panel/column兼容 |
| tests/scenes/test_m1_ui.gd及图形harness | 部分测试依赖button为column直接子节点；实施时改定位方式并保留原行为断言，不能删除失败测试 |

时序：攻击窗12ticks/200ms，受击8ticks，普通死亡敌人24ticks移除，剑弧expires=tick+10且cleanup用 >，Brinejaw警示45ticks。英雄/首领死亡可立即结果，同伴倒地保留。动画不能等待animation_finished再伤害、结算或清理。[Sprite规范](../../docs/visual-design/SPRITE_SPEC.md)给出采样/中断策略。

ContentCatalog.digest包含外观Resource：美术修改可能使版本内容hash改变。前后比较必须记录新旧hash，比较玩法观测值，不绕过回放版本保护或声称跨版本字节完全相同。

## Art production and reusable UI

- HEX、风格、比例、环境分层、光照和VFX：[ART_DIRECTION](../../docs/visual-design/ART_DIRECTION.md)。
- 概念→规格→原创像素→表格→帧清单→导入→AnimatedSprite2D→实机：[SPRITE_SPEC](../../docs/visual-design/SPRITE_SPEC.md)。
- 当前来源/缺口/复用/目标路径：[ASSET_INVENTORY](../../docs/visual-design/ASSET_INVENTORY.md)。
- Theme、原生组件、全屏幕状态、HUD面积：[UI_DESIGN](../../docs/visual-design/UI_DESIGN.md)。
- 五项文档交付已提供草案；[preview.html](../../docs/visual-design/preview.html)区分概念样稿与实际运行证据；完整预览要求见[contract](contracts/preview.md)。

## Project Structure

保留 scripts/{core,combat,characters,progression,collection,persistence,abyss,ui,debug} 的职责。以下为当前切片涉及的运行时/资产路径（实际交付与验证见末节执行证据）：

```text
assets/source/visual-vd01/       # 分层可编辑源与导出记录，后续排除release
assets/sprites/actors/aren/     # base_swordsman_vd01.png
assets/sprites/enemies/         # thrall_vd01.png, brinejaw_vd01.png
assets/tiles/coast_shrine/      # terrain_vd01.png, props_vd01.png, corruption_vd01.png
assets/effects/slice/           # sword_arc_vd01.png, homing_star_vd01.png
assets/ui/                     # 一套边框/图标，无每屏专属装饰集
data/visuals/                  # actor_overrides.tres、VisualSet、SpriteFrames
data/themes/expedition_theme.tres
scenes/world/visuals/coast_shrine.tscn
scenes/ui/components/          # ValueBar/Portrait/SkillIcon/Cooldown/ChoiceCard/
                               # ActionButton/Tooltip/BossBar/StatusIndicator
```

本轮文档：plan/research/data-model/quickstart、contracts、checklists/visual-acceptance、docs/visual-design 五项交付与审批记录。tasks.md保留87个既有任务ID及当前勾选；完成、部分、待人工与失败状态以各项证据区分，不改M1–M4或reviewer清单。

## Dependency-ordered implementation phases

以下为技术依赖顺序；实际任务按tasks.md的六阶段排程执行（原生UI先于角色/环境）。历史交付状态见末节，不要求重新执行已完成任务。

| 阶段 / 依赖 | 交付 | 退出检查 |
| --- | --- | --- |
| D0方向 | 来源审计、VD-01风格/成本、Concept 2/3或文字替代 | G0版本/方向/预算/范围明确；实际owner决定单独记录，无例行签批 |
| D1样稿，依赖G0 | 精确640×360正常/密集/腐化0与100、两同伴+boss+救援；升级UI；黑剪影、四向/锚点/帧条、2×/3×/1371、灰阶/无光 | G1完整版本证据、精确替换列表；CSS框图不能替代像素样稿，无例行签批 |
| I0基线/任务，依赖G1技术证据与范围清单 | 匹配snapshot/seed/tick/操作before，回退源清单与hash | 导入/内容/场景/相关回归、baseline完整基准；旧性能失败单列 |
| I1资产，依赖I0 | 原创三角色/两效果→地砖/道具→共享UI；源文件与provenance | 尺寸/状态/锚点/nearest/许可、离线帧回放、Godot导入；不批量全阵容 |
| I2角色/VFX，依赖I1 | 精确外观lookup、tick驱动帧、程序回退 | scene_smoke/unit/replay/abilities；四向/中断/Brann未误换/晋升/警示截图和片段 |
| I3环境，依赖I2 | TileMapLayer、低矮道具、静态阴影/腐化；原墙保留 | 四边移动/边界、Y排序/遮挡、0/100、native/2×/3×截图、阶段性能 |
| I4 HUD/升级，依赖I2+I3 | 共享Theme、原生组件、两屏替换；其余屏幕专属重排留G3 | 键鼠、180msfresh-input、升级队列/暂停、焦点/长文、25%HUD联合面积 |
| I5候选，依赖I4 | 全M4/source/release/F9回归、成对图/片段、三seed基准、十人识别/UI任务 | G2分列自动验证、失败、pending人工与实际反馈；继续无关任务，不自动扩批 |
| 后续G3，需单独范围授权（当前排除） | 每次一个角色/职业/屏幕家族，单独估算/样稿 | 新增范围先写规格/任务；范围内按版本证据、回归/截图/预算及文档自主推进 |

每个I阶段同步开发图鉴、概览、README、development、validation与该阶段tasks证据；旧截图不覆盖。自动修复导入/解析/运行/功能回归错误并复验；仅阻断依赖该错误的工作，安全的独立任务继续。已知性能未达可记录诊断，不降低负载、不借本功能重构玩法。

## Review correction R1: decisions and verification

首批8件：1英雄+2敌人+1环境+2效果+2UI；共享Theme/图标/头像/暂停seed披露是支持项。本节技术约束继续适用；原R1审批等待状态已由后续决定与当前工作流取代。

- I2：新环境完整可用时停旧_draw背景，缺资源则隐藏新视觉并完整回退；四墙/set_corruption常在。T063设置实际hosts最终Z，T066/T068验证。
- U3：事件起点为attack_until−12、有效dead_at或致死receive的hurt_until−8、warning时deadline−45；受击单姿闪烁截至实际hurt_until；同事件中断恢复不重播首帧。T058覆盖迟到/跳tick/中断/暂停/倍速，不延长寿命。
- U2/G2：最小actor_overrides Resource显式映射三份VisualSet；合同/UI/集成fixture加入unit/scene_smoke/integration_m1，阶段证据须确认实际运行和正确命中，另验故障回退。
- A2：T013在画片段前冻结recognition-protocol.json，登记各条件数量/分布/重叠/尺寸/答案/无指导流程；T022依协议制作、T023检查、T081逐项目×条件×尺寸计分，不能事后换易样本。

| G1版本化设计项 | 方案与验证条件 | 依赖任务 |
| --- | --- | --- |
| P01 边缘处理 | 四边四角+完整HUD样稿；面积/遮挡分开验。候选局部紧凑或重排、允许上部身体边界裁切，脚锚/玩家定位/临近危险仍可读；不改相机/物理。是否接受裁切及具体位置须明确决定。 | T042及相关验收 |
| P02 额外容量 | 原M4基准不变。候选30新版基础剑弧+100新版基础homing star，保留100普通敌/1boss/2同伴/500gems/腐化100；维持负载不能延长正式特效寿命或给Aren技能。G1冻结数量、选择器、补充策略及计数；沿用原参考机/三seed/30+120主动秒/p95/p99门槛。容量检查不等于日常战斗承诺。 | T032/T033新增fixture、T069/T078 |
| P03 镜像明暗 | 世界左上光；候选角色近对称明暗+独立脚影+预算内语义标记校正。原向/镜像并排审核，不默认增四方向帧或shader。 | T048–T050 |

T030将P01/P02/P03与识别协议纳入同一G1版本，沿用实际已有决定；范围内修订由agent记录理由、验证并继续，无例行G0/G1或计划/tasks批准停点。超预算/超范围仍需明确授权。

## Acceptance and risks

[quickstart](quickstart.md)提供实际现有命令和待补图形矩阵；[清单](checklists/visual-acceptance.md)区分自动、人工与owner决策；[历史决定与证据](../../docs/visual-design/APPROVALS.md)保留实际反馈。reviewer清单文件与markers只读；独立报告记录发现，不因未勾选而询问是否继续。

风险及对策：共享职业误换→精确外观映射；大画布遮挡→拥挤板审查；动画越界→tick采样；警示对比→固定高层+原几何；Theme被脚本覆盖→组件工厂接线；Y-sort层级→显式分层；旧截图不可比→成对fixture；历史性能不达→原负载实测。

## Complexity Tracking

无宪章例外。保留程序回退，不新增通用外观管理框架、骨骼系统或玩法抽象。

本轮仅文档/源码检查，没有新Godot/图形/性能/人工验收。见[检查记录](../../docs/validation/art-plan-2026-10-16.md)。



## 当前审批更新 · 2026-10-16

Owner已直接回复`approve`，接受提交的VD-01-M1设计、八件范围及P01–03/识别协议；见[审批记录](../../docs/visual-design/APPROVALS.md)。上文pending反映提交时状态。设计批准已登记，Phases1–3结束；本轮没有启动T031+或修改Godot。G2/G3与生产/实机/人工/性能检查仍开放。

## 当前切片收尾 · 2026-10-17 / VD-01-P2

Phases4–6八件已接入，owner随后报告`verified`并明确只完成本批剩余工作。f187视觉参考及EXE归档保留；P2修复长名称/标题，不扩展G3或玩法。实际引擎1371×779变换为2×、左46/上30/右45/下29余量，取代上文提案对奇数余量的另一侧分配；逻辑画面/判定未变。[当前执行证据](../../docs/validation/visual-vd01/completion-r1.md)；量化与外部验收仍分别记录。
