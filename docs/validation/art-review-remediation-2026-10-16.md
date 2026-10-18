# Visual planning review remediation · R1 · 2026-10-16

本次获授权只修订文档。游戏代码、场景、Resource、生产美术及玩法任务不在修改范围；未执行 Godot、图形、性能或人工试玩。历史验收报告保留原文，不覆盖旧证据。

## Corrections and traceability

首批正确数量为 **8件**：Aren、Thrall、Brinejaw、神殿环境、剑弧、追踪星、战斗HUD、升级UI。此前分析沿用了错误的九件口径；原七件清单实际确为七件，加入升级UI才为八件。共享Theme、图标、头像和暂停seed披露为支持项。

| Review ID | 文档修订 | 后续执行证据 |
| --- | --- | --- |
| I1 | Story1、FR-011、SC-001与中英文清单统一8件 | T011/T028/T030/T083核对真实交付 |
| I2 | 新旧背景互斥、完整回退与最终Z；四墙不变 | T063/T066/T068/T075 |
| U1 | HUD面积/遮挡分开，四边四角样稿，P01待批 | T024/T026/T042/T046/T076 |
| U2 | 显式三选择器/三VisualSet，正常接线与故障回退分开 | T055–T059/T066 |
| U3 | 权威事件时间与迟到/中断规则；处理主角/同伴dead_at无效及2tick抗性反馈 | T009/T058/T059/T074 |
| G1 | 原M4基准保留，额外新表现负载P02及新/回退计数 | T032/T033/T069/T078 |
| G2 | 合同/UI/集成fixture分别加入unit/scene_smoke/integration_m1，要求实际执行证据 | T034/T055/T058/T067/T071 |
| A1 | 原向/镜像明暗和语义标记校正，P03待批 | T019/T020/T054/T083 |
| A2 | 制作前固定fixture/答案，逐项目×条件×尺寸评分与版本追溯 | T013/T022/T023/T030/T081 |

以上表示修订已写入规划，不表示功能已实现或验证。87个任务保留原编号，均未勾选。审批记录未新增任何owner批准。

## Pending design decisions

- **P01**：边缘HUD避让与身体裁切规则；上部裁切只是候选，脚锚/定位/危险仍须可读。不授权改变相机/物理。
- **P02**：额外容量候选30新版剑弧+100新版追踪星；G1冻结确切数量、选择器和补充策略。保留原负载与性能门槛，独立报告。
- **P03**：镜像安全角色明暗；世界左上光，近对称角色明暗/独立脚影/少量标记校正是待批方案。

同一G1修订须取得这些决定与识别协议批准后才可执行依赖任务。G0/G1完整样稿、生产资产、参考机/人工/显示延迟与G2验收仍待完成。

## Static validation

实际执行：PowerShell here-string 输入 `python -`，用标准库 pathlib/re/html.parser 检查当前文档链接、HTML结构/图片alt、需求编号、任务格式及suite映射；用 hashlib 比较选定受保护文件的路径和内容摘要。检查不调用游戏、不证明艺术质量或帧时间。

- 27份文档、449个本地链接目标：0失效；包含本记录与静态结果JSON链接的最终复查。
- 3份HTML：结构栈无错误、无未闭合元素，21张现有图片均有alt；没有浏览器视觉验收。
- 25 FR、7 SC；中英文编号一致，Story1/FR-011/SC-001八件口径一致。
- 87个连续唯一任务，0勾选；T034/T055/T058明确scene_smoke/unit/integration_m1。它们仍是未来任务，未执行测试。
- 选定3,750个受保护文件及路径的SHA-256汇总前后相同：`733031d060f19acbc777457334316b5f3a8098518c02d3c4026abace916d97b7`。保护范围/扩展名详见[静态结果JSON](art-review-remediation-checks-2026-10-16.json)。
- P01/P02/P03和G0–G3仍pending；没有将修改文档的授权记为美术或实施批准。

## Sources and follow-up

[Spec](../../specs/002-2d-art-direction/spec.md) · [Plan](../../specs/002-2d-art-direction/plan.md) · [Tasks](../../specs/002-2d-art-direction/tasks.md) · [Presentation contract](../../specs/002-2d-art-direction/contracts/presentation.md) · [Approval register](../visual-design/APPROVALS.md) · [Dashboard](../game-development-dashboard.html)

本轮文档完成后再执行只读 speckit-analyze；该技能的最终分析报告在聊天中输出，不作为运行验收证据。
