# Developer Debug Panel

## 004 操作更新 · 2026-10-22

保留原App单例、DEV、F9、隔离存档及全部动作ID。`level_one`／`level_ten` 增加共享RUN等级；`level_max`将RUN升到30（不是等级上限）；`character_xp`与`run_xp`均加本局经验。`eligibility`直达RUN Lv15；原`materials`保留按钮并明确作为同一资格操作，无材料或费用。上述操作需要当前沙盒远征；已有升级／事件先结束，随后逐名转职。局外页面只预览。

转职不写沙盒档案；普通确认每角色每局一次，`test_branch`仍可临时测试另一分支。晚加入继承共享等级和升级；移除重加保留本局已选分支；重开从BASE / RUN Lv1开始。保存失败／Retry仍保护真实隔离档案；Release继续拒绝初始化和动作。004核心验证：源码／导出Debug图形116项、原生DEV140项、实际Release拒绝41项通过；原生长时钟焦点组合未完成。新验证见[004记录](validation/run-level-promotion/results.md)。下方历史操作说明如涉及永久等级／材料，以本节为准；原人工烟测清单保留，未执行项仍待验。


Double-click **Play Debug.cmd** in the project folder. It now runs **current source** through the pinned `tools/godot-4.5/Godot_v4.5-stable_win64.exe`, so later Spec Kit/polish edits cannot leave this entry on an old export. The title says **Developer Build · F9 / DEV**; a small **DEV** button stays near the top-right corner below the HUD. This reuses the original four-tab panel; no replacement panel or autoload was added.

**2026-10-18 protected-access repair:** [investigation, regression logs and remaining limits](validation/debug-protected-20261018.md). The old launcher selected a historical debug export; the Q1 default executable is release and intentionally cannot open debug. Source mounting/scene transitions were intact. F9 previously used raw key handling without an InputMap action, and normal validation omitted the debug suite. Both omissions are fixed.

## Quick start

1. Close your previous game window, then double-click **Play Debug.cmd**, or use F5 in pinned Godot 4.5. Use current source; the 2026-10-18 debug export is historical.
2. Click **DEV** at the top right, or click inside the game and press **F9**. On keyboards that use function keys for media controls, try **Fn + F9**, or use the button. Access is retained in the main-menu route (currently guild), guild, selection, roster, recruitment, promotion, battle and results, including after same-seed restart and during manual pause.
3. The developer panel opens and combat pauses. Choose **Character**, **Combat**, **Progression** or **System**. Select the character you want to edit before adding levels or XP.
4. Close the panel with **F9** or its **F9 · Close** button. If adding shared run XP earned upgrades, complete those choices before combat resumes. A pause you had already enabled with Escape also remains enabled.
5. To return to your ordinary save, choose **System → Discard session / normal menu**. Debug changes stay in the test sandbox.

**XP example:** Start as Lia, open Character, enter 250 and click **Add shared RUN XP**. All deployed members share the current run level; no stat multiplier or profile level is created. The other XP action uses the same pool. **Raise RUN level to 30** is a debug target, not a level cap.

**Promotion example:** Start a sandbox run, use **Reach RUN Lv15 eligibility**, close DEV and finish the current card if one is open. The next choice offers each living member a run-only branch. Cancel defers; use HUD **Promotion** to reopen. **Test selected branch / this run only** remains a debug bypass for comparison.

## If the panel does not open

- **No DEV button:** launch **Play Debug.cmd**, then check the Developer Build title. The ordinary release executable, AbyssExpedition.exe, has developer tools disabled. Historical debug exports may contain older UI; use current source.
- **Button works but F9 does not:** give the game keyboard focus by clicking inside it; try Fn + F9 if your keyboard uses media keys. You can always use the mouse button when the keyboard intercepts F9.
- **“Debug unavailable” appears under the button:** read the displayed reason. Resolve the normal-profile save/recovery error first; for a profile-in-use error, close the other game copy. Then click Debug again. The panel reports failure without pausing gameplay.
- **Combat stays paused after closing:** finish pending upgrade choices or release your existing Escape pause. The panel only releases its own pause.
- **Close reports a pending sandbox save:** use **System → Retry pending sandbox save** or **Discard session / normal menu**.

For editor testing, run with the pinned Godot 4.5 editor (F5); the same button and F9 controls are available.

Opening creates a save session under user://tests/developer-<process>-<session>/. SaveCoordinator clones the normal profile and all subsequent selection, settlement and debug saves use that sandbox; promotion is run-only. Your normal writer stays untouched and locked. A DEBUG SANDBOX banner remains after closing the panel. Choose **System → Discard session / normal menu** to abandon the debug run and restore the normal profile. Quitting never transfers debug progress to the normal save.

F9 opens/closes the panel. It owns one PauseCoordinator token; closing releases only that token. Existing manual/level-up pauses remain. Escape and unhandled game shortcuts are consumed while the panel is open. Keyboard focus stays in debug when run XP creates a level-up modal; closing restores modal navigation. Controls process while paused.

## Controls

Four scrollable tabs fit the 640×360 logical viewport.

| Tab | Controls |
| --- | --- |
| Character | Owned hero selector; +1/+10 RUN levels or target 30; configurable shared RUN XP; living-character heal; cooldown reset without resetting fifth counters; invincibility; current run class/stats, passives and counters |
| Combat | Existing enemy selector; reserve 1/10/50/100 enemies; duplicate-safe chapter boss; kill enemies through damage/death/drop APIs; clear hostile shots; heal living team; team god mode; same-seed restart; 1×/2×/4× speed |
| Companions (Combat tab) | Add an owned hero to this run, remove a follower, heal followers, toggle one follower's movement/attacks; HP, level, class and formation/follow/recovery/downed status |
| Progression | Reach RUN Lv15 (including retained legacy materials action); open existing promotion UI; either branch as an explicit run-only debug preview |
| System | FPS, active/pending enemy counts, seed, active time, speed, position, god mode; collision-shape hint; validated sandbox save/load, same-action Retry and bounded recent logs |

Run XP uses the existing 100 × current level threshold. No permanent HP/damage multiplier exists. Live class changes retain HP ratio, passives and shared upgrades. Companion outgoing damage remains half.

The Character selector initially targets the active hero. Both XP buttons apply the currently typed amount, including edits without Enter, to shared RUN XP. HUD and panel show the same RUN level. Close F9 to finish queued upgrade/promotion choices; prior manual/focus pauses remain.

**Promotions:** Grant RUN Lv15 eligibility, complete any existing choice, then use the normal paused promotion offer. It changes only this expedition. **Test selected branch / this run only** remains an explicit debug bypass; Resources stay immutable. Restart clears branches and upgrades.

**Speed:** No controller existed. One debug controller changes Engine.time_scale and physics_ticks_per_second together, retaining 1/60-second gameplay steps while executing more per wall second. Prior engine settings, invincibility/god-mode flags, follower AI overrides, runtime branches and collision hints restore on run exit.

**Save failures:** A failed sandbox save retains the candidate, disables further actions and blocks panel closure/resume. Retry the same action or discard the isolated session. Loading restores the collection profile, never an expedition or its XP/class.

## Limitations

- Spawning uses existing safety, warnings, cap and boss-time boundary. Partial/zero reservations are reported; resume to finish warnings. Gameplay RNG streams are untouched.
- Killing the boss resolves victory on the next unpaused simulation step; rewards go only to sandbox.
- No revival. Use restart for BASE / RUN Lv1 or runtime branch preview for comparison.
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
- Start seed 101; open DEV, change XP/level, reach RUN Lv15, preview a promotion, add an owned companion, heal/toggle God Mode, reserve enemy/boss, inspect FPS/seed and try speed. Resume to see warnings/attacks.
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
- scripts/progression/permanent_progression.gd — permanent collection settlement only
- scripts/progression/upgrade_effects.gd — derive stats without replaying heals
- tests/run_tests.gd and tests/script_manifest.gd — suite/script registration
- README.md and docs/development.md — playtest/run/architecture notes


## 002 暂停与音效补充 · 2026-10-19

失焦单独持有focus暂停；回到窗口只释放自身token。DEV打开时战斗声及升级声随debug token冻结，关闭后仍尊重level/manual/focus等原因。App继续持有唯一面板，原控件/沙盒与Play Debug.cmd启动方式保留。物理键鼠清单仍待人工执行；本切片证据见[验收矩阵](validation/combat-pacing-audio/acceptance.md)。
