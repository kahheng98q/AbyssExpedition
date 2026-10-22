# US3 图形与真实时钟 — 2026-10-21

[三尺寸快速图形日志](../us3-graphics-20261021-v2/sword-graphical.log)：676断言0失败。实际窗口1280×720／1920×1080／1371×813、逻辑视口640×360；[普通页](../us3-layout-20261021-v1/sword-captures/promotion-normal-1280.png)／[DEV页](../us3-layout-20261021-v1/sword-captures/promotion-dev-1280.png)。布局注入时钟不计入以下真实时长。

实际执行：`tools/run_validation.ps1 -OnlySuites @('integration_m2','scene_smoke') -Graphical -EvidenceDirectory docs/validation/sword-promotion-identity/us3-graphics-20261021-v2`退出0。97／156／强制DEV140断言通过；音频图形15、DEV118及原M1／M2图形通过。

真实生产Time.get_ticks_usec，每组合独立进程、1920×1080，内部150秒／外层180秒，不注入、不固定FPS。真实原生Window焦点切换250ms冻结后回焦；全部保存字节／revision、游戏HP／计数／四RNG及音频事实不变，清理回调。源码结果：

| 宿主 | Engine倍率 | 连续轮数 | 每轮有效播放 | 断言 |
| --- | --- | --- | --- | --- |
| dev | 1× | 10×2分支／10开关 | 6.000052–6.012799s | 49／0失败 |
| dev | 2× | 10×2分支／10开关 | 6.000034–6.012513s | 49／0失败 |
| dev | 4× | 10×2分支／10开关 | 5.999953–6.009824s | 49／0失败 |
| normal | 1× | 10×2分支／10开关 | 6.000151–6.010285s | 47／0失败 |

[逐轮JSON与原始日志](../us3-graphics-20261021-v2/)。各组合完成后time_scale恢复1；真实十轮约60.55秒。未进行玩家理解／物理F9验收；导出新Debug／Release结果另见最终回归。

新Debug四组合亦通过，逐轮范围／原始日志见[最终回归](../final/regression.md)；实际Release普通1×受4551阻塞未验。
