# Contract — Validation and Evidence

2026-10-21 · 验证设计；执行结果见[实际矩阵](../../../docs/validation/sword-promotion-identity/acceptance.md)，设计文字不代表通过。

## V0 · 自然九局（2026-10-21用户授权延期验收）

用户明确授权自然九局延期验收、先同步规格与依赖并实施；不代填通过，不再阻塞T003之后工作。先冻结当前未改动基线，后续在该版本完整补录，以下协议和判定不变。

严格采用[002自然录制协议](../../002-combat-pacing-audio/quickstart.md)：当前未改动构建、Integrated、Aren／Lia／Milo各101／202／303，每局全新隔离正常档，永久1级、基础职业、无同伴、腐化0、满血、1×。真人移动接敌与拾取；不用DEV、无敌、加速或自动生成轨迹。按原工具记录实际升级／免费事件选择。

完整九局各自首个接受命中≤300tick、首杀≤600tick、首次升级UI≤1800tick；缺失／死亡／超时为不满足。全部失败留档；不得补挑成功seed，若修复则另版本完整重录。允许复用经核对与当前源码hash及协议一致的完整记录。002工具同时检查的其他项目单独报告，开工判定按本规格三个时限，不额外要求自然九对或五人盲听先完成。

## V1 · 证据清单与版本冻结

每轮全新docs/validation/sword-promotion-identity/<run-id>/及独立构建目录。记录引擎版本／二进制hash、源码文件清单与hash、Release与console hash、fixture hash、协议、种子／初始档／输入／选择、命令、退出码、原始输出、失败及限制。不能把Git分支名当完整构建身份。

修改玩法表现前冻结改前源码副本／构建及比较输入，优先采集状态／图形／性能。自然九局经用户授权延期验收，不再是开工硬门槛；图形／性能环境不可用只阻塞相应SC结论，允许之后在冻结旧版补采，不能使用改后状态代填基线。比较夹具在冻结改前源码后先写入测试层，必须在改前与改后使用同一外部夹具版本；夹具不能补丁游戏规则。若夹具变化，重新建立匹配的前后证据并保留旧失败。

## V2 · 自动矩阵

| 覆盖 | 场景／预期 | 入口 |
| --- | --- | --- |
| FR001–003、SC005 | Aren／Brann、基础／两分支、主角／同伴；所有状态优先级；实际弧几何不变 | abilities、combat_feedback；图形另验 |
| FR004、SC002 | 第4／5／6次、空挥、拒绝、满血／近满血、致死、多目标、Echo、来源死亡、同伴；0错误／重复，显示误差≤0.05 | abilities、combat_feedback |
| FR005–007、SC004 | 10循环／10开关，≤8秒、静音、profile／生命／计数／RNG无变化；资格、保存失败、重复提交 | integration_m2、abilities、persistence |
| FR008–009、SC005 | 三种子前后完整玩法状态；表现开／关、预览访问／未访问；暂停／升级／事件／结果／重开 | replay、pacing、integration_m2／m4、full_run |
| FR010–011、SC005 | 音频六字段合同，其他职业，全界面DEV单例／沙盒／F9／暂停、Release全部拒绝 | combat_audio、debug_panel、Graphical／Export |

扩展现有注册suite及tests/script_manifest.gd内容清单，不把测试文件名当suite。run_validation无论OnlySuites与否都保留debug_panel。新剑系图形检查需接入-Graphical，并覆盖源码、新Debug和实际Release，不能仅靠旧m2静态截图。

US3计时分层遵循promotion-preview P5：原生suite用注入单调时钟验证状态机；`tests/sword_identity_graphical_check.gd`负责三尺寸快速图形；新 `tests/sword_preview_realtime_check.gd`独立进行1920×1080真实10循环／10开关。源码／Debug各有普通1×及DEV 1×／2×／4×，Release只有普通1×，每组合独立进程；内部150秒、外层显式180秒，保留原suite的55秒watchdog及其他Invoke-Check默认60秒。`-Graphical`执行源码真实检查，`-Graphical -Export`再执行新Debug／Release组合；外部自包含harness不依赖导出包内tests。超时保留部分日志／循环数据并判失败，注入时钟结果不能代替真实时长。

## V3 · 跨版本比较入口（已实现）

tools/validate_sword_identity.ps1已实现三种模式：

| Mode | 输入／输出约定 |
| --- | --- |
| Capture | 显式ProjectDirectory与新的EvidenceDirectory；固定4.5、匹配manifest、隔离APPDATA；运行外部sword_identity_session夹具，输出原始逐tick状态／事实及manifest |
| Compare | BaselineDirectory、CandidateDirectory、新EvidenceDirectory；只读验证两份完整manifest、fixture／协议／输入相等，再输出逐字段玩法差异；还比较候选表现开／关、预览访问／未访问 |
| Benchmark | ProjectDirectory、该版本匹配的ReleaseExecutable绝对路径、新EvidenceDirectory；沿Q1压力和真实驱动采样，拒绝debug、hash不符、负载／时长不足 |

固定101／202／303；同英雄15级、同等级被动与升级、独立档分别比较基础剑士／剑圣／深渊剑士，另覆盖两剑系英雄的同伴身份和既有弓／法及其分支。比较原replay完整玩法快照并补实际攻击／伤害／治疗时序，四随机流、队伍／位置／HP／冷却／计数、XP／升级、波次／事件／腐化及终结／保存结果都不能省略。受控输入不算自然试玩。

允许前后source hash不同，但每份记录必须匹配各自源码／构建；fixture、输入、快照与玩法投影版本须一致。负例：任一HP／计数／RNG／选择篡改、缺seed、错误manifest、改变fixture均失败。未知参数、既有证据目录、提前退出不得静默降级。旧002工具hash守卫保持。

**固定投影`sword-gameplay-v1`**：现有pacing_observer会序列化effects的脚本变量、整个followups字典，ReplayTrace.start.catalog又来自内容摘要；合法视觉Resource变化必然影响原始记录。因此保留原始记录，跨版工具仅将以下明确字段移至独立diagnostics，不要求它们跨版相等：manifest的source／build／catalog身份及会话存储ID、trace.start.catalog、effects中既有color与新增sword_visual、followups中新增sword_visual。新增弧元数据统一放在`sword_visual`命名字段内，不散落为任意可忽略字段。每份版本／catalog身份仍须核对自身manifest，原engine、simulation、seed、party、输入编码等保持比较。

不能排除整个effects／followups容器：原direction／reach／angle／expires、原弧数量与顺序，以及followup的due／origin／direction／reach／angle／damage／knockback／burn／frost均继续逐字段相等；原damage_requests及activation_heals完整比较。新增治疗表现事实／缓存另放presentation诊断区，真实HP差及原治疗次数必须相等。另逐字段核对职业Resource的全部非VisualSet玩法配置，避免catalog差异掩盖数值改动；非剑系VisualSet也须保持一致。

投影白名单在采前后基线之前冻结，未知字段变化直接失败，不能自动丢弃。必须有“仅上述颜色／视觉元数据／版本身份改变应通过”和“同一effects或followups中的任一几何／expires／due／damage变化应失败”的测试；baseline无sword_visual与candidate有该字段只在诊断区有别。原002同版本Replay兼容规则不变。

### V3 补充 · Phase 7 非空流程覆盖

Capture清单升级为`sword-identity-captures-v2`：原`samples`仍严格54组×360tick，另须`lifecycle_samples`恰好6组（Aren剑圣／深渊×101／202／303），比较总计60组。旧v1与旧fixture证据保留，不能混配或用于证明新增覆盖；重新在冻结基线的测试副本及候选采同字节外部夹具。`sword-gameplay-v1`投影白名单不扩大。

流程夹具明确从7190tick受控状态开始：永久15级、无同伴、固定draw_rng；英雄缺10HP，脚下放原场景100XP宝石及近场保活敌人。通过真实模拟阶段拾取、出升级牌并确认第一个选项，正常推进到7200事件槽，经真实event_offers RNG生成、选择免费leave／decline；在7550注入一次明确记录的致死伤害请求，走原DamageService→defeat→App.show_results→真实SaveCoordinator结算。时间起点、宝石和致死输入只是外部测试条件，不冒充自然120秒、自然九局或平衡验收，不改生产规则。

完整逐步状态／四RNG、升级牌／确认、事件offer／choice、终局summary和持久化payload均保留比较；summary的完整trace只在顶层存一份，避免重复数据。测试Writer只按revision提供确定的operation_id，真实锁、校验和、原子发布不替换。真实磁盘envelope经ProfileValidator.decode核验后，比较revision、receipt、到账payload及round_trip_payload；墙钟saved_at_utc不是玩法字段，不把它写入跨版比较记录，也不排除原payload字段。每样本必须真正升级、生成并选择事件、在7550结束、恰好结算一次／revision+1、40永久XP到账及磁盘回读相等；非空覆盖／提前终结／遗漏保存均拒绝。开启／关闭表现和访问／未访问预览均跑相同流程，旧54组空字段相等仅证明其原战斗范围。

## V4 · 真人与图形

SC001：同一英雄、永久15级、无同伴、同种子起始条件的独立分支档。5名未接触改版者先看预览，随机看无职业名的普通／第五次片段，再各玩两分支3主动分钟；至少4人正确说出两分支普通／第五次作用并给出玩法理由和偏好。试玩无DEV；保存原话、失败、死亡、疲劳、重试意愿。

SC003：1280×720、1920×1080、1371×813真实战斗及灰度记录；10张密集截图覆盖双同伴、腐化100与首领预警，冻结hash和随机题序，不显示答案。SC001同组至少4人各在≥8/10的一秒展示中同时指出主角和最近敌方预警，同距均认可。保存原图与灰度衍生图、全部回答及失败样本，不能生成假截图。

SC003另有独立灰度分支识别：同英雄15级／无同伴／同seed起始条件，三尺寸×两分支×普通／第五次共12段真实片段，各播放1秒一次，保留轮廓／动作／剑弧，统一移除职业名、治疗数值等文字答案线索；在stimuli.json记录原始片段、灰度处理／裁切规则、hash、尺寸、分支、攻击类型、标准答案及每人随机顺序，测试界面隐藏答案。SC001同组5人只给首答，可选“不确定”且计错；至少4人各≥10/12，并在普通／第五次各≥5/6。完整保存12条原始回答和两组计分，不纠错、提示或重播补答；灰度与密集预警两项分别达标才关闭SC003。

无人参与则待人工验收；自动截图证明画面存在，不能证明识别率或好玩。保留[DEV人工清单](../../../docs/developer-debug-panel.md)，源码／受控按键不代替物理键鼠检查。

## V5 · 性能

改前／后同机Release、同fixture／seed101／输入／画面设置／音频条件，各30主动秒预热＋120秒采样；100常规敌人＋1首领、双同伴、≥30效果、≥100活动弹体、500宝石、腐化100。负载要真实包含双刃／旋斩／长弧／治疗表现，不能只有无关基础职业；在baseline与candidate均使用匹配的剑系压力配置。

冻结压力队伍为15级Aren剑圣主角、Brann深渊剑士与Lia基础弓手双同伴（相同等级／被动／无临时升级），并冻结可保持两剑系接敌的布局／输入。仅Benchmark夹具在每个600主动tick窗口开始、推进该tick模拟前，把存活Brann的HP设置为其maximum−10，记录该外部缺血输入；预热亦按相同节奏运行。可保留原夹具防死亡条件，但不能仅初始缺血一次。该输入不是伤害或治疗事实，不计分；不改生产伤害／治疗／冷却／计数规则，不强制发动、调用heal或直接发布提示，Capture比较模式不得注入该压力输入。

实施时冻结布局：全队在原初始位置加(0.25,0.25)，主角拾取半径0，前两只常规敌人分别位于主角／Brann的初始位置+(24,0)并使用压力保活HP；其余沿原100敌／首领／效果／弹体／宝石布局。偏移避免整数格掉落恰与静止主角重合，不修改生产拾取规则或降低奖励守恒／负载守卫；前后必须使用同一外部夹具hash。早期未偏移样本误拾取两枚掉落物而无效，保留原记录。

正式样本为tick区间[1800,9000)，划分12个[1800+600k,1800+600(k+1))窗口，k=0…11。每窗分别守卫真实剑圣双斩发动≥5（第五次可计入）、旋斩≥1、深渊长弧发动≥5、第五次接受命中产生的正HP差治疗≥1；记录source／activation／tick／请求及实际HP差，缺血输入必须单列。两版均从真实玩法观测这些计数，改前不要求尚不存在的新治疗提示。候选每窗还须在真实渲染帧中观察到双轨／旋斩／长弧／治疗反馈各≥1次，不能仅统计创建节点或信号。原有总负载逐帧守卫照常生效；任何窗口缺项、仅预热发生、满血零治疗或使用占位弧充数，capture_valid=false，即使帧时达标也失败。保存逐窗计数、事件与渲染帧关联；新增负例覆盖每类缺失／仅预热／全程满血／缺窗口，前后使用同一夹具版本。

优先沿用tests/performance/benchmark_capture.gd的负载守卫与采样方法，以显式剑系fixture补足分支而不改变总负载；不得降低密度达标。新工具在对应源码根核验旧／新Release各自manifest，不用当前源码跳过hash守卫跑旧EXE。

保留逐帧CSV、p50／p95／p99／max、实际负载计数、CPU／GPU／driver、1920×1080／VSync off、音频设备与播放、焦点／电源／后台观测范围。改后p95≤16.67ms且p99≤25ms才满足本机帧时目标；无调试器。Q1参考5800H／GTX1650；设备不同或后台观测不足明确限制，不能关闭历史参考机、多seed或002完整环境项目。

## V6 · 文档与状态

每个实施阶段同步dashboard、overview、README链接、development、任务清单和实际证据。状态使用已实现并验证／已实现未验证／部分完成／未实现／待人工验收。自动、受控图形、自然操作、人工理解和性能分别记账；旧截图／旧日志不升级成003通过结果。
