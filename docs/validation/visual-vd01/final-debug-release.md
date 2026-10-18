# Debug / release · 2026-10-17

Executed with pinned4.5:

```powershell
./tools/run_debug_validation.ps1 -SkipRegression -BuildDirectory builds/windows/visual-vd01-final-debug-r2 -EvidenceDirectory docs/validation/visual-vd01/final-debug-r1 -DummyAudio
./tools/run_m4_release_regressions.ps1 -DummyAudio -EvidenceDirectory docs/validation/visual-vd01/final-release-r1
```

All passed: debug69,source graphical97,exported-debug graphical97,release denial20; actual M2/M3/M4 release flows,additional release denial20 and source debug97. Counts are separate checks, not summed as unique unit assertions. Real isolated user://tests profiles only; no permanent profile opened. Existing save/pending/ownership restrictions were retained.

An earlier debug attempt also failed overwriting historical PNGs; wrapper now gives source/export separate capture folders and supports explicit evidence outputs. Failed root logs remain; final-debug-r1/ contains the clean rerun. Release has no F9 entry/actions; source F9 overlay appears in source images and is absent in release. No source image is mislabeled as release.
