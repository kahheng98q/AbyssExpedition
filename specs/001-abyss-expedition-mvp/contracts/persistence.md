# Local persistence and transaction contract

**Effective from M2.** M1 has no profile or persistence dependency. One local profile, no backend/database and no mid-run continuation. All permanent commands share one writer; screens never write files directly.

## Files and schema

Use Godot `user://profiles/default/`, not installation/source folders. Set application user-data identity to Abyss Expedition during M2 implementation and display the resolved path in developer diagnostics. Tests inject a unique test-profile root and never touch the live profile.

Committed files are immutable `profile-<revision>.json` generations. A staged candidate is `pending-<operation_id>.tmp` in the same directory. Each committed generation contains the complete envelope/payload from [data-model.md](../data-model.md). Retain the current and at least one previously validated generation. Corrupt/incompatible files and unresolved staged candidates are preserved for diagnosis, not silently overwritten. Healthy-generation cleanup happens only after verified commit and cannot remove the last recovery state.

Revision is monotonic and represented within a validated exact integer range. `operation_id` is unique per action; repeated UI input reuses the same pending action ID. A committed receipt links it to its base/result revision and outcome. Draw histories persist the original ordered results and unrevealed state. Only one process may own a writable profile. Acquire a dedicated lock directory using a single native `DirAccess.make_dir` operation and check its result before reading for mutation; never use a check-then-create sequence. An existing lock blocks a second writer with a close-other-instance message. Normal exit removes only its own lock. After a crash, offer explicit stale-lock recovery only after the player confirms other instances are closed; preserve save generations and rerun full load validation. Verify competing acquisition and crash recovery on Windows during M2. This is a conservative local-file protocol using Godot built-ins, with no OS extension, network listener or backend.

## Permanent action protocol

1. Require a loaded compatible profile, no pending mutation, a matching expected revision and valid command/ownership/balances. Allocate one operation ID. Disable repeated spending/continuation input.
2. Derive a **tentative complete next profile** from the committed snapshot. Validate all invariants. For draws, generate the ordered results exactly once, resolve each against tentative ownership and advance tentative independent RNG state. For settlement, freeze participants/time/rescue/outcome and calculate exact rewards once.
3. Serialize complete candidate payload once, hash its exact UTF-8 bytes and retain those bytes in memory with operation ID. Write a same-directory temp, flush/close, reopen and verify parse/schema/references/checksum and expected revision. Any failure retains the current profile and unchanged candidate.
4. Publish by renaming the verified temp to the new generation name on the same filesystem. Never overwrite the previous valid generation. If destination exists, inspect its operation ID/checksum: exact same candidate counts as already published; any other content is a conflict, not overwrite permission.
5. Reopen the published generation and validate it. This complete validated generation is the **commit point**. Set the in-memory committed profile, emit one commit receipt, then permit continuation/reveal. If post-rename readback fails, enter failure state and Retry first inspects the destination; it never reapplies cost/reward or regenerates data.
6. Retain at least the prior validated generation. Optional cleanup failure reports diagnostics but cannot roll back an acknowledged valid new profile or delete its predecessor. Never silently fall back to an older revision because current parsing failed.

Same-filesystem rename plus validation is an implementation strategy to verify on Windows, not a promise of universal power-loss durability. Flush and close errors are failures. Process interruption tests must prove selection of complete prior/complete committed state. Keep old generations to handle unexpected filesystem corruption; no mechanism can recover data that was never successfully written.

## Failure, retry and load state machine

Profile service states: unloaded → loading → ready; ready → preparing → writing → verifying → ready; errors → save-blocked or recovery-required. Unsupported version → incompatible. Gameplay/spending can only begin in ready. Profile creation and selection confirmations also pass through the writer.

While save-blocked, hold the immutable candidate/result and prior committed profile, freeze gameplay/continuation and expose Retry. Retry writes/revalidates the **same** operation and candidate bytes. It does not re-run reward calculation or draw RNG. Closing presents the specified pending-progress warning; accepted close may lose an unwritten candidate. On reopen there is no promise to recover an uncommitted temp. A successfully published valid generation wins even if the prior process closed before UI acknowledgment.

At startup enumerate committed generation names and validate the newest candidate. If it is supported and valid, load it and return to selection/guild or its awaiting draw reveal. Ignore temp files for automatic commit; they never authorize spending. If the newest generation is corrupt/unreadable, preserve it and offer the latest valid recovery generation with save time and potential lost progress, plus Retry load. Do not automatically load that older generation as if nothing happened.

If any highest-revision generation uses a newer unsupported schema/game/content version, report incompatible and preserve it rather than rolling back to an older profile or creating a fresh one. Invalid filenames/duplicate revisions are reported for recovery review; no merging partial state. If no save artifacts exist, create and persist the initial starter profile. If artifacts exist but none is valid, offer Retry loading or explicit New Profile confirmation; new profile creation archives/preserves old evidence first and must itself save successfully before continuing.

Recovery confirmation copies the selected valid state into a fresh higher revision through the writer, retaining the damaged evidence and chosen recovery source. Its payload is not mixed with damaged balances/ownership. Recovery/migration failure stays blocked. Load failures never silently grant starters, reset currencies or change promotion branches.

## Specific operations

| Operation | Complete atomic state change |
| --- | --- |
| Initial profile | Exactly three starter records, default selected starter, level 1/zero balances; persist before play in M2+. |
| Selection confirmation | Valid distinct owned party and accepted seed selection; no cost; save before expedition start. |
| Run settlement | Participating permanent XP, victory item, later ticket/rescue ownership/repeat rewards and M4 chapter completion, plus receipt. Abandonment grants no rewards. |
| Promotion | Eligibility checked at confirmation; one item decrement and one permanent branch assignment together. Cancel does nothing. |
| Draw | One/ten tickets, independent RNG state/index, ordered receipt, new ownership, duplicate tokens and awaiting-reveal marker together. Never save cost separately. |
| Exchange | Five tokens decrement and one unowned pool hero together; owned selection rejected. |
| Reveal acknowledgment | Marks the existing receipt acknowledged; cannot change its outcomes or charge again. Save failure retries only acknowledgment. |

The last committed operation receipt and current pending ID protect immediate duplicate commands. UI does not accept arbitrary historical run summaries as new settlements; only the active RunManager can submit its one frozen run ID. Durable draw history protects all historical reveal requests. Returning to a result or history screen is a query, never another mutation.

## Validation and migrations

Enforce envelope/hash, supported schema/content, required field types, finite integral counts/XP, valid hero/profession IDs, allowed branches, no duplicate ownership, valid party, nonnegative balances, capped XP/derived level agreement, legal draw pool/results/conversion and receipt state. Reject malformed nested structures or oversize input with a useful error; do not deserialize arbitrary Godot objects/scripts from user save data.

Migrations v1→v2→v3 are pure transformations tested with golden fixtures; retain source and commit migrated complete payload as a new generation. Unknown future versions are preserved. JSON 64-bit RNG state is a decimal string, never a floating numeric field. Checksum is accidental-corruption detection, not anti-cheat or security against profile editing; offline play needs no server authority.

## Required failure-injection matrix

Automate interruption/failure before write, during/truncated write, after temp verification, before rename, after rename before readback, after readback before UI response, and during reveal acknowledgment. For each, reopen and require either complete previous state or complete committed state. Verify repeated Retry/repeated confirm cannot reroll, double-spend, duplicate rewards or make balances negative.

Cover read-only directory, disk-write error, malformed JSON, checksum mismatch, unknown hero/branch, invalid balances/party, current corrupt + valid recovery, all corrupt, newer schema/content, failed migration, interrupted initial creation, stale instance lock and second-instance refusal. Twenty representative reopen/settlement-interruption cases are the minimum SC-012 evidence; all distinct failure classes above also need coverage. SC-005 separately requires twenty close/reopen progression cases.

