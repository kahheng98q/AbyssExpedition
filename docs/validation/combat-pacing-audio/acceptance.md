# 002 验收证据矩阵

2026-10-20。**整体：部分完成；Phase 7的4项修复已实现并验证，人工/自然与完整环境验收开放。** [最新实施证据](phase7-20261020/results.md)：T065/T066/T074/T075已完成；T067–T073及原7项未执行部分保持未勾。评审清单只读。

**当前证据**：[源码16组9,232断言与新导出](phase7-20261020/regression/)通过，实际Debug DEV118及Release拒绝41通过；[真实录音](phase7-20261020/audio/loopback.json)8声部/检测削波0；[本机性能](phase7-20261020/performance/comparison.json)样本达标。[完整性核查](phase7-20261020/build-integrity.json)：当前源码、新Release、录音/性能hash一致（`fa5614aab670a76126d66d13894ff2481e00e9a85199d18277f2e0dd5a30dfd3`）。[环境范围限制](phase7-20261020/environment-review.json)使T073仍开放。原10月19日与收敛核查记录保留为历史，不自动沿用其完整性声明。

范围锁：只改首波位置、前120秒编排和呈现音效。伤害、XP门槛/奖励、敌人属性/行为、操作、profile schema v3与四玩法RNG所有权保留；无新外部依赖/后端。

| 要求 | 当前状态 | 证据与限制 |
| --- | --- | --- |
| FR001 | 已实现并验证 | 既有移动/自动攻击/选择；[当前完整回归](phase7-20261020/regression/)与三职业受控自动胜利 |
| FR002/FR003 | 已实现并验证 | 初始中心128–160、四预警、45tick、全队96、16尝试、100含预警；[US1](us1/results.md)与真实截图 |
| FR004/FR005 | 已实现并验证 | 12波48基础槽/40T4B4C、额外Thrall、母体阈值、后段/首领；[US2](us2/results.md) |
| FR006 | 已实现并验证（自动） | 无额外开局XP或数值改动；首次自然闭环时限另待SC001 |
| FR007 | 部分完成 | 7原创PCM及三职业真实输出已验；职业辨识待盲听 |
| FR008 | 已实现并验证 | 所有分支事实、接受/拒绝/致死/DoT/多杀、UI挂载去重/FIFO；[US3](us3/results.md) |
| FR009 | 部分完成 | 8声上限/抢占/同伴增益/合并自动检查通过；新真实录音无检测削波，关键短句/优先听感待T069人工 |
| FR010 | 已实现并验证（自动） | token/focus/暂停/清理/旧generation；受控图形与实际Debug通过，物理操作待验 |
| FR011 | 部分完成 | T066已补完整快照及单字段差异，T074已补终结计数；受控复放58断言通过，自然9对待T068 |
| FR012 | 已实现并验证（自动） | 当前v1/v2/v3/隔离/结算/DEV源码回归及新Debug/Release验证通过；物理烟测待T072 |
| SC001 | 待人工验收 | T018独立组、T032集成组未录制；不以旧无敌/350XP夹具代替5/10/30秒九局 |
| SC002 | 部分完成 | 编排/安全已验；旧场边固定零输入75秒夹具实际rush<45s/shot<75s；集成真人九局待验 |
| SC003 | 待人工验收 | 0/5真实新玩家；[试玩记录状态](human/gameplay.md) |
| SC004 | 部分完成 | [新WASAPI原始回环](phase7-20261020/audio/loopback.json)与负例通过；[冻结盲听题序](human/listening.md)音样hash保持一致，0/5真实回答，T069人工试听未执行 |
| SC005 | 部分完成 | 完整快照/音频开关及音色变体受控复放、边界暂停通过；自然冻结9对未执行 |
| SC006 | 部分完成 | 当前源码与新实际Debug/Release受控检查通过；[物理烟测](human/debug-smoke.md)待T072 |
| SC007 | 部分完成 | [新Release本机样本](phase7-20261020/results.md)开启p95 15.172ms/p99 19.647ms，max76.035ms；两轮逐帧focus/电源记录完成，可见进程采样不能覆盖全主机后台负载，T073及历史参考机/多seed gate开放 |

## 隔离与证据

回归APPDATA=tools/runtime-appdata且ProfileStore.test_mode=true；真人Record独立进程APPDATA/正常初始档，Replay用test_mode。DEV继续原单例沙盒。CIM设备枚举早期被拒绝；后续Godot与WASAPI报告了实际设备，不将枚举失败当设备不可用或音频通过。

[基线](baseline/results.md) · [基础层](foundation/results.md) · [US1](us1/results.md) · [US2](us2/results.md) · [US3](us3/results.md) · [最终检查](final/results.md)。所有失败/旧构建保留；截图路径修复后恢复历史PNG。自动验证不等于好玩、可听或真人接受。dashboard/overview/README、development、tasks与本矩阵同步，离线资源检查另留证据。
