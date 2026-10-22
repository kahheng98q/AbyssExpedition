# US3／最终玩法对照 — 2026-10-21

三次Compare均退出0，每次完整54组、0 divergent；固定101／202／303，Aren／Brann主角及同伴、三个剑系职业、弓／法六分支，完整360tick状态、四RNG、profile、原请求／activation_heals、队列／效果几何和职业玩法Resource逐字段比较。仅固定V3列出的视觉／版本字段单独移入诊断，未知字段保留。

| 对照 | 实际结果 |
| --- | --- |
| [冻结基线v4](../baseline-capture-20261021-v4/manifest.json) → [当前开启](../final-capture-enabled-20261021-v1/manifest.json) | [54组0差异](../final-compare-baseline-20261021-v1/comparison.json) |
| 当前开启 → [关闭表现](../final-capture-disabled-20261021-v1/manifest.json) | [54组0差异](../final-compare-toggle-20261021-v1/comparison.json) |
| 当前开启未访问 → [访问预览](../final-capture-preview-20261021-v1/manifest.json) | [54组0差异](../final-compare-preview-20261021-v1/comparison.json) |

实际入口：`tools/validate_sword_identity.ps1 -Mode Capture -ProjectDirectory . -EvidenceDirectory <new>`，关闭另加`-Presentation disabled`，访问另加`-PreviewAccess`；再用`-Mode Compare -BaselineDirectory <left> -CandidateDirectory <right> -EvidenceDirectory <new>`。原始JSON／manifest／日志／视觉诊断均保留。访问夹具使用注入时钟走真实页面状态机，不能作为真实播放计时证明；计时另见graphical.md／最终回归。

这些是受控回归，不是自然九局或真人游玩。旧v1–v3起始draw_rng不固定的失败样本完整保留，不排除profile来凑零差异。
