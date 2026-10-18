# 逐项执行对照 · VD-01-P3

2026-10-18。本表区分执行证据与评审决定，不修改正式清单，也不替代owner审美、人群/设备验收或G2签批。原正式清单仍为0/36；[只读hash](reviewer-checklist-hashes.json)。

## 八件样稿到实机

| 项目 | 实机与批准样稿的对应 | 本轮观察/限制 |
| --- | --- | --- |
| Aren / Thrall / Brinejaw | G1原创像素及精确身份映射 | P3与P2全部原生采样一致；其他角色/晋升保留程序回退 |
| 海岸神殿 | G1六处地标/地砖/腐化图形 | 当前地面/神殿素材不变；全场重复纹理和实际可走边界按既有实现保留 |
| 剑弧 / 追踪星 | G1基础两效果；升级/敌方不误换 | 当前基础和升级回退图已查看；橙色警示仍呈实际几何，动态显示待验 |
| HUD | 金色身份、青色本局等级、短信息面板 | 实机为真实Lv/HP/XP/Coins、boss/救援；不拿样稿示例数值覆盖状态。面积24.614583%来自既有完整联合测量 |
| 升级三卡 | 金色标题、三选一、青色焦点 | 实际Resource随机选项与原生系统字形是预期；完整标题/效果保留。当前第一卡焦点可见；合成压力字形已独立测量 |
| P01/P03及动作 | 已批准边缘/镜像方案 | 已查看当前右下角英雄局部裁切、HUD避让和基础效果画面。脚锚/模拟边界不变；实际显示抖动与整体人工接受仍pending |

本轮直接查看的原图：G1 battle-hud/level-up；当前combat-c100、level-up、edge-7-1371及effects-approved。其余287×2采样用[逐像素对照](pixel-comparison.json)审计。没有把程序比对描述成逐帧人工观看，也没有把原生640×360当作真实窗口截屏。

## 正式36条的执行证据映射

| 条目 | 执行状态 | 证据 | 正式决定 |
| --- | --- | --- | --- |
| VA01 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA02 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA03 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA04 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA05 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA06 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA07 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA08 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA09 | 当前完整回归通过；发布/调试补充见主报告 | [证据](regression) | pending |
| VA10 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA11 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA12 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA13 | 原生注入已验证；自然人工会话待验 | [证据](ink-release-r2/audit.json) | pending |
| VA14 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA15 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA16 | 当前完整回归通过；发布/调试补充见主报告 | [证据](regression) | pending |
| VA17 | 原生证据已补；实际窗口/显示/人工部分待验 | [证据](pixel-comparison.json) | pending |
| VA18 | 面积及原生字形通过；窗口/人工可读性待验 | [证据](ink-release-r2/audit.json) | pending |
| VA19 | 原生证据已补；实际窗口/显示/人工部分待验 | [证据](pixel-comparison.json) | pending |
| VA20 | 未执行：没有测试者 | [证据](manual-review.md) | pending |
| VA21 | 未执行：没有测试者 | [证据](manual-review.md) | pending |
| VA22 | 性能/参考条件未通过验收 | [证据](performance.md) | pending |
| VA23 | 未验证：没有测量设备 | [证据](../latency.md) | pending |
| VA24 | 原生证据已补；实际窗口/显示/人工部分待验 | [证据](pixel-comparison.json) | pending |
| VA25 | 待owner正式决定 | [证据](manual-review.md) | pending |
| VA26 | G3未启动，维持范围限制 | [证据](manual-review.md) | pending |
| VA27 | 本轮随实现更新，离线检查另列 | [证据](../completion-r2.md) | pending |
| VA28 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA29 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA30 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA31 | 原生证据已补；实际窗口/显示/人工部分待验 | [证据](pixel-comparison.json) | pending |
| VA32 | 当前像素/事件检查通过；物理显示观感待验 | [证据](cache-invalidation-release/manifest.json) | pending |
| VA33 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA34 | 性能/参考条件未通过验收 | [证据](performance.md) | pending |
| VA35 | 已有实现/历史证据；本轮正式评审待定 | [证据](../completion-r1.md) | pending |
| VA36 | 未执行：没有测试者 | [证据](manual-review.md) | pending |

完整原文与执行状态见[JSON](review-trace.json)。正式清单按[$speckit-implement](../../../../.agents/skills/speckit-implement/SKILL.md)“do NOT modify checklist files or markers”保持只读；T084因此仍为部分完成，不能代填评审者决定。
