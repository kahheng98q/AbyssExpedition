# Art direction / historical placeholder conventions

> 2026-10-17：批准的八件视觉切片已接入原生候选；[当前统一方向](visual-design/ART_DIRECTION.md)、[真实资产](visual-design/ASSET_INVENTORY.md)、[实机对照](visual-design/runtime-gallery.html)。G2人工/延迟/参考机性能未通过。以下为保留的历史占位约定。

> 2026-10-16: [VD-01 production art guide](visual-design/ART_DIRECTION.md) and [implementation plan](../specs/002-2d-art-direction/plan.md) now propose the replacement workflow. They remain pending G0/G1 approval; the legacy runtime described below is unchanged.

> Historical runtime baseline only. The [clarified production specification](../specs/002-2d-art-direction/spec.md#clarifications) selects 640×360 / 1× camera, 32×32 production tiles and 32×48 hero canvases (approximately 24×32 visible body), plus mirrored animation and minimum-frame rules. These supersede the replacement-size proposals below for future approved production; existing procedural assets remain unchanged. Numeric clarification is not G0/G1 mockup approval. [中文阅读版](../specs/002-2d-art-direction/spec.zh-CN.html)

640×360 logical viewport, integer keep-aspect viewport stretch, nearest sampling. World tiles 16×16, actor canvases 32×32, boss 64×64; hero collision diameter 16 pixels. Continuous physics; round only drawing and camera presentation.

Original procedural pixel silhouettes: swordsman with blade, archer with bow, mage with star; thrall diamond, brinejaw crab, cantor lantern, husk shell, broodmother tentacles, broodling small triangle, boss crowned cult silhouette. White hero ring and dark outlines keep ownership clear. Orange outlined warnings precede red impacts. Cyan diamond XP.

Presentation state priority: death > hurt > attack > move > idle. Placeholder states use procedural poses/flash rather than finished sprite sheets; target replacement timing idle 4/6 FPS, move 6/10 FPS, attack 4/12 FPS, hurt 2/12 FPS, death 6/8 FPS. Nothing in presentation changes damage or cooldowns. Replace silhouettes with original sprite sheets at the same canvas size.


M4: Aetheran shallow tidal shelves remain safely walkable; decorative cult stones have muted outlines. Corruption changes shoreline tint, never safe-ground collision or warning colors. Corrupted normals keep the existing behavior silhouette plus a violet forked crest/ring; the Hierophant adds original tentacles and a pale single eye within its 64-pixel canvas. Orange warnings remain distinct from violet ambient feedback. All additions are original procedural placeholders with replacement records in assets/provenance.md.
