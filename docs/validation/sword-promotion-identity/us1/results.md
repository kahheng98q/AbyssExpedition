# 003 US1 · 剑系可感知身份 — 2026-10-21

**已实现并验证（逻辑／受控图形／同输入比较）；灰度识别率／密集画面理解／改后性能待验。** 基础单剑、剑圣双刃、深渊长刃由职业VisualSet驱动，覆盖Aren／Brann主角和同伴；death > hurt > attack > move > idle。原32px主体与主角浅金／同伴标记保留，共享纯绘制器不持有run／profile，不调用RNG或战斗服务。

真实两弧保持0°／+20°同时创建，第五次额外360°，第六次普通；长弧取原实际几何。只新增只读sword_visual到effects／followups，原请求、音频六字段与原due／damage／expires不变；Echo保留原来源／发动且不继承heal_source。伤害仍由原stage4排队、下一tick stage1结算；12tick姿态不限制真实攻击，10tick视觉不改变原cleanup。

## 实际验证

- 行为red：`run_validation -OnlySuites @('unit')`在[unit red](../us1-red-unit-20261021-v1/unit.log)307项1失败；abilities在[red](../us1-red-abilities-20261021-v1/abilities.log)378项85失败。无解析／缺文件引擎错误替代行为失败。
- Green：`tools/run_validation.ps1 -OnlySuites @('unit','abilities','combat_audio','combat_feedback','replay','integration_m2') -EvidenceDirectory .../us1-green-20261021-v1`退出0，7组1,240断言。后续[音频／开关隔离检查](../us1-audio-check-20261021-v1/)227＋DEV126通过；[高攻速补充检查](../us1-fast-check-20261021-v1/)按实际日志收口，原攻击／阶段／状态矩阵均保留。
- 真实图形：`tools/run_validation.ps1 -OnlySuites @('combat_audio') -Graphical -EvidenceDirectory docs/validation/sword-promotion-identity/us1-graphics-20261021-v2`退出0，音频227／DEV126、剑系图形542、原音频图形15／DEV图形118及原M1／M2三尺寸流程通过。三种窗口、两英雄三职业、七种状态／Echo、同伴密集场景、暂停／重开均运行，148份原图／灰度衍生图在[sword-captures](../us1-graphics-20261021-v2/sword-captures/)。图像来自640×360逻辑视口；窗口配置为1280×720／1920×1080／1371×813，不能将逻辑抓图尺寸声称为物理屏幕照片。已人工查看单剑／双刃／长刃／灰度截图；不是五人辨识通过。
- 完整54组跨版：[比较结果](../us1-compare-20261021-v4/comparison.json)0差异，固定101／202／303、18个英雄／职业／身份组合、相同完整15级初始档、360tick实际状态／事实、四RNG、原effects／followups／请求／治疗键及非VisualSet配置相等。[原始候选manifest](../us1-capture-20261021-v2/manifest.json)与[基线v4](../baseline-capture-20261021-v4/manifest.json)保留。

## 比较工具修正与证据边界

首轮[PS比较](../us1-compare-20261021-v1/comparison.json)和[Python比较](../us1-compare-20261021-v2/comparison.json)均拒绝54组，差异只在fresh隔离档的随机抽卡流／起始档hash。没有白名单排除这些字段；将夹具起始draw_rng固定为DrawRng.initial("314159")后，以同一新fixture重采改前v4／候选v2。旧v1–v3基线与候选v1不再用于后续等价结论，失败保留。

PowerShell深度状态遍历很慢，Compare改用同项目标准库Python流式worker，V3白名单／完整manifest／全部原状态字段保持；PS合同测试保留，Python额外26正负例通过，诊断值单独输出并保存原始文件。曾遇shell遗留LASTEXITCODE误判，成功入口已显式exit 0，[v4比较](../us1-compare-20261021-v4/compare.log)实际退出0，无失败降级。

US2实际回血提示与US3动态转职演示仍未实现。自然九局延期待人工，不以本次54组受控样本替代；SC-001／003／006及物理DEV继续开放。
