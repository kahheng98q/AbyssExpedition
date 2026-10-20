# 首波预警遮挡修复 — 2026-10-19

固定seed303的第3槽中心落在屏幕(379.48,42.88)，与计时HUD重叠；原圈线有一部分被HUD遮住。原几何检查见[日志](opening-visibility.log)。不是位置安全失败，禁止通过换seed或移动候选来规避。

现只将首波既有Telegraph实例放到远征拥有的OpeningWarnings CanvasLayer（layer2，follow_viewport_enabled=true），维持世界坐标，HUD在1、弹窗20、DEV100。落点、45tick、安全距离、RNG消耗与预警生命周期不变；无重复预警或新模拟tick。[Godot4.5 CanvasLayer定义](https://docs.godotengine.org/en/4.5/classes/class_canvaslayer.html#class-canvaslayer-property-follow-viewport-enabled)支持独立渲染层跟随世界变换。

[red](visibility-red/)有1个行为断言失败；[green](visibility-green/)pacing282/音频168/DEV126原生断言通过，DEV118/音频focus15及三尺寸图形通过。已实际查看[seed303截图](visibility-green/gameplay-captures/graphical-opening-2.png)，计时HUD前方的预警圈/十字完整可见。三尺寸对应seed101/202/303，并增加截图中心橙色像素检查；最终完整检查见后续regression目录。自然九局时限仍未执行。

新场景/源码hash已改变，旧capture-v1性能与旧Release保留，当前版本重新导出并重测性能/真实录音，不冒用旧样本。
