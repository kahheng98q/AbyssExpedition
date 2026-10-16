# Milestone 2 screenshot guide — 2026-10-15

User request: screenshots matching FR-015 through FR-023 and SC-005, showing what is implemented and how to find it. No gameplay implementation changed for this request.

Outputs:

- docs/milestone-2-screenshots.html: requirement-filtered guide, 35 original game frames, captions, navigation steps and magnified combat views using the same images.
- docs/milestone-2-screenshots.zip: portable gallery; extract everything and open index.html. Includes original PNGs, capture manifest/log and relevant guides. No executable or user save is bundled.
- screenshots/m2-evidence/: native PNG captures and manifest.json with per-frame descriptions and checks.

Captured from the already-built builds/windows/debug-panel-access-fix/AbyssExpedition-debug.console.exe using tests/m2_evidence_capture.gd as an external harness. Prepared levels, enemy placement, fifth-attack counters, terminal outcomes and one simulated save-publication failure are controlled fixtures; captions explicitly describe this. These are actual game-rendered screenshots, not mockups or altered image assets. Tests use workspace-scoped APPDATA and unique user://tests/ profiles.

Capture result: **35 screenshots, 111 assertions, zero failures**. The manifest includes real attack object checks, level-to-stat derivation, Abyss healing, Star Hunter target transition, reward commitments including selected/downed/unselected participants, companion downing, save Retry and twenty exact saved-payload reopen comparisons. The gallery references the preceding 916-check full validation separately; it does not present that as a fresh regression run for this documentation-only change.

Requirement mapping:

| Requirement | Visible evidence | Limit of still images |
| --- | --- | --- |
| FR-015 roster | Selection entry, roster, active/companion roles, XP/classes/passive names/items | Full save validation needs tests |
| FR-016 permanent levels | Aren at 1/14/15/30 with live HP/damage | Cap/overflow and arbitrary upgrades need tests |
| FR-017 rewards | Victory, defeat and abandonment Saved lines | Minute boundaries, participant eligibility and duplicate settlement need tests |
| FR-018 promotion | Two branches on each of three promotion screens | Atomic item/branch writes and stale revisions need tests |
| FR-019 six branches | Saved roster class and real fifth-attack frame for every branch; extra Star Hunter transition | Collision sequences and zone lifetime need tests |
| FR-020 passives | All three named passives and live stats | Damage math/counters cannot be established by a still |
| FR-021 party AI | Saved 0/1/2 companions and deployed slots/HP | Following, target selection and safe recovery need tests |
| FR-022 companion combat | DOWNED pose/HUD with active hero still alive | Damage/heal/immunity/shared-upgrade rules need tests |
| FR-023 durability | Real save-error Retry interface, committed roster after Retry | Corruption/interruption/two-process lock guarantees need tests |
| SC-005 reopen | New app loads saved XP and party after twenty exact payload comparisons | The image shows state; the comparisons establish equality |

Verified all 35 PNGs have valid PNG signatures and 640×360 dimensions, all 46 gallery image references exist, all ten requirement anchors are present and unique, the gallery script parses, and the ZIP passes CRC integrity checks. Representative roster, levels, all six attack policies, rewards, downing, save-error and reopened-roster captures were visually inspected. Combat art remains small geometric placeholder art; magnification makes the effects easier to identify.

The in-app browser rejected the optional local-file HTML preview because its URL policy allows only HTTP/HTTPS. No alternate browser route was attempted. The guide was checked as a local artifact, and the original PNGs were inspected directly. Users can open the extracted index.html locally in their browser.
