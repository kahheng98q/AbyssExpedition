# Placeholder provenance

All visuals introduced in Milestone 1 are original geometric/pixel drawings authored by Codex for this project on 2026-10-14. Source: scripts/combat/actor_presentation.gd, scripts/combat/projectile.gd, scripts/combat/melee_arc.gd, scripts/combat/telegraph.gd, scripts/progression/xp_pickup.gd, scripts/world/coast_field.gd and scripts/ui/*.gd. No external/franchise art, fonts or audio were copied. Godot's built-in UI font is supplied by the engine.

| Asset | Creator/source | License | Placeholder | Replacement |
| --- | --- | --- | --- | --- |
| Three hero silhouettes | Codex/original procedural drawing | Project-owned original | Yes | Original 32×32 sheets |
| Six enemy silhouettes | Codex/original procedural drawing | Project-owned original | Yes | Original 32×32 sheets |
| Hierophant silhouette | Codex/original procedural drawing | Project-owned original | Yes | Original 64×64 sheet |
| Arc, arrow, star, bolt | Codex/original procedural drawing | Project-owned original | Yes | Original attack sprites |
| Warnings, hit flash, immunity outline, death pose | Codex/original procedural drawing | Project-owned original | Yes | Original effect frames |
| Coast tiles, gems and interface | Codex/original procedural drawing | Project-owned original | Yes | Original tiles/UI/icons |

## Milestone 2 original procedural placeholders
Creator/source: Abyss Expedition project / locally authored Godot drawing code and VisualSet Resources. Project-owned; no third-party or franchise assets. Six promoted identities and effects are detailed in assets/effects/m2-branches.md. Placeholder status: replace with original pixel animation sheets at the established scale. Runtime drawings only consume simulation state.

## Milestone 3 original placeholders — 2026-10-15

Sera, Brann and Nyra reuse the existing Mage/Swordsman/Archer procedural class silhouettes, including promotion presentations. Identity is shown by names, collection routes and distinct passives. Replacement: original 32×32 character sheets in the established art direction. The green rescue radius/cross and red failure boundary are original project-owned geometry in `scripts/collection/rescue_zone.gd`; replacement: original pixel zone/effect frames preserving the same exact gameplay radius. Guild, recruitment and rescue UI use locally authored Godot layouts and the engine font. No external images, licenses or copied franchise assets were introduced.


## M4 original procedural additions � 2026-10-15

Creator/source: project-authored GDScript drawing, no external asset source. Permission: original project content under the project's existing asset terms. Placeholder status: yes. scripts/world/coast_field.gd draws walkable tidal shelves, shell arcs, driftwood/cult stones and corruption-tinted edge lines; scripts/combat/actor_presentation.gd adds violet corrupted rings/crests and original boss eye/tentacles. scripts/ui/event_choice.gd and corruption_summary.gd provide original text/panel layouts. These use existing 16-pixel terrain, 32-pixel ordinary actor and 64-pixel boss conventions. Replacement: original coastal pixel tiles and sprite-sheet poses matching current silhouettes, warning contrast and simulation-independent timing. No copied franchise or external horror artwork was used.


## Promotion preview reuse - 2026-10-16

Promotion screens reuse project-authored ActorPresentation and profession VisualSet Resources at integer 2x. No external art or gameplay rules in UI. Original procedural placeholders remain replaceable by the planned original animation sheets. Actual release captures: screenshots/convergence-exe-m2-promotion-aren-1280.png and corresponding Lia/Milo screens.

## Q1 original procedural presentation — 2026-10-18

Original 2D drawing code in actor_presentation.gd, melee_arc.gd, projectile.gd, combat_feedback.gd and coast_field.gd creates armor/cloaks/weapons, drowned cult silhouettes, bone-crown single-eyed boss, hit sparks, trails and ruined coastal stonework. No downloaded/copied art, fonts or sounds added; Godot fallback font remains. Authoring: Codex for this project under the user's design authorization. Keep source attribution to this project; formal sprite sheets/animation production and audio are future replacement work. Design articles are references only; no art from those articles is distributed. Real before/v1/after engine captures are retained in screenshots/quality-20261018/ and are labeled controlled diagnostics.

Q1性能修正：海岸原始程序图形由tools/bake_coast_art.gd通过Godot自己的2D渲染烘焙为assets/world/coast-0.png、coast-100.png。运行时按腐化比例混合，不改变碰撞。draw_field保留为可编辑来源；替换地形美术时重新烘焙并核对前后截图。这两张图是本项目原创生成资产，不来自参考游戏或第三方网站。

Q1 enemy-atlas.png is a documentation-traceable, locally baked original sprite atlas: 7 current enemy silhouettes by 8 visual states (two motion poses, normal/hurt, uncorrupted/corrupted), generated only from this project's actor_presentation.gd by tools/bake_enemy_art.gd. Each 64x80 cell includes the original-size body plus decorative rings/shadow; hitboxes are unchanged. It is a performance atlas, not a claim of hand-authored final animation. Runtime warnings/health bars remain live; hero rendering remains procedural. Re-bake after changing source drawing or enemy VisualSet palettes.

<!-- combat-audio-generated:start -->
## Original combat audio — 2026-10-19

Generated by tools/generate_combat_audio.py using only math/random/struct/wave. No external samples or downloads. Private synthesis seed 20261019; runtime never synthesizes or consumes gameplay RNG. Mono 44.1kHz/16-bit PCM, nonlooping; source peak target0.48 (budget0.5). Manifest stores measured lengths/peaks. Listening and real mix acceptance pending.

- attack_arc: 0.090000s; SHA256 036efd04087659a0ed95f88a1a8b52dd7c43ee3855c20353c6ea543994995a49
- attack_straight: 0.100000s; SHA256 851f5ec7735ec0f94e888820a0bcdb5452877dd746f9d000e4436fd960a418f0
- attack_homing: 0.120000s; SHA256 33cda6b61142d774ebdc2b0d25d9f2da220758053c8bab3be69a3dd6378b8940
- hit: 0.064989s; SHA256 1d4cf2a1e305a4ee5c916dfef9bd6b10c43a391f85c91e54a00d7adbb9b52833
- kill: 0.130000s; SHA256 f05b19f909d1f4e7bdc9eef99718a0113d3e1f50d6982c6f6dd6b53e30379144
- hero_hurt: 0.114989s; SHA256 bc1eb99d7c6066f41705bb280e1ed2c98bcca7f38944d7e5e1f9755b9c84fab5
- level: 0.155986s; SHA256 5c68cd35644b011e5e8d58eff87c631a3565ad9f0bc7382aa46f03ff0b87c077
<!-- combat-audio-generated:end -->
