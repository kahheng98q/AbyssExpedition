# Placeholder provenance

All visuals introduced in Milestone 1 are original geometric/pixel drawings authored by Codex for this project on 2026-10-14. Source: scripts/combat/actor_presentation.gd, scripts/combat/projectile.gd, scripts/combat/melee_arc.gd, scripts/combat/telegraph.gd, scripts/progression/xp_pickup.gd, scripts/world/coast_field.gd and scripts/ui/*.gd. No external/franchise art, fonts or audio were copied. Godot's built-in UI font is supplied by the engine.

| Asset | Creator/source | License | Placeholder | Replacement |
| --- | --- | --- | --- | --- |
| Three hero silhouettes | Codex/original procedural drawing | Project-owned original | Yes | Original 32Ã—32 sheets |
| Six enemy silhouettes | Codex/original procedural drawing | Project-owned original | Yes | Original 32Ã—32 sheets |
| Hierophant silhouette | Codex/original procedural drawing | Project-owned original | Yes | Original 64Ã—64 sheet |
| Arc, arrow, star, bolt | Codex/original procedural drawing | Project-owned original | Yes | Original attack sprites |
| Warnings, hit flash, immunity outline, death pose | Codex/original procedural drawing | Project-owned original | Yes | Original effect frames |
| Coast tiles, gems and interface | Codex/original procedural drawing | Project-owned original | Yes | Original tiles/UI/icons |

## Milestone 2 original procedural placeholders
Creator/source: Abyss Expedition project / locally authored Godot drawing code and VisualSet Resources. Project-owned; no third-party or franchise assets. Six promoted identities and effects are detailed in assets/effects/m2-branches.md. Placeholder status: replace with original pixel animation sheets at the established scale. Runtime drawings only consume simulation state.

## Milestone 3 original placeholders â€” 2026-10-15

Sera, Brann and Nyra reuse the existing Mage/Swordsman/Archer procedural class silhouettes, including promotion presentations. Identity is shown by names, collection routes and distinct passives. Replacement: original 32Ã—32 character sheets in the established art direction. The green rescue radius/cross and red failure boundary are original project-owned geometry in `scripts/collection/rescue_zone.gd`; replacement: original pixel zone/effect frames preserving the same exact gameplay radius. Guild, recruitment and rescue UI use locally authored Godot layouts and the engine font. No external images, licenses or copied franchise assets were introduced.


## M4 original procedural additions — 2026-10-15

Creator/source: project-authored GDScript drawing, no external asset source. Permission: original project content under the project's existing asset terms. Placeholder status: yes. scripts/world/coast_field.gd draws walkable tidal shelves, shell arcs, driftwood/cult stones and corruption-tinted edge lines; scripts/combat/actor_presentation.gd adds violet corrupted rings/crests and original boss eye/tentacles. scripts/ui/event_choice.gd and corruption_summary.gd provide original text/panel layouts. These use existing 16-pixel terrain, 32-pixel ordinary actor and 64-pixel boss conventions. Replacement: original coastal pixel tiles and sprite-sheet poses matching current silhouettes, warning contrast and simulation-independent timing. No copied franchise or external horror artwork was used.


## Promotion preview reuse - 2026-10-16

Promotion screens reuse project-authored ActorPresentation and profession VisualSet Resources at integer 2x. No external art or gameplay rules in UI. Original procedural placeholders remain replaceable by the planned original animation sheets. Actual release captures: screenshots/convergence-exe-m2-promotion-aren-1280.png and corresponding Lia/Milo screens.


## VD-01-P1 · 2026-10-17
Original project pixel geometry by Codex, derived only from owner-approved VD-01-M1 masters (submitted hash3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49). No third-party artwork/font binary copied.6 layered ORA masters and per-state manifests are under assets/source/visual-vd01; lossless production exports under assets/sprites,assets/effects/slice,assets/tiles/coast_shrine and assets/ui.29 distinct actor/effect cells (13+6+6+2+2),16 tiles,6 props,6 icons and Aren portrait crop. Hurt/warning reuse is explicit; Thrall attack is contact-only N/A. See [actual files/source+export hashes](../docs/validation/visual-vd01/asset-delivery.json). Fixed cells/anchors retained; no resampling. G1 concept approved; production candidate/G2 taste and readability acceptance remain pending. Editable masters excluded from release.
