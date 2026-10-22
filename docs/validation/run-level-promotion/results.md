# 004 局内等级转职 · 验证记录

日期：2026-10-22。功能已实现，核心逻辑／受控图形／实际Debug与Release验证已通过；完整原生焦点长测及人工／性能验收未全部通过。

- 已读规则、旧规格、代码与测试；004 规格质量清单 16/16，设计及任务已建立，无分支变更、提交或联网。
- 首次直接脚本执行被 PowerShell execution policy 阻止，PATH 无 pwsh。已让现有 runner 兼容本机 Windows PowerShell 的 ProcessStartInfo，使用进程级 `-ExecutionPolicy Bypass`，未改系统策略。
- 受限执行 Godot 报 `Failed to read the root certificate store`，import 门禁失败，日志保留在 `migration-check/`。正常原生权限重跑消除了该环境错误。
- 实际命令：`powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_validation.ps1 -OnlySuites run_promotion -DummyAudio -EvidenceDirectory docs/validation/run-level-promotion/migration-check-native`。
- import、parse、content 通过；run_promotion 100 断言通过，覆盖旧 v1/v2/v3 的 rename/readback 迁移重试、原始字节保留和归属记录。强制 debug_panel 失败：旧测试仍读取已删除的永久 level；正在适配，不记作全绿。
- 人工游玩、自然 Lv15 可达性、可读性、物理鼠标/F9/Fn 与本版性能尚未验收；DummyAudio 不代表听感测试。

## 局内集成检查点

`focused-v2/`：run_promotion 128／progression 7通过；persistence失败，定位为新招募字典键StringName与String整字典比较不一致，已改为明确身份字段校验，保留原失败。

`focused-v3/`：persistence 343通过；abilities旧夹具还用存档设置分支，失败后改为真实局内转职准备。

`focused-v4/`：abilities 682／integration_m2 97通过；DEV 140项中2项旧测试在尚有升级卡时请求直接转职，已保留仲裁规则并修正夹具：先结束当前卡。页面也明确阻止不属于当前offer的提交。

完整命令 `-M4 -Graphical -Export -DummyAudio` 已执行至 `full-v1/`，因独立Fixture现在保留Resolute被动，其免疫到期伤害期望需从5改为4.5；未改战斗数值。`full-v2/`正在执行，已通过unit331／scene_smoke159／integration_m1 135／replay70；尚不宣称完整成功。完整命令使用新构建目录 `builds/windows/run-level-promotion/full-v2`，不覆盖003构建。


## 自动回归与图形补验

17组逻辑回归分批全部通过：full-v2提供13组，remaining-v3的recruitment299，remaining-v4的integration_m3 196／integration_m4 6926／debug_panel140。后续json-replay把局内回归增强为155项，并实际序列化JSON后重放选择和战斗状态；replay70和DEV140再次通过。按每组最新成功结果合计10,150断言（不是一次单命令完成）。无关招募／救援／章节规则保留。

补验保留：remaining-v3的两条旧schema3断言失败后改为schema4；remaining-v4的转职图形输入33项通过但退出资源未释放，门禁按失败处理。等待原生音频清理后，graphics-export-v5转职33／音频图形15通过；剑系旧夹具100XP不足当前RUN15升级、同伴资格抢先触发，9项失败后改为当前等级所需XP、显式延期其他分支，不更改生产规则。

graphics-export-v6转职33／音频15／剑系720图形检查通过；原SwordPreview绘制代码未改。原生真实时钟十轮与导出正在执行，未提前标绿。图形检查使用受控输入与注入XP，不代表自然游玩。

新增旧档夹具包含全部六角色、Lv30永久分支、27材料、已完成章节、十连历史／随机流、未展示招募结果和非空receipt；迁移验证这些无关数据保留。角色归属记录只含character_id，旧receipt仅作为迁移证据，不作为有效等级／分支。

**自然可达性限制**：现有seed101三角色自动通关分别RUN Lv10／11／11，未到15；保留原100×level经验曲线与敌人掉落，不能宣称自然15级已验证。需真实游玩验收其可达性和节奏，必要平衡调整应另有明确依据。人工／性能T018保持开放。


`graphics-export-v6`真实时钟源码普通页探针未通过：原生失焦后仅8轮，150秒截止，completed=false；并行的headless Godot导入可能干扰焦点，未将推测写作确定原因。失败、部分计时和unfocused_frames保留。`graphics-export-v7`已串行重启探针，禁止并行Godot验证，仍等待实际结果。

随后增加无暂停空档的交接：promotion→promotion／upgrade、upgrade→下一choice、事件／救援→promotion先获取后续token再释放前一token；pause-handoff中run_promotion157／integration_m1 135／replay70／combat_audio231／integration_m2 97／DEV140通过。新增序列化重放与交接后每组最新总数为10,152。暂停中HUD等级在offer发布前刷新，增加图形断言验证，不等待恢复战斗才显示新等级。


`graphics-export-v7`源码普通页十个真实循环已通过；DEV1×原生焦点探针失焦停在4轮、150秒截止，completed=false，15815个失焦帧。未并行运行其他Godot，因此不能把前次并行导入当作唯一原因。未强制回焦、延长时限或替代成注入时钟。`final-v8`将长原生焦点门禁移至已有源码／导出图形和Release拒绝之后，全部检查保留；先完成不依赖持续焦点的验证。


## 当前可运行产物与核心验证

最新构建：`builds/windows/run-level-promotion/final-v9/`，包含AbyssExpedition.exe／console和AbyssExpedition-debug.exe／console。固定引擎4.5.stable.official.876b29033，Windows PowerShell5.1.26100.9711；发布物及源码hash来自实际生成的pacing-build.json，汇总于[verification-index.json](verification-index.json)。用户正常档未用于测试，测试APPDATA和user://tests根均隔离。

实际命令（本轮补验）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_validation.ps1 -M4 -OnlySuites debug_panel -Graphical -Export -DummyAudio -EvidenceDirectory docs/validation/run-level-promotion/final-v9 -BuildDirectory builds/windows/run-level-promotion/final-v9
```

原完整命令`full-v2`与后续受影响补验共同提供17组、10,152断言的零失败记录，并非单一命令全部成功。final-v8的DEV图形两项期望仍假定资格不会新增队员选择，保留暂停队列的正确生产行为，修正夹具为完成／延期所有choice后才期望恢复；final-v9对应116项通过。

| 核心图形／构建检查 | 实际结果 |
| --- | --- |
| 源码转职三尺寸／暂停中HUD刷新 | 36项通过 |
| 源码音频事实图形／剑系图形 | 15／720项通过 |
| 源码DEV真实输入／跨屏 | 116项通过 |
| 源码M1／M2／M3／M4场景图形 | 全部通过；M2含六分支实战，未把旧存档分支当作开局状态 |
| 实际Release拒绝调试 | 41项通过，全部动作和直接入口拒绝，F9/DEV不初始化 |
| 导出Debug：DEV／转职／剑系 | 116／36／720项通过 |
| 导出Release：转职／剑系／M4 | 30／699项通过，M4三窗口通过 |

本表均为已执行检查；DummyAudio不验证听感。真实原生时钟组合另列，不因导出成功而标为通过。最新源码／Debug／Release的实际转职图形证明同一分支选择流程可达；不等同于自然游玩达到15级。


## 最终状态与未完成项

**代码及核心功能验证完成；完整验证命令退出1，未全绿。** `final-v9`在完成上述源码／Debug／Release核心检查和实际Release拒绝后，末尾源码普通页真实时钟探针提前退出：子进程exit0，但ObjectDB／3资源清理错误，realtime.json仍completed=false、仅6轮部分记录，未打印正常完成报告。原因未确定；不称为测试通过，不掩盖为正常退出。此前`graphics-export-v7`普通页十轮确实通过，DEV1×因失焦到期确实失败；不能以较早通过覆盖最新失败。

T016保留未勾选：剩余源码DEV2×/4×及导出Debug/Release完整真实时钟组合尚未完成，需要能持续保有原生窗口焦点、不中途退出的测试会话。保留原150/180秒watchdog和焦点暂停语义，没有强制回焦或降低检查标准。本轮停止重复同类探针，不把受控图形／注入计时当作实际长时钟结果。

T018保留未勾选：自然达到RUN Lv15、玩家操作理解、长局体验／可读性、物理鼠标F9/Fn及本版性能仍待人工／参考环境验收。自动seed101通关仍仅Lv10–11；本次遵守不随意平衡的范围，未降低门槛、提高经验或改变掉落。旧003性能失败仍有效，未重写历史证据。

新规格、计划、任务、质量清单与feature.json已建立；任务16/18完成，T016/T018开放。无分支切换、提交、联网或新增依赖。当前源码及上述新构建可运行；`Play Debug.cmd`继续启动固定Godot当前源码。快速受控体验：进入远征→F9→Reach RUN Lv15 eligibility→关闭DEV→依次选择；取消后HUD Promotion重开，重开远征恢复BASE / RUN Lv1。

最终离线文档审计：14份文件、230条本地引用、28张含alt图片、页面锚点和004激活指针均有效；质量清单16/16，任务顺序T001–T018与开放T016/T018一致。最终源码hash与实际导出manifest逐字相同，四个EXE的SHA256已记录；审计产物为`documentation-audit.json`。仅更新本轮文档／记录，不重写历史规格与证据。

## 2026-10-22 ChatGPT 专项复核

在当前未提交源码上重新执行 `tools/run_validation.ps1 -OnlySuites run_promotion -DummyAudio -EvidenceDirectory docs/validation/run-level-promotion/chatgpt-focused-20261022`；固定 Godot 4.5，进程退出 0。import、parse-runner、content 均通过；`run_promotion` 157 断言、`debug_panel` 140 断言均 0 失败、0 跳过。仅证明本次专项目标及受保护调试逻辑通过，不代替 T016 的完整原生长时钟/图形导出门禁或 T018 的人工自然 Lv15 验收；其开放状态保持不变。
