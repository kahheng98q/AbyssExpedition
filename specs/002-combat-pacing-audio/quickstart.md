# Quickstart — 002 验证指南

> 当前入口 · 2026-10-20：`builds/windows/combat-pacing-audio/phase7-release-20261020/AbyssExpedition.exe`，或双击 `Play Debug.cmd` 运行固定4.5源码。Phase 7已补快照/终结计数/性能守卫并完成新导出与真实录音；[最新证据](../../docs/validation/combat-pacing-audio/phase7-20261020/results.md)。下方10月19日命令/数字为历史，当前Benchmark请把ReleaseExecutable改为新目录的console.exe绝对路径；`-Diagnostic`仅用于非目标机诊断，不算SC007通过。自然/真人项目未代填。

> 2026-10-20收敛核查：[Phase7剩余任务](tasks.md)与[新报告](../../docs/validation/combat-pacing-audio/convergence-20261020/results.md)。当前源码回归通过，但hash已不同于下列10月19日v4构建/录音/性能；旧命令与数字保留作历史，不代表当前验收。Benchmark使用旧v4会被现有hash守卫拒绝，需先由T065核对4.7元数据并以固定4.5重新导出，T066/T074/T075补验证工具。自然九局/九对及真人项仍开放。

日期：2026-10-19。**实施中：近场/编排/暂停回放已接线并通过逻辑与受控图形。** 自然九局仍需真人执行，音频自动/实际输出已验证，真人与性能最终验收继续执行；不把旧EXE或历史日志当成本切片通过。

## Prerequisites and isolation

- 仓库根目录运行PowerShell。固定引擎 `tools/godot-4.5/Godot_v4.5-stable_win64_console.exe`，预期 `4.5.stable.official.876b29033`；导出需匹配4.5模板和现有Windows Desktop preset。
- 子进程APPDATA重定向至workspace专用目录，自动夹具ProfileStore.test_mode=true，使用独立user://tests路径。真人正常开局也用全新隔离档，每局重置初始快照，禁止写真实profiles/default或沿用上一局成长。
- 真实音频验收需要正常输出设备和可保存系统输出的录音路径；记录driver、设备、采样率、系统音量、游戏版本。设备不可用时继续逻辑验证，但SC004/007保持未验证。
- 每次使用新的 `docs/validation/combat-pacing-audio/<run-id>/` 和 `builds/windows/combat-pacing-audio/<run-id>/`；保存失败、stdout/stderr、hash与截图，不覆盖历史Q1/M4证据。

## A. Existing commands（基线历史与常规验证）

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64_console.exe' --version
./tools/run_validation.ps1 -OnlySuites @('unit','integration_m1','replay','integration_m4','combat_feedback') -DummyAudio -EvidenceDirectory docs/validation/combat-pacing-audio/baseline
```

该脚本总会执行import/parse/content、参数拒绝测试及debug_panel，包括OnlySuites模式。Dummy仅诊断无设备逻辑，不提供听感结果。实现后按变更范围重复窄测，最后运行完整源码/导出回归：

```powershell
./tools/run_validation.ps1 -M4 -Graphical -Export -EvidenceDirectory docs/validation/combat-pacing-audio/regression
./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory builds/windows/combat-pacing-audio/debug-probe -EvidenceDirectory docs/validation/combat-pacing-audio/debug-probe
```

第一条现有脚本将普通导出写入builds/windows/m4；执行前按仓库既有保留构建流程留存需保留的旧构建，本切片正式验收另导出到独立新目录。第二条仅在常规回归后做隔离DEV导出诊断；Dummy结果不算声音验收。-Graphical是受控图形，不能代替物理键鼠/真人测试。

## B. 002 validation entry points（已接线；自然验收待执行）

已注册 `pacing`、`combat_audio` 并默认完整回归，扩展fixtures/manifest/content校验且保留强制debug_panel。使用全新证据目录执行：

```powershell
./tools/run_validation.ps1 -OnlySuites @('pacing','combat_audio','combat_feedback','replay','integration_m4') -EvidenceDirectory docs/validation/combat-pacing-audio/focused
```

`tools/validate_pacing_audio.ps1`的Record/Replay/Audio/Benchmark已接线；完整自然Record/Replay仍待真人输入。Audio已取得真实回环；Benchmark要求本次导出带pacing-build.json的Release。`-FixtureMode US1/US2/Integrated`仅用于测试对照，默认Integrated。Record需真人正常移动；目录必须全新。命令合同：

| 参数/Mode | 预期行为 |
| --- | --- |
| -Mode Record -EvidenceDirectory <新目录> | 顺序运行固定9个隔离自然开局，记录真人按键/选择/暂停与真实显示/行为；不自动通过未完成局 |
| -Mode Replay -InputDirectory <已冻结记录> -EvidenceDirectory <新目录> | 核对输入/hash，逐条音频启用/禁用重放，输出9对玩法差异和时限结果 |
| -Mode Audio -EvidenceDirectory <新目录> | 三职业与负例/满载声音场景，生成事件日志和真实设备录制；无法录音直接标明阻塞 |
| -Mode Benchmark -ReleaseExecutable <新Release console.exe绝对路径> -EvidenceDirectory <新目录> | 对同一新版Release、同一fixture/seed101连续运行声音启用/禁用压力采样，真实driver，保存原始CSV/JSON及host/build hash |

所有模式用固定引擎、子进程隔离、明确失败退出码；未知参数失败，不静默回退Dummy；Record/Replay固定9样本不接受只挑成功seed。Benchmark拒绝debug_build或active debugger、错误分辨率/VSync、负载不足、没有实际播放事件的静音假对照。新脚本/模式完成前不可声称命令已可用。

## C. Freeze natural input traces — SC001/002/005

固定顺序：Aren 101/202/303，Lia 101/202/303，Milo 101/202/303。永久等级1、基础职业、单人无同伴、初始腐化0、满血、正常1x；不用无敌、开发刷怪/加经验/加速，不改敌人属性、经验或武器。每局最多推进到121主动秒，首个120秒事件选择免费leave/decline后继续；每次升级选择当前第一个合法选项，记录实际ID，不依赖屏幕位置猜测。

**录制协议**：操作者预先遵循“可见可拾取宝石优先；否则接近最近可见敌人/预警；冲刺预警横移、远程预警离开射线并继续接近”的正常走位原则，逐tick记录实际输入变化。第一轮9局全部保留并冻结hash，失败也进入结果。复验只播放已记录输入和选择，不在复验时重新寻路或挑成功路线。若修复需要重新录制，必须另立版本/目录、完整重录9局并保留旧失败组，不替换单个seed。

需要保存：

- 首个接受的对敌hit tick、首个敌人death tick、首次升级UI挂载时的主动tick；≤300/600/1800分别对应5/10/30秒。死亡/未发生记明确失败，不用null当0秒。
- 真实rush开始和首个敌方远程hostile_shot分别<2700/<4500tick；不能用enemy_spawned替代。90/100新波基础仅T、110固定B/C，存活旧敌继续行动。
- 每波计划/预警/激活/取消名额。基础48只统计腐化前；安全/容量跳过另列，不给计划计数减项。
- 不可走/占位/激活时闯入/100cap属于独立安全负例。正常开局出现的命中或升级超时仍是失败，不因难度归为“无效样本”。

音频开/关9对使用完全同一snapshot、游戏版本、输入和选择；比较wave、reservation终结、offer、decision、event及最终战斗状态，详见[data-model](data-model.md)。旧capture_movement的无敌/350XP不进入这组结果。

## D. Automated boundary and regression matrix

| 检查 | 输入/过程 | 预期 |
| --- | --- | --- |
| FR001–003 | 首波静止/移动、边界起点、满队占位、tick44/45/激活闯入 | 128–160初始半径，完整45tick，存活队员≥96；失败跳过；不搬迁补刷 |
| FR004–005 | 12波、5段、腐化0/24/25/49/50/75/99/100 | 基础48，增量全T，母体只替T且总份额规则正确；7200后旧主阶段/32400首领保留 |
| FR003容量/幼体 | 99敌+1预警、100敌、母体死亡和9分钟 | 不超过100常规名额，无积压；幼体旧规则保留 |
| FR010时间 | 30/60/90/110/120秒前/中/后manual、level、focus、debug与event叠加 | tick/stage与预警冻结、解除自己的token，无补刷；120升级先于事件且波仅一次 |
| FR007–009事实 | 三职业成功/无目标攻击、无敌/重复伤害、单次致死、范围多杀/DoT、同伴 | 只响实际事实，fatal不叠hit，同伴不冒充主角受伤；≤8 voices、升级保留 |
| FR008升级 | 真App显示、刷新、旧generation deferred、多次快速选择 | 每个实际显示新offer一次；不截断、不重复、FIFO清理 |
| FR010声音 | 暂停中手动发signal、恢复、结束、重开、禁用音频 | 拒绝新战斗声，不积压；旧播放仅恢复剩余部分；终局清理，无跨run残音 |
| FR011 | 固定9对真实模拟及随机流快照 | 音频开关不改变玩法结果 |
| FR012 | v1/v2/v3存档读取、正常/测试/DEV隔离、单人/满队、重试 | 原有保存合同保持；无新增schema；DEV单例/跨屏/暂停/Release拒绝 |

保留原 `persistence`、`abilities`、`integration_m2/m3/m4`、`full_run`、`combat_feedback`，使用完整-M4回归。已通过headless不代表Graphical/Export通过；导出阻塞明确列未执行。保护面板的[人工烟测清单](../../docs/developer-debug-panel.md)仍需执行。

## E. Real audio and human checks — SC003/004

先录三职业正常战斗和8声密集片段，再录规定负例与暂停/重开。保存未经增益归一化的原始PCM、录制环境、事件时间对照及削波检测结果。设备/录制失败不出“0削波”结论。逐次升级均应可听，hit/kill不双响，主角受伤优先，同伴较轻；静音时游戏仍可正常玩。

邀请5名未接触本版的玩家：30秒后不提示询问基本循环，两分钟后询问冲刺与远程应对，至少4人答出要求；记录原话、空档、死亡、疲劳，匿名编号P01–P05。

另盲听随机20音样，攻击/命中/击杀/升级各5；攻击题固定剑2/弓2/法1，每题记录反馈类别，攻击题另记职业判断。仅当类别及职业均正确时计为职业题正确。至少4名参与者须各自同时满足类别≥16/20、职业≥4/5且每职业至少1题正确；分别汇总两个分数及各职业正确数，不能用不同参与者凑两个门槛。测试前冻结题序、音样hash和答案表，保存原始回答；测试中隐藏标签且不反馈正确答案。不能让操作者看标签再算盲听，不从5人外推总体满意度。

## F. Release performance — SC007

使用本切片新Release和Q1同机环境：Ryzen 7 5800H、GTX1650、1920×1080、VSync off、无调试器。沿用benchmark_capture的100常规+1首领/双同伴/≥30效果/100活动弹体/500宝石/腐化100负载与奖励守恒；压力夹具的受控保活允许用于性能，不能当自然开局。

seed101，每次预热30主动秒、采集120主动秒，真实driver下音频启用/禁用各一轮；记录实际audio cue数量/声部峰值，确保启用样本真的发声，两个样本工作负载一致。保留p50/p95/p99/max、逐帧CSV、CPU/GPU/driver、build/fixture hash、实际音频设备、前台/电源/后台负载状态。p95≤16.67ms且p99≤25ms，负载有效才可判本机样本达标；不等于参考机/多seed或全部性能验收。

旧 `benchmark_quality.ps1` 强制Dummy，旧Q1数字只作历史参考；不得改文件标签当新结果。任何设备失败、负载不足、提前结束、时间样本不足都记无效/阻塞，不判性能通过。

## G. Completion evidence

每个检查点保存命令、实际结果、seed/hash、失败与未执行项；状态使用已实现并验证/已实现未验证/部分完成/未实现/待人工验收。更新dashboard、IMPLEMENTATION_OVERVIEW、README链接、development、validation和当前tasks；保留旧证据。当前SC001–007以验收矩阵分项记录；未执行的自然/真人项不勾完成，自动检查不代替全面验收。


## 2026-10-19 历史运行入口

当前Release：`builds/windows/combat-pacing-audio/acceptance-release-v4/AbyssExpedition.exe`，源码/实际Debug/Release自动证据在[final/regression-v4](../../docs/validation/combat-pacing-audio/final/regression-v4/)。追加夹具检查见[fixture-regression-v1](../../docs/validation/combat-pacing-audio/final/fixture-regression-v1/)。旧历史EXE均保留，不从旧Q1启动验证002。

```powershell
# 需真人移动，自动选实际挂载后的首合法升级/免费事件；目录必须全新
./tools/validate_pacing_audio.ps1 -Mode Record -EvidenceDirectory docs/validation/combat-pacing-audio/my-integrated-natural-v1
# 只重放冻结输入/真实选择/暂停，9条各声音开关一对，拒绝hash变化/缺样本
./tools/validate_pacing_audio.ps1 -Mode Replay -InputDirectory docs/validation/combat-pacing-audio/my-integrated-natural-v1 -EvidenceDirectory docs/validation/combat-pacing-audio/my-replay-v1 -Graphical
# WASAPI端点真实回环，保存native float32/PCM16；缺设备/静音/空录音明确失败
./tools/validate_pacing_audio.ps1 -Mode Audio -EvidenceDirectory docs/validation/combat-pacing-audio/my-audio-v1
# 本次新Release绝对console路径；真实driver，seed101，30+120主动秒，开关各一轮
./tools/validate_pacing_audio.ps1 -Mode Benchmark -ReleaseExecutable 'C:\Users\kahhe\Desktop\Project\new-game-project\builds\windows\combat-pacing-audio\acceptance-release-v4\AbyssExpedition.console.exe' -EvidenceDirectory docs/validation/combat-pacing-audio/my-performance-v1
```

`-FixtureMode US1`只保留旧全Thrall，`US2`只保留旧场边首波；默认Integrated。不同夹具manifest不能混用。当前自然9组/9对尚未执行，不将代码入口和受控fixture当其验收通过。

后续完整导出用 `run_validation.ps1 -M4 -Graphical -Export -BuildDirectory builds/windows/combat-pacing-audio/<新目录> -EvidenceDirectory docs/validation/combat-pacing-audio/<新目录>`，避免改写历史构建；BuildDirectory已存在会拒绝。性能校验当前源码、主EXE、console和fixture hash；若改源码需重新导出/录制。

盲听主持人使用[离线页](../../docs/validation/combat-pacing-audio/human/listening-prepared-v1/index.html)，保管答案表，收集真实P01–P05原始JSON。`python tools/score_listening.py --self-test`只检查判分器；真实判分需`--answers-directory/--key/--output`，不生成答案也不自动证明有真实参与者。


## 2026-10-20 Phase 7当前命令

当前构建：`builds/windows/combat-pacing-audio/phase7-release-20261020/AbyssExpedition.exe`；[执行证据与限制](../../docs/validation/combat-pacing-audio/phase7-20261020/results.md)。完整快照采用`pacing-final-v2`，生成终结后再统计；旧fixture hash不符不能硬改，必须完整重录。新录音/性能已执行，人工与全主机后台环境未收口。

```powershell
# 以下目录每次都换新；Record需要真人移动，不生成替代输入
./tools/validate_pacing_audio.ps1 -Mode Record -FixtureMode US1 -EvidenceDirectory docs/validation/combat-pacing-audio/my-us1-phase7-v1
./tools/validate_pacing_audio.ps1 -Mode Record -EvidenceDirectory docs/validation/combat-pacing-audio/my-integrated-phase7-v1
./tools/validate_pacing_audio.ps1 -Mode Replay -InputDirectory docs/validation/combat-pacing-audio/my-integrated-phase7-v1 -EvidenceDirectory docs/validation/combat-pacing-audio/my-pairs-phase7-v1
# 只读/构造比较器回归，不生成性能或人类答案
./tools/test_pacing_benchmark.ps1
```

T067–T073及旧7项继续按各自未执行部分收口；现有录音不能替代听感，构造或受控复放不能替代自然九局。Benchmark加`-Diagnostic`允许非目标硬件诊断，比较结果不能当SC007目标机通过。
