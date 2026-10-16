# M3 Windows export and runtime evidence — 2026-10-15

T142 is partially executed and remains open. Export succeeded at `builds/windows/m3/AbyssExpedition.exe` (embedded PCK; no separate Godot installation needed in principle). The current executable is 97,071,456 bytes, SHA-256 `91B06D52762EEA3E4432E00063840424F7FD5312682610D52B25F3BBA6BCDB6A`.

The first M3 export, SHA-256 `94355DC7EFDD110C73078F5DA13C26AF0E30E0DB8A8D5EBBFA2BC6857BC75957`, passed the exported graphical harness at 1280×720, 1920×1080 and 1371×813. That controlled session exercised guild→selection→rescue→defeat settlement→exchange cancel/confirm→single/ten draw→reopen original reveal→acknowledgment→history→full collection, plus save-blocked draw→same-action Retry. Its `screenshots/m3-release-*.png` captures were inspected, including full guild, odds, visible rescue circle, ten results and save failure. The earlier M1/M2 promotion/party source graphical harnesses also pass.

The final export adds a stricter schema/game/content-version consistency check. All final-source native suites and source graphical checks pass. Its exported harness could not start: the console wrapper reports `CreateProcess failed, error 4551`. The Windows error description is **“An Application Control policy has blocked this file.”** See `m3-release-graphical.log`. A normal direct launch attempt also failed. No Windows security settings were changed and no alternate execution method was used to bypass that policy. Therefore the current executable's runtime behavior remains unverified on this host; the earlier release's successful run must not be represented as final-binary verification.

Command: `./tools/run_validation.ps1 -M3 -Graphical -Export`. The final invocation passes every stage through `export`, then exits nonzero at the exported-launch check. An ordinary human offline release session remains unexecuted. Current M3 can be run from source with the already installed pinned Godot editor (`project.godot`, F5); all automated tests use isolated test storage.

Earlier exports are retained unchanged:

| Build | SHA-256 |
| --- | --- |
| M1 | `70B1F7A4B7017C704BCB300ABE7EA74DDF038D6BD7394B0029900B56C602DE8D` |
| M2 | `C762074AD6553EF696257926A8C8CDBA4C2BE80520F7CF56120FA6CA8AF8C2D8` |
