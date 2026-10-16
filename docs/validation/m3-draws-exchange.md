# M3 draws, exchange and persistence — 2026-10-15

Implemented T128–T139. Pool Resources contain Brann and Nyra at integer weight 1 each. Both displayed probabilities derive from those weights. One/ten pulls cost 1/10 earned tickets, without a pity rule or batch bonus. First acquisition inserts one level-one OwnedHero; every later occurrence, including later entries in the same batch, gives one shared token. Exchange previews and revalidates five tokens and unowned pool membership. All three starting classes remain guaranteed through their starter heroes.

`tests/unit/test_recruitment.gd` covers exact integer endpoints, ticket balances 0/1/9/10, all-Brann/all-Nyra/alternating batches with none/one/both pool heroes owned, ordered duplicate rewards, unchanged source payload, tokens 4/5/6, owned/story exchange rejection and decimal RNG round trips/overflow. `test_m3_passives.gd` and the M2 abilities suite cover all six identities through base/both matching promoted professions, including post-defense Bastion, interval boundaries, ignored immune hits and Far Sight.

Statistical thresholds were fixed before sampling:

| Experiment | Observed | Test |
| --- | --- | --- |
| 200,000 real draws, seed 20261015 | Brann 99,635; Nyra 100,365 | chi-square 2.664500, df=1, cutoff 10.828 at alpha .001: pass |
| 8,192 actual ten-pull candidates, seed 20261016 | Brann-count histogram 0..10: 7,85,334,980,1754,1960,1696,949,344,74,9 | Binomial(10,.5) chi-square 9.111558, df=10, cutoff 29.588 at alpha .001: pass |

Every statistical batch also conserves ten new-hero/duplicate-token rewards. Exact interval checks establish the configured 50/50 probabilities; the statistical checks look for implementation/distribution defects and do not prove randomness in general. Results are in `recruitment.log`.

The persistent draw stream has its own seed/state as signed 64-bit decimal strings and an exact monotonic index. Preparing a candidate advances only the tentative RNG. Changing expedition seeds or retrying a run leaves the draw state unchanged. Expected-revision checks and one-operation UI consumption prevent repeated spending. Complete cost, ownership, tokens, RNG, history and awaiting-reveal state use the existing SaveCoordinator writer; commit precedes reveal. Saved acknowledgment changes only the existing receipt flag.

`tests/integration/test_m3_draws.gd` injects open, truncated write, flush, close, temp read, read and rename/readback failures for draws and acknowledgments. Every Retry retains exact candidate bytes and original outcomes. Reopen checks compare committed receipts and acknowledged histories; pre/post-rename interruptions select complete prior/complete committed state. Additional checks exercise exchange readback failure/repeated confirm/stale revision/excess token persistence, invalid balances/nested fields/receipts, and actual app reveal-before-selection routing. `test_m3_rescue.gd` tests pure v1→v2 migration, the v2 golden fixture, preserved legacy bytes, migration failure/Retry and reopened RNG. Existing persistence tests remain active.

Source/exported graphical checks cover visible odds, missing balance, exchange cancel/confirm, single/ten confirmation/reveal, every ordered result, history, interrupted reveal, a failed draw's error screen and same-action Retry. All three required window sizes fit; ten results and acknowledgment fit together, while long histories/rosters scroll with keyboard focus tracking. No money, paid currency, backend or networking was introduced.

T140 remains open for its ordinary interactive manual play matrix; automated graphical captures do not establish human comprehension or ordinary full-session behavior.
