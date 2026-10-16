# Complete-loop evidence

Unit outcomes cover boss entry at tick 32400, retained crowded-entry retry, full cone/circle warnings, no automatic timeout, hero/boss simultaneous death → defeat, victory, defeat, abandonment, one summary and frozen time. Integration covers every starter's start/finish/retry/selection cleanup and rejects stale-generation result routing.

The full_run suite drives only movement and legal offered upgrades, once per actual Godot physics frame, with fixed-fps 60 for accelerated execution. It must independently defeat the boss with every starter, within 32400–39600 active ticks. It does not inject health, damage, kills, XP or clock into these full-run attempts. Earlier bot versions lost; the final bot uses a direct boss approach and warning dodges. Final actual outcomes are in full_run.log and m1-gate.md.

These automated runs establish executable complete-loop paths, not ordinary human victory duration or enjoyment. Source and release graphical harnesses intentionally set fixture state to show warnings/results; those captures are not full-run victory evidence.
