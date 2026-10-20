# AGENTS.md — Abyss Expedition

Instructions for Codex/AI coding agents working in this repository. Apply them automatically in each coding session; do not ask the user to repeat them. This file is operational guidance, not permission to expand scope.

## Project context
- Original offline single-player Godot **4.5** / GDScript survivor-like game: fantasy kingdom + Lovecraftian invasion.
- Core: automatic combat, roster/companions, branching promotion, story recruitment, earned-ticket gacha, abyss corruption and events.
- Current code spans **M1–M4** plus a developer-only F9 debug panel. Do not assume full acceptance: human playtests and performance targets remain open.
- Source of requirements and boundaries: `.specify/memory/constitution.md`, `specs/001-abyss-expedition-mvp/spec.md`, `plan.md`, `tasks.md`, and relevant contracts.
- Evidence and known limitations: `docs/validation/m4-gate.md`, `docs/validation/debug-panel.md`, `docs/development.md`, and `docs/benchmarks/`. Some historical notes describe earlier states; check the latest evidence and actual source.

## When implementing a change
1. Inspect relevant code, data, scene, requirements and existing tests first; preserve working behavior and module boundaries.
2. Follow the active Spec Kit specification and constitution. For significant new scope, first update or request appropriate specification/task approval. Never treat unimplemented roadmap items as implicitly authorized.
3. Use small changes, reusable systems, original assets, and data-driven `data/` Resources. Keep gameplay logic out of UI and visual assets. No backend, paid gacha or unauthorized dependencies.
4. Keep deterministic runs, profile/save safety, the isolated developer F9 sandbox, and release-build debug restrictions intact.
5. Test affected behavior. Use the pinned `tools/godot-4.5/` binary and applicable `tools/run_validation.ps1` switches; M4 full check: `./tools/run_validation.ps1 -M4 -Graphical -Export`. Run narrower checks when suitable. Do not claim graphical/manual testing from headless runs.
6. Do not rerun the historical `tools/create_m1_content.ps1` over current content; it overwrites starter data.

## Protected Developer Debug Panel

Developer Debug Panel is a protected development feature. Every future implementation and game polish iteration must preserve its accessibility and existing functionality in debug builds.

- Preserve `scenes/debug/debug_panel.tscn`, its existing action service, sandbox isolation and all existing controls. Reuse the App-owned single instance; do not mount copies inside replaceable screens or runs.
- Debug builds must retain the visible corner **DEV** button, registered `debug_panel_toggle` / **F9**, above-normal-UI rendering and paused input across menus, guild, selection, combat, results and restarts. Release builds must reject initialization and all debug actions.
- Run `./tools/run_validation.ps1` with the switches appropriate to the change; it always includes `debug_panel`, including `-OnlySuites` runs. `-Graphical` includes mouse/F9/transition/pause checks; `-Export` includes debug export and actual-release denial, and together they probe exported debug graphics.
- For isolated debug exports/evidence use `./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/<new-directory> -EvidenceDirectory docs/validation/<new-directory>` after the normal regression. A failed/blocked export probe is not a pass. Preserve the manual smoke checklist in `docs/developer-debug-panel.md` and report unexecuted human checks.
- Keep `Play Debug.cmd` launching current source through pinned Godot, never an old milestone/polish executable. Update the dashboard/overview/evidence with any debug change.

## Mandatory: automatic, visual implementation documentation
After **every code implementation, feature change, meaningful bug fix, or completed Spec Kit implementation milestone**, update these documents in the **same task**, without waiting for a separate request:
- `docs/game-development-dashboard.html` — create on first applicable update if missing; primary **offline, responsive, visual** game development dashboard.
- `docs/IMPLEMENTATION_OVERVIEW.md` — create if missing; concise **Simplified Chinese** GitHub-readable overview.
- `README.md` — keep a short documentation-links section pointing to both files (and existing Spec Kit docs).
- Preserve and update `docs/development.md`, `docs/validation/` and `specs/.../tasks.md` where required by the actual change; do not discard historical evidence.

### Dashboard layout and writing style
- Use a polished, restrained dark-fantasy/pixel-art aesthetic consistent with `docs/art-direction.md`. Work fully offline with local HTML/CSS/JS; do not require CDN, web server or online assets.
- **Minimal visible text**: short Simplified Chinese summaries, English code/feature names where useful, readable cards, icons and compact navigation; advanced technical detail goes in expandable sections.
- Include: milestone/status overview (M1 Combat, M2 Character Progression, M3 Recruitment/Gacha, M4 Abyss), What's New, gameplay flow, implemented feature cards, actual character gallery, actual promotion tree, UI/debug tools, tests/known issues, and how to play/test.
- Reuse **real** project screenshots/sprites from `screenshots/` or `assets/` when appropriate. Use correct relative paths from `docs/`, accessible alt text, and no invented artwork or fake screenshots. If unavailable, show a neutral labeled placeholder.
- Avoid clutter, giant prose blocks and invented progress percentages. Each card should answer: **What can the player do? What is its verified status?**
- Preserve existing dashboard styling/layout and update only changed information on later runs. Do not recreate the entire page unnecessarily.
- `IMPLEMENTATION_OVERVIEW.md`: aim for <= 600 Chinese characters of main summary plus compact tables/checklists; link to dashboard and source evidence. Emphasize what's playable, what's pending, and quick launch/test steps.
- Add a brief What's New entry for the current change (date, feature, status); avoid accumulating redundant daily notes indefinitely.

### Truthfulness and status policy
- **Source code + Resource/scene wiring + executed tests/logs** outrank checked tasks or historic summaries. Documentation must describe actual current behavior.
- Distinguish `已实现并验证`, `已实现未验证`, `部分完成`, `未实现`, and `待人工验收`. Automated validation is not the same as gameplay enjoyment/performance/human acceptance.
- Never fabricate screenshots, features, test commands, pass counts, timestamps, benchmark results or completion percentages.
- If a feature cannot be verified, label it accordingly and explain the blocker briefly rather than calling it complete.
- This project may **not** have Git metadata. Do not depend on `git diff`; use changed files, existing documentation, task evidence, and code inspection.

## Before finishing any implementation response
- Confirm the game's affected functionality is validated to the extent possible; list tests **actually run** and any limitations.
- Confirm dashboard, overview and README links are accurate; check offline relative asset paths.
- Brief final answer in Chinese: what changed, how to play/test, verification status and documentation paths.
- For a request that is **documentation-only**, edit docs only; do not silently change gameplay code.
