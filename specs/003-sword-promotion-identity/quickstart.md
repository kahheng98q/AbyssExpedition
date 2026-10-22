# Quickstart — 003 验证指南

2026-10-21 · **US1–US3源码已实现并验证**：三身份、真实双斩／旋斩／实际恢复、隔离动态演示；源码逻辑／真实时钟／54组跨版零差异通过。新Debug图形通过、四组合真实时钟通过；新Release启动4551阻塞导出验收与候选性能，自然九局延期待真人。[US3证据](../../docs/validation/sword-promotion-identity/us3/results.md)。

## 1. 环境与隔离

在仓库根目录使用PowerShell；固定Godot 4.5，导出需匹配4.5 Windows模板及Windows Desktop preset。读取[计划](plan.md)、[数据模型](data-model.md)与[验证合同](contracts/validation.md)。每次用全新证据／构建目录；保留失败。所有夹具的APPDATA／profile与真实玩家档隔离，不用真实档解锁分支。

核对引擎或启动包含003的当前源码：

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64_console.exe' --version
& './Play Debug.cmd'
```

预期引擎`4.5.stable.official.876b29033`。正常WASD／方向键移动、自动攻击，1／2／3升级；DEV／F9仅用于隔离诊断，不用于自然开局门槛或真人盲测。

## 2. 自然九局（用户授权延期验收）

2026-10-21用户明确允许先实施，以下九局仍待真人，不再阻止T003之后；先冻结未改动基线，后续从冻结版本补录，全部协议和失败保留规则不变。

已存在入口，需要真人操作；本次未运行：

```powershell
$naturalId = 'sword-baseline-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
$naturalEvidence = Join-Path (Get-Location).Path "docs/validation/combat-pacing-audio/$naturalId"
Push-Location ./builds/windows/sword-promotion-identity/baseline-20261021-v1/source
try {
    ./tools/validate_pacing_audio.ps1 -Mode Record -FixtureMode Integrated -EvidenceDirectory $naturalEvidence
} finally { Pop-Location }
```

严格按[002协议C节](../002-combat-pacing-audio/quickstart.md)顺序完成Aren／Lia／Milo各101／202／303；每局1级、基础职业、无同伴、腐化0、新隔离正常档。真人接敌／拾取，不用自动轨迹、DEV、无敌或加速；记录工具实际升级／免费事件选择。

逐局首命中≤5、首杀≤10、首升级≤30主动秒，九条都存在且版本一致。死亡／缺失／超时保留为失败，不能补挑成功局。失败先在002范围处理，另版本完整重录；缺记录仍标待人工验收；经用户授权不再阻止003实现。五人理解／盲听、自然九对、物理DEV及完整性能环境仍独立开放。

实施前先冻结当前源码／Release／完整manifest与比较输入，优先采同输入玩法输出、剑系截图及性能。具体比较夹具须先完成，再以同一外部夹具采前后版本。图形／性能环境缺失只阻塞对应SC结论，不升级为开工硬门；可以从冻结旧版补采，不能用改后状态伪造改前记录。

## 3. 实现阶段窄测

以下suite已包含003断言，并保留原行为回归：

```powershell
$checkId = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
./tools/run_validation.ps1 -OnlySuites @('abilities','combat_feedback','combat_audio','integration_m2','persistence','replay') -EvidenceDirectory "docs/validation/sword-promotion-identity/$checkId-focused"
```

脚本包含import、parse、content、参数拒绝和强制debug_panel。音频设备故障时可另用-DummyAudio诊断，不能算听感验证。每阶段须测试其新行为及相关回归，失败先修复。

| 阶段 | 具体操作与预期 |
| --- | --- |
| US1 | 两剑系英雄分别主角／同伴，以基础／两分支观察idle／move／attack／hurt／death；无颜色仍见单／双／长刃；两弧同批，五次旋斩、第六次普通；伤害几何／计数不变 |
| US2 | 记录第4／5／6次受伤／近满血／满血、拒绝、空挥、多目标、Echo、致死、来源死亡／同伴；仅真实恢复一次提示，一位小数误差≤0.05；满血后受伤不补发 |
| US3 | 逻辑suite注入单调时钟推进10循环／10开关，保留55秒watchdog；独立真实检查观察10循环／10开关并核验静音、焦点、调速、清理与状态隔离；等级14／15×道具0／1、取消／重复确认／保存失败／Retry |

详见[战斗](contracts/combat-presentation.md)及[预览](contracts/promotion-preview.md)契约。自动测试验证数字、隔离、清理；视觉质量另做真实图形和人工。

已接线的 `tests/sword_preview_realtime_check.gd` 使用生产单调时钟，固定1920×1080，每组合独立进程：源码／新Debug各普通1×与DEV 1×／2×／4×，实际Release普通1×。内部150墙钟秒、外层显式180秒；设计周期6秒、每循环有效播放≤8秒，失焦另记，超时保留部分结果并失败。`-Graphical`执行源码真实检查，`-Graphical -Export`追加新Debug／Release外部harness；三尺寸布局仍走快速图形。接线已实现，源码四组合均完成十轮真实检查；注入时钟或固定帧率加速不能替代真实播放证据。

## 4. 完整回归与新导出

新剑系图形与真实播放探针已接入源码／Debug／Release；以下完整命令仍保留原M1–M4检查：

```powershell
$releaseId = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
./tools/run_validation.ps1 -M4 -Graphical -Export -BuildDirectory "builds/windows/sword-promotion-identity/$releaseId" -EvidenceDirectory "docs/validation/sword-promotion-identity/$releaseId-regression"
```

期望M1–M4、音频、保存、DEV全界面／暂停／F9及实际Release拒绝无新增失败。需要独立DEV导出诊断时，在正常回归后使用：

```powershell
./tools/run_debug_validation.ps1 -SkipRegression -DummyAudio -BuildDirectory "builds/windows/sword-promotion-identity/$releaseId-debug" -EvidenceDirectory "docs/validation/sword-promotion-identity/$releaseId-debug"
```

Dummy仅诊断。受控图形不等于物理键鼠；保留[人工DEV清单](../../docs/developer-debug-panel.md)。未执行／失败导出不能记pass。

## 5. 跨版本与性能（已实现入口）

`tools/validate_sword_identity.ps1`已接线Capture／Compare／Benchmark，分别要求显式ProjectDirectory、完整前后证据目录、匹配源码与Release console绝对路径；已有目录／未知参数／缺seed或hash不符拒绝，不回退旧构建。[V3／V5合同](contracts/validation.md)保持。原始数据与诊断分开，白名单只含明列视觉／版本身份。

```powershell
$swordRunId = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
./tools/validate_sword_identity.ps1 -Mode Capture -ProjectDirectory . -EvidenceDirectory "docs/validation/sword-promotion-identity/$swordRunId-candidate"
./tools/validate_sword_identity.ps1 -Mode Compare -BaselineDirectory docs/validation/sword-promotion-identity/convergence-capture-baseline-20261021-v1 -CandidateDirectory "docs/validation/sword-promotion-identity/$swordRunId-candidate" -EvidenceDirectory "docs/validation/sword-promotion-identity/$swordRunId-compare"
./tools/test_sword_identity.ps1
python -X utf8 tools/sword_identity_compare.py --self-test
```

Capture为受控15级独立档、54组360tick战斗状态＋6组非空流程状态，使用固定draw_rng初始状态；不会创建真人记录。Phase 7清单v2额外要求6组升级／事件／结算流程；需重采匹配外部fixture的改前与改后，旧v4及更早记录仅保留其历史战斗覆盖，不能混配。改前ProjectDirectory使用冻结的`builds/windows/sword-promotion-identity/baseline-20261021-v1/source`，外部夹具只覆盖临时测试副本。`-Presentation disabled`／`-PreviewAccess`只供夹具，不是玩家开关；US3访问真实动态预览，夹具注入时钟验证十循环及后续玩法零副作用；真实计时另由独立探针完成。

Benchmark实际命令见[基线结果](../../docs/validation/sword-promotion-identity/foundation/results.md)，必须传与ProjectDirectory对应的Release console绝对路径；不接受Debug／错误manifest／不足时长或负载。固定15级Aren剑圣、Brann深渊、Lia，原布局全队加(0.25,0.25)避免拾取半径0时与掉落点完全重合，保留全部奖励／总负载守卫；每600tick仅夹具把Brann设为maximum−10。

正式30主动秒预热＋120秒采样，[1800,9000)分12窗，每窗真实双斩≥5／旋斩≥1／长弧≥5／正治疗≥1；候选还须各类表现至少1实际渲染帧。当前只有匹配冻结原版的有效基线，p95=13.593ms／p99=15.618ms；候选Release两版启动4551，Benchmark严格manifest守卫拒绝，改后帧时未采，完整环境及人体验收仍开放；保留前两轮失效样本，不降低负载。

## 6. 图形与真人验收

真实图形覆盖1280×720、1920×1080、1371×813；录制普通／第五次动作、灰度、暂停／重开及双同伴／腐化100／首领预警。保留原图和灰度衍生图，禁止生成假截图。

邀请5名未接触本版者，按[spec的SC-001／003](spec.md)用同英雄15级、无同伴、同种子独立档比较：看预览、随机无职业名片段、每分支操作3主动分钟。至少4人正确说明双斩＋旋斩／长弧＋有效伤害回血，并给出玩法偏好理由。相同组再看随机10张密集截图，每张1秒；至少4人各在≥8张同时指出主角和最近预警。保留全部原话、失败、死亡、疲劳和重试意愿。

SC-003还须独立判灰度分支识别：三尺寸×两分支×普通／第五次共12段实机灰度片段，保留轮廓／动作／剑弧，移除职业名、数值等文字答案线索；每段1秒一次，随机顺序，只计首答，“不确定”计错，不提示／重播补答。相同5人中至少4人各≥10/12，且普通／第五次各≥5/6；保存素材hash、处理规则、题序和全部原答。该项与10张密集截图分开计分，两项均通过才能关闭SC-003。

无人参与或设备不可用则标待人工验收／未验证，不用截图存在、AI回答或自动通过代替。002未完成事项继续独立记账。

## 7. 交付记录

每阶段保存实际命令／结果／失败／限制，更新dashboard、overview、README、development、tasks及validation；美术更新art-direction／provenance。实际执行范围见[验收矩阵](../../docs/validation/sword-promotion-identity/acceptance.md)，不要把命令存在视为某轮通过。

## 8. 独立演示与人测试材

双击`Play Debug.cmd`→DEV／F9→原沙盒角色／转职页，即可观看两个静音示例；普通档在角色转职入口观看，仍须原等级15及1道具才能永久提交。示例标明数值／节奏，不消耗真实HP或道具；普通页被DEV覆盖冻结，DEV内页在暂停树中播放。

[源码真实播放逐轮证据](../../docs/validation/sword-promotion-identity/us3/graphical.md)已取得；新Debug已实际运行，Release4551与候选性能阻塞见[回归](../../docs/validation/sword-promotion-identity/final/regression.md)／[压力结果](../../docs/validation/sword-promotion-identity/performance/results.md)。人测试材为受控60tick帧序列，以60fps播放1秒；原图完整保留，统一移除反馈数字／HUD，灰度仅做L8转换。五人同组、首答、灰度总分及普通／第五次分组门槛均按第6节执行。


当前[离线首答页](../../docs/validation/sword-promotion-identity/human/prepared-20261021-v2/readability.html)与[私有材料清单](../../docs/validation/sword-promotion-identity/human/prepared-20261021-v2/stimuli.json)已冻结：18段彩色、12段灰度、10张密集图，3250文件hash，0份真人回答。向参与者只提供首答页，不展示答案清单；每人完成或中断都下载原答，失焦／丢帧／加载失败保留。主角／最近预警坐标为逻辑640×360，三窗口同倍率逻辑素材。生产时钟独立测试，材料60tick序列不充当真实播放计时。

复现材料（新目录，不覆盖旧证据）：

```powershell
# 源码图形夹具只收 --captures <已建目录>，不能用于自然九局
& ./tools/godot-4.5/Godot_v4.5-stable_win64_console.exe --path . --script res://tests/sword_identity_stimuli.gd -- --captures <新绝对目录>
python -X utf8 tools/build_sword_stimuli.py --capture <该捕获目录> --build-manifest docs/validation/sword-promotion-identity/final-capture-enabled-20261021-v1/manifest.json --output <新材料目录>
python -X utf8 tools/check_003_docs.py
```

上方`<...>`必须换成实际路径。材料捕获需原生窗口，外层180秒守卫保留，失败即停；该独立捕获已实际完成，未伪造玩家答案。候选Benchmark只在实际Release拒绝探针通过、manifest如实为passed且源码hash匹配后执行，不能手改状态字段冒充通过。


Phase 7新增工具守卫：`python -X utf8 tools/test_sword_lifecycle.py`、`python -X utf8 tools/test_003_task_audit.py`。流程明确从7190受控tick起，经真实拾取／升级／7200事件及7550致死请求触发原保存；不计作自然游玩。每份v2 Capture可用 `python -X utf8 tools/sword_identity_compare.py --validate <证据目录>` 只读核验，少任何必经行为即拒绝。任务文档允许合法追加，原54项描述及编号受固定清单保护；评审checklists保持只读。


## Phase 7 当前结果（覆盖上文历史4551状态）

[本轮证据](../../docs/validation/sword-promotion-identity/convergence-20261021-v1/results.md)：新`builds/windows/sword-promotion-identity/convergence-release-20261021-v1/`的Debug与实际Release均可启动，完整图形、Release41禁调试、九组合真实时钟通过。Capture必须使用清单v2（54战斗＋6流程）并重采匹配外部fixture；当前改前基线为convergence-capture-baseline-20261021-v1，三组各60零差异。候选性能采样有效但p95 16.732ms超16.67目标，T049／T057未完成；帧时瓶颈待定位，不以重跑筛选成功值。自然九局、五人理解／辨识与物理DEV仍需真人，不由自动化代替。
