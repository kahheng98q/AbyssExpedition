# 003 US2 · 实际恢复反馈 — 2026-10-21

**已实现并验证（逻辑／受控图形／54组跨版零差异）。** 在原DamageService治疗调用前后读HP差；原heal签名、治疗／消费键／顺序保留，仅接受正有限实际恢复且原命中实际扣血>0时发只读branch_heal_applied。致死命中可触发，满血仍消费原键；多目标／Echo／来源已死不增加恢复机会。原音频事实／触发不变。

CombatFeedback独立最多3个36主动tick记录，每来源最新成功替换旧值，不累加；同伴跟随当前恢复者，四舍五入一位，小正数可显示+0.0，误差≤0.05＋浮点epsilon。拒绝旧generation、非正／非有限、重复／乱序事实；暂停事实丢弃不补播，存活提示停龄。死亡／离场、终局同步清理、退出断开；原48伤害反馈预算保留。共用纯绘制／数字格式已供后续UI演示复用。

## 实际测试

- Red：[abilities](../us2-red-abilities-20261021-v1/abilities.log)487项1失败、[combat_feedback](../us2-red-combat_feedback-20261021-v1/combat_feedback.log)10项1失败；缺新行为，不是解析／缺类型错误。
- Green及图形：`tools/run_validation.ps1 -OnlySuites @('abilities','combat_feedback','combat_audio','integration_m2','replay') -Graphical -EvidenceDirectory docs/validation/sword-promotion-identity/us2-graphics-20261021-v1`退出0；6组1,096断言（abilities590／feedback31／audio227／integration_m2 52／replay70／强制DEV126）。两英雄主角／同伴、4／5／6次、多目标、近满血／满血、满血消费后受伤、接受致死、拒绝、无目标、来源死亡、Echo、旧generation和synthetic零实际扣血目标均覆盖；零损失stub只验证不发成功事实，未改变旧heal路径。
- 扩展真实图形：`tools/run_validation.ps1 -OnlySuites @('combat_feedback') -Graphical -EvidenceDirectory docs/validation/sword-promotion-identity/us2-graphics-20261021-v2`退出0；反馈31／DEV126、剑系图形640、原音频图形15／DEV图形118及原M1／M2三尺寸通过。[真实图像](../us2-graphics-20261021-v2/sword-captures/)覆盖主角／同伴10／1.25／0.001／0缺血、实际恢复／跟随、升级／事件暂停、终局／重开。已查看真实+1.3（1.25四舍五入）、同伴+6.4、小正数+0.0截图。原图为逻辑视口抓取，窗口配置三尺寸，不声称物理屏幕照片或人类识别率。
- `tools/validate_sword_identity.ps1 -Mode Capture -ProjectDirectory . -EvidenceDirectory docs/validation/sword-promotion-identity/us2-capture-20261021-v1`退出0；再以[基线v4](../baseline-capture-20261021-v4/manifest.json)和[当前候选](../us2-capture-20261021-v1/manifest.json)Compare退出0：54组原完整玩法状态／请求／activation_heals／实际HP／计数／四RNG0差异。[比较](../us2-compare-20261021-v1/comparison.json)及独立视觉诊断保留，未删玩法字段。

US3动态转职演示仍未实现；自然九局延期、五人理解／灰度判分、物理DEV与改后性能仍待验。当前新表现通过Play Debug.cmd运行源码；旧002构建保持历史原样。
