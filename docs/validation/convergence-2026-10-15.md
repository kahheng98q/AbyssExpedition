# Phase 14 收敛修复 · 2026-10-15—16

**未完全收敛。** 本轮完成新增任务 11 项；T180/T181/T182/T183/T190 保持开放。原 T001–T175 的 26 个开放项没有被自动测试替代。当前共 191 项，160 完成 / 31 开放；这是任务状态，不是完成率或验收结论。

本轮依 approved spec/plan/tasks 与宪法实施，规格和技术计划字节未改；其 SHA-256 与 [实施前快照](convergence-2026-10-15/before-hashes.json) 一致。Reviewer-owned requirements 16/16、gameplay 0/40 保持原状；此前明确的 M4 实施授权及本轮 proceed 适用于范围内修复。无扩展 hooks、新依赖、外部服务或玩法范围扩展。

## 已落实的缺口

| 任务 | 实际实现与可执行证据 |
| --- | --- |
| T176 | 各阶段腐化 50+ 将 Thrall 的 10 个百分点转为 Broodmother，可在 8:00 前出现。阈值 49/50/75/100、五阶段同随机数对照，现存敌人快照与数量规则回归。 |
| T177 | 非规范名称、重复 revision、无法枚举的存档目录均阻止静默新档/任意回退。明确恢复后原始字节移入 recovery evidence，再提交更高 revision；负例、故障注入和重开验证。 |
| T178 | 结果显示每位参与者实际 XP、前后等级、Lv30 cap 与溢出丢弃；混合三人队与保存 Retry 回归，受控发布版截图可查。 |
| T179 | M1 App fixture 注入唯一 test profile；原生 runner 拒绝默认和逃逸路径。当前 M4 App 循环不再被描述为独立 M1 验收。 |
| T184 | Resource 类型、ID/引用、阶段引入关系、effect 枚举/范围/能力要求在加载时验证，报告 path/ID/reason；新增错误配置负例。 |
| T185 | 常规阵位在四边/四角向场内反射，两名同伴目标不重合，保留安全重定位、健康与冷却。边界逻辑及三尺寸跟随/倒地受控图形回归。 |
| T186 | Battle Mend、Vitality、burn/frost、Echo 等执行与说明读取同一 Resource 参数；保持既定数值，改变测试配置后核对实际效果与预览。 |
| T187 | 记录阶段 0 实际消费的 tick 移动变化；7400 tick 实际记录驱动回放，含暂停与选择，另保留二十对随机 trace。大 trace 不进入永久 settlement receipt，20,000 输入保存通过。满级队首次救援 Sera 也提示回放起始条件变化。 |
| T188 | 两分支预览复用实战 ActorPresentation / VisualSet，原创占位、整数 2×。三基础职业的双分支预览和六分支实战受控图形通过；取消不消耗。 |
| T189 | 测量真实 living normals/boss、effects、moving shots、gems 与奖励守恒；按主动时间 30 秒预热/120 秒采样。支持 source / release EXE / template，记录 CPU/physics/draw calls/nodes、PID 对应 OS 内存和硬件/窗口/VSync/调试元数据。三组完整 release 捕获有效，预算不通过。 |
| T191 | 重新整理 42 FR、12 SC、38 AC、20 边界、8 宪法原则与技术计划证据；更新四阶段 gate、Quickstart、图鉴、概览和 README。未执行条件仍显式开放。 |

代码缺口修复过程中发现：实际输入 trace 可使 receipt 超过 1 MiB，故存档只保留完整的结算结果字段，不保存诊断 trace；满级队救援改变 Sera 所有权会改变下一局事件调度，故提示同时比较 members 与 sera_owned。两者均有先失败后通过的用例，不改变奖励或事件规则。

## 最终原生与图形验证

固定引擎 `4.5.stable.official.876b29033`，Compatibility。最终完整单次运行 [results.json](convergence-2026-10-15/results.json)：**13 组 / 5,239 断言，0 失败、0 跳过**。不累加重复运行、red 或下面的图形断言。

| Suite / 实际日志 | 断言 | 失败 / 跳过 |
| --- | ---: | ---: |
| [abilities](convergence-2026-10-15/final-replay-disclosure/abilities.log) | 123 | 0 / 0 |
| [debug_panel](convergence-2026-10-15/final-replay-disclosure/debug_panel.log) | 69 | 0 / 0 |
| [full_run](convergence-2026-10-15/final-replay-disclosure/full_run.log) | 9 | 0 / 0 |
| [integration_m1](convergence-2026-10-15/final-replay-disclosure/integration_m1.log) | 37 | 0 / 0 |
| [integration_m2](convergence-2026-10-15/final-replay-disclosure/integration_m2.log) | 45 | 0 / 0 |
| [integration_m3](convergence-2026-10-15/final-replay-disclosure/integration_m3.log) | 196 | 0 / 0 |
| [integration_m4](convergence-2026-10-15/final-replay-disclosure/integration_m4.log) | 3734 | 0 / 0 |
| [persistence](convergence-2026-10-15/final-replay-disclosure/persistence.log) | 343 | 0 / 0 |
| [progression](convergence-2026-10-15/final-replay-disclosure/progression.log) | 13 | 0 / 0 |
| [recruitment](convergence-2026-10-15/final-replay-disclosure/recruitment.log) | 293 | 0 / 0 |
| [replay](convergence-2026-10-15/final-replay-disclosure/replay.log) | 44 | 0 / 0 |
| [scene_smoke](convergence-2026-10-15/final-replay-disclosure/scene_smoke.log) | 131 | 0 / 0 |
| [unit](convergence-2026-10-15/final-replay-disclosure/unit.log) | 202 | 0 / 0 |

实际执行：

```powershell
./tools/run_validation.ps1 -M4 -Graphical -Export -DummyAudio -OnlySuites unit,scene_smoke,integration_m1,replay,full_run,progression,persistence,abilities,integration_m2,recruitment,integration_m3,integration_m4,debug_panel -EvidenceDirectory docs/validation/convergence-2026-10-15/final-replay-disclosure
./tools/run_m4_release_regressions.ps1 -DummyAudio -EvidenceDirectory docs/validation/convergence-2026-10-15/release-final-replay
./tools/check_m2_lock.ps1
```

- import、parse、内容清单（51 root Resources / 27 scenes / 98 shipping scripts）与非法 suite/seed 拒绝通过。另递归加载 [145 scripts / 29 scenes / 51 Resources，0 错误](convergence-2026-10-15/audit-final.log)。
- 源码 M1/M2/M3/M4 图形及**最终生成 EXE** 的 M2/M3/M4 流程在 1280×720、1920×1080、1371×813 通过；[release 身份](convergence-2026-10-15/release-final-replay/runtime.json)、[M2 图形](convergence-2026-10-15/release-final-replay/m4-prior-m2-release.log)、[M3 图形](convergence-2026-10-15/release-final-replay/m4-prior-m3-release.log)、[M4 图形](convergence-2026-10-15/release-final-replay/m4-current-release.log)。这是受控场景检查，不是完整自然键鼠游玩。
- [开发版 F9 图形 97 条](convergence-2026-10-15/release-final-replay/m4-debug-graphical.log)与[发布版禁用 20 条](convergence-2026-10-15/release-final-replay/m4-debug-release-denial.log)通过；[Windows 多进程锁/崩溃恢复](convergence-2026-10-15/windows-lock.log)通过。只使用隔离 test profiles，未操作真实玩家存档。
- 目视检查真实 release 的[转职预览](../../screenshots/convergence-exe-m2-promotion-aren-1280.png)与[三人封顶结果](../../screenshots/convergence-exe-m2-cap-results-1371.png)：实际外观、每人 XP/cap、按钮完整显示。没有把静态截图当作玩法体验验收。
- full_run 的三个 starter seed 101 均受控胜利：Aren 33283、Lia 33004、Milo 32860 tick；不是 SC-002 普通玩家样本。

最终 EXE：`builds/windows/m4/AbyssExpedition.exe`，SHA-256 `965F0E7B9A6254FC3AC5ECD5D92EC87A682410A44A604EDC7C8C3C79703FF17B`。内容 digest `5602ba5970d2a4e031b0fb0c012af7b6963378acd09d845be0e0228748425fbc`，trace simulation `m4-convergence-1`。Trace 版本标明修正后的模拟规则；不承诺跨版本物理回放一致。已有存档 schema/game version 保持兼容。

## Release 性能：捕获有效，未达预算

实际运行（没有并行 Godot 验证/导出）：

```powershell
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory docs/validation/convergence-2026-10-15/benchmark-optimized-executable
```

[host 元数据](convergence-2026-10-15/benchmark-optimized-executable/host.json)、[结果](convergence-2026-10-15/benchmark-optimized-executable/results.json)、[逐 CSV 复核](convergence-2026-10-15/benchmark-checks.json)。原始逐帧/OS 进程 CSV 位于同目录，各 seed 分开保存。

| Seed | 帧样本 | p95 ms | p99 ms | process / physics p95 ms | OS 工作集 MiB 范围 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 101 | 5290 | 27.571 | 28.558 | 16.477 / 7.987 | 117.1–168.9 |
| 202 | 5161 | 27.670 | 28.504 | 16.625 / 7.749 | 117.8–167.5 |
| 303 | 4967 | 29.259 | 30.500 | 21.101 / 8.198 | 115.9–168.8 |

所有帧：100 living normals + 1 boss、30–31 effects、100–111 moving projectiles、500 gems；两 living companions、最大腐化。三个 capture 都完成 30 主动秒预热 + 120 主动秒捕获，boss 实际存在，gem 合并精确保留 XP/coin，PID 与被采样引擎一致。逐 CSV 独立重算分位数/计数通过；`capture_valid=true`、`frame_budget_pass=false`。

主机 Ryzen 7 5800H / GTX 1650、1920×1080、Compatibility、VSync off、debug build=false、debugger=false；Balanced 电源计划。RAM 和 GPU driver 的 CIM 查询被拒，记录 null 与错误，未猜测。进程以 Hidden 启动，前台状态未独立确认。release 静态内存监视器返回 0，标注 unavailable；表中内存来自实际引擎 PID 的 OS WorkingSet。CPU/physics 是引擎监视器样本，不能当作整帧耗时的互斥占比。

采样命令内部使用 Dummy audio，仅用于避免本机 WASAPI 设备失效对诊断的干扰，项目音频设置未改；不能证明真实音频设备正常。捕获 build SHA `8D7D8296AD6E1B29F2E5035423365EC3A1ADF7531D9219DF9656A8F9F6BA0B1D`，备份于 `builds/windows/m4-performance-capture/AbyssExpedition.exe`。最终构建在此后仅增加 Sera 所有权变化的结果提示；战斗/性能代码和 Resource 未再改变，因此没有将该次捕获冒称为最终文件 hash 的采样。

已依据实际累计情况移除无敌期无效 hero hit request 的分配：10,000 次压力用例，retained IDs 从 10,000 降为 0；同 tick、45 tick 边界、Bastion 与终局回归通过。三个 bot 的 tick/kill/HP 与优化前一致。不同运行的音频/进程观测条件有差异，不能把帧时差异全部归因于这项优化；没有减少负载、修改数值或引入推测性 pooling。T180 仍需继续分析并在指定参考机验证 p95≤16.67 ms / p99≤25 ms，以及 VSync-on 显示反馈≤100 ms。

## 失败与历史证据

- 初期导出后启动曾被 Windows Application Control 4551 拦截；保留 `final/`、`final-followup/` 日志。后来重导出后的实际 EXE 已通过，当前不再描述为启动受阻。未修改 Windows 安全设置。
- `release-template/` 与 `benchmark-release-full/` 为未修改 release 模板加载当时 pack；与真正生成 EXE 的结果分别保留。
- `benchmark-executable-full/` 的 seed 202 遇到 WASAPI device invalidation，wrapper 报错且批次停止，未运行 seed 303；不计作三组通过。之后 Dummy audio 的三组捕获如上。
- `benchmark-executable-memory-smoke/` 曾观测 console wrapper PID，不能把它的内存当作引擎内存；后续 GUI EXE PID 对照及最终完整捕获已修正。
- red 用例和中间失败保留于同名证据目录，包括 `replay-condition-red/` 的 45 断言 / 1 失败；最终整轮用例 45 / 0。没有删去失败或修改标准使之通过。
- 原 M4 build、530 张截图保留于 `builds/windows/m4-before-convergence/`、`baseline-screenshots/`；优化前 build 和 EXE 截图另存 `builds/windows/m4-pre-performance/`、`pre-performance-screenshots/`。历史性能 CSV 未覆写。

## 需求与仍开放的验收

[42 FR / 12 SC 索引](convergence-2026-10-15/requirements-status.json)与[38 AC / 20 边界 / 8 宪法 / 15 计划组核对](convergence-2026-10-15/acceptance-review.json)分别记录实现入口、已执行自动证据与验证边界。所有功能实现不代表所有体验/硬件成功标准已满足；原 26 个开放任务继续保留。

| 开放任务 | 仍缺少的实际证据 |
| --- | --- |
| T180 | 指定 Windows 11 / i5-8400 / GTX1050Ti / 16GB 的三 seed release 达标测量；VSync-on 输入/命中显示延迟。当前非参考机帧耗时也未达标。 |
| T181 | 十名初见玩家的启动/操控、三角色机械差异、乐趣/重试、危险辨识与契约成本收益理解的逐人原始记录。 |
| T182 | 二十次普通 baseline 单人胜利，starter 7/7/6，每角色可赢且至少 16 次为 9–11 主动分钟。 |
| T183 | 各保留 milestone 发布版的自然键鼠离线会话；当前完整 MVP 全流程、保存失败/恢复/禁选、退出重开。 |
| T190 | 原阶段各项人工操作观察；自动图形断言只作辅助。 |

美术仍是有替换路径的原创程序占位；没有新增正式立绘/生产精灵要求。未实现局内断点续玩，符合排除范围。文档离线链接/图片/alt/重复 ID 检查见 [documentation-checks.json](convergence-2026-10-15/documentation-checks.json)。

[开发图鉴](../game-development-dashboard.html) · [简明概览](../IMPLEMENTATION_OVERVIEW.md) · [Tasks](../../specs/001-abyss-expedition-mvp/tasks.md) · [Quickstart](../../specs/001-abyss-expedition-mvp/quickstart.md) · [此前完整验证](verification-2026-10-15.md)
