# Developer Debug Panel

Double-click **Play Debug.cmd** in the project folder. It now runs **current source** through the pinned `tools/godot-4.5/Godot_v4.5-stable_win64.exe`, so later Spec Kit/polish edits cannot leave this entry on an old export. The title says **Developer Build · F9 / DEV**; a small **DEV** button stays near the top-right corner below the HUD. This reuses the original four-tab panel; no replacement panel or autoload was added.

**2026-10-18 protected-access repair:** [investigation, regression logs and remaining limits](validation/debug-protected-20261018.md). The old launcher selected a historical debug export; the Q1 default executable is release and intentionally cannot open debug. Source mounting/scene transitions were intact. F9 previously used raw key handling without an InputMap action, and normal validation omitted the debug suite. Both omissions are fixed.

## Quick start

1. Close your previous game window, then double-click **Play Debug.cmd**, or use F5 in pinned Godot 4.5. The final verified debug export is `builds/windows/debug-protected-20261018/AbyssExpedition-debug.exe`; the source launcher stays current after future edits.
2. Click **DEV** at the top right, or click inside the game and press **F9**. On keyboards that use function keys for media controls, try **Fn + F9**, or use the button. Access is retained in the main-menu route (currently guild), guild, selection, roster, recruitment, promotion, battle and results, including after same-seed restart and during manual pause.
3. The developer panel opens and combat pauses. Choose **Character**, **Combat**, **Progression** or **System**. Select the character you want to edit before adding levels or XP.
4. Close the panel with **F9** or its **F9 · Close** button. If adding shared run XP earned upgrades, complete those choices before combat resumes. A pause you had already enabled with Escape also remains enabled.
5. To return to your ordinary save, choose **System → Discard session / normal menu**. Debug changes stay in the test sandbox.

**XP example:** Start as Lia, open Character, enter 250 and click **Add permanent XP**. The selected hero's permanent XP/level and live combat stats update. **Hero Lv** in the combat HUD shows that permanent level. **Add XP to shared run** advances the separate **Run Lv / XP** and grants normal upgrade choices. Permanent levels cap at 30.

**Promotion example:** Select a character, open Progression and use **Grant promotion requirements**, then **Open existing promotion UI** and confirm a branch. Close the panel to try its attacks. To preview the alternate branch without changing the saved sandbox class, use **Test selected branch in this run only**.

## If the panel does not open

- **No DEV button:** launch **Play Debug.cmd**, then check the Developer Build title. The ordinary release executable, AbyssExpedition.exe, has developer tools disabled. Historical debug exports may contain older UI; use current source.
- **Button works but F9 does not:** give the game keyboard focus by clicking inside it; try Fn + F9 if your keyboard uses media keys. You can always use the mouse button when the keyboard intercepts F9.
- **“Debug unavailable” appears under the button:** read the displayed reason. Resolve the normal-profile save/recovery error first; for a profile-in-use error, close the other game copy. Then click Debug again. The panel reports failure without pausing gameplay.
- **Combat stays paused after closing:** finish pending upgrade choices or release your existing Escape pause. The panel only releases its own pause.
- **Close reports a pending sandbox save:** use **System → Retry pending sandbox save** or **Discard session / normal menu**.

For editor testing, run with the pinned Godot 4.5 editor (F5); the same button and F9 controls are available.

Opening creates a save session under user://tests/developer-<process>-<session>/. SaveCoordinator clones the normal profile and all subsequent selection, promotion, settlement and debug saves use that sandbox. Your normal writer stays untouched and locked. A DEBUG SANDBOX banner remains after closing the panel. Choose **System → Discard session / normal menu** to abandon the debug run and restore the normal profile. Quitting never transfers debug progress to the normal save.

F9 opens/closes the panel. It owns one PauseCoordinator token; closing releases only that token. Existing manual/level-up pauses remain. Escape and unhandled game shortcuts are consumed while the panel is open. Keyboard focus stays in debug when run XP creates a level-up modal; closing restores modal navigation. Controls process while paused.

## Controls

Four scrollable tabs fit the 640×360 logical viewport.

| Tab | Controls |
| --- | --- |
| Character | Owned hero selector; +1/+10/max permanent levels; configurable permanent/shared run XP; selected living-character heal; cooldown reset without resetting fifth counters; active invincibility; identity, XP/level, saved/runtime classes, HP, attack, defense, speed, skills/passive and counters |
| Combat | Existing enemy selector; reserve 1/10/50/100 enemies; duplicate-safe chapter boss; kill enemies through damage/death/drop APIs; clear hostile shots; heal living team; team god mode; same-seed restart; 1×/2×/4× speed |
| Companions (Combat tab) | Add an owned hero to this run, remove a follower, heal followers, toggle one follower's movement/attacks; HP, level, class and formation/follow/recovery/downed status |
| Progression | Grant items or level-15/item requirements in sandbox; open existing promotion UI; bypass requirements by granting them in sandbox; either branch as a runtime preview without changing saved class |
| System | FPS, active/pending enemy counts, seed, active time, speed, position, god mode; collision-shape hint; validated sandbox save/load, same-action Retry and bounded recent logs |

Leveling respects 30/2900 XP and existing stat derivation. Live refresh preserves HP and shared upgrades; heal explicitly or restart for full HP. Undeployed heroes show derived starting stats. Companion outgoing damage remains half after modifiers.

The Character selector initially targets the active hero. XP buttons apply the number currently typed, including edits made without pressing Enter. Feedback shows the selected hero's before/after permanent XP and level. The combat HUD labels **Hero Lv** (permanent) and **Run Lv / XP** (shared expedition progression) separately. The Character tab also displays shared run XP, its next threshold and pending upgrades while paused. Close F9 to choose earned run upgrades; permanent levels do not consume those choices.

**Promotions:** Grant requirements and use normal promotion confirmation to save a branch *within the sandbox*. Alternatively **Test selected branch / this run only** tests either branch on an already-promoted hero or below level 15. It updates attacks/stats/passives/procedural visuals without spending items, changing saved class or adding respec. Runtime previews reset on run exit/restart. Resources remain immutable.

**Speed:** No controller existed. One debug controller changes Engine.time_scale and physics_ticks_per_second together, retaining 1/60-second gameplay steps while executing more per wall second. Prior engine settings, invincibility/god-mode flags, follower AI overrides, runtime branches and collision hints restore on run exit.

**Save failures:** Profile-dependent stats refresh only after commit. A failed sandbox save retains the candidate, disables further actions and blocks panel closure/resume. Retry the same action or discard the isolated session. Loading restores permanent test data, never an expedition.

## Limitations

- Spawning uses existing safety, warnings, cap and boss-time boundary. Partial/zero reservations are reported; resume to finish warnings. Gameplay RNG streams are untouched.
- Killing the boss resolves victory on the next unpaused simulation step; rewards go only to sandbox.
- No revival or permanent class reset; use restart or runtime branch preview.
- No active-hero swap, new ownership, recruitment, gacha or corruption systems.
- Collision shapes use the native debug hint. Debug resources remain bundled but are not mounted in release; service/direct command guards deny release use, and forged health/AI flags cannot affect release combat.
- Debug actions alter run conditions; seed reuse alone does not preserve replay equality.
- Graphical automation covers three sizes; exhaustive ordinary human playtesting/performance acceptance remain separate.

## Validation and manual checks

    ./tools/run_validation.ps1 -M4 -Graphical -DummyAudio -EvidenceDirectory docs/validation/<new-directory>
    ./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/<new-directory> -EvidenceDirectory docs/validation/<new-directory>/exports

Normal validation always runs the developer suite, including focused `-OnlySuites` calls; `-Graphical` adds source DEV/F9/transition checks; `-Export` produces debug/release exports and an actual-release denial probe. Combined `-Graphical -Export` also checks exported debug graphics. The dedicated debug script additionally probes both exports. Child APPDATA is scoped to tools/runtime-appdata and profiles are isolated. Use fresh evidence/build directories to retain historical results; `-DummyAudio` isolates host audio-device errors and does not validate sound. Actual new results: [protected-access evidence](validation/debug-protected-20261018.md); original results: [debug-panel.md](validation/debug-panel.md).

October 15 XP/level regression evidence: [debug-xp-level-fix.md](validation/debug-xp-level-fix.md). BuildDirectory chooses a fresh export location when Windows refuses to replace an existing executable.

October 15 debug-entry verification: [debug-access-fix.md](validation/debug-access-fix.md).

1. Start debug executable/F5, enter combat, press F9; confirm time stops and controls work.
2. Character: add levels/XP, heal/reset cooldown, toggle invincibility, inspect stats.
3. Progression: grant requirements, confirm a branch through existing UI, close F9 and observe changed attacks. Preview its alternate branch; saved class must stay unchanged.
4. Combat: add two followers, toggle one AI, reserve enemies, close F9 for warnings. Request boss twice; second must fail.
5. Select 2×/4×; paused time stays fixed, resumed combat accelerates. Restart; seed stays and temporary modifiers reset.
6. Add run XP, close F9 and complete normal upgrade choices. Open/close during manual pause; manual pause remains.
7. Save/reload sandbox, inspect path/logs, discard session; normal progress remains unchanged.
8. Launch release and press F9; no panel opens and no DEV button is visible.

### Required manual graphical smoke (human acceptance remains pending)

This complements injected engine input and screenshots; automation cannot confirm physical keyboard focus, Fn/media-key interception, operating-system scaling or a person's visibility judgment.

- Double-click **Play Debug.cmd** from Explorer. Confirm current Q1 visuals, **Developer Build** title and unobtrusive, readable **DEV** button. Test a physical F9/Fn+F9 with game focus and a real mouse click.
- Visit guild → selection → roster → promotion → recruitment → guild; use DEV/F9 on each screen. Tab through XP input and close with F9. No extra panel should appear.
- Start seed 101; open DEV, change XP/level, grant materials, preview a promotion, add an owned companion, heal/toggle God Mode, reserve enemy/boss, inspect FPS/seed and try speed. Resume to see warnings/attacks.
- Esc pause → DEV → close: the manual pause remains. Resume, reopen and restart; same seed returns, temporary modifiers reset, DEV/F9 still work. Abandon to results and return to guild; entry persists.
- Resize to 1280×720, 1920×1080 and 1371×813. Confirm DEV does not obscure HUD actions and the overlay draws above menus/modals. Scroll all tabs. End sandbox; normal save remains unchanged.
- Launch the release executable: no DEV, F9 has no effect. Record build, date, window sizes, physical input results and any failure; do not mark this checklist complete from headless or injected-input tests.

### Ownership and preservation

`App.initialize_debug_ui()` mounts the original `DeveloperDebug` CanvasLayer only in debug, once. It stays outside the replaced `ScreenHost`, `ModalHost` and `ExpeditionHost`; implemented navigation uses these hosts rather than replacing the App scene. A new autoload manager would duplicate the existing lifetime owner. Layer 100 is above screen 10/modal 20; `PROCESS_MODE_ALWAYS` retains input during pause. The launcher uses a viewport-anchored parent whose empty area ignores mouse input. F9 is registered as `debug_panel_toggle` at debug startup; logical/physical raw F9 remains compatible. Release never registers that action, mounts the panel or permits service mutations. See the permanent rule in [AGENTS.md](../AGENTS.md).

## Files

Created:

- scenes/debug/debug_panel.tscn
- scripts/debug/debug_panel.gd
- scripts/debug/debug_action_service.gd
- scripts/debug/battle_speed_controller.gd
- tests/integration/test_debug_panel.gd
- tests/debug_graphical_check.gd
- tests/debug_release_probe.gd
- tools/run_debug_validation.ps1
- docs/developer-debug-panel.md
- docs/validation/debug-panel.md

Modified:

- scripts/core/app_router.gd — debug-only mount/cleanup and modal focus coordination
- scripts/characters/character_factory.gd — reusable stat derivation/member override
- scripts/characters/companion_controller.gd and scripts/combat/attack_executor.gd — guarded AI disable
- scripts/combat/actor.gd — runtime level/AI diagnostics
- scripts/combat/actor_health.gd — guarded invincibility flags
- scripts/progression/permanent_progression.gd — pure capped XP mutation
- scripts/progression/upgrade_effects.gd — derive stats without replaying heals
- tests/run_tests.gd and tests/script_manifest.gd — suite/script registration
- README.md and docs/development.md — playtest/run/architecture notes


## 002 暂停与音效补充 · 2026-10-19

失焦单独持有focus暂停；回到窗口只释放自身token。DEV打开时战斗声及升级声随debug token冻结，关闭后仍尊重level/manual/focus等原因。App继续持有唯一面板，原控件/沙盒与Play Debug.cmd启动方式保留。物理键鼠清单仍待人工执行；本切片证据见[验收矩阵](validation/combat-pacing-audio/acceptance.md)。
