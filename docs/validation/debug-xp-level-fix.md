# XP and level reflection fix — 2026-10-15

Reproduced the supplied situation with active Lia at permanent level 14 / 1300 XP, shared run level 1 / 0 XP, seed 101. Mouse clicks already changed permanent levels and combat stats, but the HUD labeled only shared expedition progression as “Lv / XP,” making the permanent change invisible there. The panel initially selected Aren even when Lia was deployed. Native typing also reproduced stale XP: entering 250 and clicking Add permanent XP without Enter used the previous SpinBox value. Temporarily removing the explicit input application reproduced five dependent failures; restoring it passed all checks.

Changes:

- Apply the typed XP/material amounts before dispatching button actions.
- Select the deployed hero on initial panel opening.
- Display Hero Lv and Run Lv / XP separately in the combat HUD, updated by existing authoritative state notifications.
- Display shared run XP, threshold and pending upgrades inside the paused Character tab; report exact permanent XP/level before and after changes and the level-30 cap.
- Add actual mouse and keyboard regression coverage to the graphical harness, executed against source and the exported debug executable.

Verification completed with Godot 4.5.stable.official.876b29033:

| Checks | Assertions | Failures |
| --- | ---: | ---: |
| All nine M1/M2 suites | 633 | 0 |
| Developer integration | 68 | 0 |
| Source graphical / mouse / keyboard | 80 | 0 |
| Exported debug graphical / mouse / keyboard | 80 | 0 |
| Actual exported release denial | 18 | 0 |
| Total | 879 | 0 |

Import, content, parser, invalid-input rejection, existing M1/M2 graphical checks and both exports also passed. Gameplay content digest remains 318c0d513ea44edd6741a532de640dfabfc410fc99e31bfbb4ec0832ef1716d4. M1 seed-101 victory ticks remain Aren 33754, Lia 33206 and Milo 33080. Promoted ability and persistence regression suites pass.

Mouse/keyboard assertions verify +1/+10/max, repeated capped additions, typing 250 without Enter, permanent XP 1400→1650 / level 15→17, shared run XP 150/200 / level 2 with one pending choice, HUD/bar/panel updates, Lia's level-30 maximum health 237, sandbox reload and restart, finishing upgrade choices and restoring combat pause, HUD bounds, and exact normal-profile bytes remaining unchanged. Three window sizes and all four tabs/promotion UI remain covered. Captures: screenshots/debug-xp-level-buttons.png and screenshots/debug-xp-level-hud.png were visually inspected.

The complete validation command passed through source checks, then Windows refused to rename the embedded temporary export over the existing debug executable. The old executable remains unchanged. Export and native probes completed successfully in a fresh directory using:

    & './tools/run_debug_validation.ps1' -SkipRegression -BuildDirectory 'builds/windows/debug-panel-xp-fix'

Fresh builds:

- builds/windows/debug-panel-xp-fix/AbyssExpedition-debug.exe — SHA-256 7B0CC84C52522E3254F75A724F125CDD67D078BD22CD764BEF44E6D5DAA0043B
- builds/windows/debug-panel-xp-fix/AbyssExpedition.exe — SHA-256 7C498ADE3A7139B3828153B58D9CD7C07310B6D21147E8A9B8E7DE29D82E46F9

The original M1/M2 executable hashes remain unchanged. Child APPDATA and all profiles are isolated beneath workspace test storage. Permanent debug changes remain sandbox-only by design; the fix does not transfer test progress to the normal save. Existing human/performance acceptance gates remain separate.
