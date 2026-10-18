# UI_DESIGN · VD-01

**当前更新 · VD-01-P2**：owner已验证f187视觉参考；本批收尾仅修复长名称/标题与暂停全名详情，精灵/动画/场景/调色板未变。[当前结果与限制](../validation/visual-vd01/completion-r1.md)。下文早期pending记录按其版本保留，量化/物理显示/十人门槛仍分别开放。

> **最新实施 · 2026-10-17**：批准切片已接入原生候选，生产文件/回退/自动检查见[素材现状](ASSET_INVENTORY.md)与[最终评审包](../validation/visual-vd01/review-package.md)。下方2026-10-16未实现/pending文字保留为原设计提交状态；当前G0/G1已批，G2待验收。
> **当前状态 · 2026-10-16**：VD-01-M1的G0/G1及列明设计决定已获owner `approve`。[审批记录](APPROVALS.md)。下文pending是原提交状态；生产清稿/接线/G2未完成。
2026-10-16 · 设计提案，原生UI未实现 · [计划](../../specs/002-2d-art-direction/plan.md)

## Shared Godot strategy

一份 `data/themes/expedition_theme.tres` 管理12px正文、16/20px标题、4/8/12间距、panel/button/tooltip/progress样式、focus/hover/pressed/disabled。内建字体继续使用，暂不采购/绘制新字体。像素边框先用StyleBoxFlat，确有批准纹理再用StyleBoxTexture；不把HTML/CSS交给游戏运行。

`app_router.configure_theme` 改为引用共享Theme；`screen.gd`的局部style overrides移入主题，但保留panel/column接口、build/build_scroll、armed_at与回调。HUD位于另一CanvasLayer，须显式赋Theme，不能假定从router兄弟Control继承。非切片屏幕仅获得已批准基础主题继承，不改流程/布局；全面重排等G3。

| Reusable scene（拟scenes/ui/components/） | Godot composition | Input / behavior |
| --- | --- | --- |
| ValueBar | HBox/VBox、Label、ProgressBar | HP/XP当前/上限、语义变体；无插值延迟掩盖真实伤害；max=0安全 |
| Portrait | TextureRect + focus/status边框 | 24×24 crop、姓名tooltip；未制作身份显示明确占位，不用Aren代替Brann |
| SkillIcon | TextureRect + Label | 16×16原图、准确效果文字；缺图保留文本 |
| Cooldown | ProgressBar/遮罩 +数值Label | 只读现有ready tick；无可读语义数据则不显示，禁止新增技能/计时器；首批HUD不强加此项 |
| ChoiceCard | PanelContainer、MarginContainer、VBox、真实Button | 一个原始upgrade_id/offer_id、label/effect_preview/stacks；信号接既有confirmed |
| ActionButton | Button/theme variation | default/hover/focus/pressed/disabled；disabled说明可见，不能只换灰色 |
| Tooltip | PanelContainer + wrapped Label | hover和键盘focus可达，不抢焦点/暂停；边缘clamp；重要代价不只放tooltip |
| BossBar | ValueBar + boss name | 现有boss状态，隐藏/入场/活跃，不模拟boss生命 |
| StatusIndicator | Icon + short Label | corruption、downed、pending/saved；形状/文字与颜色同时表达 |

只在本批实际使用时实例化组件；Cooldown等仅定义接口，不建立未使用的大型组件框架。先场景和Theme复用，不重构玩法数据服务。HUD mouse_filter=IGNORE；装饰不得阻挡鼠标。

## Battle HUD native layout proposal

优先级：HP与即时危险/救援 → XP/Run Lv/时间 → 身份/Hero Lv/腐化/金币/两同伴。以下均为640×360逻辑像素，数字是布局上限，**尚未实机测量**。

| 占用区域 | Rect (x,y,w,h) | 内容 |
| --- | --- | --- |
| 英雄 | 8,8,192,40 | Aren/Hero Lv；HP当前/上限+条 |
| 跑局成长 | 208,8,184,40 | Run Lv；XP当前/threshold+条 |
| 次要计时/资源 | 400,8,232,40 | active time、coins；Abyss 0–100+条 |
| 条件boss | 192,56,256,28 | boss名/入场危险文字、HP条 |
| 条件同伴 | 8,306,200,46 | 两行姓名+HP当前/最大或DOWNED；长名可省略但focus/详情可达 |
| 条件救援 | 216,310,416,38 | 当前/30秒、失败，或earned/saves at settlement两行 |

不相交上限面积 **56,496 / 230,400 = 24.52%**，留出至少75.48%无非模态UI区域。实际检查必须取所有可见panel/文字/icon/bar/外扩border矩形的**union**，不是只算panel、不是把整个顶带/空隙算面积。若字体/换行越界或额外提示超出则本方案失败并修订，不能引用该理论值称实机通过。不得缩小关键文字低于12px解决面积超标。没有额外常驻底部帮助条；Esc/C提示纳入已有资源区域或现有暂停说明。

精确seed目前只在HUD长行。迁移时在**现有pause屏**追加只读seed与Run Lv/Hero Lv说明，G1替换清单须包含这项信息迁移；不新增页面或改暂停逻辑。Corruption summary已有C入口，保留其完整阈值/实际修正信息。若迁移接线未完成，不能先删HUD原值。

容器/anchor按640×360布局，顶/底安全边距8px；使用Container minimum sizes、wrap和布局测试而非按物理屏幕分辨率重算。1280/1920只整数放大；1371×779同2×内容加黑边。HUD不是手机响应式新平台功能；HTML阅读页可响应式，游戏仍保持现有逻辑viewport。

## Level-up cards

保留居中约490px宽Panel，三张纵向ChoiceCard（每张约64px高），标题/解释/输入提示合计不超过可用360高度；内容不足时容器可滚动且follow_focus，不能裁掉第三选项。每卡16px图标、12px效果、已选stack计数和键1/2/3；效果文本直接读Resource.effect_preview()，不能把“starting damage +10%”误成当前值乘1.1。

第一卡焦点，鼠标/方向键+Enter/1–3，保留180ms fresh-input guard和防重复确认；显示世界暂停、仅本局、无reroll/skip。选择仍发 confirmed(offer_id, upgrade_id)，由现有ChoiceCoordinator判断，不在卡片发奖励。Esc不能跳过；队列升级始终冻结世界且必须重新输入。视觉过渡不延迟输入或自动选卡。

## State treatment for all existing screens

范围列“后续”表示本轮只设计，不改运行布局；全部沿用shared states。

| Screen / scope | 视觉方案与必须保留状态 |
| --- | --- |
| Combat / slice | 上述区域；normal/boss/0–2 companions/downed、rescue active/failed/success/declined、corruption0/100、同时组合 |
| Level-up / slice | 三卡；hover/focus/pressed、不同stack/长效果；不增加取消、跳过、重抽 |
| Selection / 后续 | 角色crop+class卡；fresh/六owned、locked、seed合法/非法、preview/start、滚动可达 |
| Roster / 后续 | 共享角色行；active/0–2 companions/重复或未拥有禁用、save/cancel；永久经验/被动不丢 |
| Promotion / 后续 | 两branch并排预览；14级/无item/已转/unowned禁用原因；15级成本、永久性、保留被动、confirm/cancel |
| Guild / 后续 | 当前入口，紧凑余额+路线；fresh/全收集/章节完成；不新增main menu启动步骤 |
| Main menu / 后续legacy | 标题/共享按钮静态key art，注明当前路由走guild；不暗中启用旧菜单 |
| Recruitment / 后续 | pool→confirm→ordered reveal/history/exchange；1/10票、50/50、十条完整顺序、重复token、余额不足/全owned/空history/中断reveal |
| Rescue prompt / 后续 | offer/reward、accept/decline；Sera与repeat ticket；earned≠saved |
| Events / 后续 | 共享选择卡；商人/祭坛精确代价与收益、health/corruption headroom、unaffordable原因、free leave |
| Corruption summary / 后续 | 阈值表、准确修正、C返回；紫色仅标状态不伪装警示 |
| Pause / seed disclosure only | 当前暂停/继续/abandon二次确认；显示seed信息；只释放manual reason |
| Results / 后续 | outcome/chapter/party gains/caps、saved/pending、retry snapshot差异提示；不提前声称结算 |
| Save error/recovery / 后续 | 最高可读性实底；长路径wrap/scroll、retry同一pending、锁/新版本/损失风险、explicit confirm |
| F9 / shared styling only | 明确SANDBOX、四tab/滚动；保留profile隔离、release禁用，不加功能 |

所有交互组件需 default/hover/keyboard focus/pressed/disabled/error/pending 状态页。focus=亮青双边+指示符；disabled=无高亮+文字原因；error=图标+说明；pending=文字状态+禁止重复提交。精确成本、保存状态与禁用原因常显；tooltip不能成为唯一信息源。

关键文本≥4.5:1、关键边界≥3:1；色觉/灰阶、长名字/大数/长路径、焦点可达、三尺寸实际截图都要审。自动Contrast计算仅验证色对，不能证明阅读速度或审美。

## R1 · Edge/corner readability — P01 pending G1

24.52%仅为矩形预算。T024/T026给出四边四角、boss+双同伴+救援+腐化100样稿，标英雄脚锚/定位和邻近危险。T046/T076分别检查面积、遮挡、关键文字；T068/T075验证场地边缘。

候选局部紧凑/重排，并仅在视口边界允许上部身体裁切；脚锚/玩家定位/相关危险须可读。是否接受裁切、哪些组件移动及位置须G1冻结P01，当前pending。若要求边缘完整身体，另行审议与现有相机/画布的兼容方案；本批不授权改相机、物理根、碰撞、可走范围，不能缩关键文字或丢必要值。

## 当前源码审计 / 阶段1刷新

`scenes/ui/*.tscn`为壳，具体布局由`scripts/ui/`生成；`screen.gd`设置1px边、20/14内距、7px行距、12px按钮和180ms armed_at。`app_router.configure_theme()`运行时创建Theme并仅给screen/modal hosts；HUD是兄弟CanvasLayer且局部覆盖颜色/字号，因此不能靠只换Theme假定HUD同步。当前没有data/themes生产Theme。

`combat_hud.gd`有640×42实底顶带，HP/XP条、boss、party/rescue文字；腐化字号10、帮助/party/rescue11，小于本提案12px目标。当前Hero/Run Lv、seed混于长行，数值仍准确；本轮只记录拥挤风险，不改它。`show_menu()`实际转到guild；历史menu.png不是当前启动画面。Selection/roster/recruitment等已有ScrollContainer及disabled资格理由，必须保留。F9四页签、sandbox提示、debug feature与隔离profile限制由router/debug服务负责，不是UI装饰的职责。

已逐类审阅selection、roster、promotion、guild/legacy menu、recruitment、rescue、events、corruption、pause、results、save recovery与F9脚本的构建/状态路径；上表是全表面设计契约，并不授权对这些屏幕重排。招募精确成本为1/10票、5代币兑换、Brann/Nyra各50%；旧UI合同中“四代币不足”是不足案例，不是兑换成本。

## VD-01-M1 交互样稿 / 状态矩阵

[七状态板](mockups/vd01/ui-states.png)为共用视觉语法；[升级四状态板](mockups/vd01/level-up-states.png)包含长效果与scroll提示。截图只示意，不证明原生scroll/held-input正确。HTML顶端画板支持鼠标、键1–3/方向键/Enter；试选只更新提示，不发放奖励、不保存。

| 状态 | 边框 / 形状 | 文本 / 输入约束 |
| --- | --- | --- |
| default | 1px暗边+冷石内线 | 精确值/成本常显 |
| hover | Kingdom亮边 | 不夺走键盘焦点；保留完整效果 |
| focus | Ally双边+左侧箭头 | Tab/方向键可见；不只改色 |
| pressed | 内缩亮边 | 只发既有action；防重复确认 |
| disabled | 冷石边，无交互强调 | 常显Need item/缺票/等级等原因；不只变灰 |
| error | 红边+错误标签 | 长路径wrap/scroll；Retry同一pending，风险常显 |
| pending | 紫边+Saving文字 | 禁重复提交；不可写成Saved |

ValueBar输入约束：**max=0安全；仅clamp条形比例，不改显示/源数值；不扣币/随机/保存**。HUD矩形见[hud-layout.json](mockups/vd01/hud-layout.json)，8张边缘板提案上部cluster向下88px、底部条件条向上58px；位置只按明示P01候选展示，不是新运行规则。必须在实机确认不遮脚锚/危险，不能以面积达标替代。
