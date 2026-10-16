# 开发图鉴文档复核 · 2026-10-15

本次只更新文档。未实现新玩法，未修改任务勾选。日期采用 Asia/Singapore。

## 范围与依据

- 阅读 constitution、Spec、Plan、Tasks、现有 README、开发记录、美术方向、M4 gate、调试与基准记录。
- 核对主场景→AppRouter→目录→Expedition/界面接线，以及角色、职业、技能、卡池、救援、腐化与事件 Resources。
- 检查成长结算、转职条件、被动、同伴、招募事务、档案迁移、调试版本限制及相关测试。
- 六角色、九职业（其中六转职）、六被动、十二升级、五常规敌人＋召唤幼体、一首领、三类事件均由当前目录注册；不是根据 tasks 勾选推断。
- 实测截图复用 `screenshots/` 的留存文件。M1/M2/M3、M4 发布版回归及开发版图片分别标注来源，不视为本次重新截取。
- 角色没有独立立绘；看板用明确说明的字母占位。外观实际由 `scripts/combat/actor_presentation.gd` 按职业程序绘制。

## 本次执行：固定 Godot 原生测试

版本：`4.5.stable.official.876b29033`。为避免覆盖历史最终日志，直接调用验证脚本所用的固定引擎及测试 runner，保存到 `dashboard-*.log`。测试用 APPDATA 设为工作区内的 `tools/runtime-appdata`；不访问系统 APPDATA 玩家档案。

执行方式（项目根目录，以下循环实际执行）：

```powershell
$env:APPDATA = Join-Path (Get-Location) 'tools/runtime-appdata'
$dashboardEngine = './tools/godot-4.5/Godot_v4.5-stable_win64_console.exe'
& $dashboardEngine --version
& $dashboardEngine --headless --path . --log-file docs/validation/dashboard-content-engine.log --script res://tests/validate_content.gd
foreach ($dashboardSuite in @('unit','scene_smoke','integration_m1','replay','full_run','progression','persistence','abilities','integration_m2','recruitment','integration_m3','integration_m4','debug_panel')) {
  & $dashboardEngine --headless --fixed-fps 60 --path . --log-file "docs/validation/dashboard-$dashboardSuite-engine.log" --script res://tests/run_tests.gd -- --suite $dashboardSuite
}
```

命令标准输出也各自保存在对应 `dashboard-<suite>.log`。全部退出码为 0。

| 本次日志 | 断言 | 失败 | 跳过 |
| --- | ---: | ---: | ---: |
| [unit](dashboard-unit.log) | 182 | 0 | 0 |
| [scene_smoke](dashboard-scene_smoke.log) | 130 | 0 | 0 |
| [integration_m1](dashboard-integration_m1.log) | 37 | 0 | 0 |
| [replay](dashboard-replay.log) | 40 | 0 | 0 |
| [full_run](dashboard-full_run.log) | 9 | 0 | 0 |
| [progression](dashboard-progression.log) | 13 | 0 | 0 |
| [persistence](dashboard-persistence.log) | 304 | 0 | 0 |
| [abilities](dashboard-abilities.log) | 107 | 0 | 0 |
| [integration_m2](dashboard-integration_m2.log) | 36 | 0 | 0 |
| [recruitment](dashboard-recruitment.log) | 293 | 0 | 0 |
| [integration_m3](dashboard-integration_m3.log) | 196 | 0 | 0 |
| [integration_m4](dashboard-integration_m4.log) | 307 | 0 | 0 |
| [debug_panel](dashboard-debug_panel.log) | 69 | 0 | 0 |
| **合计** | **1,723** | **0** | **0** |

[内容校验](dashboard-content.log)：51 root Resources / 27 scenes / 98 scripts，`valid=true`；摘要 `97664f9f25b1232d331b80728d5cfdd10f637e261e35a1f4e3a79b538a7ea2c9` 与 [M4 最终记录](m4-gate.md)一致。`full_run` 三名初始角色 seed 101 胜利时间为 33348 / 32860 / 32893 ticks，是加速模拟而非普通人工通关。

## 页面与文档检查

本次新增：

- [game-development-dashboard.html](../game-development-dashboard.html)：离线 HTML/CSS/JS、中文短文、真实截图、里程碑、五步玩法、12 张功能卡、六角色、六分支、腐化阈值、工具、验证与启动说明。
- [IMPLEMENTATION_OVERVIEW.md](../IMPLEMENTATION_OVERVIEW.md)：GitHub 可读中文概览。

README 增加链接区，验证命令更新为 M4。`development.md` 的当前状态入口纠正为 M4 已实现，原有历史交付内容保留。两文件各有历史混用编码的破折号字节，更新时规范为 UTF-8。

静态链接、资源、HTML 结构、响应式规则和脚本筛选/导航逻辑的执行结果记录在 [dashboard-document-checks.json](dashboard-document-checks.json)。原生执行前后比对 `scripts/`、`scenes/`、`data/`、`tests/` 文件 SHA-256，确认玩法文件未更改。

- HTML 标签闭合、唯一 ID、内部锚点通过；四份入口文档共 143 处本地引用均存在。
- 14 处图片引用、13 个不同 PNG 文件路径和文件头/尺寸有效；所有图片有 alt，无外部 CSS/JS/字体/网络请求。
- 720px / 1000px 响应式规则存在；12 张功能卡、6 张角色卡、3 棵职业树与实际数据相符。
- Node.js `vm` 中以最小 DOM 替身执行页面原脚本：全部→已验证→部分完成→全部分别显示 12→11→1→12 项，按钮状态与提示一致；8 个导航高亮状态通过。此为逻辑检查，不是浏览器渲染/点击测试。
- 执行前后 **367 个**源码/场景/数据/测试文件清单与 SHA-256 完全一致；[执行前清单](dashboard-source-before.json)保留作为依据。

**实际浏览器渲染未验证**：首次内置预览超时；随后浏览器工具以 URL 策略拒绝本地 `file://` 协议。没有绕过该限制，也未架设服务器或把文件上传到外部。双击本地 HTML 是交付后的正常查看方式，但本次未能检查其浏览器实际打开效果、图片解码、视觉布局、点击导航或窄屏渲染。静态路径检查及隔离脚本测试不代表这些浏览器行为通过。

## 状态边界

- “已实现并验证”仅覆盖源码接线、自动功能与已列出的历史受控图形证据。
- **性能未达标**：[M4 基准](../benchmarks/m4.md)记录 p95 25.277–25.816 ms，高于 16.67 ms。非指定参考机、源运行；本次未重跑。
- **待人工验收**：十人易用性/乐趣/契约理解、二十次普通通关、完整离线手动流程、密集画面辨识及显示延迟。T153/T168/T170/T172/T174/T175 与此前人工/硬件门槛仍开放。
- **部分完成**：原创程序占位视觉与姿态反馈已存在；正式动画精灵表、独立立绘未实现。
- 游戏图形回归、发布版探针、锁竞争与性能测量本次均未重跑；引用历史记录时明确时间/范围。没有把 headless 当作图形、人工或性能验收。
- `project.godot` 的显示名与 features 元数据仍含早期 M3/4.7 标记；当前执行按固定 4.5 核验，本次不修改玩法配置。
