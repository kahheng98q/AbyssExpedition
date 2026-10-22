# 003 Phase 7 收敛实施 · 2026-10-21

**部分完成：T055／T056／T062已完成，性能有效但p95未达标，真人验收待做。**

阶段记录：T062任务文档检查器已支持合法追加、原54项描述保护与唯一有序编号；10个针对性测试通过，旧检查行为3个失败保留。初次缺API测试错误另存，不充当行为red。T055流程样本正在实施；Release、性能及真人验收仍未完成。

实际命令：`python -X utf8 tools/test_003_task_audit.py`，10 tests OK；[行为red](docs-behavior-red.log)、[green](docs-green.log)、[首次API错误](docs-red.log)。本阶段暂未运行Godot。旧文档检查报告已另存为prior/docs-check.md／JSON，不覆盖历史结果。

[任务](../../../../specs/003-sword-promotion-identity/tasks.md) · [验收矩阵](../acceptance.md)。

## T055 新流程捕获（对照尚未完成）

`python -X utf8 tools/test_sword_lifecycle.py`：10 tests OK，[red](lifecycle-red.log)／[green](lifecycle-green.log)；原Python投影26检查通过。`tools/run_validation.ps1 -OnlySuites @('integration_m2','replay') -DummyAudio -EvidenceDirectory docs/validation/sword-promotion-identity/convergence-logic-20261021-v1`：import／parse／content、97＋70＋DEV140断言及参数拒绝通过，Dummy仅诊断。第一次直接无隔离check-only出现引擎signal11，[原日志](parse-fixture.log)保留；随后标准隔离验证及实际Capture成功，不把失败删去。

[候选v2 Capture](../convergence-capture-enabled-20261021-v1/manifest.json)实际取得54战斗＋6流程样本，严格校验通过。6流程各362个阶段状态、1升级offer／1确认、1事件offer／1免费选择、7550tick真实defeat；磁盘校验回读相等、revision恰好+1、一次结算到账40永久XP。101／202为商人leave，303为祭坛decline。7190受控起点、100XP宝石及终局致死输入均明确记录，不计自然九局。完整改前／开关／预览对照及新完整回归仍在执行，T055暂不勾选。

## T055 对照收口

三组Compare均退出0、60样本0差异：

| 对照 | 原始报告 |
| --- | --- |
| 冻结改前→候选开启 | [60组](../convergence-compare-baseline-20261021-v1/comparison.json) |
| 开启→关闭表现 | [60组](../convergence-compare-toggle-20261021-v1/comparison.json) |
| 未访问→访问预览 | [60组](../convergence-compare-preview-20261021-v1/comparison.json) |

新fixture已在改前测试副本／候选全部重采；投影白名单未扩大。`tools/test_sword_identity.ps1 -CaptureDirectory ...convergence-capture-enabled-20261021-v1 -EvidenceDirectory ...convergence-tool-contract-20261021-v1`：54检查0失败（含缺流程／流程hash错误）；Python投影26检查0失败；流程守卫扩充为12 tests OK，另加的跳tick／非法事件选择2个行为red保留。[扩充red](lifecycle-extra-red.log)／[扩充green](lifecycle-extra-green.log)。任务校验10 tests OK。T055／T062完成，其他验收不自动关闭。

## T056 执行中

本轮完整命令为 `tools/run_validation.ps1 -M4 -Graphical -Export -BuildDirectory builds/windows/sword-promotion-identity/convergence-release-20261021-v1 -EvidenceDirectory docs/validation/sword-promotion-identity/convergence-regression-20261021-v1`。16组9917原生断言、源码三尺寸图形与四组合真实十轮通过。新Release导出、实际启动及调试拒绝探针已通过；新Debug导出通过，后续导出图形／真实时钟仍在执行，暂不标T056完成。旧4551失败不删除、不归因为已确认的系统修复，本轮未修改系统安全策略。

## T056 自动验收完成

完整 `-M4 -Graphical -Export` 命令实际退出0：16组9917原生断言0失败0跳过、源码M1–M4／音频／DEV118／剑系676图形、新Debug DEV118／剑系676、实际Release剑系655及M4图形通过；Release全28动作拒绝探针41项0失败。源码4＋Debug4＋Release1共9个生产时钟组合全部通过，每组合两分支各10轮、10次开关，全部180个分支循环约6秒、均≤8秒；真实焦点／清理及保存／HP／次数／RNG隔离通过。

[原始回归目录](../convergence-regression-20261021-v1/) · [真实构建与逐组合结果](build-integrity.json)。来源hash为966031715e4542716ed50140d44327d42969d4ca6618215ac7ea54aa4cd19a61；206个生产文件与此前最终证据完全相同。新构建目录为`builds/windows/sword-promotion-identity/convergence-release-20261021-v1/`，本轮Release已可正常运行。此前4551及首次独立解析signal11均保留，不推断系统故障原因或声称已修改系统设置。

T047／T056均按实际结果勾选。T049／T057已开始候选实际Release Benchmark，结果尚未取得；自然九局、五人理解／灰度密集首答和物理DEV依旧待人工，不能由本轮图形／计时检查代替。

## T049／T057 · 有效但未达标，停止后续实现

实际执行 `tools/validate_sword_identity.ps1 -Mode Benchmark -ProjectDirectory . -ReleaseExecutable <convergence-release-20261021-v1/AbyssExpedition.console.exe绝对路径> -EvidenceDirectory docs/validation/sword-promotion-identity/convergence-benchmark-candidate-20261021-v1`，工具退出0表示样本有效，**不表示帧时预算通过**。30主动秒预热＋120主动秒，8016帧、全部获焦；100常规＋1首领、双同伴、≥30效果、≥100弹体、500宝石、腐化100与奖励守卫通过；12窗真实双斩／旋斩／长弧／合法正治疗及四类实际渲染记录均满足。

候选p50=15.498ms、p95=16.732ms（目标≤16.67，超0.062ms）、p99=17.927ms（目标≤25）、max=42.950ms。改前相同fixture有效基线p95=13.593／p99=15.618ms。实际5800H／GTX1650、Godot OpenGL日志NVIDIA546.30、1920×1080、VSync off、无调试器、WASAPI48000、Default、1139音频cue／峰值6声部；fixture hash与改前完全相同。CIM读取不可用，[观测限制](machine.json)保留；可见进程CPU／内存和电源并非完整后台GPU观测。

[原始候选CSV／日志／环境](../convergence-benchmark-candidate-20261021-v1/) · [摘要及负载](performance-summary.json)。frame_budget_pass=false；T049／T057不勾选，不重跑挑选达标样本。当前尚无CPU／GPU瓶颈归因证据，不把静态猜测当性能原因。按speckit-implement非并行任务失败即停止的规则，本轮仅完成必要文档收口，后续性能修复需先定位瓶颈并保持完整负载。

## 本轮状态

已完成T055、T056、T062及其原任务T047；共52／62任务行完成。剩10行对应5类开放项：性能预算T049／T057；自然九局T002／T061；五人理解T050／T058；同组灰度／密集首答T051／T059；物理DEV T052／T060。后四类无人实际执行，0份真人成绩，不自动邀请或代答；002历史开放项保持。

本轮无游戏玩法／美术代码变动；更新测试夹具、比较工具、文档检查器及离线文档。没有.specify/extensions.yml，无before／after_implement hooks。文档最终检查结果见[当前报告](../final/docs-check.md)。

## 最终文档与保护核验

实际 `python -X utf8 tools/check_003_docs.py` 退出0：48文件、450本地引用、26图片alt、5420题材文件hash均通过；62个任务ID唯一有序、原54项描述未改，52完成／10行开放。206个生产文件与本轮真实构建manifest完全一致，无玩法／美术修改。requirements清单16／16、质量清单0／38保持只读；沿用此前实施授权，无新扩展钩子。人测与性能失败状态未被勾成完成。
