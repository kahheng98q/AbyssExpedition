# US1 — 2026-10-19

近场首波已实现并验证：固定初始中心、四象限128–160候选、每次两RNG抽样、最多16次、45tick预警、存活全队96距离、激活复检、容量与run_end终结trace。关闭旧generation追加。场边/幼体/首领旧规则保留。

Red见[red](red/)，6个行为失败；green见[logic-green](logic-green/)，unit251、integration_m1 43、integration_m4 3734、combat_feedback9、debug_panel126断言均0失败。后续[regression](regression/)中pacing143、unit251、integration_m1 43、replay51、integration_m4 3734、combat_feedback9、debug_panel126均0失败；源码DEV图形118断言、M1三尺寸及M2图形通过。已查看1280×720实际[首波截图](regression/gameplay-captures/graphical-opening-0.png)，四预警可见。

自然录制/复放工具与观察器已接线；session-check的pacing143/debug_panel126断言通过。参数拒绝见[tool-negatives.log](tool-negatives.log)。没有真人操作者，T018九局自然录制未执行，SC001时限保持未验证；不使用自动路径冒充真人。后续集成必须重录完整九局，不复用旧无敌/350XP夹具。
