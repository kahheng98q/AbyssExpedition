# Research decisions

- Decision: shared RUN level for all current members, fixed threshold 15. Rationale: existing RunProgression already shares XP/upgrades; avoids gratuitous balance changes. Alternative independent XP would require a new economy.
- Decision: ownership-only schema4; legacy validation kept, ordered pure migrations. Rationale: old fields cannot silently become effective; schema3 chapters must not be reset by v2 migration. Alternative retaining inert saved levels misrepresents requested removal.
- Decision: HP ratio on live class switch, retain modifiers/counters/cooldown. Rationale: no full-heal exploit and passives/upgrade stacks survive. Existing projectiles/echoes keep committed facts.
- Decision: coordinator nonce/token plus cancel deferral and explicit HUD reopen. Rationale: reuse existing modal host/pause ownership and previews without creating a second UI subsystem.
- Decision: keep DEV IDs, redirect old material/level requirements to run XP. Rationale: protected controls remain useful, sandbox save testing still uses real writer; no material economy survives.
- No unresolved research; all evidence local. No hooks file present during setup; no network or agent delegation needed.
