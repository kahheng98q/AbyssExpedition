# SC-005 close/reopen evidence

Executed native test_persistence_v1.gd on pinned Godot 4.5 through the persistence suite. Twenty controlled successive operations close the writer, instantiate a new writer, load the newest generation and compare the complete committed payload exactly. Every comparison passes.

The cases vary permanent XP through level 30/cap, saved promotion from eligible level 15, zero/two companions, seed and item balances. Additional independent tests cover eligibility/item boundaries, promotion atomicity, failed Retry, current corruption/recovery, no recovery, unsupported version, orphaned creation, interrupted before/after-publication actions and writer locks.

All roots are isolated under user://tests/. This is twenty controlled storage reopen comparisons, not twenty manual player sessions.
