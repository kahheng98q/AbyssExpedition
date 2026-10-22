# 003 任务生成记录 · 2026-10-21

本次仅生成文档，未实施功能；自然九局门槛仍未满足。产物：[tasks.md](../../../specs/003-sword-promotion-identity/tasks.md)。

## 输入与流程

- 读取本地speckit-tasks技能、003规格／计划／研究／数据模型／三份合同／quickstart、宪法，以及当前相关源码、Resource、验证入口和文档；未修改游戏、引擎配置、测试或工具源码。
- 执行 `python .specify/scripts/python/setup_tasks.py --json` 首次失败：Windows管道cp1252无法输出模板中的Unicode字符，抛出UnicodeEncodeError；脚本未改。
- 执行 `python -X utf8 .specify/scripts/python/setup_tasks.py --json` 成功，解析FEATURE_DIR为003，模板为 `.specify/templates/tasks-template.md`，AVAILABLE_DOCS为research.md、data-model.md、contracts/、quickstart.md。
- 依模板生成Setup／Foundation／按优先级的US1–US3／最终验收，并补依赖图、并行示例、MVP策略及FR／SC映射。保留001／002任务与历史证据、003需求清单所有勾选状态。

## 任务与证据边界

| 范围 | 任务数 | 独立验证 |
| --- | --- | --- |
| Setup | 4 | 自然九局、版本冻结与旧行为回归 |
| Foundation | 8 | 固定投影／manifest正负例、同夹具改前记录 |
| US1 P1 | 11 | 两英雄三职业／主角同伴、姿态与真实弧、三尺寸／灰度、同输入玩法 |
| US2 P2 | 9 | 第4／5／6次及治疗边界矩阵、最多一次实际差值提示、误差≤0.05 |
| US3 P3 | 12 | 两宿主10循环／10开关、焦点／遮盖／速度、资格／保存、真实状态零变化 |
| 最终验收 | 10 | 完整M4／实际导出、三seed比较、真人、物理DEV及Release性能 |
| 合计 | 54 | 全部未执行；6项[P]构成3组不同文件的并行机会 |

MVP为自然门槛＋基础设施＋US1；US1可单独试玩不等于SC-001／003／006通过。US2逻辑可独立测试；US3复用共享绘制、独立测试页面，无需完整远征。比较白名单只允许契约V3明列视觉／版本字段，原玩法几何／damage／due及未知变化均不得略过。

自然九局是代码／美术开工硬门槛；规划可先行。无人操作／设备不足时不代填，也不将五人理解／盲听等002开放项追加为开工条件。54项checkbox表示待实施工作，不含本次文档生成本身。

## 扩展钩子与静态检查

- 生成前以 `Get-Item .specify/extensions.yml -ErrorAction SilentlyContinue` 检查、生成后用Python Path.exists复查，文件均不存在：没有before_tasks／after_tasks hook需要派发。
- 已执行UTF-8 Python静态校验：54项均为未勾选checkbox，ID严格连续T001–T054；故事阶段标签、精确文件路径及6个[P]标记符合格式，三组并行任务无文件重叠。
- 统计：Setup 4、Foundation 8、US1 11、US2 9、US3 12、最终验收10，与正文相符；无未填模板字段。
- 检查14份文档的242个本地链接／媒体引用及锚点，0缺失；dashboard的21张图片均有非空alt，仍使用原离线样式／资源，未新增网络依赖。overview主摘要含179个汉字，低于600字目标。
- 文档同步范围：任务清单、计划内任务入口、README、dashboard当前What's New、中文overview、development及本记录；未更改001／002任务、需求质量清单或游戏／美术资产。
- 未运行Godot、导出、自然九局、图形、真人理解、物理键鼠或性能测试；静态校验不属于游戏验收通过证据。
