# 当前实现完整验证 — 2026-10-15

**结论：M1–M4 与 F9 的自动功能、受控图形及导出回归通过；完整验收仍开放。** 修正 `project.godot` 的引擎 features 声明 `4.7 → 4.5`，与现行计划和实际验证二进制一致。未发现需要修改的确定性玩法错误，未更改战斗数值、存档协议或任务验收勾选。

## 环境与检查范围

- 根目录执行，固定引擎 `tools/godot-4.5/Godot_v4.5-stable_win64_console.exe`，实际 `--version` 为 `4.5.stable.official.876b29033`；Compatibility，匹配的本地 Windows x86_64 导出模板。
- Windows `10.0.26200.0`；AMD Ryzen 7 5800H；电源计划 Balanced。[机器与最终构建信息](verification-2026-10-15/environment.json)。本次 Godot 图形日志报告 NVIDIA GeForce GTX 1650 / OpenGL NVIDIA 546.30。CIM 系统/内存/CPU/显卡查询被运行环境拒绝；改用 .NET OS 信息、指定 CPU 注册表属性和 Godot 输出。RAM 未核实。
- 阅读 `project.godot`、导出设置、运行器、验证/锁/压力脚本、核心场景与内容目录、宪章、spec/plan/tasks、现有 gate 和人工检查说明。使用项目原生 `SceneTree` 测试运行器，无 GUT/GdUnit 依赖。
- 注册表静态对照：29 个 unit/integration/scenes fixture 全部注册，无失效路径；98 个交付脚本均在 smoke manifest 中。[对照结果](verification-2026-10-15/registration-checks.json)。
- 测试 profile 使用工作区内 APPDATA 和唯一 `user://tests/` 路径。直接启动 smoke 使用独立 `tools/runtime-verification-source/`、`tools/runtime-verification-release/`，未读取真实玩家存档。
- [首轮完整输出](verification-2026-10-15/baseline.log)和[修正后完整输出](verification-2026-10-15/final.log)分开保存。下列断言数只计修正后的一轮，不将重复运行累加为独立覆盖。

## 实际命令与结果

以下均已执行；普通检查进程 exit 0，负例按设计 exit 2。`$G` 在表中表示固定的 console.exe，`$V` 表示 `docs/validation/verification-2026-10-15`。

| 命令 / 检查 | 本次结果与证据 |
| --- | --- |
| `./tools/run_validation.ps1 -M4 -Graphical -Export` | 修正前、修正后各执行一轮，均完整结束；[final.log](verification-2026-10-15/final.log) |
| 内含 `& $G --headless --editor --import --path .` | 两轮导入 exit 0；[import.log](verification-2026-10-15/import.log) |
| 内含 `& $G --headless --path . --check-only --script res://tests/run_tests.gd` | 运行器解析 exit 0；[parse-runner.log](verification-2026-10-15/parse-runner.log) |
| 内含 `& $G --headless --path . --script res://tests/validate_content.gd` | 51 根 Resource、27 注册场景、98 交付脚本有效；[content.log](verification-2026-10-15/content.log) |
| 内含 `& $G --headless --fixed-fps 60 --path . --script res://tests/run_tests.gd -- --suite <组名>` | 下表 12 组、1,654 条断言通过；包括场景逐帧 smoke、M1–M4 集成、存档和全局模拟 |
| 内含 `--suite missing_suite` / `--seed 2147483648` | 分别实际退出 2；[未知组](verification-2026-10-15/reject-unknown-suite.log)、[溢出 seed](verification-2026-10-15/reject-invalid-seed.log)按预期拒绝 |
| 内含源码 `graphical_check.gd`、`m2_graphical_check.gd`、`m3_graphical_check.gd`、`m4_graphical_check.gd` | 均 exit 0；1280×720、1920×1080、1371×813；[完整输出](verification-2026-10-15/final.log)及各原始日志 |
| 内含 `--headless --export-release 'Windows Desktop' builds/windows/m4/AbyssExpedition.exe` 及实际发布版 M4 图形探针 | 导出及运行成功；[export.log](verification-2026-10-15/export.log)、[m4-release-graphical.log](verification-2026-10-15/m4-release-graphical.log) |
| `./tools/run_debug_validation.ps1 -SkipRegression` | 原生 debug_panel 69 条、源码图形 97 条、实际调试导出图形 97 条、实际发布版禁止调试 20 条全部通过；debug/release 导出成功；[debug.log](verification-2026-10-15/debug.log)。M1–M4 回归已单独完整执行 |
| `./tools/run_m4_release_regressions.ps1` | 当前 M4 发布版通过 M2 六分支/同伴/倒地与 M3 救援/抽取/兑换/历史/重开三尺寸回归；实际 M4 release 禁调试 20 条、源码 F9 图形 97 条通过；[release-regressions.log](verification-2026-10-15/release-regressions.log) |
| `./tools/check_m2_lock.ps1` | 第二进程拒绝写锁（exit 4），强制终止持锁测试进程后，显式确认恢复成功（exit 0）；[windows-lock.log](verification-2026-10-15/windows-lock.log) |
| `& $G --headless --path . --script res://docs/validation/verification-2026-10-15/audit_project.gd` | 修正前后均成功。递归加载 `scripts/tests/scenes/data` 中 142 脚本、29 PackedScene、51 Resource，0 加载/脚本错误；[audit-final.log](verification-2026-10-15/audit-final.log)、[可复跑脚本](verification-2026-10-15/audit_project.gd) |
| `& $G --headless --path . --log-file $V/source-startup-engine.log --quit-after 180` | 当前主场景实际启动至菜单并按帧退出；[source-startup.log](verification-2026-10-15/source-startup.log) |
| `./builds/windows/m4/AbyssExpedition.console.exe --headless --path . --log-file $V/release-startup-engine.log --quit-after 180` | 新发布版主场景实际启动至菜单并退出；[release-startup.log](verification-2026-10-15/release-startup.log) |
| `./tools/run_m4_benchmarks.ps1` | 三种子均采样结束、exit 0；**3/3 帧耗时预算未达标**；[benchmarks.log](verification-2026-10-15/benchmarks.log) |
| `./docs/validation/verification-2026-10-15/check_documentation.ps1` | 实际检查 9 份更新文档的本地链接，以及 dashboard 的图片 alt、片段 ID、离线依赖，0 失败；[结果](verification-2026-10-15/documentation-checks.json) |

直接运行 Godot 命令前先将 `$env:APPDATA` 设为工作区 `tools/runtime-appdata`；启动 smoke 使用上文各自独立目录。完整 runner 调用还传入各自 `--log-file`，PowerShell 包装器配置 60 秒进程 watchdog；benchmark 为每种子 180 秒。原始 stdout/stderr 保存在本报告同名目录。递归审计中的 142 = 98 交付脚本 + 44 测试脚本，29 场景包括 27 注册场景、额外开发面板与压力场景；加载检查不等于每个场景的交互验收。

## 修正后原生断言

每个链接均为本次实际运行的原始日志，全部 0 失败、0 跳过；另有[机器可读汇总](verification-2026-10-15/results.json)。

| 组 | 断言 | 主要回归范围 |
| --- | ---: | --- |
| [unit](verification-2026-10-15/unit.log) | 182 | 伤害、波次、升级、结果优先级、随机流 |
| [scene_smoke](verification-2026-10-15/scene_smoke.log) | 130 | 脚本加载、场景实例化与逐帧、M1 UI 接线 |
| [integration_m1](verification-2026-10-15/integration_m1.log) | 37 | 选择暂停、战斗与结果循环 |
| [replay](verification-2026-10-15/replay.log) | 40 | 十个冻结种子、Sera 两种所有权，二十对回放 |
| [full_run](verification-2026-10-15/full_run.log) | 9 | Aren/Lia/Milo seed 101 均受控胜利 |
| [progression](verification-2026-10-15/progression.log) | 13 | 永久成长、等级上限 |
| [persistence](verification-2026-10-15/persistence.log) | 304 | 迁移、破坏/失败注入、重开、v3 中断与精确 Retry |
| [abilities](verification-2026-10-15/abilities.log) | 107 | 六转职分支、被动、同伴 |
| [integration_m2](verification-2026-10-15/integration_m2.log) | 36 | 保存、队伍、路由与成长 |
| [recruitment](verification-2026-10-15/recruitment.log) | 293 | 救援、票券、概率/重复/兑换与被动 |
| [integration_m3](verification-2026-10-15/integration_m3.log) | 196 | 救援结算与持久化抽取/展示 |
| [integration_m4](verification-2026-10-15/integration_m4.log) | 307 | 腐化阈值、事件成本/排序、章节与迁移 |
| [debug_panel](verification-2026-10-15/debug-panel.log) | 69 | 隔离存档、暂停、XP/等级、刷怪、预览与清理 |
| **合计（13 组）** | **1,723** | **0 失败，0 跳过** |

full_run：Aren 33348 tick、Lia 32860 tick、Milo 32893 tick，与首轮及此前 M4 记录一致。这是固定策略、60 Hz 加速模拟，不能当作普通玩家的通关时长样本。内容摘要仍为 `97664f9f25b1232d331b80728d5cfdd10f637e261e35a1f4e3a79b538a7ea2c9`。

## 压力采样

三组按顺序实际执行，每组 30 秒预热 + 120 秒采样；没有与其他 Godot 图形/导出进程并行。全部采样进程 exit 0、无引擎错误，但 **p95 ≤16.67 ms / p99 ≤25 ms 的预算全部未达到**。原始 CSV 的分位数已重新计算，与日志一致，详见[机器可读计数与恢复检查](verification-2026-10-15/benchmark-results.json)。

| Seed / 原始数据 | 样本 | p50 ms | p95 ms | p99 ms | 最大 ms | 预算 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| [101](verification-2026-10-15/m4-101.csv) | 7068 | 16.733 | 18.409 | 25.519 | 54.433 | 未达标 |
| [202](verification-2026-10-15/m4-202.csv) | 6982 | 16.863 | 18.757 | 26.078 | 37.532 | 未达标 |
| [303](verification-2026-10-15/m4-303.csv) | 6955 | 16.915 | 18.587 | 25.729 | 31.782 | 未达标 |

全部新 CSV 记录：常规敌人 100、效果 30–31、移动弹体 100–109、宝石 500；首领栏为 1。内存范围分别为 44,119,549–52,322,013 / 44,120,637–52,297,805 / 44,120,365–52,290,461 bytes。夹具启用双同伴、100 腐化及高血量首领。首领栏由现有夹具固定写入 1，缺少逐帧独立计数；窗口 1920×1080 / VSync-disabled 为脚本设置，未另作外部观测。尚缺 CPU/physics/draw calls/nodes 细分、RAM 和显示反馈延迟；这仍是源码引擎采样，不是指定参考机器上的 release 验收。

本次只修元数据，未做性能优化；本次和历史采样的数值差异不能作为优化效果。历史 [M4 记录](../benchmarks/m4.md)与 `docs/benchmarks/m4-*.csv`、历史 engine/stdout 日志已保留/还原，CSV 和 stdout 的恢复 hash 核对通过；新采样与历史备份分别在本报告同名目录和其 `benchmark-history/` 中。

## 已修复问题与错误审查

1. **引擎声明漂移**：当前计划、验证脚本与模板固定 4.5，`project.godot` 却声明 4.7。已仅将 `config/features` 中版本改为 `4.5`，首轮和修正后均执行完整 import/原生/源码图形/导出/发布版图形；内容摘要、自动胜利 tick 未变化。此为配置一致性修复，无玩法平衡调整。
2. **本次无已确认的导入、解析、Resource 接线、运行时或断言错误**。对本次复制的功能日志搜索 `WARNING / ERROR / SCRIPT ERROR / FAIL / leak / Orphan` 无命中。此结论限于实际覆盖路径。
3. **硬件元数据采集限制**：CIM 查询拒绝访问；未提权，使用可读的本地信息补充。记录为环境限制，不将它写成测试通过。
4. 性能指标与显示延迟属于未关闭验收项，详见下节；没有通过降低工作负载、改变伤害/波次或跳过失败断言掩盖问题。

当前重新导出的 M4 executable：97,101,832 bytes，SHA-256 `7047A7DA04110CB430D112207EDB966B700DD67F945712A71B402376B7803453`。历史 gate 的 hash 属于此前构建，不代表本次文件。

## 未执行或仍缺少的验收

| 检查 | 本次状态 / 原因 | 后续实际操作 |
| --- | --- | --- |
| 十名初见玩家的操控、乐趣、重试意愿、1 秒危险识别 | **未执行**：没有参与者样本；自动截图不能代替 | 依 [M1 人工协议](m1-human-playtest.md)记录逐人反馈与识别结果 |
| 二十次普通单人胜利，三初始角色 7/7/6 | **未执行**：只有受控 bot；无普通手动样本 | 记录 seed、起始进度、主动时长，检验 ≥16 次在 9–11 分钟 |
| 十人祭坛收益/成本理解（至少 8 人正确） | **未执行**：无参与者研究 | 按 [M4 人工协议](m4-human-playtest.md)执行，不提示答案 |
| 各里程碑完整离线、键鼠自然操作流程 | **待人工验收**：受控脚本可执行功能，但不是完整人类试玩 | 手动完成公会→战斗→救援/事件→结算→成长→转职/同伴→抽取/兑换→退出/重开；补死亡、放弃、Retry、拒绝/禁选、存档失败恢复 |
| 参考机器 release 性能 | **无法执行**：当前主机非 i5-8400/GTX 1050 Ti/16 GB 指定机器；本次压力脚本运行源码引擎 | 指定硬件、release、1920×1080、三 seed 原协议并采完整元数据、CPU/physics/draw calls/nodes |
| 显示移动/命中反馈 ≤100 ms、密集场景辨识 | **未执行**：缺少输入/命中与屏幕帧的同步测量/高速录像 | VSync-on 实测、录像关联输入/命中与显示帧，另做十人辨识检查 |
| 历史 M1/M2/M3 单独可执行文件重建/试玩 | **未重跑**：本次验证当前 M4 源码和导出，未改写旧里程碑包 | 当前 M4 已回归先前功能；旧包的验收仍以各历史 gate 与后续人工检查为准 |
| M2 额外图鉴截图生成器 `m2_evidence_capture.gd` | **未重跑**：属于历史文档素材生成；已解析，M2 自动功能与三尺寸源码/当前发布版回归已执行 | 需要重拍旧专题素材时单独执行，不计入本次通过数 |

没有因工具缺失而跳过已注册原生测试。正式精灵动画/独立立绘尚未实现，视觉仍为原创程序占位，不能作正式美术验收。T153/T168/T170/T172/T174/T175 及此前人工/硬件任务继续开放；本次没有更改其勾选。

已查看本次发布版 `m4-release-boss-double-eruption-1280.png`、`m4-release-altar-cap-disabled-1371.png`、`m4-release-chapter-saved-1920.png`：主角/敌人/双圆与锥形预警、阈值 HUD、祭坛禁选原因和章节保存结算可见，未见明显遮挡。三尺寸的自动布局检查通过；这些为逻辑 viewport 截图与受控状态，不证明所有窗口状态、动态镜头或密集实战画面均经过人工检查。

## 快速复查

运行 `builds/windows/m4/AbyssExpedition.exe`，WASD/方向键移动，自动攻击，1/2/3 选升级，Esc 暂停，C 查看腐化。源码 F5 的 F9 为隔离开发沙盒；release 禁用。

自动复跑主入口：`./tools/run_validation.ps1 -M4 -Graphical -Export`；F9：`./tools/run_debug_validation.ps1 -SkipRegression`；当前发布版旧流程：`./tools/run_m4_release_regressions.ps1`；跨进程锁：`./tools/check_m2_lock.ps1`。

文档：[离线开发图鉴](../game-development-dashboard.html) · [简明概览](../IMPLEMENTATION_OVERVIEW.md) · [开发记录](../development.md) · [历史 M4 gate](m4-gate.md)。
