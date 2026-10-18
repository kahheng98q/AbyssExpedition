# VD-01 · 本机剩余工作 R2

2026-10-18 · **77/87任务完成；10项保留未完成部分。** 本轮继续当前八件切片，没有扩展G3。Owner已明确暂无参考机、测量设备和十位测试者，先完成本机可做部分。按当前AGENTS工作流继续独立验证，不从自动化结果生成真人或硬件验收。

## 本轮结果

- **已实现并验证**：角色提示线/脚影与剑弧在绘制输入不变时复用现有绘制指令；连续显示位置/帧/受击/警示仍按当前模拟状态更新。只修改ActorPresentation和MeleeArc的`_process`及本地缓存字段，其他函数体完全相同。没有修改场景、模拟、AI、成长、转职、数值、存档或美术源像素。
- **已实现并验证**：源码和实际发布版287×2原生图对P2全部逐像素一致；两端各36组状态变化对强制重绘一致。源码/发布字形扫描各187个Label，6个正常垂直滚动项分列；故意越界校准被正确识别。没有把字形边界检查说成人类可读性验收。
- **已实现并验证**：12组5,278＋debug69＝**5,347**条功能断言，零失败/跳过；源码图形、实际EXE的M2/M3/M4、调试导出和发布F9禁用通过。像素/字形/浏览器工具测试不叠加成功能断言。
- **已实现并验证**：当前实际时钟源码163帧/19段，发布138帧/17段；原始before137帧保留。包括真实推进/暂停/恢复和明确标注的控制事件，非物理视频或完整自然人工会话。
- **部分完成**：冻结180张实际引擎辨识帧和3项UI素材，离线答卷支持随机顺序、2秒遮罩、5秒作答信号、无效/缺测保留、原始JSON/待评分CSV与可复制文本。评分器11项合成测试通过；正式答卷与评分均为0，42个评分单元pending。
- **未达标**：6组完整性能均为有效采样，只有P02 seed303达预算；其余5组失败。参考机与物理延迟未测。

## 构建与证据

当前候选 `78405f80c49d1d9193a9e36d186539d43a478f02d6bf273717ad0879cccf0574`；实际嵌入EXE `f7ff2552727165592da061c4b708eed1087cf5966e0f17918665d7b392dd54cd`。G1包SHA仍为 `3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49`，不重设已批准样稿或父版记录。

[构建索引](completion-r2/candidate-files.json) · [两文件差异](completion-r2/production-changes.json) · [函数边界](completion-r2/function-boundaries.json) · [P2回退文件/EXE](completion-r2/retained-p2/) · [574组像素对照](completion-r2/pixel-comparison.json)

[完整回归](completion-r2/regression-summary.json) · [源码图形/导出](completion-r2/regression/) · [当前EXE复验](completion-r2/release-regression/) · [F9隔离/禁用](completion-r2/debug/) · [源码字形](completion-r2/ink-source/audit.json) · [发布字形](completion-r2/ink-release-r2/audit.json)

[实际时钟摘要](completion-r2/wallclock-summary.json) · [帧hash/时间](completion-r2/wallclock-frame-index.json) · [当前实机对照](../../visual-design/runtime-gallery.html) · [当前实际时钟播放器](../../visual-design/wallclock-gallery.html) · [离线答卷](../../visual-design/review-session.html)

## 性能结论

| 负载 | seed | p95 ms | p99 ms | 预算 |
| --- | --- | --- | --- | --- |
| M4 | 101 | 27.956 | 42.279 | FAIL |
| M4 | 202 | 26.148 | 31.533 | FAIL |
| M4 | 303 | 28.210 | 39.127 | FAIL |
| P02 | 101 | 32.443 | 55.942 | FAIL |
| P02 | 202 | 20.458 | 30.705 | FAIL |
| P02 | 303 | 14.778 | 15.718 | PASS |

短时ABBA顺序：父版32.054→缓存版28.282→缓存版27.495→父版35.209ms（p95，seed101、同P02、10主动秒预热+10主动秒测量）。这是诊断性相对结果，不能用来替代30+120完整预算、也不能解释完整采样中的全部波动。缓存保留，但性能任务不关闭。

[完整性能、原始CSV/主机/内存与限制](completion-r2/performance.md) · [ABBA原始记录](completion-r2/cache-abba/comparison.json)。完整六组与ABBA各自顺序独占图形运行；只进行轻量文件/文档工作，未控制所有主机活动/功率/温度。关闭绘制的短探针不是可接受游戏画面，不用于美术通过。

## 仍未完成的10项

| 任务 | 仍缺证据 |
| --- | --- |
| T033、T073 | source/release真实窗口的三尺寸完整before/after截图矩阵 |
| T074 | 实际显示器上的运动抖动、窗口/字形观感与完整人工动作检查 |
| T077 | 字形像素边界本轮补齐；完整自然人工UI会话/全状态观察仍待验 |
| T078 | 完整预算仍5组失败；指定参考机未提供 |
| T079 | 没有物理输入/命中到显示的高帧率设备记录 |
| T080 | 当前缓存改动574对均相同；全范围物理/视觉验收仍缺 |
| T081、T082 | 十位真实参与者、逐条件原始答案和独立评分 |
| T084 | 36条执行证据已映射；正式逐项评审决定仍待评审者 |

[剩余状态](completion-r2/remaining-tasks.json) · [逐项执行映射](completion-r2/review-trace.md) · [具体人工/硬件程序](completion-r2/manual-review.md)。按[$speckit-implement](../../../.agents/skills/speckit-implement/SKILL.md)“do NOT modify checklist files or markers”，正式评审清单只读；没有代填批准。当前项目工作流不要求为未勾选条目重复询问继续，独立工作已继续执行。

## 复现与使用

双击 `builds/windows/m4/AbyssExpedition.exe`；公会→Expedition；WASD/方向键移动，自动攻击，1/2/3或方向键+Enter升级，Esc暂停，C腐化。发布版无F9开发面板。原有非切片角色/晋升/敌人与界面继续使用完整回退。

本轮实际执行：`run_validation.ps1 -M4 -Graphical -Export -DummyAudio`；`run_debug_validation.ps1 -SkipRegression -DummyAudio`；`run_m4_release_regressions.ps1 -DummyAudio`；两端native/重绘/字形与wallclock工具；M4与P02各三seed完整采样；四模式和ABBA诊断；离线工具/链接检查另见对应报告。每个命令均使用独立EvidenceDirectory，原始历史未覆盖。

检查器首轮将6个滚动项误报为面板越界，已保留失败记录并按真实滚动内容边界纠正，同时用故意越界字形校准。答卷浏览器初轮resize检查缺等待已修正，下载被当前自动化浏览器取消的问题及可复制原始文本回退单独记录；没有隐去失败或将工具自动化答卷当真人。

其他英雄/晋升/敌人/首领、独立立绘及其他屏幕的生产美术不在本批范围，仍列在原资产库存；未开始G3。

离线答卷20项浏览器检查、评分器11项合成检查通过；[浏览器记录/下载取消限制](completion-r2/review-browser-r4/review-session-browser-checks.json)。自动化JSON/CSV下载均被浏览器取消，原因未确定；原始文本回退的内容、有效/无效/超时记录已实际验证，可复制另存。没有将下载成功写成通过。

画廊30项、真实时钟播放器13项、开发图鉴4项、答卷20项，共67项独立浏览器检查通过（无远程请求/未捕获页面错误）。[图鉴检查](completion-r2/dashboard-browser-checks.json) · [画廊检查](completion-r2/offline-browser-checks.json) · [播放器检查](completion-r2/wallclock-browser-checks.json) · [本地引用检查](offline-links.json)。评分器11项合成检查另列，不计入真人或功能断言。概览主摘要287个汉字，228个运行文件及当前EXE与候选索引完全匹配；四份reviewer清单hash未变。
