# Player-facing UI contracts

UI emits commands and renders snapshots; it owns no combat, RNG, eligibility, currency or file rules. Keyboard arrows/WASD navigate where appropriate, Enter confirms, Escape opens manual pause/back where permitted. Each newly displayed modal requires a fresh input edge; held/repeated confirmation cannot choose the next screen.

## Screen contracts

| Screen | Required inputs/actions | Visible result / restrictions |
| --- | --- | --- |
| Main menu (M1) | New Expedition, character selection, quit | Offline entry; short controls. No locked future guild/recruitment screens needed for M1. |
| Character selection (M1) | Aren/Lia/Milo, seed blank or 0..2147483647, Start | Attack preview and selected seed; invalid seed explains limits. Fixed starter access without save. Changing hero changes the next run, never swaps control during combat. |
| HUD (M1) | Read-only, Escape pause | Current/max HP, XP/next requirement, run level, active elapsed time; hero remains easy to identify. No currency/corruption widgets before their milestone. |
| Level-up (M1) | Exactly three eligible distinct options, one confirmation | Short accurate effects; world frozen; no skip/reroll; cannot Escape-dismiss. Queued levels stay frozen and use updated eligibility. |
| Pause (M1) | Resume, confirmed abandon, quit | Resume releases manual reason only. Pending level/event/save still blocks. Active time remains frozen. |
| Results (M1) | Retry, New Expedition, selection | Outcome, seed, hero/party, active time, run level, kills and later rewards. Retry same seed; New Expedition new seed. No permanent rewards in M1. |
| Roster/party (M2) | Active owned hero, 0–2 other owned distinct companions, confirm | Ownership, permanent XP/level, base/current class, passive, branch/item eligibility; invalid party shows reason. Switching affects next expedition only; persisted before launch. |
| Promotion (M2) | Preview both branches, confirm one, cancel | Level-15/item requirements, permanent choice, changed attack/effect/visual preview, preserved passive. Level 14/no item/already promoted/unowned blocked without spending. |
| Save error/recovery (M2) | Retry; explicit close warning; recovery/new profile confirmation where applicable | Same pending results, readable storage failure, continuation/spend disabled. Recovery shows timestamp/lost-progress risk; newer version reported incompatible, not fresh profile. |
| Guild (M3) | Expedition, roster/party, promotion, rescue status, draw, exchange/history | Owned starters; all six catalog entries and acquisition routes; item/ticket/token balances. Locked heroes are not selectable. |
| Recruitment (M3) | Preview one/ten pull, confirm/cancel; exchange; history/reveal | Brann 50% / Nyra 50%, total 100%, costs 1/10 tickets; no discount/pity. One ordered list of all ten results; duplicate token labels. Four tokens/insufficient tickets shows missing amount. |
| Rescue (M3) | Accept/decline paused offer | Sera/repeat-ticket reward route, remain inside marked zone 30 active seconds. Defending overlay shows zone/timer; failure/success clear. Success says earned for settlement, not already saved ownership. |
| Corruption (M4) | Compact HUD meter and accessible threshold summary | Value 0–100; exact active advantages and future-wave dangers; class names do not imply initial corruption. |
| Events (M4) | One event at a time, one chosen offer or Leave/Decline | Exact costs/rewards/headroom before confirmation. Unaffordable choices disabled with reason; leave available. No hidden deductions; context outside busy combat. |
| Chapter completion (M4) | Results/return/replay | Victory persists Chapter 1 completion after save; replay still requires defeating boss. |

## Navigation and overlapping states

M1: menu → selection → expedition → result → retry/new/selection. M2 adds roster/promotion before launch. M3 uses guild as the persistent hub and restores unrevealed committed draws before further spending. M4 adds coast/event presentation while preserving previous paths.

Priority: terminal outcome cancels choices; earned levels precede events; existing events resolve/dismiss before boss entry; manual pause remains until explicit resume. Escape may dismiss an event only as its defined free decline/leave, never auto-accept. Confirming abandonment grants no uncommitted rewards. Closing after a failed save uses the specified loss warning.

Replay display explains that same seed requires matching version/party/progression/decisions; Retry does not rewind permanent rewards. Store and compare starting snapshot with the next selected snapshot to warn when conditions changed. No automatic control swapping on hero death. Companion downing is visible and ends its contribution until next run.

## Graphical verification

Review real-window and exported Windows play at 1280×720 and 1920×1080 plus an irregular size. Check crisp pixels, letterboxing, text/focus, shape-based hero/enemy differentiation, 0.75-second minimum warnings, hit direction, invulnerability and all five animation states. Dense-scene feedback, input latency and human comprehension require graphical/human evidence; headless UI scene loading proves neither. See [quickstart](../quickstart.md) for counts and reporting.
