# Baseline — 2026-10-19

命令：`./tools/run_validation.ps1 -OnlySuites @('unit','integration_m1','replay','integration_m4','combat_feedback') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/baseline/regression`

import / parse / content通过（51 Resources、27 scenes、99 scripts）。unit 202、integration_m1 37、replay 44、integration_m4 3734、combat_feedback 9、强制debug_panel 126断言，均0失败；unknown suite / invalid seed均以2拒绝。详见[原始日志](regression/)。

这是旧实现基线。Dummy/headless没有提供图形、真实音频、人工或性能结论；CIM设备枚举被拒绝，见[环境](environment.md)。未导出或覆盖旧构建。
