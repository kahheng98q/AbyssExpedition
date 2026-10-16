# Movement/combat evidence

Final unit suite tests opposing/diagonal/released input, damage/defense/minimum, health clamp/no revival, exact 45-tick immunity, ready-no-target counters, nearest/spawn-order ties, dead target removal, stale/duplicate hits, arcs, straight/homing shots, expiry/reacquisition and melee Echo snapshots. Scripts and scenes pass parsing/loading.

Actual keyboard input in the running graphical demo moved Aren 145.6 pixels right during a 1.5-second hold (96 px/s); release yielded zero velocity. Pausing froze the clock at tick 654 across a subsequent wait and resuming advanced it. The input receiver had to be set to always-process so it could remain controllable while the game tree was paused; that receiver is a tool-injected file and is absent from the release.

One attempted tool-side spawn call supplied an Array where Vector2 was required; the connector rejected that call. This is not counted as a successful gameplay check. Native tests use proper Vector2 arguments and final runs have no game errors. All starter silhouettes, effects and HUD snapshots were inspected. Displayed latency and human dense-scene comprehension remain unmeasured.
