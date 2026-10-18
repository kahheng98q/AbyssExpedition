# Phase 1 · Visual audit · 2026-10-16

状态：**已实现并验证（仅源码/文件审计）**。T001–T006；不构成游戏图形或性能测试。

- prerequisite实际执行：`python .specify/scripts/python/check_prerequisites.py --json --require-tasks --include-tasks`，返回`specs/002-2d-art-direction`。
- requirements两份各16/16；visual-art-quality为0/40、visual-acceptance为0/36。用户回复`yes`允许继续限定阶段1–3，reviewer清单保持原样。
- `.specify/extensions.yml`不存在，无before/after hooks。Git检查成功；现有ignore已覆盖Godot缓存、引擎、builds、runtime、logs及Python缓存。未增加依赖、配置或运行工具；Node/Pillow仅用现有本机文档运行时。
- 只读核查：actor/melee/projectile/telegraph、CoastField、expedition场景、VisualSet内嵌Resource、全部UI类别构建、router/Screen/debug隔离与玩法UI合同。具体来源/风险映射见[审计](../../../specs/002-2d-art-direction/visual-audit.md)和[UI审计](../../visual-design/UI_DESIGN.md)。
- 实际assets只有4份Markdown；没有PNG、tiles、动画源；`data/visuals/`不存在。六英雄/九职业/六普通敌人身份与已有boss都是定义/程序表现，不能算生产动画。
- 建立[audit-baseline.json](audit-baseline.json)：234受保护文件SHA256、5张真实历史截图SHA256、引擎pin/640×360/1×/960×540、三精确选择器、历史benchmark引用。当前实际Git存在，但不靠diff推断文件未改。
- 本轮目视查看历史M4 boss/双预警原图；其余4张历史图片保留原规格审计观察并只核查文件/hash，不声称本轮重新运行或新拍摄。历史截图/原preview完整保留。

审计发现优先级：P0身份映射/判定几何/警示遮挡/权威事件起点；P1小字号与Theme不一致/魔法敌我；P2来源误标。六项均有具体fallback与验证入口。已同步中文审计。其他阵容和屏幕生产明确排除。

没有执行Godot import、headless、graphical、export、benchmark或人工游玩；此阶段无运行时改动，执行文件审计与后续离线文档检查即可。原M1–M4人工/硬件/性能gate不变。
