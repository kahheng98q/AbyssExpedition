# Visual Art Direction · 需求质量检查清单

**Purpose**: 审查视觉需求的完整性、清晰度、一致性、可衡量性及场景覆盖；不检查实现完成情况。
**Created**: 2026-10-16
**Feature**: [002-2d-art-direction](../spec.md) · [计划](../plan.md)
**深度 / 使用者 / 时机**: 标准深度，覆盖用户指定十个领域；需求作者与审批者在 G0/G1、任务拆分及后续批次审批前使用。

**Note**: 由 `$speckit-checklist` 生成，所有新增项目保持未勾选。
**Review Ownership**: 本清单由评审者维护；只有评审者确认需求质量满足标准后才标记 `[x]`。
**Marker Semantics**: `[x]` 仅表示该条需求质量经评审满足，不代表设计获批、资产已制作、代码已接线或测试已通过。

## 评审层次与证据边界

| 层次 | 判定对象与所需记录 | 本清单的作用 |
| --- | --- | --- |
| 需求质量 | 条款是否明确、完整、一致、可评审；引用与未决问题 | 本文件唯一勾选含义 |
| 设计审批 G0/G1 | 文字替代/参考、实际像素样稿、同一修订的 owner/date/decision/scope | 审查审批标准是否写清；不代签审批 |
| 实现完成 | 获批资产、表现层/UI 接线、保留回退及玩法边界 | 审查完成定义是否充分；不把计划当实现 |
| 测试与运行验收 G2 | 实际 source/release 图形、回归、识别反馈、延迟及参考机性能证据，另列 owner 视觉决定 | 审查证据标准是否充分；自动通过不等于人工接受 |
| 扩批 G3 | 每家族单独范围、成本、样稿、审批和受影响验证 | 审查扩批边界；不从切片批准推断全量授权 |

执行验收另见 [visual-acceptance.md](visual-acceptance.md)；实际审批见 [APPROVALS.md](../../../docs/visual-design/APPROVALS.md)。当前登记 G0–G3 均 pending，G1 像素样稿与 G2 实机尚未交付。本文件不改变这些状态。

## 需求完整性 · 风格、动画与界面

- [ ] CHK001 风格要求是否完整规定近俯视、描边、材质明度层、光向、接地和语义色，并明确所有资产共用的风格修订？[Completeness, Spec §FR-005–009; ART_DIRECTION §统一语言/Palette / HEX roles]
- [ ] CHK002 缺失 Concept Images 2/3 时，参考图比较与文字替代的审批条件、原始来源及权利边界是否分别定义？[Completeness, Spec §FR-003/021; Spec §Approval and Rollout Gates G0]
- [ ] CHK003 每个首批资产是否有画布、可见身体、脚锚、透明留边和世界像素比例要求，并区分可见轮廓与碰撞/攻击范围？[Completeness, Spec §Art Consistency and Production Starting Budget; SPRITE_SPEC §Dimensions / atlas / anchors]
- [ ] CHK004 适用动画状态、最低有效帧、唯一原创格上限、镜像/复用规则和不适用理由是否均有明确要求？[Completeness, Spec §FR-014/015; SPRITE_SPEC §Animation manifest baseline]
- [ ] CHK005 UI 要求是否覆盖首批 HUD/升级、暂停 seed 披露，以及后续所有屏幕的默认、焦点、禁用、错误和待保存状态，并标明各批范围？[Completeness, Spec §FR-016–020; UI_DESIGN §State treatment for all existing screens]

## 需求清晰度 · 主观语言与量化边界

- [ ] CHK006 “cute, expressive”“memorable”“restrained”“quiet”“dramatic”等审美用语是否有正反例、评审维度和明确裁决者，而非被视为自动可测的通过条件？[Clarity, Ambiguity, Spec §FR-005/006/009/010]
- [ ] CHK007 “approximately 24×32”“about one-third”等比例是否规定允许偏差、身体/装备/头部的测量边界及 G1 冻结方法？[Clarity, Ambiguity, Spec §Art Consistency and Production Starting Budget; ART_DIRECTION §比例、像素与轮廓]
- [ ] CHK008 “partial crowd overlap”“dense combat”“less prominent”是否给出遮挡条件、代表性构图和判断依据，且不把最大性能负载直接等同于识别用画面？[Clarity, Gap, Spec §FR-008/009/013; Spec §SC-002/006]
- [ ] CHK009 可旋转 VFX 与不可旋转角色的边界、镜像语义标记校正，以及升级后非基础攻击范围的回退范围是否写得明确？[Clarity, Spec §Explicit Technical Constraints; SPRITE_SPEC §Promotions and identities]
- [ ] CHK010 制作成本是否区分原创设计数、唯一格数、复用引用、返修成本与排期估算；若仅以资产数量限额控制成本，是否明确其不构成工时承诺？[Clarity, Gap, Spec §FR-015; Spec §SC-005; Plan §Art production and reusable UI]

## 需求一致性 · 文档和批次口径

- [ ] CHK011 首批交付范围是否统一采用R1纠正的八件交付物口径，并消除 Story 1、FR-011 与 SC-001 旧列表遗漏 level-up 的歧义？[Consistency, Conflict, Spec §Planning scope addendum/Story 1/FR-011/SC-001; Plan §Summary]
- [ ] CHK012 hero attack 的历史 12 FPS 与 SPRITE_SPEC 的 15 FPS 提案是否明确区分继承值、候选值、G1 生效条件和批准后的唯一基线？[Consistency, Ambiguity, Spec §Art Consistency and Production Starting Budget—Timing; SPRITE_SPEC §Animation manifest baseline]
- [ ] CHK013 32×32 地砖、640×360 逻辑画面、960×540 场地和非整 tile 边缘的要求是否一致，且不允许为对齐素材扩大边界？[Consistency, Spec §Explicit Technical Constraints; ART_DIRECTION §Environment / Godot-native pipeline]
- [ ] CHK014 UI 的 G1 设计覆盖、切片实际替换及 G3 后续验收是否与 SC-003/004 的“每屏/每任务”口径一致，避免把 promotion 等后续项目算入切片完成？[Consistency, Ambiguity, Spec §FR-017/018/SC-003/004; Plan §Dependency-ordered implementation phases; visual-acceptance §G2]
- [ ] CHK015 默认零动态灯/阴影/全屏后处理/装饰粒子与后续可选光效的许可、预算及审批条件是否一致，且不允许删减现有攻击负载换取视觉性能？[Consistency, Spec §FR-010/024; ART_DIRECTION §Lighting / shadows / shaders]

## 验收标准质量 · 可衡量与可裁决

- [ ] CHK016 SC-002 是否明确参与者资格、提示/答案规则、每条件“8/10”的计分单位、漏答/误认处理，以及重复观看和练习影响的控制方式？[Measurability, Gap, Spec §SC-002]
- [ ] CHK017 SC-003 的五秒起止、正确答案、各任务适用屏幕/批次及无辅导规则是否足以由不同评审者得到一致判定？[Measurability, Gap, Spec §SC-003; UI_DESIGN §Level-up cards]
- [ ] CHK018 HUD ≤25% 是否明确同时压力状态、所有可见信息矩形并集、边框/换行的计入方式，并区分理论布局面积与实机测量？[Measurability, Spec §FR-016/SC-004; UI_DESIGN §Battle HUD native layout proposal]
- [ ] CHK019 文字 4.5:1、关键边界 3:1 的要求是否定义相邻色、透明叠层和实际背景的取样口径，并保留灰阶/形状与人工可读性标准？[Measurability, Gap, Spec §FR-009/019/SC-004; ART_DIRECTION §Palette / HEX roles]
- [ ] CHK020 原创性、来源、可编辑源、预算去重与有效帧标准是否具有可追溯记录要求，而非仅凭文件存在或格数达标认定合格？[Measurability, Spec §FR-021/022/SC-005; SPRITE_SPEC §Reusable production workflow]

## 场景覆盖 · 角色、环境与 UI

- [ ] CHK021 角色可读性要求是否覆盖四向移动/攻击、两敌差异、同伴/倒地、受击/死亡中断，以及零/最大腐化下的友方魔法和危险区识别？[Coverage, Spec §FR-008/009/013/014; Spec §Edge Cases]
- [ ] CHK022 环境要求是否同时规定地面/中层/稀疏前景、Y 排序交错、脚锚和危险边线遮挡限制，并要求 painted/unlit 和腐化 0/100 对照？[Coverage, Spec §FR-005/010/013; ART_DIRECTION §Environment / Godot-native pipeline]
- [ ] CHK023 UI 要求是否覆盖 boss、双同伴含倒地、救援和最大腐化的同时非模态状态，而不是分别通过就推定组合通过？[Coverage, Spec §FR-013/016/023; UI_DESIGN §Battle HUD native layout proposal]
- [ ] CHK024 六角色、同职业不同身份、六晋升轮廓的设计覆盖与后续生产边界是否分别规定，避免复用抹除身份或扩大首批制作范围？[Coverage, Spec §FR-008/011/022; SPRITE_SPEC §Promotions and identities]

## 边界、异常与恢复要求

- [ ] CHK025 长名字、大数值、长路径、十条结果及滚动/焦点要求是否明确关键内容优先级，且不允许用缩小关键字号掩盖布局问题？[Edge Case, Spec §Edge Cases/FR-019/020; UI_DESIGN §State treatment for all existing screens]
- [ ] CHK026 1371×779 黑边、整数放大、移动/翻转/旋转效果与 atlas 边缘是否具有明确的像素清晰度要求和证据类型？[Edge Case, Spec §Explicit Technical Constraints/FR-023]
- [ ] CHK027 缺资源、未批准家族、非基础攻击范围或动画中断时，需求是否定义保留程序回退与关键状态提示，且禁止延迟伤害、清理和结果？[Exception Coverage, Spec §FR-014/022; SPRITE_SPEC §Animation manifest baseline/Promotions and identities]
- [ ] CHK028 拒绝修订、回退替换与视觉基线更新是否要求保留原始源、历史证据、审批修订关系和精确回退范围？[Recovery Coverage, Spec §Story 1/FR-022/023; APPROVALS]

## 非功能要求 · Godot、性能与玩法保全

- [ ] CHK029 Godot 4.5、纯 2D、Compatibility、离线运行及不增运行依赖是否作为明确兼容边界，且 HTML 预览不被误认作原生游戏 UI？[Non-Functional, Spec §Explicit Technical Constraints; Plan §Technical Context; Preview contract §Files and current delivery level]
- [ ] CHK030 像素兼容要求是否区分最近邻/无 mipmap/无有损压缩、整数显示与连续模拟，明确不得通过视觉取整改变物理状态？[Non-Functional, Spec §Explicit Technical Constraints; Plan §Technical Context]
- [ ] CHK031 性能要求是否完整保留参考机、renderer/build、三 seed、敌人/特效/弹体/宝石负载、预热/采集时间及 p95/p99 阈值，并独立披露既有失败？[Measurability, Spec §SC-006/Assumptions; Spec §FR-024]
- [ ] CHK032 ≤100ms 显示输入/受击反馈是否定义测量起止事件、采集方式、精度与缺设备时的待验处理，而不只援引模拟 tick？[Measurability, Gap, Spec §FR-023/SC-006; Plan §Acceptance and risks]
- [ ] CHK033 玩法保全要求是否覆盖碰撞/警示几何及时间、数值、离线存档、随机流、奖励结算与 F9 隔离，并明确表现不能成为模拟权威？[Consistency, Spec §FR-001/012/014/020/022; Plan §Architecture and minimum integration surface]
- [ ] CHK034 匹配前后回归的等价标准是否区分玩法观测值与包含外观的 content hash，避免要求跨版本字节一致或弱化 replay 版本保护？[Clarity, Spec §FR-001/023/SC-007; Plan §Architecture and minimum integration surface]

## 依赖、证据与审批状态

- [ ] CHK035 G0/G1 是否要求实际样稿、参考或文字替代决定及具名 owner/revision/date/scope，明确规格澄清、计划交付和自动检查均不是美术批准？[Dependency, Spec §FR-003/004; Spec §Approval and Rollout Gates; APPROVALS]
- [ ] CHK036 G2 证据要求是否区分静态图、动作片段、source/release、三尺寸与 native，并要求相同 fixture/seed/tick/输入/相机/队伍/腐化及版本元数据？[Traceability, Spec §FR-023/SC-007]
- [ ] CHK037 视觉差异评审是否规定预期替换区域、零未审变化、关键提示/几何/UI 的禁止性差异及基线更新审批，避免整图像素相等成为美术替换标准？[Acceptance Criteria, Spec §FR-023/SC-007]
- [ ] CHK038 需求是否要求逐项区分未实现、已实现未验证、已实现并验证、部分完成与待人工验收，并分别记录未执行、失败、缺硬件和缺人群的限制？[Traceability, Spec §FR-022/023/SC-007; Plan §Acceptance and risks]
- [ ] CHK039 参考图、真实像素样稿、审批、参考机和参与者是否被列为后续交付依赖，且历史截图/离线框图不被当成新实机或 G1 完整交付？[Dependency, Spec §FR-002/003/013; Preview contract §Provenance labels and offline behavior]
- [ ] CHK040 后续 tasks 是否有明确的需求到实施/验证证据映射要求及批准前置条件，并说明现有87个未开始任务不构成直接实施授权？[Dependency, Gap, Spec §Approval and Rollout Gates G1; Plan §Project Structure/Dependency-ordered implementation phases]

## 已识别的歧义与可测性风险（R1修订后，待审批/执行）

以下是文档交叉阅读发现或尚待补足的定义，不是本清单勾选结果，也不表示所有相关要求均缺失。

| 关联条目 | 当前依据与问题 | 建议由需求评审明确 |
| --- | --- | --- |
| CHK011 | R1同步八件清单及Story1/FR-011/SC-001；历史九件为算术错误，原seven清单确为七件 | 核对八件资料包；共享Theme/seed为支持项，审批仍pending |
| CHK012 | Spec Timing 保留 attack 12 FPS；SPRITE_SPEC 提议 15 FPS 并标 G1 审批；规格允许经评审调整美术时序 | 不是已确认玩法冲突；需记录候选时序的批准及生效版本，保留 12ticks 玩法窗 |
| CHK006–008 | 有色表、比例和剪影板要求，但“可爱/戏剧性/安静/部分遮挡”仍缺统一裁决标尺；约数无显式容差 | 审美项用 owner 对指定修订的决定；量化项定义边界/容差和代表构图 |
| CHK016–017 | R1明确SC-002六项目×条件×尺寸各8/10，T013先冻结样本/答案，T030审批；SC-003仍为五秒UI任务 | 核对冻结协议及实际参与者/原始记录，不以文档定义冒充验收 |
| CHK014 | SC-003 涵盖 promotion，SC-004 涵盖所有屏幕；计划把非切片屏幕留至 G3 | 明确切片适用子集与整体验收，防止阶段性结果被汇总成全功能通过 |
| CHK010 | 有 58 格/16 地砖/6 道具和复用策略，尚不能由此推导人工成本或返修工期 | 明确“低成本”以数量上限控制，或另列估算单位、假设和重估触发条件 |
| CHK019/032 | 有对比阈值、实际底图审查和 ≤100ms 目标；尚缺统一取样/透明叠层及延迟采集精度口径 | 指定可重复的测量定义；缺测量条件保持未验证 |
| CHK039–040 | APPROVALS 全 pending；preview 合同明确完整样稿缺失；已有87个未开始任务；P01/P02/P03与G0/G1待审批 | 属于已披露的交付依赖，不是实现/测试失败，也不要求本次补做 |

## 引用索引

- **Spec / Plan**: [spec.md](../spec.md)、[plan.md](../plan.md)
- **ART_DIRECTION / SPRITE_SPEC / UI_DESIGN**: [风格](../../../docs/visual-design/ART_DIRECTION.md)、[精灵](../../../docs/visual-design/SPRITE_SPEC.md)、[界面](../../../docs/visual-design/UI_DESIGN.md)
- **Preview contract / APPROVALS**: [预览合同](../contracts/preview.md)、[审批登记](../../../docs/visual-design/APPROVALS.md)
- **治理**: [constitution](../../../.specify/memory/constitution.md) §IV/V/VI/VII；不以清单通过替代审批或玩法验收。

## Notes

- 只有评审确认需求质量满足后才勾选；澄清、纠正或尚待评审的条目保持未勾选。
- `$speckit-implement` 可读取清单状态作为门禁，不得修改本清单标记；门禁通过仍不代表 owner 的 G0/G1/G2/G3 批准。
- `checklists/requirements.md` 由 `$speckit-specify` / `$speckit-clarify` 独立维护；现有 `visual-acceptance.md` 是未来验收记录清单，两者均未被本次改写。
- 历史清单生成只新建本文件；R1另获授权同步规划文档，游戏代码/资产/场景未改，未运行Godot/图形/性能/人工测试。
