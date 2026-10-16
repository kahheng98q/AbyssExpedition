# M2 promotion evidence — 2026-10-14

All six branch Resources and three passive Resources load and validate in the explicit content registry. Exactly two branches belong to each base; promoted definitions cannot point to another tier. Tuning values and descriptions live in Resources.

Native abilities suite: 107 assertions pass across promotion eligibility 14/15/30, item 0/1, wrong base/unowned/already promoted/stale revision, cancellation, failed readback Retry, duplicate confirmation and saved branch reopen. The profession fixtures create level-15 promoted characters and exercise actual attack/damage paths.

Verified behavior: Swordmaster fires two arcs and one fifth full-circle hit; Abyss Swordsman has greater reach and fifth accepted damage heals 2% once, with immunity preventing healing; Sharpshooter adds three fifth arrows and stops after three distinct piercing victims; Star Hunter bounces once to a different living enemy without extending expiry and cancels dead-target marks; Elemental Sage alternates splash/frost and has a larger fifth burst alongside Milo's independent ×1.5 passive; Void Caster creates finite damage zones and moves susceptible enemies while armor resists pull. Echo children and zone ticks do not increment activation counters. No target preserves readiness/counters.

Resolute reduces damage after defense with minimum one; Fleet Step adds 10% starting speed; Arcane Pulse remains tied to identity after promotion. Counter and health isolation are exercised in new-run/party tests.

Graphical fixture captured roster, three promotion previews, six branch attacks, two followers and downing at 1280×720, 1920×1080 and 1371×813. The selection layout initially exceeded 360 logical pixels; spacing was reduced and the full graphical check passed. Screenshots are in screenshots/m2-*.png. Original procedural branch art is documented in assets/effects/m2-branches.md and assets/provenance.md.

Only permanent progression was verified against a parse-valid missing implementation before coding (two expected failures in m2-red-engine.log). Promotion/ability tests were added as regression fixtures after the implementation; a full red-first phase sequence is not claimed. Interactive human play of all six branches and all UI failure/confirmation paths remains open, so T101 is not marked complete.
