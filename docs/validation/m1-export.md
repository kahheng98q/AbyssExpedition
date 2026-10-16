# Windows export evidence

Command: tools/godot-4.5/Godot_v4.5-stable_win64_console.exe --headless --path . --export-release "Windows Desktop" builds/windows/m1/AbyssExpedition.exe.

Pinned 4.5 templates are explicit custom template paths under tools/godot-4.5-templates/templates. Release export succeeds. The EXE embeds its PCK. An optional AbyssExpedition.console.exe wrapper provides logs. Tests/docs/specs/tools/screenshots/tool-injected receivers are excluded. Shipping content consists only of M1 Resources, scenes and systems.

The first export failed because the preset selected resources without selecting files. Switching to all_resources plus explicit exclusions fixed it; final export.log contains no errors. Final executable size/hash are recorded in m1-gate.md.
