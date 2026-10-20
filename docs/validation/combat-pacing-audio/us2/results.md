# US2 — 2026-10-19

五个Resource开局段已实现并验证：12波48基础槽、40Thrall/4Brinejaw/4Cantor，腐化额外槽全Thrall、每槽固定抽样且母体只替Thrall，7200起原主阶段和54波408基础槽保留。观察器记录真实rush开始和hostile_shot。

Red见[red](red/)：unit14失败（后续修正数组StringName比较以只比较内容）；corruption660行为失败，无装载错误。逻辑green见[logic-green](logic-green/)：unit291、integration_m1 135、integration_m4 6926、debug_panel126断言0失败。

[regression](regression/)：pacing263、unit291、integration_m1 135、replay51、integration_m2 52、integration_m4 6926、full_run9、combat_feedback9、debug_panel126断言0失败；三职业自动全程胜利。源码DEV图形118、M1三尺寸和M2图形通过。自然集成九局T032未录制；真实rush/shot45/75秒目标未验收。人工、真声音和性能保持开放。

夹具US1仅旧全Thrall，US2仅旧场边首波，Integrated使用实际配置；没有发行设置入口。协议写入fixture_mode且不匹配拒绝。完整真人运行待执行。
