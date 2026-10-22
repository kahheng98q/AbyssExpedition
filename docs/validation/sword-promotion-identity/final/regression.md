# 完整回归 · 最新自动通过，历史失败保留 — 2026-10-21

**最新Phase 7**：[新完整回归](../convergence-20261021-v1/results.md)已退出0，新Release实际41项拒绝／655剑系图形及全部九组合真实时钟通过；新Debug118／676通过。新构建及源码hash见[当前身份](../convergence-20261021-v1/build-integrity.json)。以下原命令退出1及4551记录保持为历史，不改作通过。

实际完整命令：`tools/run_validation.ps1 -M4 -Graphical -Export -BuildDirectory builds/windows/sword-promotion-identity/final-release-20261021-v1 -EvidenceDirectory docs/validation/sword-promotion-identity/final-regression-20261021-v1`。import／parse／content、16组9917断言0失败0跳过、参数拒绝、原M1–M4／音频15／DEV118／剑系676源码图形及源码四组合真实十轮通过；Release导出退出0，但其实际启动探针返回-1／CreateProcess4551，**完整命令退出1，不能判整体通过**。后续Debug步骤未执行，原始日志均在[原轮次](../final-regression-20261021-v1/)。

[同一Release一次复测](../release-start-retry-20261021-v1/debug-release-denial.log)仍4551；首次尝试提取工具前缀在交互作用域因PSScriptRoot为空而未执行探针，不算启动结果，随后将原帮助函数保存带绝对工具路径再实际执行。

按原preset正常重导出至全新`builds/windows/sword-promotion-identity/export-recovery-20261021-v2`：[Release与Debug导出](../export-recovery-20261021-v2/)均退出0，Release再次启动4551，Debug实际DEV图形118通过。[新Debug剑系图形](../debug-completion-20261021-v1/sword-debug-graphical.log)676通过。新Debug真实播放结果由最终结果收录，未跑实际Release图形／真实时钟。未改变OS安全策略、未使用旧EXE替代。系统CodeIntegrity日志只读访问也被OS拒绝，无法确定更细原因。

实际构建／console／源码身份见[build-integrity.json](build-integrity.json)。Release拒绝探针没有执行任何断言，不冒用历史41项通过。T047保持未勾选；受阻的Release步骤及T049候选性能需待本机允许正常启动后补验。原55／60秒suite限制保留，独立真实演示内部150／外层180秒，超时日志保留。


## 源码／新Debug生产时钟最终结果

每组合两分支各连续十轮、开关十次，实际Window焦点转移；Time.get_ticks_usec未替换、无fixed-fps，真实墙钟约60.55秒，退出0。1/2/4×均约六秒；profile字节／revision、游戏HP／计数／四RNG、音频事实不变，清理后time_scale恢复1。

| 版本 | 宿主 | 倍率 | 每轮有效播放 | 断言／失败 |
| --- | --- | --- | --- | --- |
| source | dev | 1× | 6.000099–6.011102s | 51／0 |
| source | dev | 2× | 6.000060–6.010988s | 51／0 |
| source | dev | 4× | 5.999712–6.013215s | 51／0 |
| source | normal | 1× | 5.999994–6.009192s | 47／0 |
| debug | dev | 1× | 5.999935–6.013011s | 51／0 |
| debug | dev | 2× | 5.999964–6.012792s | 51／0 |
| debug | dev | 4× | 5.999952–6.012688s | 49／0 |
| debug | normal | 1× | 5.999974–6.011895s | 47／0 |

[完整逐组合索引](realtime.json)。实际Release普通1×未运行，不能将以上八组合冒充九组合通过。
