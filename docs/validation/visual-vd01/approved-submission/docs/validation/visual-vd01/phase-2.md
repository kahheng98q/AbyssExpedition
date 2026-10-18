# Phase 2 · Art direction · 2026-10-16

状态：**设计文档/数值检查已验证；G0未批准**。T007–T014完成；T015实际owner方向决定继续pending。用户授权制作阶段3待审样稿，不代表接受文字替代或方向。

五份共享设计文档明确18个语义色、2–3明度、上左光、quiet ground、纯2D/nearest/integer与零动态灯默认。角色32×48/32×48/32×32，脚锚16,40/16,40/16,24；地砖32×32。13+6+6+2+2=29概念独创格，生产上限58；地砖16/道具6/支持图标6。attack3格/15FPS=12ticks；hurt按真实截止；普通死亡3格/8FPS<24ticks；Brinejaw warning45ticks；剑cleanup>expires。数据/规格与manifest一致。

正文12px、标题16/20px、4/8/12间距；ValueBar max=0安全且不改原值。对比度只验证色对，不证明艺术/阅读速度或实际Godot混合底图。

| 色对 | 实测ratio | 阈值 |
| --- | ---: | ---: |
| Ivory / Panel | 13.245:1 | 4.5:1 |
| Mist / Panel | 9.504:1 | 4.5:1 |
| Gold / Panel | 7.985:1 | 4.5:1 |
| Ally focus / Panel | 13.095:1 | 3:1 |
| Light border / Panel | 3.811:1 | 3:1 |
| Warning / bright ground | 5.547:1 | 3:1 |
| Warning / abyss | 6.32:1 | 3:1 |

来源路径/画布/锚点/预算检查由`source/validate_package.py`执行，结果见[document-checks.json](document-checks.json)。[识别协议](recognition-protocol.json)于构图前写入并保留hash；明确正常4普通敌人vs密集14、两同伴、1boss、1剑弧、2友方星、2预警；位置/重叠/camera/答案逐项登记。此密集板不是100敌人M4 benchmark，未开展人工测试。

缺失：Concept2/3或书面替代批准、G0/G1、最终生产清稿、实机接线及人工/参考机证据。G0审阅入口见[APPROVALS](../../visual-design/APPROVALS.md)。所有正文规则仍为draft，不能据数值检查自批。
