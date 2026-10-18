# VD-01-P1 · 可玩视觉候选 / G2待审

2026-10-17 · 仅批准八件及支持范围；不扩展G3，不替换已接受视觉基线。

候选 SHA256 `f187bd763fe92b69069722432c4534178c32206be6cf76a59ba9fe8fe7e95d42`。实际嵌入游戏EXE SHA256 `c6d626b275117e8f5ec8c476ed6cc8574792a8b53bd3dab55927d8e565d98bfe`。[文件索引](candidate-files.json) · [原G1提交](approved-submission/docs/visual-design/mockups/vd01/package.json)（hash3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49不变）。

## 打开与查看

双击 `builds/windows/m4/AbyssExpedition.exe`，公会→Expedition→未晋升Aren。WASD/方向键走位，自动攻击；1/2/3或方向键+Enter选升级；Esc暂停查看seed，C看腐化。9:00首领。其他角色、晋升和首领仍是完整程序外观。已有存档若已晋升，可直接查看离线实机对照，不需修改正式档案。

[离线概念+REAL预览](../../visual-design/preview.html) · [18组实机对照/两秒采样/灰阶/倍率](../../visual-design/runtime-gallery.html) · [实际捕获索引](after/capture-manifest.json)。原生640×360视口，三种请求窗口；没有把视口图说成物理窗口截图。两秒动作是控制场景按tick采样，不是自然游玩录像或显示延迟测量。

## 已实现并自动验证

- Aren基础剑士、Thrall、Brinejaw、神殿、剑弧/基础追踪星、HUD和三卡升级；29独创格、16地砖槽、6道具、6个可编辑ORA。精确映射/完整回退，[素材来源/缺口](../../visual-design/ASSET_INVENTORY.md) · [交付检查](asset-acceptance.md)。
- [完整回归＋最终定向复验](final-regression.md)：12组当前覆盖5,275断言；debug69另列，合计5,344；零失败/跳过。源码/发布图形及F9隔离/禁用另[有记录](final-debug-release.md)。首轮固定路径截图保存错误未抹去，独立目录复验通过。
- [旧/新实际EXE120tick逐项对照](comparison/gameplay-r1/comparison.json)一致，战斗/AI/成长/转职/数值/保存代码保持边界。[22个旧文件修改](comparison/protected-source-changes.json)均为表现/接线/测试/导出范围；[原函数检查](comparison/unchanged-functions.json)及[像素diff](comparison.md)独立保存。
- HUD全部可见Control联合面积最大24.61%，脚锚在8个边缘/角落均不落入HUD矩形；[测量与限制](hud-acceptance.json)。普通捕获未观察到文字裁切；[补充UI边界复核](ui-boundary.md)已测当前目录、合成大数/长效果；合成长名称/标题仍有遮挡或裁切，独立glyph像素边界待测。原概念24.52%仅是六面板面积。
- [原生输入/队列](ui-interactions.md)、[像素/事件](pixel-motion.md)、[环境/边缘](environment-review.md)及[离线预览30项](offline-browser-checks.json)、[看板4项](dashboard-browser-checks.json)通过各自已执行范围；0网络请求。

- [UI边界复核](ui-boundary.md)：源码51/发布51项观测，当前六种HUD名称及12种升级的字体覆盖/面板/横向布局检查通过；大数精确、长效果可滚动。两项合成长名称/标题限制保留。生产候选未变，102项观测不增加功能断言总数。

## 未通过 / 待人工验收

[性能](performance.md)：完整测量已保存；预算结果见下表，参考机验收仍未完成。 旧版和已完成候选采样均有预算失败；本机不是参考机。不能把有效采样或原版超标当作放宽门槛。

[显示延迟](latency.md)无设备测量；[十人辨识/五秒UI](recognition-results.md)0参与者，CSV只有表头。物理窗口黑边/像素抖动、完整死亡/暂停/倍速实录、合成长名称/标题已测且受限；大数/长效果样本已测通过各自范围。逐字形像素边界、tooltip边缘、长存档路径及完整自然操作会话未验收。M1–M4历史人工和性能门槛仍开放。

## 需要owner评审的具体画面

1. 六个代表地标对齐G1中央视口；全场潮纹/重复实例密度/枝纹按960×540移植，源像素未变。
2. P01已批准的上身裁切/面板避让在实机边角是否仍清楚定位；低亮紫符号与友方星弹能否辨认。自动面积检查不替代这个判断。
3. 三角色/两特效/原生字形与系统字体的成品观感是否接受。G2不能提前通过未测的人类/硬件条件；可记录视觉反馈而不授予新基线或G3扩批。

## 审阅清单

| checklist | checked | status |
| --- | --- | --- |
| requirements.md | 16/16 | reviewer-owned; unchanged |
| requirements.zh-CN.md | 16/16 | reviewer-owned; unchanged |
| visual-acceptance.md | 0/36 | reviewer-owned; unchanged |
| visual-art-quality.md | 0/40 | reviewer-owned; unchanged |

按[$speckit-implement](../../../.agents/skills/speckit-implement/SKILL.md)的“do NOT modify checklist files or markers”，reviewer清单保持只读；执行证据在本包单列，不把测试通过写成owner签批。用户已授权在未勾选清单下继续当前范围，不重复询问。

G2 reviewer/date/decision/new-baseline字段均pending。当前停止于可审阅候选；不继续其它Godot角色/玩法或G3批次。
