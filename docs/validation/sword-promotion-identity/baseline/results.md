# 003 改前基线 — 2026-10-21

T003：当前未改动源码已冻结到`builds/windows/sword-promotion-identity/baseline-20261021-v1/source/`；逐文件复核204文件无变化，构建／引擎／catalog身份见[manifest.json](manifest.json)。固定白名单复制scripts/data/scenes/assets/tests、根配置及本地工具／引擎／模板，不递归复制builds、docs、.git或runtime。自然输入尚缺，15级受控输入／选择待T007／T011补齐，不伪装为已经采集。

从冻结根实际执行`tools/run_validation.ps1 -M4 -Export -BuildDirectory <baseline绝对目录>/export -EvidenceDirectory <仓库绝对目录>/docs/validation/sword-promotion-identity/baseline-export-20261021-v1`，退出0。16组9,232原生断言、import／parse／content、未知suite／seed拒绝、Release导出／console实际调试拒绝与Debug导出均通过。[原始输出](../baseline-export-20261021-v1/)。未运行-Graphical，导出成功不等于图形或人类验收。

T004：在当前根实际执行`./tools/run_validation.ps1 -OnlySuites @('abilities','combat_feedback','combat_audio','integration_m2','persistence','replay') -EvidenceDirectory docs/validation/sword-promotion-identity/baseline-check-20261021-v1`，退出0。7组879断言（含强制debug_panel 126）、import／parse／content和参数拒绝通过；未使用Dummy。[原始日志](../baseline-check-20261021-v1/)。没有真人听感／自然操作／性能结论。

T002已获[用户明确授权延期验收](../authorization-20261021.md)，仍未勾选。改前源码保留供补录／图形／性能与同夹具比较，不修改其玩法文件；后续外部测试层变化单独记hash。
