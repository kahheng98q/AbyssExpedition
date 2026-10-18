# Offline visual preview delivery contract

## Files and current delivery level

| Required path | 本轮内容 | 未来完整G1/G2内容 |
| --- | --- | --- |
| docs/visual-design/ART_DIRECTION.md | VD-01风格/HEX/光照/层级提案 | G0/G1审定修订与对应图 |
| docs/visual-design/ASSET_INVENTORY.md | 路径审计/缺口/复用/预算 | 实际作者/源稿/exports/hashes/批准/接线 |
| docs/visual-design/SPRITE_SPEC.md | 尺寸/锚点/动画/工作流 | 每asset最终manifest与有效帧证据 |
| docs/visual-design/UI_DESIGN.md | 原生Theme/组件/两屏布局与全屏状态设计 | 原生实现后的实机矩形/焦点/状态证据 |
| docs/visual-design/preview.html | 离线规划入口、历史真实图、布局框图与缺图占位 | 已批准像素mockup、动画条和独立G2实机画廊 |

本轮HTML不制作角色原画或完整G1样稿，不将缺图占位称为已交付角色外观。原画制作属于D1后续阶段。HTML**不是原生Godot UI替代品**。

## Required future boards

1. Battle HUD：exact640×360 native，normal/dense、boss/双同伴含倒地/rescue active-success-failed、最大腐化的同时组合，标注占用rect union≤25%。
2. Level-up：三个准确Resource效果卡、focus/hover/pressed、长文、键1–3/Enter/fresh-input；画面说明是提案，不可真的结算。
3. Character/enemy：Aren、Thrall、Brinejaw剪影与上色、canvas vs body vs anchor，四向移动/攻击演示和最小有效帧strip；魔法独立caster展示。
4. Corrupted shrine：海岸/神殿0/100腐化、painted/unlit、地面/中层/前景拆解；原可走边界不变。
5. 2×/3×整数展示及1371×779 letterbox、灰阶/色觉独立符号review。正常/密集2秒clip用于识别，不能用静态图推断时序。

## Provenance labels and offline behavior

每张图就近标 **REAL / 历史项目实机**、**PROPOSED / 未批准样稿** 或 **MISSING / 生产资产缺失**，附源路径、revision、实际日期和用途；不得把现有截图裁剪重绘后称新实机。G2加入真实source/release图时另标build/fixture/size，并保持原图文件。

页面只用本地HTML/CSS/JS/图片；无CDN、远程字体、fetch、服务器依赖。系统字体、alt、keyboard focus、可折叠细节、reduced-motion、窄屏水平滚动画板；原始像素板不分数缩小，缩略图必须标示仅浏览。读者能离线比较来源/提案/缺口，不需要HTML模拟Godot交互。

G1完整性检查要求上述所有board/strip真实存在且关联批准记录。当前只有框图/缺图，**不得通过G1完整性检查**。G2实机截图必须来自实际图形运行；自动文件检查不证明画质。

R1：首批8件。G1包须含P01四边四角HUD/脚锚/危险样稿、P03原向/镜像对照、版本化识别fixture/答案及P02额外负载提案/决定位置。Pending不算批准；HTML框图不替代缺失样稿。
