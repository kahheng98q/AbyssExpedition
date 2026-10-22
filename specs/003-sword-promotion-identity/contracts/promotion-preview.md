# Contract — Promotion Preview

2026-10-21 · 设计合同；当前实装与验收以[实际矩阵](../../../docs/validation/sword-promotion-identity/acceptance.md)为准。补充[001 UI](../../001-abyss-expedition-mvp/contracts/ui.md)与[保存合同](../../001-abyss-expedition-mvp/contracts/persistence.md)。

## P1 · 页面与输入

复用scenes/ui/promotion.tscn、promotion.gd及原confirmed(hero, branch, revision)／canceled信号；保留selected、submit、submitted、confirm_button、branch_previews两分支键。不新增操作键，不改变非剑系静态预览。

两剑系分支各一个自动静音画布，常驻“演示 · 示例数值 · 节奏示意”，配一句玩法说明：剑圣近身双斩／第五次旋斩；深渊长弧／第五次有效伤害恢复最大生命2%。确认仍提示永久选择、等级15、1道具、无重置、保留等级与被动。低等级／无道具可观看和选择，不能确认。

旧72×58区不足以画完整长弧，需用有界区域及整数缩放容纳全轮廓，不裁掉判定含义；正文滚动，panel≤640×360。画布mouse_filter=IGNORE，不抢键盘焦点，确认／取消及DEV/F9可达。检查1280×720、1920×1080、1371×813。

## P2 · 示例时序与来源

以60Hz本地时间推进360tick（6秒）循环；在30／90／150／210／270tick显示第1–5次发动，下一tick示例命中，360tick清理重置。第五次剑圣有完整旋斩；深渊有效示例命中后一次回流与实际示例恢复量。第六次即下一循环首次普通攻击。循环≤8秒，失焦冻结时间不计循环播放时间。

只读职业配置快照和共享绘制器；示例最大HP读分支基础max_health（当前250），开始缺10，按其heal_fraction（当前2%）裁剪后的after−before显示5.0。角色不使用真实英雄永久等级／生命，示例值有明确标签；动画节奏也不是实战频率承诺。示例不调用RunManager、AttackExecutor、DamageService、CombatAudio、SaveCoordinator、ProfileStore或玩法RNG。

## P3 · 隔离不变量

观看、选择、取消、循环、隐藏／回焦和重新开页前后，真实profile字节／revision、道具、奖励、队伍、生命、远征计数、四玩法随机流与后续随机结果一致。预览不创建音频节点、不发布真实战斗事实、不更改共享Resource。每页恰好两示例，无跨页面残留。

DEV隔离测试先让原ensure_session成功，再对沙盒writer／payload／revision取预览基线；另在建立沙盒前后与预览期间核对normal_writer的持久化字节不变。原克隆、receipt及writer切换是建立沙盒的既有行为，不算观看预览的副作用，也不能为测试而禁止。

普通转职确认才使用原提交路径：等级≥15、道具≥1、正确基础职业、未永久转职且revision有效；消费恰好1道具、一次永久选择，保留XP／等级／被动。submitted防重复；取消无消费。保存失败阻止继续，Retry提交同一pending结果，不重复扣物，不由演示重发确认。

## P4 · 生命周期与DEV

创建时初始化Window.has_focus并绑定focus_entered／focus_exited；失焦创建不能播放。可见且获焦才推进；本地单调时差独立于Engine.time_scale，DEV 1×／2×／4×不改变六秒示例。回焦重置时间基准，从冻结tick继续，不补发跳过的攻击。

普通页面被DEV覆盖时冻结其示例；DEV内promotion_host自己的可见示例仍可在ALWAYS宿主和暂停树内播放。选定挂接：App.show_promotion给普通页注入现有debug_panel.overlay引用；页面订阅visibility_changed并在挂载时读overlay.visible，作为host_occluded。保存阻塞拒绝close_panel时overlay仍可见，普通页继续冻结。DEV内页不绑定该遮罩；release无overlay时host_occluded=false。退出树断开订阅，不扫描全场景树。不能仅依赖is_visible_in_tree识别遮盖。停止示例不解除任何真实pause token，也不改变SceneTree.paused。

离页／取消／确认提交／父宿主clear时立即停止，退出树断开焦点连接、清空弧／提示，清除本地时间累计；不使用能在退出后继续发射的deferred任务。重开从新Session开始。App单例DEV、沙盒service与release拒绝保持；预览无权初始化调试面板或绕过限制。

## P5 · 必验场景

连续10完整循环、10次开关；初始失焦、反复失焦／回焦、切英雄、普通页／DEV内页、DEV遮盖、调速、关闭父宿主；真实状态零变化。等级14／15×道具0／1、取消、确认、重复确认、stale revision、保存失败／Retry；保留其他职业及原DEV全控件回归。自动检查与真实图形分别记录；FR-005–007／009／011、SC-004／005仍未验证。

计时检查分为两层：integration_m2／debug_panel的逻辑用例注入单调微秒时钟，推进同一生产状态机的10循环／10开关及焦点边界，不等待60秒、不改Engine.time_scale；默认生产时钟仍为Time.get_ticks_usec，注入入口仅供夹具设置，无玩家开关。逻辑注入不算真实播放时长证据。

新增外部 `tests/sword_preview_realtime_check.gd` 执行真实播放检查，不进入55秒的原生suite。源码与新Debug各检查普通页1×、DEV页1×／2×／4×；实际Release只检查普通页1×，每个组合独立进程，固定1920×1080，每次连续观察10完整循环、10次开关，并检查焦点／清理。设计周期6秒、实测每循环有效播放≤8秒；失焦时间独立记录且不计播放时长。单进程内部截止150墙钟秒，外层Invoke-Check显式180秒，超时必须保存已采集循环／日志并失败；其他suite的55／60秒限制不放宽。三尺寸布局与快速图形仍由原剑系图形脚本检查；真实检查通过外部自包含harness覆盖导出包排除tests的情况。不得使用注入时钟、固定帧率加速或缩短循环冒充真实播放。
