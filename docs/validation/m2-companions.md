# M2 companion evidence — 2026-10-14

Native abilities suite includes valid 0/1/2 companions and rejects third, duplicate, active-as-companion, unowned and nonstring selections. Factory assigns separate state/health and stable negative companion IDs.

Formation targets are distinct within 32 pixels, following speed is at least the active hero's, targeting uses each actor's own position, and followers do not chase. After 120 blocked active ticks or separation above 128 pixels, safe placement checks field bounds, physics obstacles, living enemies and other party members. Unsafe recovery waits without resetting health/cooldown/downing. Party collision layer zero prevents body blocking.

Integration M2: 36 assertions pass including app cases. Outgoing damage is multiplied by 0.5 after own modifiers; healing/defense retain full effect; one shared upgrade updates all living members from independent permanent baselines. Downed companions stop movement/attacks/upgrades/healing, remain visible and get no death gems/kills; selected downed members receive equal permanent rewards. Only active hero collects XP; independent 45-tick companion immunity is tested. Active death ends the run despite a living follower; next run restores full health and counters.

Seeds 101/202/303 fixtures use identical fixed schedules. Solo baseline versus a full level-30 promoted party has identical scheduled wave composition/counts and unchanged enemy/boss baseline stats. Spawn placement still checks every living party member, so occupancy can legitimately change safe placement/cancellation.

Graphical captures include two followers and downed text for all six branches at all three window sizes. Interactive blocked movement, warning behavior and ordinary full-party runs remain human acceptance work; T111 stays open.
