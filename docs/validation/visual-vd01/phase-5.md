# Phase5 — bounded playable art · 2026-10-17

Exact Aren+base Swordsman, Thrall and Brinejaw mappings are integrated through an optional visual Resource table. Legacy professions/definitions were not migrated. Actor bodies sample authoritative simulation deadlines, never animation completion; only presentation offsets snap. Retained full procedural rendering for Brann/promotions/other enemies and injected faults. Sword48/100 and friendly base homing star use actual sheets; upgraded/hostile effects retain full procedural visuals. Projectile simulate and arc contains/hit/cleanup rules are unchanged.

Shrine subtree uses collision/navigation-free32px TileSet, quiet ground, six props and one low-alpha corruption overlay family. Last28px world strip is cropped; four walls and960×540 remain. Actors stay Y-sorted at0, pickups5, effects/projectiles10, warnings20; visual layers−30/−20/−10. No new runtime lights, dynamic shadows, shaders, particles or gameplay events. Portrait/crops/icons now load actual local pixels.

## Executed

[Actual source/export/anchor/state/hash delivery](asset-delivery.json): original approved native cells,29 distinct authored cells,16 tiles,6 props,6 icons,6 editable ORA; valid alpha and no duplicate filler within applicable states. Hurt/warning reuse/contact N/A is explicit. These exports preserve reviewed pixels; final candidate art/readability acceptance is G2, not self-approved.

`run_validation.ps1 -M4 -OnlySuites @('unit','scene_smoke','replay','abilities','integration_m1') -DummyAudio -EvidenceDirectory docs/validation/visual-vd01/phase-5-final` passed import/parse/content and all5 suites:223/166/44/123/63 assertions (719 total). All three new fixtures execute in their named suites. Red contract run retained. Initial external-resource mutation in fault tests and preview-context lookup were fixed; final logs have zero failures. Replay digest protection remains enabled; new visual resource digest is1eb094cd5188983e9a8890e4ffa43ad87a39ffd2d657a90b5c8886f439008fe5; simulation version unchanged.

120-tick paired sprite/fallback observations agree on HP/hits/target/cooldown/spawn order/projectile paths. Tests cover interrupted/resumed/late attack, skipped expiry, death origins, synthetic death, two-tick feedback, warning45, fixed mirrored anchors, pause and current-tick sampling. Existing cleanup/removal logic is unchanged; no animation controls simulation.

Source captures: screenshots/visual-vd01/phase-5/source-r1 (105 native engine viewport images; controlled fixtures, not ordinary gameplay or physical-window screenshots). Expanded recognition fixture/source-r2 follows fixed G1 positions/populations; no participant results are claimed. True physical-window scaling/letterbox, full manual interaction, complete death/pause/speed motion clips and edge-danger acceptance remain pending.

`run_visual_stress.ps1 -Mode after -Executable <pinned source console> -Smoke -EvidenceDirectory docs/validation/visual-vd01/phase-5-perf-smoke`: three valid1s+2s diagnostic runs; p95 26.839/26.651/25.939ms, budget fails. New arc minima30 and star minima100, new actors present; explicit fallback counts retained. This is source/debug short sampling, not final release/reference acceptance.

G2 remains pending. Final full regression, matched release/source comparison and full sequential benchmarks are next; no gameplay optimization or target relaxation authorized.
