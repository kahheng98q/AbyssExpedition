# Sword Promotion Requirements Quality Checklist

**Purpose**: 审阅剑系职业差异、真实回血反馈、永久转职演示及验收边界的需求质量。
**Created**: 2026-10-21
**Feature**: [spec.md](../spec.md) · [plan.md](../plan.md)
**Audience / timing**: 实施任务拆分前的规格审阅者；标准深度。

**Note**: 本清单检查需求是否完整、明确、一致且可验收，不评价功能实现或游戏测试结果。
**Review Ownership**: 本清单由审阅者维护；仅在审阅者认定需求质量满足时将条目标为 `[x]`。
**Marker Semantics**: `[x]` 只代表对应需求质量已通过审阅，不代表代码完成、测试通过或玩家验收。

## Requirement Completeness · 范围与内容

- [ ] CHK001 三种剑系身份是否分别覆盖待机、移动、普通攻击和第五次攻击，并明确同一职业用于不同英雄及同伴时的共同特征？[Completeness, Spec §US1, §FR-001–003]
- [ ] CHK002 基础剑士与两条分支的视觉要求是否分别列出，避免只定义两条转职后的差异？[Completeness, Spec §US1, §FR-002]
- [ ] CHK003 剑圣双斩、第五次旋斩和深渊长弧的视觉要求是否同时说明对应的真实判定范围、方向和时间关系？[Completeness, Spec §US1, §FR-003]
- [ ] CHK004 回血提示要求是否分别涵盖恢复者身份、提示位置、实际增量、正增量条件及单次发动提示次数？[Completeness, Spec §US2, §FR-004]
- [ ] CHK005 两分支预览是否都要求普通攻击、第五次收益、示例标识、玩法说明及演示结束后的循环状态？[Completeness, Spec §US3, §FR-005]
- [ ] CHK006 转职决策要求是否涵盖可预览但不可确认、永久提交、取消、重复提交及保存失败后的处理？[Completeness, Spec §US3, §FR-007]
- [ ] CHK007 原音频、非剑系职业、DEV沙盒及发布限制的保留边界是否均被列为明确要求？[Completeness, Spec §FR-001, §FR-011]

## Requirement Clarity · 用语与边界

- [ ] CHK008 “灰度下可区分”是否有足够明确的判定口径，能区分职业轮廓辨识与密集截图中的主角／预警定位？[Clarity, Spec §FR-002, §FR-010, §SC-001, §SC-003]
- [ ] CHK009 “双斩方向可辨”“完整旋斩轮廓”和“长弧清晰可见”是否各有可审阅的视觉界限，避免仅凭主观形容词判定？[Clarity, Spec §US1, §FR-003]
- [ ] CHK010 “不暗示额外判定”是否清楚区分真实有效范围、装饰拖尾与同次两弧的可见时序？[Clarity, Spec §US1, §FR-003]
- [ ] CHK011 “实际恢复量四舍五入到一位”是否定义很小的正增量、显示为0.0及临界舍入值的成功提示语义？[Ambiguity, Spec §FR-004, §SC-002]
- [ ] CHK012 “每次发动至多一次”是否清楚说明多目标、同次附加斩击与第五次计数之间的关系，而不会被理解为每个目标一次？[Clarity, Spec §US2, §FR-004, §FR-008]
- [ ] CHK013 “失焦冻结、回焦不补播”是否说明循环时长计量和失焦期间的预览进度如何解释？[Clarity, Spec §FR-005–006, §SC-004]
- [ ] CHK014 “示例实际恢复量”是否明确区别演示中的示例生命与玩家的真实生命、职业数值及攻速？[Clarity, Spec §US3, §FR-005–006]

## Requirement Consistency · 跨场景约束

- [ ] CHK015 攻击视觉的出现时点要求是否与“伤害、射程、攻速及第五次规则保持不变”一致，不容许为画面清楚而新增或推迟伤害？[Consistency, Spec §FR-003, §FR-008]
- [ ] CHK016 满血时不提示成功的要求是否与“治疗规则不变”及满血第五次后受伤不补发的边界场景一致？[Consistency, Spec §US2, §FR-004, §FR-008]
- [ ] CHK017 死亡／受伤优先级是否与已发动攻击的结算保持一致，避免视觉覆盖被误读为取消或追加伤害？[Consistency, Spec §FR-002–003, §FR-009]
- [ ] CHK018 演示允许始终观看的要求是否与等级／道具资格限制和永久一次转职条件相容？[Consistency, Spec §US3, §FR-005–007]
- [ ] CHK019 FR-012的实施前条件是否与计划及验收合同一致，明确仅自然九局是开工硬门槛，其他002开放项各自记账？[Consistency, Spec §FR-012, §Assumptions, Plan §Constitution Check]
- [ ] CHK020 预览的“零真实状态变化”是否与DEV首次建立隔离沙盒的既有行为区分，避免把原有沙盒初始化误判为需求冲突？[Consistency, Spec §FR-006, §FR-011, Plan §Design and Boundaries]

## Acceptance Criteria Quality · 可判定性

- [ ] CHK021 五人职业理解标准是否规定参与者前置经验、顺序、独立档、正确回答构成和至少4人达标的计算方式？[Measurability, Spec §SC-001]
- [ ] CHK022 回血反馈的“0个错误／重复提示”和≤0.05生命误差是否有明确的事实基准，并覆盖低于一位小数分辨率的正恢复？[Measurability, Spec §SC-002, §FR-004]
- [ ] CHK023 十张密集画面的一秒辨识标准是否明确截图条件、随机顺序、同距预警及单个参与者≥8/10的计分方式？[Measurability, Spec §SC-003]
- [ ] CHK024 预览≤8秒、10个循环、10次开关和真实状态零变化是否分别有可观察的起止点与对照对象？[Measurability, Spec §SC-004]
- [ ] CHK025 固定种子前后比较是否明确相同起始档、输入、选择及“玩法状态一致”覆盖哪些结果，且不把合法表现差异算作玩法差异？[Measurability, Spec §SC-005, Plan §Design and Boundaries]
- [ ] CHK026 帧时目标是否同时指定有效负载、预热／采样时长、发布版条件、环境记录及不能降低负载的规则？[Measurability, Spec §SC-006]

## Scenario and Edge Case Coverage · 分支与异常

- [ ] CHK027 正常、无目标、拒绝、满血、近满血、多目标、致死、恢复者死亡及同伴场景是否都在治疗需求中获得互不矛盾的结果定义？[Coverage, Spec §US2, §Edge Cases, §FR-004]
- [ ] CHK028 高攻速、双斩重叠与附加斩击同时存在时，需求是否仍定义可辨结构及不改变实际判定时点的优先关系？[Coverage, Spec §Edge Cases, §FR-003, §FR-008]
- [ ] CHK029 暂停、升级选择、结果、重开和失焦／回焦是否分别定义效果冻结、清理及跨远征隔离的期望？[Coverage, Spec §Edge Cases, §FR-006, §FR-009]
- [ ] CHK030 预览中切换英雄、重复确认、取消与保存失败时，需求是否分别说明示例状态和真实永久选择状态的归属？[Coverage, Spec §US3, §Edge Cases, §FR-006–007]
- [ ] CHK031 DEV遮盖普通转职页、DEV内打开转职页和关闭被保存保护阻止的情形，是否在需求或设计合同中有一致的焦点／可见性语义？[Gap, Spec §FR-006, §FR-011, Plan §Design and Boundaries]

## Non-Functional Requirements · 视觉与证据

- [ ] CHK032 32像素主体、清晰采样、灰度分支差异及主角／同伴标记是否形成一致且可评价的视觉约束？[Non-Functional, Spec §FR-002, §FR-010]
- [ ] CHK033 友方旋斩与敌方橙色预警／红色危险的语义区分，以及HUD、主角标记和最近预警的优先级，是否写得足够明确？[Non-Functional, Spec §Edge Cases, §FR-010]
- [ ] CHK034 预览静音、可读文本及既有确认／取消输入的要求是否覆盖普通页面与DEV页面，且没有隐含新增操作？[Non-Functional, Spec §FR-005, §FR-011]
- [ ] CHK035 自动、真实图形、自然操作、真人理解及性能的证据界限是否明确，尤其说明无人参与或环境不足时的状态？[Non-Functional, Spec §FR-012, §SC-001, §SC-003, §SC-006]

## Dependencies & Assumptions · 门禁与历史证据

- [ ] CHK036 自然九局是否明确当前版本、三职业×三种子、隔离档、真人操作、5／10／30秒阈值、失败保留及完整重录条件？[Dependency, Spec §FR-012, §Assumptions]
- [ ] CHK037 001既有攻击／治疗／保存合同、002尚未完成验收及原创美术约束是否在本功能中作为可追溯的依赖或排除边界？[Dependency, Spec §Assumptions, §FR-008, §FR-012]
- [ ] CHK038 规格和计划是否明确已有自动通过或历史截图不能替代本功能新增视觉、真人理解与性能结论？[Assumption, Spec §Edge Cases, §FR-012, Plan §Planning Validation]

## Notes

- 本次新建38条，全部保留 `[ ]`；审阅者应记录未满足项对应的规格修改或明确的接受理由。
- 现有 [requirements.md](requirements.md) 属于 `$speckit-specify`／`$speckit-clarify` 的独立清单，本次未改动其中已勾选状态。
- `$speckit-implement` 可读取本清单状态作为门禁，但不得修改勾选标记；勾选权归审阅者。
