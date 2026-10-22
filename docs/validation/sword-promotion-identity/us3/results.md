# 003 US3 · 独立转职演示 — 2026-10-21

已实现：两分支只读配置快照、本地60Hz／360tick周期，30／90／150／210／270发动；第五次双斩旋斩，深渊下一tick按250最大HP／2%计算示例5.0。原实战绘制器复用，明确“演示 · 示例数值 · 节奏示意”。未接入真实战斗、保存、音频或RNG服务。

初始化实际Window焦点；隐藏／失焦／普通页被既有DEV overlay遮盖时冻结，回焦不补播。DEV页可在暂停树内播放；提交／取消／父clear停止并解绑。原永久选择、资格、revision、submitted与保存失败Retry语义保留，非剑系仍为静态预览。

## 已执行

- 行为red：`us3-red-abilities-20261021-v2/abilities.log`（601项2失败）、`us3-red-persistence-20261021-v1/persistence.log`（344项1失败）和[integration_m2](../us3-red-integration_m2-20261021-v1/integration_m2.log)53项1失败。早期误插函数的解析失败不算行为red。
- `tools/run_validation.ps1 -OnlySuites @('abilities','integration_m2','persistence','scene_smoke','combat_feedback','combat_audio','replay') -EvidenceDirectory docs/validation/sword-promotion-identity/us3-green-20261021-v2`退出0；8组1674断言：601／97／353／155／31／227／70／140。import、parse、content、参数拒绝通过。原生测试使用注入时钟，不是60秒真实播放证明。
- [快速图形](../us3-layout-20261021-v1/sword-graphical.log)676断言0失败；真实三窗口逻辑视口截图。已查看普通／DEV示例长弧、完整旋斩及+5.0。原音频15、DEV118及M1／M2图形通过。
- 首次green中HP标签使用不支持的格式符导致场景错误，保留失败；已修为Godot支持的格式并重跑通过。

[生产真实时钟](graphical.md)源码四组合十轮／十开关通过；[三组54样本对照](compare.md)均零差异。新Debug受控图形118／676及四组合真实时钟通过；新Release两版启动遭Windows4551阻止，实际Release拒绝探针／图形／真实播放及候选性能未验证。自然九局、五人理解／灰度、物理DEV继续待人工验收。
