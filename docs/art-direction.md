# Original placeholder conventions

640×360 logical viewport, integer keep-aspect viewport stretch, nearest sampling. World tiles 16×16, actor canvases 32×32, boss 64×64; hero collision diameter 16 pixels. Continuous physics; round only drawing and camera presentation.

Original procedural pixel silhouettes: swordsman with blade, archer with bow, mage with star; thrall diamond, brinejaw crab, cantor lantern, husk shell, broodmother tentacles, broodling small triangle, boss crowned cult silhouette. White hero ring and dark outlines keep ownership clear. Orange outlined warnings precede red impacts. Cyan diamond XP.

Presentation state priority: death > hurt > attack > move > idle. Placeholder states use procedural poses/flash rather than finished sprite sheets; target replacement timing idle 4/6 FPS, move 6/10 FPS, attack 4/12 FPS, hurt 2/12 FPS, death 6/8 FPS. Nothing in presentation changes damage or cooldowns. Replace silhouettes with original sprite sheets at the same canvas size.


M4: Aetheran shallow tidal shelves remain safely walkable; decorative cult stones have muted outlines. Corruption changes shoreline tint, never safe-ground collision or warning colors. Corrupted normals keep the existing behavior silhouette plus a violet forked crest/ring; the Hierophant adds original tentacles and a pale single eye within its 64-pixel canvas. Orange warnings remain distinct from violet ambient feedback. All additions are original procedural placeholders with replacement records in assets/provenance.md.

## Q1 表现约定 — 2026-10-18

沿用640×360、最近邻、32px常规角色与64px首领。新增原创程序披风/装甲/武器朝向、分段触须与独眼骨冠；主角头顶浅金标记和地面椭圆，同伴保留较弱识别环。攻击是快速扫斩并在真实命中tick显示完整范围边缘；细亮刃沿弧扫过后收势。伤害数字取实际扣血，敌方为青/击杀浅金，玩家受伤为珊瑚色；48条上限/36tick，不用全屏闪光、镜头抖动或时间缩放。静态低对比破碎石路与潮汐浅滩均可走，场景装饰不可伪装为障碍。

第一版HUD文字重叠已通过截图发现并修正。仍属于程序像素美术，正式精灵表、原创音效和真人密集画面辨识未完成；不能称为最终商业美术。所有素材和样式由本项目原创绘制，设计参考见Q1报告。

Q1密集敌人已从同源程序绘图生成8状态图集，主体原比例不变，图集单元额外包含阴影与腐化外环。运行时选择对应动作/受击/腐化帧；预警与血条继续实时绘制。图集缓存中的敌人阴影跟随1px步态，原程序绘图与烘焙脚本保留供修改。现有敌人图集是性能用原创资产，正式手工角色动画仍待制作。

## 003 US1 剑系身份 — 2026-10-21

原创程序像素：VisualSet.sword_identity配置single／dual／long，由sword_presentation.gd共享绘制，保留32px主体／nearest／整数绘制位置。单刃17px、双刃两组17px、长刃26px仅是武器装饰尺度，不定义判定；动作12tick，death > hurt > attack > move > idle，主角浅金／同伴较弱标记最后绘制。真实剑弧读取原几何，0°／+20°同时可见，第五次360°，10主动tick，色彩辅助身份，不用敌方橙／红危险语义。逻辑与真实受控图形已验，五人灰度／密集辨识尚待验。

## 003 US2 实际恢复反馈 — 2026-10-21

原创程序短回流／一位小数浮字，使用SwordPresentation.draw_heal／heal_text共用纯绘制；主角浅青绿、同伴较弱蓝青，跟随当前恢复者，36主动tick、每队员最多一条，不累加恢复量、不覆盖原48条伤害预算。小正数允许+0.0，满血／拒绝／重复不发成功；真实Godot受控图像位于docs/validation/sword-promotion-identity/us2-graphics-20261021-v2/sword-captures，未引入第三方美术／字体／依赖，不代表人类可读性验收通过。

### 003 US3 示例表现 · 2026-10-21

独立程序绘制，无外部素材；复用SwordPresentation，画布明确示例数值／节奏。250HP／2%来自只读职业配置，初始缺10，第五次示例显示5.0。实际逻辑／布局已验，真实播放及人类理解另验。

#### 003 受控人测试材 — 2026-10-21

实际Godot逻辑视口：三窗口／同Aren15／无同伴／seed101，基础／双刃／长刃普通与第五次18段60tick序列，12段分支灰度。完整原图保留；无名版统一隐藏CombatFeedback全部数字和粒子、固定裁切(192,104,224,176)移除HUD／DEV，保留角色及真实武器弧；灰度Godot L8，不重绘／生成假图。10张双同伴／腐化100／首领预警密集原图单独保留。材料不等于人类辨识通过；私有hash／题序／答案与公开首答页分离，无AI代答。
