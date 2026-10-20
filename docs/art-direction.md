# Original placeholder conventions

640×360 logical viewport, integer keep-aspect viewport stretch, nearest sampling. World tiles 16×16, actor canvases 32×32, boss 64×64; hero collision diameter 16 pixels. Continuous physics; round only drawing and camera presentation.

Original procedural pixel silhouettes: swordsman with blade, archer with bow, mage with star; thrall diamond, brinejaw crab, cantor lantern, husk shell, broodmother tentacles, broodling small triangle, boss crowned cult silhouette. White hero ring and dark outlines keep ownership clear. Orange outlined warnings precede red impacts. Cyan diamond XP.

Presentation state priority: death > hurt > attack > move > idle. Placeholder states use procedural poses/flash rather than finished sprite sheets; target replacement timing idle 4/6 FPS, move 6/10 FPS, attack 4/12 FPS, hurt 2/12 FPS, death 6/8 FPS. Nothing in presentation changes damage or cooldowns. Replace silhouettes with original sprite sheets at the same canvas size.


M4: Aetheran shallow tidal shelves remain safely walkable; decorative cult stones have muted outlines. Corruption changes shoreline tint, never safe-ground collision or warning colors. Corrupted normals keep the existing behavior silhouette plus a violet forked crest/ring; the Hierophant adds original tentacles and a pale single eye within its 64-pixel canvas. Orange warnings remain distinct from violet ambient feedback. All additions are original procedural placeholders with replacement records in assets/provenance.md.

## Q1 表现约定 — 2026-10-18

沿用640×360、最近邻、32px常规角色与64px首领。新增原创程序披风/装甲/武器朝向、分段触须与独眼骨冠；主角头顶浅金标记和地面椭圆，同伴保留较弱识别环。攻击是快速扫斩并在真实命中tick显示完整范围边缘；细亮刃沿弧扫过后收势。伤害数字取实际扣血，敌方为青/击杀浅金，玩家受伤为珊瑚色；48条上限/36tick，不用全屏闪光、镜头抖动或时间缩放。静态低对比破碎石路与潮汐浅滩均可走，场景装饰不可伪装为障碍。

第一版HUD文字重叠已通过截图发现并修正。仍属于程序像素美术，正式精灵表、原创音效和真人密集画面辨识未完成；不能称为最终商业美术。所有素材和样式由本项目原创绘制，设计参考见Q1报告。

Q1密集敌人已从同源程序绘图生成8状态图集，主体原比例不变，图集单元额外包含阴影与腐化外环。运行时选择对应动作/受击/腐化帧；预警与血条继续实时绘制。图集缓存中的敌人阴影跟随1px步态，原程序绘图与烘焙脚本保留供修改。现有敌人图集是性能用原创资产，正式手工角色动画仍待制作。
