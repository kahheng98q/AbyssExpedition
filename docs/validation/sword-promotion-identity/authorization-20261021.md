# 003 实施授权修订 — 2026-10-21

用户明确选择：**“将自然九局延期验收，先同步规格与任务依赖并继续实现；保留未验证状态”。**

这是对003 FR-012实施顺序的明确修订，不是自然九局通过。已同步spec、plan、research、data-model、validation合同、quickstart和tasks；不修改评审清单。当前依赖改为T001→T003冻结未改动源码／构建→T004旧行为回归→Foundation→US1→US2→US3。T002独立延期待真人，保留完整九局协议、三时限、起始条件、版本／输入／选择hash与失败留档要求；002其他未验项继续开放。

预检重新核对204个源码／资产文件与2个原录制夹具，均与preflight-20261021-v1清单一致；未找到新的有效Record组。原始源码身份仍为`fa5614aab670a76126d66d13894ff2481e00e9a85199d18277f2e0dd5a30dfd3`，后续冻结它以便补录与比较。源码变更后的记录不得冒充该改前版本。

本条替代[此前natural-gate](baseline/natural-gate.md)、[环境预检](baseline/environment.md)及旧预检报告中的“阻止T003”结论，其历史观察／缺失事实不变。[当前任务](../../../specs/003-sword-promotion-identity/tasks.md)只按实际工作勾选；不将延期项标为完成。没有`.specify/extensions.yml`，无before_implement hook。
