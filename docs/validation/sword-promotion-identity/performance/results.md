# 剑系压力 · 本轮有效但未达标 — 2026-10-21

[Phase 7实际结果](../convergence-20261021-v1/results.md)已补候选Release采样；此前启动4551阻塞不再是当前状态，原失败保留在下方历史记录。

| 同机匹配fixture | p95 ms | p99 ms | 结论 |
| --- | --- | --- | --- |
| 冻结改前基线v3 | 13.593 | 15.618 | 有效基线 |
| 当前新Release | 16.732 | 17.927 | 有效但p95超16.67目标，未达标 |

候选30＋120主动秒／8016帧、全程获焦，12窗四类攻击／正治疗／渲染关联及完整负载通过。[候选CSV／环境／日志](../convergence-benchmark-candidate-20261021-v1/) · [摘要](../convergence-20261021-v1/performance-summary.json)。fixture hash一致；实际5800H／GTX1650／NVIDIA546.30、1920×1080／VSync off、WASAPI48000、无调试器。可见后台观测有限、CIM读取不可用，不关闭历史参考机、其他种子、002完整环境或人工验收。T049／T057继续未勾选；尚未定位帧时瓶颈，不用重跑筛选成功样本。

## 以下为早期采样与阻塞记录（历史）

# 剑系压力 · 部分完成 — 2026-10-21

改前有效基线：[v3实际采样](../baseline-benchmark-20261021-v3/m4-101.json)。同机5800H／GTX1650／NVIDIA546.30、1920×1080、VSync0、WASAPI48000、30主动秒预热＋120主动秒，p50=11.945／p95=13.593／p99=15.618／max=55.778ms，11900帧，焦点11900/11900。12窗双斩／旋斩／长弧／合法正治疗、总敌人／弹体／效果／宝石和奖励守卫通过。早期整数位置误拾取的v1/v2失败仍保留，v3与候选使用相同固定(0.25,0.25)布局／fixture。

候选**未采样，SC006未验证，T049未勾选**。完整命令已实际尝试：`tools/validate_sword_identity.ps1 -Mode Benchmark -ProjectDirectory . -ReleaseExecutable <export-recovery-20261021-v2/AbyssExpedition.console.exe绝对路径> -EvidenceDirectory docs/validation/sword-promotion-identity/candidate-benchmark-20261021-v1`；当前新Release两版均被Windows CreateProcess4551阻止，pacing-build.json如实记录release_denial=blocked。工具在严格manifest守卫前置拒绝，[原始异常](candidate-preflight-blocked.log)已保留，没有创建候选CSV或假帧时，不用Debug／旧Release替代。

[本轮构建身份](../final/build-integrity.json)及[回归](../final/regression.md)。本机电源／可见进程观测不保证完整后台GPU范围；历史参考机与002完整环境仍开放。Windows允许该实际Release正常启动、实际拒绝探针通过并重新建立真实passed构建manifest后，才能补候选30＋120秒、12窗渲染四类守卫及本机p95≤16.67／p99≤25ms结论。
