# 003 T001 · 环境与版本核对

> **2026-10-21后续授权**：[自然九局延期验收](../authorization-20261021.md)，不再阻止T003之后工作；以下为原预检时点，身份／未执行事实保留。

2026-10-21（Asia/Singapore）· **T001已完成；003新功能未实现／未验证。** T002仍未满足，尚未冻结T003源码或生成003构建。

## 实际观察

| 项目 | 观察／限制 |
| --- | --- |
| 引擎 | 固定console执行`--version`输出`4.5.stable.official.876b29033`，退出0；console与GUI文件均存在 |
| 平台 | API报告Microsoft Windows 10.0.26200／X64；PowerShell 7.6.5；不据版本字符串推断营销名称 |
| project.godot | 4.5／GL Compatibility、640×360逻辑视口、1280×720初始窗口、integer stretch、nearest；仅配置核对 |
| export_presets.cfg | Windows Desktop指向本地4.5目录Debug／Release x86_64模板；文件存在，已记录hash，未执行新导出 |
| 源码hash | `fa5614aab670a76126d66d13894ff2481e00e9a85199d18277f2e0dd5a30dfd3`；204文件，算法沿现有002录制／导出工具，完整[清单](../preflight-20261021-v1/source-manifest.json) |
| 原录制夹具hash | pacing_session／pacing_observer：`1af5b040974c0bb476b5dce282f45acfd37b4b63e8762e25b4964db5f1be8776`；003比较夹具未创建 |
| 现有构建 | `builds/windows/combat-pacing-audio/phase7-release-20261020/`的pacing-build.json源码hash匹配；Release与console实际SHA256也匹配manifest。Debug两文件存在并记录hash；未重新运行探针 |
| 设备 | 本轮未探测CPU／GPU／driver、显示／音频、焦点、电源或完整后台负载；不等于设备不可用。002[历史环境限制](../../combat-pacing-audio/phase7-20261020/environment-review.json)保留，不将Q1参考5800H／GTX1650当本轮实际硬件 |
| 现有行为 | VisualSet尚无sword_identity；原双斩／第五次旋斩与治疗存在，CombatFeedback只有原伤害队列，promotion页为静态actor。schema v3／App单一DEV／音频事实路径保留；Play Debug.cmd仍运行固定4.5当前源码 |
| ignore检查 | `git rev-parse --git-dir`退出0；.gitignore已覆盖Godot缓存、引擎／模板、builds、runtime、日志、Python与通用临时／编辑器目录。未检测到Docker／ESLint／Prettier／Node发布／Terraform／Helm配置，未新增无关ignore文件 |

完整引擎／模板／EXE文件hash、字节数与实际身份比较在[environment.json](../preflight-20261021-v1/environment.json)；[版本原始输出](../preflight-20261021-v1/engine-version.log)。清单按`scripts/`、`data/`、`scenes/`、`assets/`既有白名单扩展名及project.godot／default_bus_layout.tres计算，不以分支名代替身份。这里是身份清单，**不是T003冻结源码／新构建**。

## 需求与会话记录

[验收矩阵](../acceptance.md)逐项覆盖FR-001–012／SC-001–006，尚无003游戏通过结果。[自然门槛核查](natural-gate.md)没有可用九局。

[ValidationSession空模板](../preflight-20261021-v1/validation-session-template.json)含全部模型字段：`run_id、engine、source_manifest、build_hash、fixture_hash、protocol、seed、hero、profession、party、starting_profile_hash、inputs、choices、environment、outcomes、failures、limitations`。观察字段初始为null、status为not_executed；不能当一次真实会话，不能把null当0秒成绩。预检身份事实另存environment.json；后续会话须填真实输入、起始档hash、选择及全部结果／失败。

## 边界与下一步

未改游戏源码、Resource、场景、测试、引擎配置或旧构建；保留会话开始时已有的用户修改。未运行Godot回归／图形／导出、自然操作、录音、性能或人类测试。T002须由真人按[natural-gate](natural-gate.md)完成当前版九局，通过后才执行T003冻结及T004旧行为基线；002其他人工／复放／环境项目独立开放。
