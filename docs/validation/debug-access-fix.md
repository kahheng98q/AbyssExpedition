# Debug access fix — 2026-10-15

The reported screenshot shows a debug game with no visible developer entry point. The prior panel started hidden, provided no startup hint, and recognized only logical F9 keycodes. A regression test reproducing a physical F9 event without a logical keycode failed before the change and passes afterward. This establishes a specific input failure; the screenshot alone does not establish which keyboard event or operating-system shortcut occurred on the user's machine.

The developer build now provides:

- A visible **Debug · F9** mouse button from startup, including menus, combat and existing manual pauses.
- A **Developer Build · F9 / Debug** window title and startup hint.
- Logical and physical F9 handling, with held-key repeats ignored.
- A readable **Debug unavailable** reason when sandbox creation cannot proceed.
- A project-root **Play Debug.cmd** launcher pointing to the newly verified debug executable.
- A quick-start, XP/promotion examples and troubleshooting in docs/developer-debug-panel.md.

Opening still creates an isolated sandbox and acquires its own pause token. Closing through F9 or the existing close button preserves other pauses. The regular release executable retains all native debug restrictions.

Executed successfully:

    & './tools/run_debug_validation.ps1' -BuildDirectory 'builds/windows/debug-panel-access-fix'

| Checks | Assertions | Failures |
| --- | ---: | ---: |
| All M1/M2 suites | 633 | 0 |
| Developer integration | 69 | 0 |
| Source graphical / mouse / keyboard | 97 | 0 |
| Exported debug graphical / mouse / keyboard | 97 | 0 |
| Actual exported release denial | 20 | 0 |
| Total | 916 | 0 |

Import, content, parser, invalid-input rejection, M1/M2 graphical checks and debug/release exports also passed. Existing XP/level mouse/typing, reload, live-stat, promoted ability and save-isolation checks remain passing. The gameplay content digest is unchanged; seed-101 M1 victories remain Aren 33754, Lia 33206 and Milo 33080 ticks.

New native input checks exercise mouse opening in the menu and combat, logical and physical F9, closing from a focused XP field, ignoring key repeats, mouse closing, opening during manual pause, retaining that pause on close, reporting a blocked normal profile without pausing, and launcher/error bounds. Release probes verify there is no developer button/title and both F9 event forms leave gameplay unchanged. All automated profiles use unique test roots and workspace-scoped child APPDATA.

Visually inspected screenshots/debug-access-menu.png and screenshots/debug-access-combat.png. Existing four-tab, scrolling and promotion checks pass at 1280×720, 1920×1080 and 1371×813.

Verified builds:

- builds/windows/debug-panel-access-fix/AbyssExpedition-debug.exe — SHA-256 47618E3102CDC25F891B1D83592A0ABA1E738AB4C3BAE4E93065F6879B3DED22
- builds/windows/debug-panel-access-fix/AbyssExpedition.exe — SHA-256 B0A2211371A5DE03EC372EA572ED4391DA70C033FC190D63C6840521ABE3871E

The export uses a fresh directory so prior running executables need not be overwritten. Previous builds remain available. Ordinary human playtesting/performance acceptance is separate from these functional checks.
