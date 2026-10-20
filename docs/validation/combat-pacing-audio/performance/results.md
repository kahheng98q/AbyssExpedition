# 002 最终Release真实音频性能 — 2026-10-19

> 2026-10-20核查：本页保留原构建的历史样本。当前源码hash与acceptance-release-v4及本次性能记录不符；[最新完整性核查](../convergence-20261020/build-integrity.json)及[剩余工作](../convergence-20261020/results.md)优先。未重新采样，不将以下数字视为当前源码SC007通过。

[当前原始对照capture-v2](capture-v2/) · [环境](capture-v2/host.json) · [判定](capture-v2/comparison.json) · [修复前旧样本capture-v1](capture-v1/)

当前构建acceptance-release-v4包含首波预警层修复；旧构建和旧数据保留。AMD Ryzen 7 5800H with Radeon Graphics / NVIDIA GeForce GTX 1650；1920×1080、VSync off、真实WASAPI / Default / 48000Hz、实际Release/无调试器、seed101。

每轮30主动秒预热+120主动秒采样；100常规+1首领、双同伴、≥30效果、≥100活动弹体、500宝石、腐化100均保持，负载及奖励守恒有效；两轮最终kills均382。

| 声音 | 样本数 | p50 ms | p95 ms | p99 ms | max ms | cues / 声部峰值 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 开启 | 11922 | 12.141 | 13.453 | 14.073 | 21.564 | 861 / 6 |
| 关闭 | 11907 | 12.150 | 13.472 | 14.306 | 24.553 | 0 / 0 |

**本机样本达到p95≤16.67ms / p99≤25ms。** 单对样本不估计音频因果开销。Balanced电源已记录；开启/关闭结束时聚焦状态分别为True/True，未独立监督全程前后台负载。完整SC007与历史参考机/多seed gate继续开放。

[源码/构建/录音/性能hash一致](../final/build-integrity.json)；[当前构建hash](../../../../builds/windows/combat-pacing-audio/acceptance-release-v4/pacing-build.json)。未改历史Q1标签或数字。
