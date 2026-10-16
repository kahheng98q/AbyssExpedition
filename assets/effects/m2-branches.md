# M2 procedural placeholder effects

Original Godot drawing assets authored for Abyss Expedition on 2026-10-14; no external sources, copied artwork, or new runtime dependencies. Project-owned placeholders; replace with original pixel animation sheets at the documented 32×32 character scale.

The profession VisualSet Resources are the identity assets. Swordmaster adds a second blade and gold arcs; Abyss Swordsman adds a spectral mantle arc and a longer violet strike; Sharpshooter adds a long bow and green piercing arrows; Star Hunter adds a star-tipped bow and blue impacts; Elemental Sage adds a three-color mantle and alternating orange/ice-blue shots; Void Caster adds a ringed staff and violet damage/pull rings. Draw implementations live in actor_presentation.gd, melee_arc.gd, projectile.gd and damage_zone.gd.

Damage, healing, activation counts, pull, slow and expiry remain simulation-owned. The art consumes actor/effect state and cannot trigger combat callbacks. Companion outlines and HUD health/downed text distinguish followers from the active hero.
