# 003 T002 · 自然九局开工门槛

> **当前授权修订 · 2026-10-21**：用户明确选择自然九局延期验收、先同步规格与依赖并实施；T002仍未验证／未勾选，但不再阻止T003之后工作。先冻结原版，后续补录。[授权记录](../authorization-20261021.md)。下文为该授权之前的预检观察；缺失与未执行事实仍有效，原阻塞结论已被本条替代。

2026-10-21 · **待人工验收，未满足。** 本轮未启动Record，未生成替代输入，未填写成绩。T002未勾选，T003及之后未执行。

依据：[规格FR-012](../../../../specs/003-sword-promotion-identity/spec.md)、[验证合同V0](../../../../specs/003-sword-promotion-identity/contracts/validation.md)、[002自然协议C节](../../../../specs/002-combat-pacing-audio/quickstart.md)。[任务依赖](../../../../specs/003-sword-promotion-identity/tasks.md)明确：“T002未满足不得进入代码／美术／比较工具实施”。本轮yes只确认越过需求质量清单，没有提供九局记录或修改FR-012。

## 查找结果

递归检查`docs/validation/combat-pacing-audio/`只找到3份Record manifest，均为`us3/tool-contract/`工具负例；完整路径／hash见[原始记录](../preflight-20261021-v1/environment.json)。没有可复用的、协议与当前hash一致的完整九局。[002验收矩阵](../../combat-pacing-audio/acceptance.md)也仍列未录制。

| 目录 | 实际内容 | 不可用原因 |
| --- | --- | --- |
| hash-mismatch | 9项，build_hash=intentionally-wrong | 故意错误身份，工具负例 |
| missing-group | 8项，旧build_hash | 缺局、版本不符 |
| missing-sample | 9项，旧build_hash | 缺样本负例、版本不符 |

当前有效输入／选择／起始档hash与各局结果均缺失。缺失不是一次实测失败，也不是0秒成绩。

| 英雄／基础职业 | seed | 首接受命中≤300tick | 首杀≤600tick | 首升级UI≤1800tick | 状态 |
| --- | --- | --- | --- | --- | --- |
| Aren／swordsman | 101 | 未记录 | 未记录 | 未记录 | 未执行 |
| Aren／swordsman | 202 | 未记录 | 未记录 | 未记录 | 未执行 |
| Aren／swordsman | 303 | 未记录 | 未记录 | 未记录 | 未执行 |
| Lia／archer | 101 | 未记录 | 未记录 | 未记录 | 未执行 |
| Lia／archer | 202 | 未记录 | 未记录 | 未记录 | 未执行 |
| Lia／archer | 303 | 未记录 | 未记录 | 未记录 | 未执行 |
| Milo／mage | 101 | 未记录 | 未记录 | 未记录 | 未执行 |
| Milo／mage | 202 | 未记录 | 未记录 | 未记录 | 未执行 |
| Milo／mage | 303 | 未记录 | 未记录 | 未记录 | 未执行 |

## 真人录制入口

在仓库根目录运行以下**现有**入口，本轮未执行。工具依次开启9局、逐局独立APPDATA／正常初始档，自动选实际显示后的首合法升级／免费事件；真人用WASD／方向键移动接敌并拾取，按002协议优先宝石并避开预警。每局最多121主动秒，不在首次升级后提前退出；不要用Play Debug.cmd普通档替代录制。

```powershell
$naturalId = 'sword-baseline-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')
./tools/validate_pacing_audio.ps1 -Mode Record -FixtureMode Integrated -EvidenceDirectory "docs/validation/combat-pacing-audio/$naturalId"
```

每局永久1级、基础职业、无同伴、腐化0、满血、1×；不用DEV／无敌／加速／自动输入。保留全部9份原始JSON、日志、输入／选择及manifest。九局各自首命中／首杀／首升级须≤5／10／30主动秒；缺失、死亡、超时均未满足，不能补挑成功seed。修复须在002范围处理并另版完整重录，保留原失败。

录制后核验[当前源码与夹具hash](environment.md)、所有样本hash、起始条件／输入／选择及三个时限，再更新本页与T002。工具还报告rush／shot等002结果，须单独保留；开工判定按V0，不追加五人理解／盲听、自然九对、物理DEV或完整性能环境条件。
