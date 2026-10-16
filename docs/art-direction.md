# Original placeholder conventions

640×360 logical viewport, integer keep-aspect viewport stretch, nearest sampling. World tiles 16×16, actor canvases 32×32, boss 64×64; hero collision diameter 16 pixels. Continuous physics; round only drawing and camera presentation.

Original procedural pixel silhouettes: swordsman with blade, archer with bow, mage with star; thrall diamond, brinejaw crab, cantor lantern, husk shell, broodmother tentacles, broodling small triangle, boss crowned cult silhouette. White hero ring and dark outlines keep ownership clear. Orange outlined warnings precede red impacts. Cyan diamond XP.

Presentation state priority: death > hurt > attack > move > idle. Placeholder states use procedural poses/flash rather than finished sprite sheets; target replacement timing idle 4/6 FPS, move 6/10 FPS, attack 4/12 FPS, hurt 2/12 FPS, death 6/8 FPS. Nothing in presentation changes damage or cooldowns. Replace silhouettes with original sprite sheets at the same canvas size.


M4: Aetheran shallow tidal shelves remain safely walkable; decorative cult stones have muted outlines. Corruption changes shoreline tint, never safe-ground collision or warning colors. Corrupted normals keep the existing behavior silhouette plus a violet forked crest/ring; the Hierophant adds original tentacles and a pale single eye within its 64-pixel canvas. Orange warnings remain distinct from violet ambient feedback. All additions are original procedural placeholders with replacement records in assets/provenance.md.
