# Game Polish 收敛核查 — 2026-10-20

> 后续[Phase 7实施](../phase7-20261020/results.md)已完成T065/T066/T074/T075并取得新构建/录音/性能证据；下文保留核查时的发现和旧hash，不代表修复后的当前状态。自然/人工及完整环境项仍开放。

**结果：`tasks_appended`，尚未收敛；核心功能部分完成验收。** 活动指针 `.specify/feature.json` 和 prerequisite JSON 均指向 `specs/002-combat-pacing-audio`。完整任务已经生成，现有57项实施记录及阶段日志证明 implement 已执行。本轮仅核查、追加任务和更新文档，没有修改应用源码、Resources、场景或 spec/plan。

## 范围与结论

核对12 FR、7 SC、13验收场景、8条Edge Cases、14项计划约束、8项宪法原则和全部T001–T064（不依赖勾选状态）。11项发现全部为`partial`：HIGH 7、MEDIUM 4；missing / contradicts / unrequested均0。没有发现明确缺失的玩法模块、已确认的宪法MUST违规或范围外新增功能；发现验证工具缺口及构建元数据/证据漂移，不能据此宣称无回归或全部验收通过。

| ID → 任务 | 级别 | 来源 | 源码/证据与剩余工作 |
| --- | --- | --- | --- |
| F1 → T065 | HIGH | plan引擎约束；T001/T062；FR012 | `project.godot:13,21`出现3D兼容设置和4.7 feature，执行工具仍锁定4.5。[当前摘要](build-integrity.json)不同于昨日Release/录音/性能；实际Benchmark前置检查[拒绝旧构建](stale-release-probe.log)。核实元数据意图，保留旧构建并重新导出/检查受影响证据。此为元数据与证据漂移，未据此断言4.5运行失败。 |
| F2 → T066 | HIGH | FR011/SC005；T015/T048 | `tests/fixtures/pacing_observer.gd:58–87`最终快照含HP/位置/冷却/状态/奖励/四RNG，但未包含SpawnDirector预留/序号/首领状态、`run.boss_hits`及warning判定字段等。对遗漏字段的差异当前不会被该比较器发现；补齐快照和逐字段负例。不是已观测到音频改变玩法。 |
| F3 → T067 | HIGH | SC001/002；US1/AC1–3、US2/AC1–5；T018/T032 | US1及Integrated自然九局目录/manifest尚无执行证据；现有旧场边零输入和无敌/注入XP夹具不能证明自然5/10/30秒及45/75秒目标。两组完整记录仍需真实操作者。 |
| F4 → T068 | HIGH | FR011/SC005；T052 | 没有冻结自然输入的9对输出。受控Replay通过只覆盖既有夹具和选定状态字段，不能替代本项。 |
| F5 → T069 | HIGH | FR007/009、SC004、US3/AC1–5；T053 | [旧真实录音](../us3-audio-v4/)与事件负例有证据；每次升级可听、主角优先、同伴轻重、残音听感尚无逐段人工结果，且旧录音hash不匹配当前源码。 |
| F6 → T070 | HIGH | SC003；T059 | [玩法理解记录](../human/gameplay.md)仍为0/5；需五人无提示原话与空档/死亡/疲劳观察。 |
| F7 → T071 | HIGH | SC004；T060 | [盲听材料](../human/listening.md)已冻结，真实回答0/5；需按类别及职业联合门槛判分。 |
| F8 → T072 | MEDIUM | FR012/SC006；T061 | [物理烟测](../human/debug-smoke.md)未执行。受控InputEvent的DEV/F9/跨屏/暂停检查通过；不能代填物理28动作和隔离检查。 |
| F9 → T073 | MEDIUM | SC007；T058 | [历史目标机样本](../performance/results.md)达标，但全程前后台状态未独立观察，且当前源码hash已不同。需在新Release补全环境观察/实际对照，不关闭历史参考机/多seed验收。 |
| F10 → T074 | MEDIUM | plan生成生命周期；T014/T017 | `pacing_session.gd:175–184`先取observer/terminal report，再terminate并只替换trace；`pacing_observer.gd:89–98`的counts因此不会包含后来追加的run_end取消。预警中提前结束时存在计数失真路径；补终结后重算与负例。本轮为源码路径核查，未运行新增故障注入测试。 |
| F11 → T075 | MEDIUM | plan性能约束；T057；SC007 | `validate_pacing_audio.ps1:96–99`两轮一致性仅比较kills和主动时长；fixture的`same_machine_target`只写入summary，没有纳入该判定，也不比较两轮设备/采样率。已有每轮负载/奖励守恒检查有效；仍需补目标机/环境一致性守卫及拒绝测试。 |

## 覆盖索引

| 意图 | 检查的当前实现与测试 | 结论边界 |
| --- | --- | --- |
| FR001–003/006；US1/AC1–3 | PlayerController/AttackExecutor、FieldDefinition/coast_field、SpawnDirector、RunManager；content/waves/pacing/graphical | 四近场候选、45tick/96距离/16尝试/100cap、激活复检/跳过/后续场边接线；自动逻辑/图形通过，自然时限待验。 |
| FR004–005；US2/AC1–5 | WaveSchedule/coast_waves、CorruptionService、Brinejaw/hostile_shot观察点；waves/corruption/choice_pause/m4_chapter/party/full_run | 12波48基础槽、额外Thrall后腐化替换、旧存活敌/120秒事件/后段/首领保持；自然实际遭遇时限另待验。 |
| FR007–009；US3/AC1–4 | 本地7 WAV/provenance、CombatAudioDefinition/buses、AttackExecutor/DamageService、CombatAudio/VoiceAllocator/AppRouter；audio_content/audio_facts/combat_audio | 模式事实、接受/拒绝/致死互斥、8声池/优先级/合并/升级FIFO自动检查通过；音色识别与密集听感待人工，录音只作对应旧版本样本。 |
| FR010；US2/AC4、US3/AC5 | PauseCoordinator、AppRouter focus token、CombatAudio bind/shutdown、ChoiceCoordinator；choice_pause/m2_app/audio/pacing graphics | 所有权/冻结/清理/旧generation受控检查通过；物理操作仍开放。 |
| FR011/SC005 | ReplayTrace、pacing_session/observer、test_replay、会话工具 | 既有成对夹具通过；完整快照、提前终结计数及自然9对缺口见F2/F4/F10。 |
| FR012/SC006 | ProfileStore/SaveCoordinator、App-owned debug场景/action service、Play Debug.cmd、InputMap；persistence/debug_panel/graphical | 本轮源码回归通过；没有新存档schema。实际Release拒绝/Debug导出仅有昨日证据，本轮未导出且当前hash不同。 |
| SC001–004/007及T018/032/052/053/058–061 | 验收矩阵、human、录音/性能原始JSON/CSV、当前hash与工具守卫 | 自动、安全、真实输出、自然输入、盲听、环境/性能、物理烟测分别记账，未执行不勾选。 |

14项计划决策：PD01固定4.5/匹配模板；PD02离线/无新增依赖；PD03无存档字段；PD04配置/事实/呈现职责；PD05首波候选；PD06固定组成/腐化；PD07预警生命周期/trace；PD08事实schema；PD09八播放器/有界合并；PD10升级去重/FIFO；PD11暂停/失焦/清理；PD12版本/hash/自然录制复放；PD13像素/既有DEV保存约束；PD14新Release真实性能。PD01/07/12/14存在上述缺口，其他在所查范围未发现新差距。

宪法I–VIII均检查：核心优先、职责分离、原创来源、测试及如实报告、既有像素表现、性能/种子约束、离线范围、分阶段证据。未把未验证的体验/性能目标当成宪法违规事实，也未据自动测试关闭人工目标。

## 本轮实际验证

```powershell
python .specify/scripts/python/check_prerequisites.py --json --require-spec --require-tasks --include-tasks
./tools/run_validation.ps1 -M4 -Graphical -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/convergence-20261020/regression
```

- prerequisite仅运行一次；识别002，spec/plan/tasks齐备。执行前后未发现`.specify/extensions.yml`，没有前/后converge hooks。
- 固定`4.5.stable.official.876b29033`：import/parse/content通过，52根Resources、27场景、116脚本；[回归日志](regression/)16组共9,178原生断言，0失败、0跳过；未知suite/非法seed按预期拒绝。
- 三尺寸M1–M4源码受控图形通过；[音频/focus图形](regression/pacing-audio-graphical.log)15断言、[DEV图形](regression/debug-graphical.log)118断言通过。已目视本轮seed303四预警和升级界面DEV截图；这是受控截图观察，不是自然试玩/物理鼠标操作。
- 单独调用现有Benchmark入口搭配旧v4构建，得到预期的source/release/fixture hash拒绝；没有启动新的性能采样，见[拒绝日志](stale-release-probe.log)。Release/console文件本身仍匹配旧manifest；源码不匹配，未推断具体漂移起因。
- 本轮未执行Export、真实音频录制、真人自然九局、九对自然复放、5人理解/盲听、物理DEV、完整性能采样；历史结果保留并限定到其构建。

![本轮seed303四个近场预警，DEV仍可见](regression/gameplay-captures/graphical-opening-2.png)

## 任务与文档交接

在[tasks.md](../../../../specs/002-combat-pacing-audio/tasks.md)末尾追加Phase 7的T065–T075，全部未勾选；原始64任务的字节前缀保持不变，spec/plan与源码hash校验见[audit-baseline.json](audit-baseline.json)。原7项未完成仍开放；追加项引用同一剩余验收，不要求重复采集已满足且版本一致的证据。总75项：57勾选、18未勾选；不是进度或验收通过率。

离线文档审计实际检查33份文件、328个本地引用和21个图片alt，断链/缺alt/远程运行资源均0；100个冻结盲听刺激hash匹配、真实回答文件0。概览全文件369个汉字。原任务字节前缀、spec/plan及受保护源码hash检查通过；没有重新进行浏览器响应式视觉验收。复用现有检查器的只读解析器，未调用会改写10月19日报告的main入口。

下一步运行`$speckit-implement`处理Phase 7；先补工具/构建证据，再执行自然会话/受影响设备测试；真实人员项目继续开放。无需例行人工批准。只读评审清单没有代勾。

[离线图鉴](../../../game-development-dashboard.html) · [实现概览](../../../IMPLEMENTATION_OVERVIEW.md) · [验收矩阵](../acceptance.md) · [离线链接/追加约束检查](docs-check.json)
