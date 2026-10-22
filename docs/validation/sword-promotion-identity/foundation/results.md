# 003 Foundation — 2026-10-21

**Foundation已实现并验证；游戏新表现尚未实现，进入US1测试先行。**

- T005／T006：`tools/test_sword_identity.ps1 -EvidenceDirectory docs/validation/sword-promotion-identity/foundation-red-20261021-v1`取得parse有效的行为red：39项11失败；实现冻结V3白名单／12窗守卫后，green-v1为39项0失败。后续补CLI与manifest负例，实际`-CaptureDirectory .../baseline-capture-20261021-v3 -EvidenceDirectory .../foundation-green-20261021-v3`为51项0失败。各轮[原始检查](../foundation-green-20261021-v3/contract.json)保留。
- T007／T008／T011：用`tools/validate_sword_identity.ps1 -Mode Capture -ProjectDirectory builds/windows/sword-promotion-identity/baseline-20261021-v1/source -EvidenceDirectory docs/validation/sword-promotion-identity/baseline-capture-20261021-v3`采集54组完整360tick状态，退出0。[manifest](../baseline-capture-20261021-v3/manifest.json)包含三种子、Aren／Brann三职业主角／同伴、全部弓法分支、15级起始独立档、逐tick原完整状态、实际事实、原Resource配置、输入／选择／保存结果。新夹具只覆盖workspace测试副本tests，冻结玩法源码不改；Controlled不算自然九局。
- 早期v1／v2捕获保留；v3修订夹具以确定性固定操作ID启动真实App、默认空VisualSet字段兼容及预览注入时钟访问，前后比较必须使用v3一致的fixture hash，不能混用。
- 实际`tools/validate_sword_identity.ps1 -Mode Compare -BaselineDirectory .../baseline-capture-20261021-v3 -CandidateDirectory .../baseline-capture-20261021-v3 -EvidenceDirectory .../baseline-self-compare-20261021-v1`退出0：54组0差异。[完整结果](../baseline-self-compare-20261021-v1/comparison.json)。这是比较器同输入自检，尚无改前／改后游戏结论。
- T010／T012：已注册新脚本并扩展replay对四路64bit随机状态／原请求容器检查；`tools/run_validation.ps1 -OnlySuites @('replay','abilities','combat_feedback','combat_audio','integration_m2','persistence') -EvidenceDirectory docs/validation/sword-promotion-identity/foundation-check-20261021-v2`退出0，7组891断言；import／parse／content、强制DEV及参数拒绝通过。[日志](../foundation-check-20261021-v2/)。
- 冻结原版真实图形：`source/tools/run_validation.ps1 -OnlySuites @('scene_smoke') -Graphical -EvidenceDirectory <workspace>/docs/validation/sword-promotion-identity/baseline-graphics-20261021-v1`，scene_smoke149／DEV126／pacing-audio图形15／DEV图形118及原三尺寸流程通过，完整日志保留；不是003新画面或物理操作验收。
- T009诊断：新外部Release benchmark复用原压力／采样守卫，固定15级剑圣Aren／深渊Brann／弓手Lia、每600tick缺血。首轮[原始数据](../baseline-benchmark-20261021-v1/m4-101.json)实际30+120秒、12窗双斩／旋斩／长弧／正治疗均有计数，但capture_valid=false，p95=17.450／p99=24.980ms不得用于性能验收。失败保留，新增守卫诊断后另轮运行；未减少负载或改生产规则。

自然九局、真人理解／灰度判分、物理DEV和最终性能仍未验证；新游戏表现尚未实施。未知suite／seed拒绝、002 Replay同hash要求保持。无before／after_implement扩展文件。

## 守卫诊断与最终基础检查

第二轮[诊断](../baseline-benchmark-20261021-v2/m4-101.json)确认静止主角恰与2枚掉落物重合，原奖励守恒因真实拾取失败。未修改生产拾取／奖励，固定夹具全队位置偏移(0.25,0.25)，保留0拾取半径与全部负载；V5已记录此前后共同布局。第一、二轮无效样本均留档。

实际`tools/validate_sword_identity.ps1 -Mode Benchmark -ProjectDirectory builds/windows/sword-promotion-identity/baseline-20261021-v1/source -ReleaseExecutable <baseline export绝对路径>/AbyssExpedition.console.exe -EvidenceDirectory docs/validation/sword-promotion-identity/baseline-benchmark-20261021-v3`退出0：[完整摘要](../baseline-benchmark-20261021-v3/m4-101.json)、逐帧CSV和[环境采样](../baseline-benchmark-20261021-v3/environment.json)保留；30秒预热＋120主动秒、100敌＋1首领／双同伴／≥30效果／≥100弹体／500宝石／腐化100均有效，12窗所有四类真实玩法计数达标，奖励守恒通过。改前不要求尚不存在的新治疗渲染。实际5800H／GTX1650／WASAPI48000，p95=13.593ms、p99=15.618ms；无主机全背景／物理声音／人类理解通过结论，尚无改后样本，不能关闭SC-006。

`tools/test_sword_identity.ps1 -CaptureDirectory .../baseline-capture-20261021-v3 -EvidenceDirectory .../foundation-green-20261021-v4`退出0，52项（含完整真实capture manifest／全原状态字段接受）0失败。T009／T012完成；本轮基于实际通过的工具／原生／捕获检查进入US1，T002及全部人体验收继续开放。[离线文档检查](docs-check.json)为阶段同步时点，后续新增路径另做验证。
