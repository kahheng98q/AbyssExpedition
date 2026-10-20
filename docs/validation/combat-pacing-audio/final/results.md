# 002 最终交付检查 — 2026-10-19

> 2026-10-20：[收敛核查](../convergence-20261020/results.md)发现当前源码已不匹配本页旧Release/录音/性能hash；本页命令与结果保持历史证据含义。当前源码重新回归通过，新增缺口与未执行项见最新报告，不能把本页历史完整性声明沿用到当前版本。

整体状态：**部分完成；核心功能已实现并自动验证，人工验收开放。** 未发现.specify/extensions.yml，前后implement hooks均无可执行项。

## 当前构建和命令

当前Release：[AbyssExpedition.exe](../../../../builds/windows/combat-pacing-audio/acceptance-release-v4/AbyssExpedition.exe)。[构建hash](../../../../builds/windows/combat-pacing-audio/acceptance-release-v4/pacing-build.json)与性能样本一致。Play Debug.cmd继续运行当前源码；旧构建保留。

实际执行：

```powershell
./tools/run_validation.ps1 -M4 -Graphical -Export -DummyAudio -BuildDirectory builds/windows/combat-pacing-audio/acceptance-release-v4 -EvidenceDirectory docs/validation/combat-pacing-audio/final/regression-v4
./tools/run_validation.ps1 -OnlySuites @('pacing','combat_audio') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/final/fixture-regression-v1
./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/combat-pacing-audio/us3-debug-v2 -EvidenceDirectory docs/validation/combat-pacing-audio/us3-debug-v2
./tools/validate_pacing_audio.ps1 -Mode Audio -EvidenceDirectory docs/validation/combat-pacing-audio/us3-audio-v4
./tools/validate_pacing_audio.ps1 -Mode Benchmark -ReleaseExecutable 'C:\Users\kahhe\Desktop\Project\new-game-project\builds\windows\combat-pacing-audio\acceptance-release-v4\AbyssExpedition.console.exe' -EvidenceDirectory docs/validation/combat-pacing-audio/performance/capture-v2
python tools/score_listening.py --self-test
```

- 完整[regression-v4](regression-v4/)：16组9,178原生断言，0失败/跳过；内容52根Resources、27场景、116加载脚本，import/parse/参数拒绝通过。
- 源码M1–M4三尺寸图形、新增音频/focus图形15断言、DEV源码及实际Debug各118、实际Release禁用41、实际Release M4图形通过。
- 此前[追加夹具](fixture-regression-v1/)：pacing281、combat_audio168、debug_panel126断言0失败，覆盖独立旧场边固定输入和当前工具schema/全部暂停/音色变体等。Audio v4基于最后源码实际重录；可见性修复后最终完整pacing282断言均通过。
- [隔离DEV导出](../us3-debug-v2/)通过；[真实录音](../us3-audio-v4/)35秒、8声部场景，检测削波0、非有限样本0。原始native 48kHz/float32立体声，系统音量100%和端点在JSON；不做归一化，回环可能包含其他应用。
- [目标机性能](../performance/results.md)：声音开启p95 13.453ms/p99 14.073ms，本机样本达标；窗口/后台环境限制保留。开关最终负载相同。
- PowerShell语法、Python编译、判分器5项内存合同检查通过；无假参与者答案。

## 开放项

T018/032/052完整自然九局及九对需真人输入，尚未录制。T053人工试听、T059五人理解、T060五人盲听、T061真实物理鼠标/键盘全控件未执行。SC001–007分项见[矩阵](../acceptance.md)，不把自动/图形/录音等同好玩或人工接受。盲听刺激/hash/答案表已冻结，0份真实回答。

失败/修复历史见[US3](../us3/results.md)；最终截图写独立目录，旧历史PNG在备份后按初始Git状态恢复，详见[恢复记录](legacy-capture-preservation/restoration.json)。不删除或冒充通过。离线文档检查见[docs-check](docs-check.md)。

首波seed303遮挡修复的独立red/green、世界坐标与像素检查见[visibility.md](visibility.md)；最后源码、Release、真实录音与性能hash一致，见[build-integrity](build-integrity.json)。
