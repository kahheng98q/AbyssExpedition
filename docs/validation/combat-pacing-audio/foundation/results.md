# Foundation — 2026-10-19

已实现并验证：PauseCoordinator只读嵌套快照与实际变更通知；App独立focus token（重复失焦、部分释放、失焦启动、离场/重开）；trace版本combat-pacing-audio-1 / reservation-events-v2及metadata不匹配拒绝；默认pacing/combat_feedback回归入口。

Red：integration_m1行为断言1失败，integration_m2行为断言1失败，replay行为断言2失败；没有解析/装载失败替代red。原始日志在[red](red/)。

Green命令：`./tools/run_validation.ps1 -OnlySuites @('pacing','integration_m2','replay','combat_feedback') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/foundation/regression`。

import/parse/content通过；pacing 97、integration_m2 50、replay 51、combat_feedback 9、debug_panel 126断言均0失败；未知suite/非法seed拒绝。详见[regression](regression/)。

限制：headless无物理焦点，测试显式调用focus转换；图形窗口切换待检。此阶段没有生成生命周期接线/音效/自然会话，不证明SC001–007通过。现有99源码脚本manifest已覆盖本阶段修改文件，无新增源码。Git仓库存在，追加缺失Python/通用忽略项；无Docker、Node发布、ESLint、Prettier、Terraform或Helm配置，无需相应ignore。
