# M2 durable progression evidence — 2026-10-14

User explicitly authorized M2 after the checklist pause. Reviewer-owned checklist markers and open M1 human/hardware gates were not changed. Workspace has no Git repository or extension hooks.

Engine: 4.5.stable.official.876b29033. Run tools/run_validation.ps1 -M2 -Graphical -Export with process-local APPDATA=tools/runtime-appdata. Shipping storage resolves to user://profiles/default/ under the Abyss Expedition custom user-data identity; test writers exclusively inject unique user://tests/ roots. This scoped APPDATA prevents automated tests from touching the user's real profile.

Progression: 13 assertions pass. 100 XP per permanent level; cap 2900/level 30; profession starting HP/damage gain 2% per permanent level; each selected participant earns 20 XP per full active minute and 100 on victory; one shared victory item; abandonment grants none. Run upgrades, health, counters and effects reset.

Persistence: 136 assertions pass, including twenty exact close/reopen comparisons, integral balances/derived level/branch/party validation, exact UTF-8 checksum, bounded input, immutable generation publication, current/prior retention, all injected I/O failure stages, same-candidate Retry, post-publication readback failure, before/after-publication close, pending creation, corrupt current explicit recovery, no valid recovery and newer-version blocking. Test-only fault adapter rejects live-profile roots. Tests model flush/close failures; Godot provides no separate close return status. Universal OS power-loss durability is not claimed.

Windows native multi-process check: tools/check_m2_lock.ps1 passed second-writer refusal, forced process termination with a retained lock, and explicit stale-lock recovery. See m2-lock-processes.log. The test terminates only its own uniquely rooted fixture process.

App integration verifies load-before-play, saved selection/seed/party, settlement blocking, duplicate result entry, same frozen Retry and changed permanent starting stats on Retry. Save failure offers pending-loss confirmation on close. Recovery publishes a higher revision while preserving corrupt evidence; incompatible versions cannot create a new profile or fall back.

Automated scene/graphical evidence is recorded in m2-gate.md. Interactive manual failure-dialog/close confirmation and general filesystem power-loss testing remain unverified; T088 stays open.
