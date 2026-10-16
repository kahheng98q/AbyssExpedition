# M4 persistence integrity — 2026-10-15

Executed persistence suite: 304 assertions, zero failures/skips. Existing v1 fixtures remain active alongside tests/integration/test_persistence_v3.gd. All fixture roots are isolated user://tests/ directories under workspace-local APPDATA; the real player profile is untouched.

Twenty representative M4 settlement interruption cases rotate open, short_write, flush, close, temp_read, read, rename, readback and cleanup faults. A settlement includes participant XP, promotion item, tickets, Sera and chapter completion in one candidate. Every failed pre-acknowledgment operation exposes the prior payload; reopening returns exactly the complete prior or complete published payload. Retry uses frozen payload bytes; repeated operation IDs do not add rewards. Every final reopen preserves the complete saved state. Cleanup diagnostics do not roll back a valid commit.

Golden v2/v3 migration, failed migration and identical Retry preserve the source bytes and recruitment RNG. Expedition-state fields and invalid chapter flags are rejected. Earlier persistence/recruitment tests retain malformed JSON, checksum mismatch, invalid balances/XP/branch/party/seed/ownership, oversize input, current-corrupt recovery, all-corrupt explicit new profile, newer version preservation, interrupted creation, draw/reveal interruptions and acknowledgment Retry. Native Windows lock tests refuse a competing writer and explicitly recover an isolated crash lock.

Fault adapters simulate write/read/publication failures; they are not claims of a physical disk-full or power-loss hardware experiment. Ordinary full-session close/reopen and human acceptance remain separate open gates.
