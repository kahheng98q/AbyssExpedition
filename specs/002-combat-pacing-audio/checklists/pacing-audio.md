# Pacing & Audio Requirements Checklist: 首两分钟节奏与战斗音效

**Purpose**: 评审节奏与生成安全、战斗音效与暂停要求的完整性、清晰度、一致性及可衡量性；覆盖确定性、存档/DEV保护和验收证据边界。
**Created**: 2026-10-19
**Feature**: [spec.md](../spec.md) · [plan.md](../plan.md)
**Depth**: Standard（标准）
**Actor / Timing**: 需求评审者；Phase 1设计之后、任务拆分与实施之前。
**Scope basis**: 本次调用未附加专项要求；采用当前特性的节奏/安全与音效/暂停两个主要领域。tasks.md尚未生成。

**Note**: 本清单由 `$speckit-checklist` 按当前特性生成，只检查需求文本质量，不是游戏测试步骤或实现完成清单。
**Review Ownership**: 本清单由评审者拥有；只有评审者判定需求质量标准已满足后，才可将条目标为 `[x]`。
**Marker Semantics**: `[x]` 仅表示该项需求质量已评审并满足，不表示代码已实现或游戏验收通过。本轮所有条目均保持未勾选。

## Requirement Completeness / 需求完整性

- [ ] CHK001 首波位置、前两分钟组成和声音反馈三项变更的范围，以及继续继承旧MVP的规则，是否有明确且可追溯的边界？ [Completeness, Spec §FR-002–FR-006, Spec §Assumptions]
- [ ] CHK002 攻击、有效命中、敌人致死、主角受伤和升级反馈的需求，是否完整区分声音来源、目标身份及各自的触发事实？ [Completeness, Spec §FR-007–FR-009, Contract audio §Ownership and facts]
- [ ] CHK003 未发动攻击、未命中、拒绝伤害、无敌及同次致死不叠普通命中音等负向声音要求，是否均有明确陈述？ [Completeness, Spec §User Story 3, Spec §FR-008]
- [ ] CHK004 暂停、恢复、升级选择、结束、离场和重开各生命周期的声音要求，是否覆盖已有声音与新声音两种情形？ [Completeness, Spec §FR-010, Contract audio §Pause and lifecycle state table]
- [ ] CHK005 正常档、测试档、开发沙盒及开发/发布版本的保留要求，是否明确到受影响的使用场景与保护范围？ [Completeness, Spec §FR-012, Spec §SC-006]

## Requirement Clarity / 需求清晰度

- [ ] CHK006 “主动秒”、开局计时起点以及手动暂停、失焦、升级和事件选择的时间排除规则，是否有一致且明确的定义？ [Clarity, Spec §SC-001, Spec §Assumptions]
- [ ] CHK007 “初始位置”“附近”“玩家能看见预警”是否被明确区分，且距离范围与可见性要求足以避免不同评审者采用不同解释？ [Clarity, Spec §User Story 1, Spec §FR-002, Ambiguity]
- [ ] CHK008 基础名额、腐化数量加成名额、预警名额及实际出现敌人的含义是否清楚，且各计数口径不会被混用？ [Clarity, Spec §FR-003–FR-005, Spec §SC-002]
- [ ] CHK009 “回收段”是否明确仅限制新生成的基础特殊敌人，而不承诺清场、绝对安全或停止存活敌人的行为？ [Clarity, Spec §User Story 2, Spec §Edge Cases]
- [ ] CHK010 “最多同时播放8个战斗声音”的计数范围是否明确包含升级、主角受伤以及暂停中的声音，并区分待处理升级提示与正在播放的声音？ [Clarity, Spec §FR-009, Contract audio §Voices, arbitration and mixing, Ambiguity]

## Requirement Consistency / 需求一致性

- [ ] CHK011 每10秒四个基础名额、12波/48基础名额与腐化增量后的总计划数量之间，是否在规格、计划及合同中使用一致口径？ [Consistency, Spec §FR-004–FR-005, Spec §SC-002, Contract pacing §Scheduling and composition]
- [ ] CHK012 “额外名额全部先为Thrall”“腐化只替换Thrall”与继承的母体总组成份额要求是否相容，且没有隐含改变基础冲刺/远程名额？ [Consistency, Spec §FR-005, Spec §Clarifications, MVP Spec §FR-036, Contract pacing §Scheduling and composition]
- [ ] CHK013 120秒的成长、事件与下一主阶段要求是否采用一致的优先关系，并与暂停后不重复、不补刷的要求相容？ [Consistency, Spec §FR-005, Spec §FR-010, Contract pacing §Time and 120-second boundary]
- [ ] CHK014 每次已呈现升级保留一次声音、普通战斗声不积压补播、终局清除旧声音三者的适用范围和优先关系，是否一致且无冲突？ [Consistency, Spec §User Story 3, Spec §FR-009–FR-010, Contract audio §Upgrade exactly once]

## Acceptance Criteria Quality / 验收标准质量

- [ ] CHK015 九局基准的角色、种子、起始成长/队伍状态、正常操作范围及输入/选择记录冻结规则，是否足以使开局时限标准可重复评审？ [Measurability, Spec §SC-001, Quickstart §C]
- [ ] CHK016 有效样本、安全负例、普通时限失败和提前结束的分类要求是否明确，且不会允许通过剔除失败或更换种子满足成功标准？ [Measurability, Spec §Edge Cases, Spec §SC-001–SC-002, Quickstart §C]
- [ ] CHK017 首次对敌有效命中、首次敌人击杀、首次升级选项呈现以及实际冲刺/射击的计时终点，是否分别定义，而非以生成类型或待呈现选择代替？ [Measurability, Spec §SC-001–SC-002, Contract pacing §Observable contract / acceptance]
- [ ] CHK018 新玩家理解的提问范围、无提示条件、合格回答和“至少4/5人”的人数口径，是否明确到能够一致判定基本循环与两种威胁应对？ [Measurability, Spec §SC-003, Quickstart §E]
- [ ] CHK019 四类反馈盲听的识别标准与三职业攻击音“可区分”的要求，是否各有对应验收定义，避免只达到四类辨认率就认定职业音色已可区分？ [Measurability, Spec §FR-007, Spec §SC-004, Gap]

## Scenario Coverage / 场景覆盖

- [ ] CHK020 三个用户故事独立评审所使用的基线条件及隔离范围是否写明，足以分别评价首波、遭遇组成与声音需求？ [Coverage, Spec §User Story 1–3, Plan §Phase 1 — Design and implementation checkpoints]
- [ ] CHK021 单人/满队、初始基础职业/已有成长与转职等替代起始状态，是否有明确的保留要求，并说明计划压力不随玩家强度调整？ [Coverage, Spec §Edge Cases, Spec §FR-005, Spec §SC-006]
- [ ] CHK022 同帧多次伤害、范围击杀、持续伤害及同伴同时攻击时，可合并/省略声音的范围与不可改变的战斗结果是否写清？ [Coverage, Spec §Edge Cases, Spec §FR-008–FR-009]
- [ ] CHK023 手动暂停、失焦、开发面板与升级/事件选择叠加时，声音冻结、升级短句例外及恢复条件是否有完整的需求描述？ [Coverage, Spec §FR-010, Spec §Assumptions, Contract audio §Pause and lifecycle state table]

## Edge Case Coverage / 边界覆盖

- [ ] CHK024 候选落点不可用、队员占位及预警期间队员进入安全半径的情形，是否明确安全优先、尝试上限、取消结果及禁止强制贴脸/迁移补刷的要求？ [Coverage, Spec §FR-003, Spec §Edge Cases, Contract pacing §Opening candidate and reservation]
- [ ] CHK025 容量达到100、预警尚未激活以及母体幼体的特殊安全范围，是否均有清楚且互不矛盾的计数与丢弃规则？ [Coverage, Spec §FR-003, Spec §Edge Cases]
- [ ] CHK026 119.99秒到120秒的边界是否明确旧敌人保留、新阶段接续及同刻选择的要求，而不只描述一般波间暂停？ [Coverage, Spec §Edge Cases, Spec §FR-005, Spec §SC-005]
- [ ] CHK027 音频关闭、输出设备不可用及恢复输出后的声音处理要求是否明确，并区分仍可离线游玩的要求与不可宣称声音验收通过的限制？ [Coverage, Spec §Edge Cases, Spec §FR-011, Contract audio §Pause and lifecycle state table]

## Non-Functional Requirements / 非功能需求

- [ ] CHK028 性能目标是否同时指定帧时分位数、参考环境、发布状态、代表负载、预热/采样时长及真实音频开关对照，且限制条件在计划中保持一致？ [Measurability, Spec §SC-007, Plan §Technical Context]
- [ ] CHK029 确定性要求是否明确限定同版本、种子、起始状态和带时间的输入/选择，并定义声音变化不得影响的玩法结果与最终状态范围？ [Clarity, Spec §FR-011, Spec §SC-005, Data Model §7]
- [ ] CHK030 可辨认、同伴不盖过主角、无削波及升级可听等声音质量用语，是否被转换为可评审的标准，并明确真实设备证据与逻辑证据的不同适用范围？ [Measurability, Spec §User Story 3, Spec §SC-004, Quickstart §E]
- [ ] CHK031 静音仍可理解战斗、像素预警可读性和原创资源来源等约束，是否与既有视觉提示、原有操作及项目原创原则一致，而不形成新增玩法依赖？ [Consistency, Spec §FR-001, Spec §FR-007, Spec §Edge Cases, Constitution §III–V]

## Dependencies & Assumptions / 依赖与假设

- [ ] CHK032 继承旧MVP的生成/腐化/后段规则和本切片明确覆盖的默认行为，是否能追溯到具体来源，并约定如何处理历史文档与当前要求的差异？ [Traceability, Spec §Requirements, Spec §Assumptions, Plan §Compatibility and affected expectations]
- [ ] CHK033 真人、真实音频设备、参考硬件和待补验证能力等依赖，是否明确对应受阻的验收项，以及依赖不可用时应保留的未验证状态？ [Completeness, Spec §SC-003–SC-007, Spec §Assumptions, Assumption]
- [ ] CHK034 不新增存档字段、保留正常/开发隔离与DEV入口、逐阶段更新实现文档等约束，是否在计划中有明确承接，而未被视作本切片之外可忽略的事项？ [Traceability, Spec §FR-012, Plan §Phase 1 — Design and implementation checkpoints, Constitution §VIII]

## Ambiguities & Conflicts / 歧义与冲突

- [ ] CHK035 节奏合同中的“首次接受伤害”与规格中的“首个有效命中”，是否一致明确指主角对敌人的有效命中，而不会被解释为主角首次受伤？ [Ambiguity, Spec §User Story 1, Spec §SC-001, Contract pacing §Observable contract / acceptance]
- [ ] CHK036 正常开局不额外发经验、不改门槛/伤害/奖励与5/10/30秒目标未达标时的处理边界，是否写明，避免将验收目标误当成自动修改平衡数值的授权？ [Conflict, Spec §FR-006, Plan §Risks and acceptance boundaries]
- [ ] CHK037 每个已呈现升级提示都须可听与终局立即清声音的要求，是否明确快速连选后立即结束这类交界情形的优先关系及验收口径？ [Ambiguity, Spec §User Story 3, Spec §SC-004, Contract audio §Upgrade exactly once]
- [ ] CHK038 规划合规、需求质量评审、实现验证和人工验收的状态是否明确分开，确保旧报告或清单勾选不能被解释为本切片已完成？ [Clarity, Spec §Status, Spec §Assumptions, Plan §Constitution Check]

## Notes

- 本轮新建38项（CHK001–CHK038），全部未勾选；没有评价任何条目是否满足。
- `[Gap]`、`[Ambiguity]`、`[Conflict]`、`[Assumption]` 表示需要评审关注的维度或潜在问题，不是本次已作出的缺陷结论。
- `Spec`指[本切片规格](../spec.md)；`Plan`指[实施计划](../plan.md)；`MVP Spec`指[旧MVP规格](../../001-abyss-expedition-mvp/spec.md)；`Contract pacing`和`Contract audio`分别指[节奏合同](../contracts/pacing.md)与[声音合同](../contracts/audio.md)；`Quickstart`和`Data Model`分别指[验证指南](../quickstart.md)与[数据模型](../data-model.md)。
- 评审者仅在需求质量标准已满足后勾选；仍需澄清、修正或评审的条目保持未勾选，可在条目下补充依据或发现。
- `$speckit-implement`读取自定义清单状态作为门槛，但不得修改勾选标记；未勾选不表示游戏测试失败。
- [requirements.md](requirements.md)是由`$speckit-specify`/`$speckit-clarify`维护的独立内置清单；本轮保留其内容和状态。
- 本清单不生成tasks、不修改规格/计划、不改变游戏实现，也不替代[quickstart](../quickstart.md)中的后续验收。
