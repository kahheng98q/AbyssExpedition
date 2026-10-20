# 002 任务生成检查 — 2026-10-19

**范围**：文档生成与静态检查。功能未实现，SC001–007未执行；本报告不提供游戏通过、听感、图形或性能结论。

## 输入与执行

- 读取 speckit-tasks 技能、AGENTS.md、宪法v1.0.0、002 spec/plan/research/data-model/quickstart及pacing/audio合同；核对已有生成/暂停/复放、runner/manifest、性能入口与文档导航。
- `python .specify/scripts/python/setup_tasks.py --json` 首次因stdout cp1252产生UnicodeEncodeError；设置进程环境 `PYTHONIOENCODING=utf-8` 后重跑成功，FEATURE_DIR为 `specs/002-combat-pacing-audio/`，读取返回的TASKS_TEMPLATE_CONTENT；无代码修复。
- 执行前和完成时检查 `.specify/extensions.yml`，文件不存在；before_tasks/after_tasks均无hook需要派发。
- 生成 [tasks.md](../../../specs/002-combat-pacing-audio/tasks.md)，同步 [README](../../../README.md)、[概览](../../IMPLEMENTATION_OVERVIEW.md)、[离线图鉴](../../game-development-dashboard.html)、[开发记录](../../development.md)。未重写旧001任务、规格、设计决定或历史证据。

## 检查内容

对本次tasks及上述文档运行Python标准库静态检查：任务checkbox/连续唯一ID、故事阶段标签、并行标记、每项具体文件路径、六个阶段/依赖/逐故事并行示例/验收覆盖，以及本次文档的Markdown/HTML本地链接、图鉴图片alt及离线资源引用。实际计数见下表；未检查未来尚未创建的实现目标是否已存在。

| 项目 | 结果 |
| --- | --- |
| 任务 | 64项，T001–T064连续唯一，全部未勾选 |
| 分组 | Setup 3 / Foundational 5 / US1 13 / US2 12 / US3 22 / Polish 9 |
| 格式 | 所有任务包含checkbox、ID、正确的故事标签及具体文件路径；9项[P]，均为故事内不同文件的测试批次 |
| 覆盖 | FR001–012、SC001–007有任务映射；每个实施检查点列明验证/文档同步 |
| 本地引用 | 检查tasks、README、overview、dashboard、development及本报告，共169处本地引用，无缺失本地链接/HTML资源；图鉴21个图片标签均含alt，无远程运行资源引用 |

任务与文档检查不代表功能验收。未运行Godot/import/游戏测试、浏览器响应式视觉检查、自然开局录制、音频录音、人工试玩/盲听或性能采样。新验证命令/suites是待实施任务，当前不可据此运行；既有Q1/M4结果保持历史范围。

**下一步**：按需先做speckit-analyze核对跨文档一致性，或进入已授权范围内的后续实施工作；本轮没有执行实现。
