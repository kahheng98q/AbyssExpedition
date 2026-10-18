# Phase 3 · Visual mockups · VD-01-M1 · 2026-10-16

状态：**设计样稿已交付并执行离线检查；待owner审批；非Godot实现/验收**。T016–T029设计交付；T030评审包已组装，实际决定pending，T015同样不自批。用户授权阶段1–3待审样稿制作及在reviewer清单未勾选时继续，清单保持原样。

## 实际交付

- 八件切片的原创像素概念：Battle HUD、Level-up（三个实际Resource效果/stack）、Aren、Thrall、Brinejaw、神殿、剑弧、Milo已有星。
- 正常/密集/腐化100、painted/unlit/灰阶、组合boss+双同伴含倒地+rescue active/success/failed/declined、large-values样稿、四边四角脚锚/P01候选。
- 角色5状态及原向/镜像/四向动作、两效果各2格、中断恢复/迟到事件示意。13个WebM由浏览器WebCodecs以显式时间戳编码；战斗样本精确2秒，不是游戏录像。
- 6份OpenRaster母稿（可编辑图层），透明sprite PNG及原创本地绘制源；角色13+6+6、效果2+2，去重29格；16概念地砖、6概念道具和6个支持图标。
- 51张native/2×/3×/1371×779及edge倍率板；1371板是绘制的黑边提案（45/46、29/30），不能称真实窗口证据。
- [离线交互预览](../../visual-design/preview.html)：切画板/历史REAL、战况/救援、灰阶、倍率、腐化/unlit；三卡鼠标/键盘试选、焦点/新输入保护；仅页面提示，无保存/收益。

## 执行验证与证据

实际命令（项目根；Python/Node使用桌面提供的本地依赖运行时）：

```text
python docs/visual-design/mockups/vd01/source/audit_sources.py
python docs/visual-design/mockups/vd01/source/build_mockups.py
node docs/visual-design/mockups/vd01/source/record_motion.cjs
node docs/visual-design/mockups/vd01/source/check_browser.cjs
python docs/visual-design/mockups/vd01/source/validate_package.py
```

[document-checks.json](document-checks.json)是本地路径/尺寸/锚点/帧去重/ORA/倍率板/大数字/面积/色对/保护hash的逐项实际结果；[browser-checks.json](browser-checks.json)是Chrome `file://`、1440×1000和390×844、reduced-motion的实际交互/媒体解码结果；[motion-recording.json](motion-recording.json)列13片段实际尺寸/帧数/时长。页面运行无HTTP依赖。

本轮作者实际查看battle/level/lineup/stress与desktop/mobile、attack/late采样图片；原始图形交付和页面图有独立来源标签。首次浏览器检查把正常取消的视频预读取计为错误，保留[browser-initial.json](browser-initial.json)；改为记录cancellations后，逐视频实际seek/decode，不忽略真实加载或脚本错误。首次文件检查发现Brinejaw idle/move0重复，已重绘移动腿姿、重做对应图与视频后再校验，不以重复图凑帧。

## 范围与未通过项

这不是正式生产美术：像素概念动作/道具仍需清稿、组合复核、正式exports/TileSet/SpriteFrames/Theme。现有素材只能复用历史截图与原程序语义；没有虚构可用生产图。Lia/Milo与boss保留fallback形状示意，不制作额外角色。

G1的**素材可审阅性**已具备，不等于G1批准。Concept2/3/文字替代、G0、P01边缘、P02容量、P03镜像、识别fixture、计划/tasks和实际G1决定仍pending。清单各项按[visual-acceptance](../../../specs/002-2d-art-direction/checklists/visual-acceptance.md)逐类审阅：G0/G1的owner/参考项未满足；运行自动接线、G2真实图形/十人/延迟/性能项未执行；G3不在范围。保持reviewer复选框只读。

234受保护运行文件及5张历史截图hash不变；新增/更新文件只在docs和本功能文档。未执行任何Godot import/headless/graphical/export/benchmark，没有新FPS、显示延迟或人工识别通过结果。历史p95超预算及M1–M4人工gate不变。停在Gate A，**T031–T087未开始**。
