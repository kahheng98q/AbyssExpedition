# SPRITE_SPEC · VD-01

**当前更新 · VD-01-P2**：owner已验证f187视觉参考；本批收尾仅修复长名称/标题与暂停全名详情，精灵/动画/场景/调色板未变。[当前结果与限制](../validation/visual-vd01/completion-r1.md)。下文早期pending记录按其版本保留，量化/物理显示/十人门槛仍分别开放。

> **最新实施 · 2026-10-17**：批准切片已接入原生候选，生产文件/回退/自动检查见[素材现状](ASSET_INVENTORY.md)与[最终评审包](../validation/visual-vd01/review-package.md)。下方2026-10-16未实现/pending文字保留为原设计提交状态；当前G0/G1已批，G2待验收。
> **当前状态 · 2026-10-16**：VD-01-M1的G0/G1及列明设计决定已获owner `approve`。[审批记录](APPROVALS.md)。下文pending是原提交状态；生产清稿/接线/G2未完成。
2026-10-16 · VD-01-M1 概念帧已绘制，生产清稿/导入未实现 · [计划](../../specs/002-2d-art-direction/plan.md)

## Reusable production workflow

1. **Concept reference**：登记实际参考路径、作者/权利和用途。Concept 2/3当前缺失；G0批准文字替代或取得图后再比较。生成式AI可作明确标注的概念参考，不能默认作有效动画表或成品来源授权。
2. **Asset specification**：填asset_id、精确替换对象、画布/可见身体/脚锚、帧状态、方向、色表、唯一格预算、来源与fallback；G1看 native-size剪影和拥挤板。
3. **Original sprite creation**：用可保留像素/图层的本地工具原创逐帧，保留可编辑源和导出PNG；不要求新增付费软件。AI参考须人工重绘、统一比例/锚点/边缘、校正每帧动作和权利记录，不可自动切整图充数。
4. **Sheet preparation**：RGBA8透明PNG、lossless，帧格固定不trim、不旋转打包；同asset同锚点，单源像素一致。独立文件命名asset_state_frame也可作为编辑源；交付统一atlas+manifest。
5. **Frame organization**：每行一个状态，列按时间；manifest记录使用格、重复引用、帧长、loop、NA原因及方向。空格不算完成帧；镜像不计新增原创格。
6. **Godot import**：获批后才放assets；Nearest在节点/继承设置确认，mipmaps关，lossless；SpriteFrames引用AtlasTexture准确region。不能把整张sheet直接当一帧。TileSet采用纹理padding；精灵atlas相邻格透明留边，pixel采样不越界。
7. **AnimatedSprite2D integration**：只在Presentation内创建，读取现有actor/clock；使用SpriteFrames保存序列，按有效tick采样frame/frame_progress（避免自动wall-time推进）。idle/move可保存表现循环起点；短事件按原模拟起点采样，不按首次观察/中断恢复重置，暂停冻结、debug倍速跟随run tick；不得在绘制访问中更改run状态或消费RNG。
8. **In-game validation**：native/2×/3×/irregular截图与四向/暂停/中断clip，灰阶/拥挤/0和100腐化。以G1对齐与G2实机验收关闭资产，不以导入成功判艺术通过。

## Dimensions / atlas / anchors

坐标从左上起，(x,y)为纹理像素位置，角色世界原点不动。使用centered=false配负anchor offset，或等价整数center offset；必须验证flip_h后脚不漂移，必要时按镜像公式校正视觉offset，不移动物理根。

| Asset | Canvas / visible body | Proposed anchor | Atlas ceiling / first batch |
| --- | --- | --- | --- |
| Aren base swordsman | 32×48 /约24×32 | (16,40)，脚在原点，头部约y8 | 6列×5行=192×240，实际只用清单格 |
| Saltbound Thrall | 32×48 /身高24–32 | (16,40) | 4列×5行=128×240 |
| Skittering Brinejaw | 32×32 /宽24–32 | (16,24) | 4列×5行=128×160 |
| Existing boss later | 64×64，未在本批绘制 | 后续G3核定，不修改当前原点 | 无本批sheet |
| Sword arc | 64×96 /原reach48、100°扇形的装饰绘制 | (8,48) | 2格起步=128×96；最多4格 |
| Homing star | 16×16 /约10×10 | (8,8) | 2格起步=32×16；最多4格 |
| Terrain | 32×32 | grid原点 | ≤16格，128×128 |
| Props | 32×32/32×64，神殿≤64×96 | 底部接地标记 | ≤6设计，按尺寸分sheet，不拉伸 |
| Portrait / icon | 24×24面部crop /16×16图标 | UI居中 | 优先裁剪已批准角色，不做新增独立立绘 |

英雄身体范围提案x4..27/y8..39；剑与披风可进入padding但不改变碰撞。Aren和Thrall底部预留8px；Brinejaw同样8px。以上锚点要通过G1脚位测试才能冻结。

## Animation manifest baseline

| Asset/state | Effective frames min / unique ceiling | Playback proposal | Runtime constraints |
| --- | --- | --- | --- |
| Hero idle | 2 /4 | 6FPS，loop | 轻微呼吸，不抖脚 |
| Hero move | 4 /6 | 10FPS，loop | 左右镜像；up/down也用同身体+方向cue，G1四向检查 |
| Hero attack | 3 /4 | **15FPS**三帧，12ticks总窗 | 比历史12FPS提案更快以适配200ms；首帧即打击，G1审批；不得延长attack_until |
| Hero hurt | 1 /2 | 单帧+flash，参考12FPS | 保持8ticks hurt窗口；允许复用idle pose |
| Hero death | 4 /6 | 8FPS，非loop；预览完整500ms | 实机终局可打断；不能拖延结果；倒地同伴停最后姿态 |
| Thrall idle/move | 1/2 /各2/4 | 4FPS idle静态；8FPS move | contact-only，无凭空新增攻击行为 |
| Thrall attack | N/A /0 | manifest写contact-only及源码依据 | 保留contact受击反馈，不造attack事件 |
| Thrall hurt/death | 1/3 /各2/4 | hurt复用+flash；death8FPS | 3死亡帧375ms在24ticks=400ms内可见 |
| Brinejaw idle/move | 1/2 /各2/4 | 4FPS静态/10FPS move | 横向低姿，不旋转身体 |
| Brinejaw warning | 1 /2 | 蓄力pose可复用+原橙警示 | 完整45ticks=750ms，rush30/recover90ticks不变 |
| Brinejaw hurt/death | 1/3 /各2/4 | hurt复用；death8FPS | 普通死亡24ticks清理，不等动画结束 |
| Sword | 2 /4 | 两帧12FPS或按10tick归一化 | 存活约167–183ms，不改expires，首帧就是原命中反馈 |
| Star | 2 /4 | 12FPS loop | 原projectile生灭/路径，命中即消失，不为全帧延寿 |

状态顺序idle/move/attack-or-warning/hurt/death五行；Thrall attack行空且明确NA。建议初稿唯一格：hero13（2+4+3+复用hurt0+4），Thrall6（1+2+0+复用hurt0+3），Brinejaw6（1+2+复用warning0+复用hurt0+3），剑2，星2，总**29**。实际清单按去重结果登记；最宽上限22+14+14+4+4=**58**。没有“生成58格”的生产承诺。

5状态必须有条目。攻击/死亡被真实状态打断不视为缺帧；离线预览仍须展现所有适用有效帧。重复同图不算最低多帧。新四方向sheet需修订估算和G1，不能旋转身体省画。

## Promotions and identities

复用同一帧序列、手/脚定位、画布与节奏；换装备/头发/披肩像素层，最后扁平导出共享帧布局。六晋升分支必须有非调色的轮廓区别；同职业Aren/Brann等须有脸/衣/徽记差异。首批只有Aren基础剑士，晋升后继续现有程序外观，不误套基础sheet。不得引入通用骨骼或每英雄独立动画系统。

剑弧reach会随升级改变：64×96稿只对应已批准基础reach48、angle100。保留程序精确边线；非基础reach/angle先完整回退程序效果并在清单注明未替换，不能分数缩放让像素密度混乱、也不能显示错误边界。若要覆盖升级reach，需G1补充像素重采样/变体方案及测量，本批不暗中扩素材量。星只替换已批准基础友方homing效果，敌弹/晋升元素/其他投射物保持原状。

## R1 · Event sampling and mirror review

攻击起点=attack_until−12；受击采用单姿闪烁截至实际health.hurt_until，不统一反推8tick起点（抗性反馈可为2tick）；死亡优先有效dead_at，主角/同伴用致死receive设置的hurt_until−8；仅ai_state为warning时，Brinejaw预警起点=deadline−45。受击结束后同一次攻击仍有效则继续当前帧；迟到观察/跳tick直接采当前有效帧，不补播过期打击，不等animation_finished，不延长24tick清理。最低有效帧约束资产/完整离线预览，真实中断或低帧率不强制补齐播放。

P03待G1：世界左上光；角色候选近对称明暗，脚影独立，语义标记预算内少量校正。T019/T020并排原向/镜像，T054核对成品，批准前不能作为正式制作规则。

源码边界：run_manager.mark_dead只为非主角、非同伴登记dead_at；ActorHealth.receive在致死时仍设置hurt_until=tick+8，因此倒地同伴可采该致死时间并最终停姿，主角结果仍可立即打断。直接构造dead=true且没有有效时间字段的故障fixture显示终止姿态并报告缺少时间依据，不创建模拟时间或延迟结果。受击pose/flash只在tick<hurt_until显示，兼容damage_zone的2tick抗性反馈；其多帧起点若无已知事件依据则不推断。

## 当前交付与限制 / VD-01-M1

[实际概念manifest](mockups/vd01/animation-manifest.json)列出每个region、画布、脚锚、reuse/N/A、FPS和事件窗口。三角色概念稿13+6+6、两效果2+2，共29个不同像素格；多帧不能重复同图凑数。hurt复用idle并闪白；Thrall attack=N/A（contact-only），Brinejaw warning复用idle+独立45tick警示。动画atlas透明留格，不trim、不旋转角色；镜像由播放器演示，未生成额外方向格。

[动画需求速查](ANIMATION_REQUIREMENTS.md) / [五状态条](mockups/vd01/actors-strip.png) / [四向与事件播放器](mockups/vd01/motion-player.html)。PNG/ORA仅为可审阅概念；正式美术仍需逐帧清理、表情/轮廓审阅、镜像P03决定、正式exports和SpriteFrames。死亡姿态可改变身体重心，脚锚坐标本身固定；不能因画布padding变大而扩大碰撞。
