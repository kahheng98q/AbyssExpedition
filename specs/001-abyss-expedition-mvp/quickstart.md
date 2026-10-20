# Build, run and validation guide

**Status (2026-10-16)**: M1 combat, M2 progression/promotions/companions, M3 recruitment/gacha and explicitly requested M4 corruption/events/chapter are implemented. The project and local console executable use `4.5.stable.official.876b29033` with Compatibility rendering and matching export templates. Latest M4 evidence: [M4 gate report](../../docs/validation/m4-gate.md). Earlier human/reference-hardware criteria and ordinary M3 manual release acceptance remain open.

From the project root, run the existing validation harness:

```powershell
& ./tools/run_validation.ps1 -M4 -Graphical -Export
& ./tools/check_m2_lock.ps1
```

The harness verifies the engine pin, runs import/parse/content checks, twelve native suites, invalid-input checks and source graphical checks at three window sizes. It gives each child process a workspace-local APPDATA directory; fixtures use isolated test profiles. Logs are written to `docs/validation/` and captures to `screenshots/`. `-M4 -Export` rebuilds the M4 release and, with `-Graphical`, runs the exported M4 graphical harness. Earlier M1/M2/M3 exports remain unchanged.

Playable releases are retained at `builds/windows/m1/AbyssExpedition.exe`, `builds/windows/m2/AbyssExpedition.exe`, `builds/windows/m3/AbyssExpedition.exe` and `builds/windows/m4/AbyssExpedition.exe`. For the separately requested developer tools, launch `Play Debug.cmd`; see [debug controls](../../docs/developer-debug-panel.md).

## Phase 14 fixes and current validation

See [current evidence](../../docs/validation/convergence-2026-10-15.md): corruption can introduce mothers early at 50+, anomalous profile names require explicit recovery, results report actual capped XP, formation stays distinct at edges, upgrades share configuration with previews, movement changes are traced, and promotions show their actual placeholder appearances. Simulation trace version is `m4-convergence-1`; old traces are not an equality baseline for corrected rules.

Current source and actual generated Windows EXE graphical checks pass at all three required sizes. The final 13-suite run passes 5,239 native assertions, with zero failures/skips. Earlier 4551 launch failures are retained as history. Controlled probes do not satisfy ordinary human acceptance. Long diagnostic input traces stay outside permanent settlement receipts; results also disclose Sera ownership changes affecting replay conditions.

```powershell
./tools/run_validation.ps1 -M4 -Graphical -Export -EvidenceDirectory docs/validation/<new-run-directory>
# Regress M2/M3/M4 flows in the actual generated EXE:
./tools/run_m4_release_regressions.ps1 -EvidenceDirectory docs/validation/<new-release-run>
# Optional -UseTemplate separately checks the pack, not generated-EXE launch.
# Each benchmark directory is new; historical CSV files are preserved:
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory docs/validation/<new-benchmark-run>
# -Smoke is 1s warmup + 2 active seconds: tooling validation only.
```

Benchmark JSON separates `capture_valid` from `frame_budget_pass` and reference/latency acceptance. Metadata records unavailable hardware queries explicitly. Release profiling launches the GUI EXE directly and verifies its PID against OS memory sampling. Static-memory zero means unavailable in release, not zero usage. Benchmarks use diagnostic Dummy audio; `-DummyAudio` can isolate host-device failures in validation/release regressions without changing project audio. The current three release captures are valid but exceed frame budgets; reference hardware and VSync-on displayed latency remain unmeasured. Native tests enforce unique `user://tests/` profiles, including the current App combat-loop fixture. Reviewer/human/hardware gates remain open.

## Prerequisites and setup (M1.0)

1. Use the standard Windows x86_64 Godot 4.5 stable editor/console binary and exactly matching export templates. Record the full `--version` result; expected baseline `4.5.stable.official.876b29033`. If using another build, revise the pin and rerun all replay/import checks before acceptance.
2. Configure `ABYSS_GODOT_EXE` locally to the actual verified console executable path. The Godot connector is available but no `godot` command was found on PATH in planning. Do not assume the editor feature tag identifies installed tooling.
3. During M1.0 implementation, set Compatibility renderer, remove incompatible Forward Plus/D3D12 settings, reconcile feature version, assign `scenes/app/app.tscn` as main scene, and add movement/menu input actions. Apply the 640×360 integer viewport conventions from [plan](plan.md).
4. Create native test runner/content manifest and Windows Desktop export preset. Install matching templates through Godot's export tooling; no package manager, external service or network access is required during play/tests once tooling is installed.

PowerShell session setup, after supplying the real executable path through the environment:

```powershell
$ProjectRoot = 'C:\Users\kahhe\Desktop\Project\new-game-project'
$GodotExe = $env:ABYSS_GODOT_EXE
if (-not $GodotExe -or -not (Test-Path -LiteralPath $GodotExe)) { throw 'Set ABYSS_GODOT_EXE to the verified Godot console executable.' }
& $GodotExe --version
& $GodotExe --help
```

Record outputs in `docs/validation/<date>-<phase>.md` during implementation. A tool failure/nonzero exit or parse/runtime error blocks the phase. Expected version cannot be inferred from a successful process launch.

## Import, parsing, content and scene validation

Run from the configured session after M1.0 artifacts exist:

```powershell
& $GodotExe --headless --path $ProjectRoot --import
& $GodotExe --headless --path $ProjectRoot --check-only --script res://tests/run_tests.gd
& $GodotExe --headless --path $ProjectRoot --script res://tests/validate_content.gd
& $GodotExe --headless --path $ProjectRoot --script res://tests/run_tests.gd -- --suite scene_smoke
```

Check `$LASTEXITCODE` and logs after **each** invocation; stop on failure rather than continuing because a later command succeeds. The implementation's runner must exit 0 only when all requested cases pass, nonzero for failures, unknown suite/argument, missing fixture or engine error. A watchdog handles hangs and reports failure, never pass.

`--check-only` validates the specified script, not every file. Content/scene runner must load every registered script/Resource/PackedScene, instantiate each active-milestone scene, advance several process/physics frames, assert required children/connections, then free it and check cleanup/runtime errors. Explicitly validate unloaded enemy/projectile/UI/branch scenes too. Import alone cannot establish this. Release content manifest must use ResourceLoader references rather than raw `.tres` directory enumeration.

## Automated suites

Runner arguments are passed after `--`; Godot's own `--test` is not the gameplay suite. Implemented suites are `unit`, `scene_smoke`, `integration_m1`, `replay`, `full_run`, `progression`, `persistence`, `abilities`, `integration_m2`, `recruitment`, `integration_m3` and the separate `debug_panel` suite. `--seed` accepts specification seed limits. Unknown parameters and unavailable suites fail visibly. `integration_m4` is active for corruption, event schedules/costs, arbitration and chapter reopen.

```powershell
& $GodotExe --headless --path $ProjectRoot --script res://tests/run_tests.gd -- --suite unit --seed 101
& $GodotExe --headless --path $ProjectRoot --script res://tests/run_tests.gd -- --suite integration_m1 --seed 101
& $GodotExe --headless --path $ProjectRoot --script res://tests/run_tests.gd -- --suite replay
```

The replay suite runs ten controlled pairs using seeds 0, 1, 2, 42, 101, 202, 303, 8675309, 2147483646, 2147483647. Record build/engine/content hash, starting state and tick decisions for each. Compare wave/position/skip and upgrade traces; M4 adds event sequences. Add a pair differing only in paused wall duration and a check that cosmetic RNG cannot alter traces. Identical seeds with changed progression are not an equality test.

M2+ persistence tests use an injected isolated root such as `user://tests/<unique suite run ID>/`, never `user://profiles/default/`. The runner rejects live-profile paths, creates independent fixtures and logs their exact path. Fault injection is a test-only file-store adapter; no test is permitted to corrupt the real player save.

```powershell
& $GodotExe --headless --path $ProjectRoot --script res://tests/run_tests.gd -- --suite persistence --seed 101
& $GodotExe --headless --path $ProjectRoot --script res://tests/run_tests.gd -- --suite integration_m2 --seed 101
```

Use corresponding `integration_m3`/`integration_m4` only at those checkpoints. Fast-forwarding simulated ticks is useful for logic assertions but does not establish playable run length or graphics.

## Automated coverage matrix

| Requirements | Required automated cases / expected outcome |
| --- | --- |
| FR-001–FR-003, FR-014 | M1 scene boots with only M1 content; each selected starter yields correct weapon/controller; opposing/normalized diagonal input; field bounds; nearest center distance/tie by spawn order; no target holds ready without firing/counter advance. |
| FR-003, FR-008 | Arc hits distinct victims, straight direction fixed, homing reacquire or immediate expiry, 3-second lifetime; damage/flat defense/minimum 1, knockback resistance, 45-tick invulnerability and no refresh from ignored hits; death emitted once. |
| FR-004 | Exact ten-second wave indices through 8:50, 4/6/8/10/12 counts/weights and forced introductions, fixed type stats; deterministic candidates, 100 cap including broodlings/reservations, ≤3 children/mother, no unsafe overlap or stored backlog; no normal/child spawns at 9:00. |
| FR-005–FR-007 | XP gem every non-boss death, pickup once, 100×current-level requirement, overflow and multiple pending levels; 12 definitions, caps/compatibility, three unique offers, uniform without-replacement logic, fallback trio, offer fixed, one application and no world tick between choices. |
| FR-009–FR-011 | Boss at tick 32400, ≥45-tick warning before cone/eruption hits, no timeout win/defeat, live-hero boss kill victory, simultaneous death defeat; one result, pause reason overlap, cleanup/retry fresh health/XP/upgrades, HUD snapshot values. |
| FR-012 | Seed syntax/range/blank; ten trace pairs, stable stream derivation, spawn tie order, pause/cosmetic isolation, retry same seed and New Expedition new seed path. |
| FR-013 | Automation only checks presentation state signals/scene assets. Readability/visible latency require manual checks below. |
| FR-015–FR-020 | Owned roster, permanent XP at 1/14/15/30 and overflow, +2%/level, reward full-minute/victory/defeat/abandonment, downed participant reward; item 0/1 and promotion cancellation/repeated input; six branches, fifth activation counted once despite extra shots/arcs, passive continuity. |
| FR-021–FR-023 | Parties 0/1/2 companions, duplicate/unowned/third rejection; own-position targeting/no chase, speed/formation, blocked 2s/separation >8 widths safe recovery, downing/restoration, active death defeat, 0.5 outgoing multiplier and full healing/defense; same enemy schedule/stats for parties at levels 1/30/promoted. |
| FR-023, FR-033 | Round trip, initial/selection save, v1→v2→v3 migration, exact prior/new state under failures, same-candidate Retry, no silent reset, recovery consent, no valid recovery, newer schema/content preservation, interrupted reveal, twenty reopen cases. Full [failure matrix](contracts/persistence.md) required. |
| FR-024–FR-028 | Guild routes; exactly 6 heroes/3 initial owners; Sera absent from pool; minute-4 rescue independent of RNG/M4, centered zone inclusive boundary, exit/death/decline fail, 30 active seconds paused correctly, success+defeat grants Sera, repeat ticket, new recruit only next run; tickets at 4:59/5:00/victory/abandonment. |
| FR-029–FR-034 | Tickets 0/1/9/10; cancel/repeated click; random inputs 0/1 cover exactly equal selection intervals; all-Brann/all-Nyra/alternating ten batches from none/one/both owned; exact conversion, costs/history; token 4/5/owned exchange; seed replay cannot reset/select draw RNG. |
| FR-035–FR-037 | +5 each full active minute, 0/25/50/75/100 and multi-crossings, cumulative totals applied once, next-wave counts ceil/weight swap/damage, existing enemies unchanged, gem snapshot bonus, next warned second eruption; Blood Tithe health leaves ≥1, insufficient headroom rejects whole bargain, decline unchanged. |
| FR-038–FR-042 | 2/4/6 event schedule and probabilities, guaranteed unowned rescue, owned scheduling change, merchant exact coin costs/heal/Might, one offer once, event/level/manual pause/boss collision, coins reset; chapter save/repeat, ten event seeds and three ordered sequences; all earlier regressions. |

Branch/passive suites must also exercise Sera's 20-second lowest-health-percentage heal/tie rule, Brann's first eligible hit per 20-second interval, Nyra's +20% reach, Aren's reduction, Lia's speed and Milo's fifth damage. No passive can revive a downed hero or advance while paused.

## Real-window and exported build checks

Launch after main scene exists:

```powershell
& $GodotExe --path $ProjectRoot
```

Play all three starters with seed 101: move with both key sets, diagonals/release/bounds; observe distinct arc/straight/homing attack, five enemy silhouettes, XP/three-choice upgrades, overflow choices, pause/resume, boss cone/circle warnings, hit/invulnerability/death, victory/defeat and retry. Use developer fixtures for targeted edge cases, then complete ordinary runs without fixture cheats. M1 must work with no later module or content loaded.

In M2, select each hero for the next expedition; test promoted/unpromoted solo/party and followers under separation, downing and active death. In M3, verify guild, rescue, each draw/exchange/reveal and live save-error presentation. In M4, verify every event choice/disabled reason, warning/environment changes, chapter completion and full offline session. Networking is not needed for any of these flows.

Create the Windows Desktop preset and output directory during implementation, then:

```powershell
New-Item -ItemType Directory -Path (Join-Path $ProjectRoot 'builds/windows') -Force | Out-Null
& $GodotExe --headless --path $ProjectRoot --export-release 'Windows Desktop' (Join-Path $ProjectRoot 'builds/windows/AbyssExpedition.exe')
```

Check export output/exit status, then **manually launch** the produced executable and exercise the same controls/scene/save paths offline on Windows. Match templates to editor. Verify all referenced Resources are included, `user://` is writable, no development fixture is exposed, and closing/reopening returns to selection/guild or committed reveal. Graphical validation uses the release executable as well as editor runs; headless export success is not playtest success.

## Human and performance acceptance

| Criterion | Procedure and threshold |
| --- | --- |
| SC-001 | Ten first-time players, only in-game instructions: ≥9 start/move/attack within 2 minutes. Record elapsed wall time and help given. |
| SC-002 | Twenty ordinary baseline solo victories distributed across all starters (7/7/6); ≥16 finish in 9–11 active minutes and every starter wins. Pauses excluded; no accelerated/debug runs. |
| SC-003 | Same ten players try all starters: ≥8 explain their mechanical differences; ≥7 rate enjoyment and willingness to retry 4 or 5/5. Record the two ratings separately. |
| SC-004 | Log every exercised outcome/pause/retry case; all produce correct single result, usable continuation and reset temporary state. |
| SC-005 | Controlled progression/party boundaries plus twenty close/reopen cases; every state matches, including caps and passive continuity. |
| SC-006–SC-007 | Exact roster/routes and controlled draw interval/batch tests; graphical odds/cost/history inspection; no statistical sample substitutes for 50/50 interval verification. |
| SC-008 | Ten players view bargains before deciding; ≥8 correctly state both benefit and cost; all threshold/decline/unavailable tests pass. |
| SC-009 | Ten event seeds above collectively show all types and ≥3 ordered offer sequences; unowned Sera guaranteed in every eligible run. Repeat with owned Sera; chapter survives reopen. Freeze fixtures, do not cherry-pick seeds after failure. |
| SC-010 | On the reference hardware/workload in plan: input and hit feedback ≤100 ms. ≥8/10 identify active hero and boss danger within 1 second. Record visual latency procedure and raw observations. |
| SC-011 | Ten deterministic repeat pairs as specified above, including pause-duration independence. |
| SC-012 | Full earlier acceptance after M4, twenty representative save/reopen/interruption cases and a complete offline session with no balance/ownership/claim corruption. |

Use the [plan benchmark](plan.md) for exact hardware/counts/frame budgets and the three-seed, 30-second warm-up/120-second capture protocol. Record p50/p95/p99/max and stalls rather than average FPS alone. Do not substitute a faster machine or headless loop for the declared hardware claim. If unavailable, report measured conditions and keep reference acceptance unverified. Optimize only after identifying a bottleneck and rerun affected reward/replay tests.

## Evidence and gate reporting

Each phase report includes date/phase/build/content revision, exact executable/version, commands/procedures, seed/start conditions, counts passed/failed/skipped, logs, screenshot/video where relevant, benchmark CSV/data, and limitations. Label **automated**, **manual graphical**, **human study**, and **performance** separately. Written tests and document review are not execution. Fix import/parse/runtime/integration failures before moving on; required unavailable tests remain open.

M1 acceptance: Stories 1–3 / FR-001–FR-014 / SC-001–SC-004 and SC-010–SC-011. Only then activate M2 tasks; M2 gate adds Stories 4–5 / FR-015–FR-023 / SC-005; M3 adds Stories 6–7 / FR-024–FR-034 / SC-006–SC-007; M4 adds Stories 8–9 / FR-035–FR-042 / SC-008–SC-009 / SC-012. Update docs and relevant prior regression evidence at every phase.

## Planning-stage observations

- Setup script completed and resolved this feature directory; its Python launcher emitted a location warning but returned exit 0 and copied the plan template.
- No Git repository/branch exists; setup's branch value is a feature-name fallback.
- Installed Godot version was queried through the connector; no engine import/run/export was performed.
- No extension hook configuration existed before or after planning.
- Application behavior, graphical play, benchmarks and human criteria remain unverified until implementation.

### Completed document checks (2026-10-14)

A read-only PowerShell check inspected all seven generated Markdown documents: 15 relative document links resolved; code fences were balanced; no unresolved planning/template markers remained. A separate requirement-ID/range check found all 42 functional requirements and all 12 success criteria represented in this guide. The author also reviewed milestone boundaries, Resource/runtime separation, event ordering and save transaction consistency against the specification and constitution. These checks validate planning artifacts only; they are not Godot or gameplay tests. The existing project configuration remains unchanged, and no application files were created.

M4 corruption summary: C (Escape or Return closes it). Run `tools/run_m4_benchmarks.ps1` for maximum-corruption stress captures. The full-run policy now makes real event contract choices; it is a controlled accelerated verification, not a human duration study. The final M4 executable launches successfully on this host; the historical M3 block remains recorded in M3 evidence.

## Q1当前构建 — 2026-10-18

本轮独立构建为 `builds/windows/quality-20261018/AbyssExpedition.exe`。已有M4构建保持保留。战斗反馈/场景/HUD改动的前后截图、14组5,249原生断言、三尺寸源/实际EXE图形验证与限制见[Q1报告](../../docs/validation/quality-20261018.md)。运行 `./tools/validate_quality.ps1` 可重现本轮图形与单独导出；其Dummy audio是诊断配置，不改变正常游戏音频设置。
