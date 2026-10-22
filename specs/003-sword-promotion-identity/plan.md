# Implementation Plan: Sword Promotion Identity · 剑系转职可感知差异

**Feature / setup BRANCH**: `003-sword-promotion-identity`  
**实际 Git 分支**: `feature/visual-art-direction—v3`（只读核对；未创建或切换分支）  
**Date**: 2026-10-21 | **Spec**: [spec.md](spec.md) | **Constitution**: 1.0.0  
**Status**: US1–US3已实现；Phase 7三组各60样本跨版零差异，含升级／事件／终局保存。新Release／Debug完整图形及九组合真实时钟通过；候选性能有效但p95=16.732ms超目标，自然九局与人工待验。[当前证据](../../docs/validation/sword-promotion-identity/convergence-20261021-v1/results.md)。

输入为本目录规格及2026-10-20澄清。`.specify/feature.json`选择本功能；setup返回的BRANCH是功能标识，不代表Git已切换。

## Summary

只增强基础剑士、剑圣、深渊剑士的单剑／双刃／长刃轮廓、已有双弧与第五次旋斩，以及真实第五次治疗反馈；适用于Aren、Brann及其同伴身份。现有转职页增加静音、独立状态、六秒循环的两分支示例。

沿用原创程序像素绘制，以职业VisualSet驱动共享剑系绘制器。实战弧读取既有几何与附加视觉元数据；治疗只在原结算点测量HP实际增量。演示复用绘制器，不调用真实战斗、进度或存档服务。伤害、攻击计数、冷却、治疗、随机流、保存schema及其他职业保持原合同。

**2026-10-21用户授权修订：自然九局延期验收**：[002验收矩阵](../../docs/validation/combat-pacing-audio/acceptance.md)仍将自然九局列为待人工验收。FR-012保留当前未改动基线版本三职业×101／202／303，逐局首命中≤5秒、首杀≤10秒、首升级≤30主动秒；失败留档，在002范围修复并完整重录。规划和任务分解可先行；用户已明确授权代码／美术／工具先实施，先冻结改前源码，九局仍待人工验收。五人理解／盲听、自然九对、物理DEV、完整性能环境各自开放，不追加为开工条件。

## Technical Context

| 项目 | 选定方案 |
| --- | --- |
| Language / Version | Godot 4.5、GDScript；引擎固定`4.5.stable.official.876b29033`；验证编排沿用PowerShell |
| Primary Dependencies | 现有Godot内置Node2D、Control、Resource、Window；无第三方包、插件或在线服务 |
| Storage | Resource视觉配置、内存表现／预览状态；本地profile schema v3不增字段、不迁移 |
| Testing | 原生runner及run_validation；扩展abilities、combat_feedback、integration_m2、combat_audio、replay；US3注入时钟逻辑窄测与独立真实播放检查分层，新增剑系图形及跨版比较夹具 |
| Target Platform / Type | Windows桌面、离线单人2D游戏；现有Windows Desktop导出preset |
| Performance Goals | 同机Release改前／后各预热30主动秒、采样120主动秒；100常规敌人＋1首领、双同伴、≥30效果、≥100活动弹体、500宝石、腐化100；改后p95≤16.67ms、p99≤25ms |
| Reference Environment | Q1参考：Ryzen 7 5800H、GTX1650、1920×1080、VSync off、无调试器、真实音频输出；实测环境需另记，非参考机只报告本机样本 |
| Constraints | 640×360逻辑视口、nearest、32px常规角色；60Hz主动时间；12tick攻击姿态／10tick弧寿命；既有48条伤害反馈预算不变 |
| Scale / Scope | 3种剑系外观、2分支示例、2现有剑系英雄及主角／同伴身份；3窗口尺寸、3种子比较；不扩职业、地图、升级或音频 |

技术未知项已在[research.md](research.md)决策；未执行的自然／人工／环境验收是证据门槛，不是可以自行代填的技术答案。

## Constitution Check

| 原则 | Phase 0前审查 | Phase 1后复核 |
| --- | --- | --- |
| I Gameplay First | 合规：只改善已有剑系差异，先保护自然开局基线 | 合规：US1→US2→US3增量；不扩展角色或玩法系统 |
| II Modular Architecture | 合规：玩法结算与绘制分离，职业Resource驱动 | 合规：共享纯绘制器、独立预览、只读治疗事实；UI不承担真实战斗规则 |
| III Original IP | 合规：沿用项目原创程序像素 | 合规：补provenance，不复制素材，不声称完成正式精灵表 |
| IV Testable Development | 合规：规格已有FR／SC与失败场景 | 合规：覆盖实际差值、拒绝／致死／多目标、保存失败、跨版比较；人工另记 |
| V Pixel Art | 合规：沿用32px、nearest及敌我语义 | 合规：单／双／长刃、同时双轨、完整旋斩；三尺寸与灰度实机验收 |
| VI Performance | 合规：有Q1负载、环境、帧时目标 | 合规：有界记录与预览，无玩法RNG／全树扫描；前后Release分别核对hash |
| VII Scope Control | 合规：无在线、付费、平衡或非剑系重绘 | 合规：profile与DEV合同不变；002开放项独立保留 |
| VIII Incremental Delivery | 合规：规划不声称实现 | 合规：每步有验证／文档检查点；自然九局延期且未记通过；先冻结基线再实施 |

**设计门禁：PASS，无宪法例外。实施：已授权；FR-012自然九局延期验收，保留未验证。** 规划可以交付，不等于授权或验证实现。

## Project Structure

### Documentation (this feature)

```text
specs/003-sword-promotion-identity/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── tasks.md
└── contracts/
    ├── combat-presentation.md
    ├── promotion-preview.md
    └── validation.md
```

2026-10-21规划交付后，`speckit-tasks`已生成[tasks.md](tasks.md)：54项包含开工门槛、三故事及最终验收；当前T001证据准备完成，余53项未完成，功能未实现。规划与身份核对不代表游戏验收通过。

### Source Code (repository root)

预定扩展位置，**不是本次已创建或修改的源码**：

```text
data/professions/{swordsman,swordmaster,abyss_swordsman}.tres  # 内嵌VisualSet
scripts/data/visual_set.gd                                  # 可选剑系身份
scripts/combat/
  actor_presentation.gd                                    # 剑系调用共享绘制
  sword_presentation.gd                                    # 拟新增：纯绘制／姿态
  sword_branch_attacks.gd, attack_executor.gd               # 附加视觉元数据
  melee_arc.gd                                            # 按既有几何渲染
  damage_service.gd, combat_feedback.gd                     # 实际治疗事实与提示
scripts/core/run_manager.gd                                # 信号／元数据转交
scripts/core/app_router.gd                                # 普通预览绑定既有DEV遮罩显隐
scripts/ui/promotion.gd, promotion_preview.gd               # 后者拟新增
scenes/ui/promotion.tscn                                    # 复用页面
tests/unit/, tests/integration/                             # 扩展现有suite
tests/sword_identity_graphical_check.gd                     # 拟新增图形检查
tests/sword_preview_realtime_check.gd                      # 拟新增：外部真实播放检查
tests/fixtures/sword_identity_session.gd                    # 拟新增比较夹具
tools/run_validation.ps1                                   # 接入新图形检查
tools/validate_sword_identity.ps1                           # 拟新增Compare入口
docs/validation/sword-promotion-identity/                   # 实施后证据
```

继续使用`scenes/debug/debug_panel.tscn`及App拥有的单一实例；不在页面挂副本。DEV复用预览仍走原沙盒action service。

## Design and Boundaries

1. **轮廓**：VisualSet加可选`sword_identity`（空／single／dual／long），只给三剑系Resource赋值。共享绘制器接收归一的death > hurt > attack > move > idle、朝向、主动tick与主角／同伴标记，不按英雄姓名判断。32px主体保留，真实剑弧范围独立取实际几何。
2. **攻击**：既有create_arc链传职业及primary／secondary／spin／echo视觉元数据，不增加伤害请求。两弧同时显示，方向保持0°／+20°；第五次完整360°旋斩。完整边界从创建可见，伤害仍按原模拟阶段结算。Echo保留既有延时，不增发动计数或分支治疗。
3. **治疗**：原heal调用前后测实际HP差，仅>0发新只读`branch_heal_applied`；原满血时仍消耗治疗去重键。保持attack_committed六字段与所有音频合同。提示跟随恢复者、显示一位小数；每队员最多一个36主动tick记录，最多3个，不合并成虚构恢复量。
4. **演示**：每页仅两个剑系示例，复用绘制器，读配置快照。360本地tick循环，在30／90／150／210／270tick演示五次发动，271tick模拟第五次有效命中／恢复，360重置。六秒循环标注“演示 · 示例数值 · 节奏示意”；使用分支基础max_health（当前250），缺血10，heal_fraction（当前2%）计算示例差值5.0，不代表英雄当前状态或真实攻速。其他职业静态预览不变。
5. **生命周期与布局**：画布直接监听所属Window焦点并初始化has_focus；页面不可见停钟、离页断开／清理、提交后停止。普通菜单无run也能冻结；App.show_promotion向普通页传入既有debug_panel.overlay，页面绑定其visibility_changed并初始化遮盖状态，关闭被保存保护拒绝时仍冻结。DEV内页不绑定这个遮罩，只按自身可见性运行；ALWAYS父节点／树暂停下仅推进示例，不解冻run。用本地单调时间差推进60Hz且剔除失焦时间，与Engine.time_scale解耦，回焦不补播。扩展旧72×58区域为可容纳完整长弧的有界画布，保持整数像素尺度，滚动页面panel不超过640×360、确认／取消可达。
6. **比较**：冻结改前源码／构建清单及相同输入、快照、选择。比较版本hash允许不同，但各自必须匹配自身manifest。002 Replay只支持同hash，不绕过守卫。新Compare入口核对全部原玩法状态投影，表现字段另存，不能删掉不相等的玩法字段来制造通过。
7. **验证执行**：US3生产默认Time.get_ticks_usec，原生suite注入单调微秒时钟推进同一状态机，保留55秒watchdog；真实10循环／10开关用独立脚本及外部harness，1920×1080下源码／Debug各普通1×及DEV 1×／2×／4×、Release普通1×，每组合内部150秒／外层180秒，超时保留证据。三尺寸布局另做快速检查，注入结果不替代真实时长。
8. **验收判定**：SC-003增加12段灰度片段（三尺寸×两分支×普通／第五次）、每段1秒一次，5人中至少4人各≥10/12且两攻击组各≥5/6；原10张密集截图≥8/10另行判分。SC-006按验证合同V5冻结Aren剑圣／Brann深渊／Lia队伍和每600tick的缺血输入，120秒分12窗，每窗真实双斩≥5／旋斩≥1／长弧≥5／合法正治疗≥1；候选四类表现各至少1个实际渲染帧，总负载与帧时标准不变。

详见[data-model.md](data-model.md)、[战斗表现契约](contracts/combat-presentation.md)、[预览契约](contracts/promotion-preview.md)、[验证契约](contracts/validation.md)。

## Delivery Sequence for Task Generation

| 顺序 | 检查点 | 要求 |
| --- | --- | --- |
| 0 门槛／基线 | 自然九局延期验收；实施前冻结改前源码／构建及比较输入。图形／性能优先采集，环境缺失仅阻塞相应SC结论，可从冻结旧版补采 | FR-012、SC-005／006 |
| 1 US1 | VisualSet、共享绘制、弧元数据；两英雄主角／同伴、状态优先级；abilities／音频／图形窄测 | FR-001–003、009–011 |
| 2 US2 | 实际治疗事实、有界反馈；4／5／6次及满血／拒绝／致死矩阵、暂停／重开 | FR-004、008–011、SC-002 |
| 3 US3 | 两分支循环、普通／DEV宿主生命周期、保存保护；10循环／10开关及资格边界 | FR-005–007、009、011、SC-004 |
| 4 验收 | 完整M4与Debug／Release图形、跨版玩法、真人辨识、Release性能，逐项保留缺口 | SC-001–006、FR-012 |

每个实现检查点更新dashboard、中文overview、README链接、development、当前tasks及实际validation；美术变化同步art-direction和provenance。自动测试失败先修复再推进。人工不可执行时保持待验，不关闭002未完成事项。

## Complexity Tracking

无宪法例外。共享绘制器解决实战／演示一致性，Compare入口只满足SC-005／006，不建立通用动画框架或第二套战斗模拟器。

## Planning Validation

仅文档工作：已读取源码／Resource／scene、现有测试及证据，核对命令参数；未运行Godot、导出、自然游玩或性能测试。新增入口均标为拟新增。执行前后均未发现`.specify/extensions.yml`，无before_plan／after_plan hook可执行。

已完成文档静态检查：7份设计产物及README／overview／dashboard共10份文档，192个本地引用有效；dashboard的21张图片均有alt，未发现缺失文件／锚点或模板占位符。Git whitespace检查无错误（提示现有CRLF将规范化为LF）。这些检查不代表游戏功能或视觉验收通过。
