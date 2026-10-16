# M2 Windows release evidence — 2026-10-14

Pinned standard Godot 4.5 engine and matching Windows release templates. Export command: tools/godot-4.5/Godot_v4.5-stable_win64_console.exe --headless --path . --export-release "Windows Desktop" builds/windows/m2/AbyssExpedition.exe.

The embedded-PCK executable runs offline. A development-only external graphical harness launches the exported AbyssExpedition.console.exe and loads the packaged app, roster, promotion screens, nine professions/three passives and combat scenes. It exercises all six promoted attack/effect identities with two companions/downing, the saved roster and long promoted descriptions at 1280×720, 1920×1080 and 1371×813. Native logger captures engine/script errors and layout checks reject panels exceeding the 640×360 logical viewport. Final result: failures=0. Screenshots were visually inspected.

Run tools/run_validation.ps1 -M2 -Graphical -Export to regenerate the harness and source/export checks. The external harness is excluded from the package; it is not required for normal play. Tests, tools, docs, specs and test-profile fixtures are excluded.

The original M1 executable remains unchanged: SHA-256 70B1F7A4B7017C704BCB300ABE7EA74DDF038D6BD7394B0029900B56C602DE8D.

This is an automated graphical release smoke check. A complete ordinary manual offline release session covering all save dialogs, closing/reopening, every branch and combat path was not performed; T114 remains open.

Final M2 executable: 96992856 bytes; SHA-256 C762074AD6553EF696257926A8C8CDBA4C2BE80520F7CF56120FA6CA8AF8C2D8. Final exported graphical harness: failures=0.
