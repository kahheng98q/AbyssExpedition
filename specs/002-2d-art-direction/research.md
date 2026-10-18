# Research — VD-01

2026-10-16。依据当前源码/Resource/场景、Godot **4.5** 官方文档及只读架构研究子任务；没有运行游戏。结论是计划决策，不是已实现能力。

| Decision | Rationale / evidence | Alternatives considered |
| --- | --- | --- |
| 保留640×360/1×/Compatibility | project.godot为integer viewport、nearest；Camera2D无平滑；规格已澄清 | 提高逻辑分辨率/3D/renderer迁移改变基线，拒绝 |
| 现有ActorPresentation加可选AnimatedSprite2D | 已有表现边界，SpriteFrames可组织状态 | 重写Actor状态机无必要；全阵容替换越界 |
| Aren+基础职业精确覆盖 | catalog覆盖character.visual_set，actor.visual取profession；Brann共享剑士 | 单改swordsman会误换Brann；另起角色系统过重 |
| 模拟tick选帧 | 12tick攻击/8tick受击/24tick尸体/10tick剑弧/45tick警示，必须暂停和倍速同步 | wall-clock播放可能暂停后继续；延长生命污染玩法 |
| TileMapLayer+Sprite2D装饰 | CoastField有四面真实墙；Actors已有Y-sort | 重写Field丢墙；伪3D/导航重建无必要 |
| 默认painted light、0新增动态效果 | 已有M4性能超标，像素光斑足以提出方向 | 每单位灯、全屏雾、装饰粒子拒绝；单神殿灯仅后续测量审批 |
| 一个Theme+小场景组件 | app_router创建Theme，screen/HUD有局部override；HUD需显式Theme | 只换tscn壳无效；改业务回调不必要 |
| 原创逐帧源+manifest | assets没有可用生产动画表 | AI整图只可作未批准概念；须人工重绘/切帧/校准/来源审查 |
| 分阶段文档预览 | 本轮是规划，实际G1样稿仍缺 | 不把CSS框图/历史图假称成品或当前游戏图 |

## Technical references

- [AnimatedSprite2D 4.5](https://docs.godotengine.org/en/4.5/classes/class_animatedsprite2d.html)：SpriteFrames、flip_h和frame/frame_progress。非居中或整数offset用于锚点；tick采样是结合本项目的设计判断。
- [TileMapLayer 4.5](https://docs.godotengine.org/en/4.5/classes/class_tilemaplayer.html)：单层节点可组合，本计划仅承载装饰地面。
- [2D lighting 4.5](https://docs.godotengine.org/en/4.5/tutorials/2d/2d_lights_and_shadows.html)：原生2D灯/阴影能力可用，本切片默认不用动态灯/阴影。
- [Theme editor 4.5](https://docs.godotengine.org/en/4.5/tutorials/ui/gui_using_theme_editor.html)：共享Control样式，本项目还需处理脚本局部override。

R1已明确背景互斥、三资源映射、权威事件采样与suite执行；P01边缘处理、P02额外负载及P03镜像明暗仍待G1，不能视为已批准。Concept 2/3或文字替代批准、G0/G1、原创源稿、十人review和参考机是后续gate依赖。历史release p95 27.571/27.670/29.259ms来自旧报告，不是本轮或新美术测试。

