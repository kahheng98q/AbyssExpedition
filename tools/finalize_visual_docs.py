"""Summarize retained VD01 evidence; never grants human gates or changes gameplay."""
from pathlib import Path
import json, re, hashlib

R=Path(__file__).resolve().parents[1]
E=R/'docs/validation/visual-vd01'
if (E/'completion-r1/candidate-files.json').exists():
    raise SystemExit('Legacy P1 document generator stopped: preserve the owner-verified reference. Current evidence uses tools/record_visual_completion.py; do not overwrite P2 docs with historical counts.')
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def put(p,text): p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding='utf-8')
def table(folder):
    rows=[]
    for seed in (101,202,303):
        p=E/folder/f'm4-{seed}.json'
        if p.exists():
            v=read(p);rows.append(f"| {seed} | {v['p50_ms']:.3f} | {v['p95_ms']:.3f} | {v['p99_ms']:.3f} | {v['max_ms']:.3f} | {v['capture_valid']} | {v['frame_budget_pass']} |")
        else: rows.append(f'| {seed} | pending | — | — | — | — | — |')
    return '| seed | p50 ms | p95 | p99 | max | capture valid | budget pass |\n| --- | --- | --- | --- | --- | --- | --- |\n'+'\n'.join(rows)

groups=['before/perf','before/perf-visual-r1','after/perf-r1','after/perf-visual-r1']
result_paths=[E/g/f'm4-{seed}.json' for g in groups for seed in (101,202,303)]
complete=all(p.exists() and read(p).get('capture_valid') and not read(p).get('smoke') and read(p).get('capture_active_seconds',0)>=120 for p in result_paths)
candidate=read(E/'candidate-files.json')
ch=candidate['candidate_sha256'];pack=candidate['embedded_release_sha256']
summary='完整测量已保存；预算结果见下表，参考机验收仍未完成。' if complete else '最终顺序测量进行中；pending不是通过，完成后刷新本文件。'
perf=f'''# Performance · VD-01-P1 · 2026-10-17

{summary}

Each full run uses30 active seconds warmup +120 active seconds capture; Compatibility1920×1080, VSync off, uncapped. Seeds101/202/303 run sequentially; original M4 fixture is unchanged. Target per seed p95≤16.67ms,p99≤25ms. Capture validity and budget status are separate. Current host self-reports AMD Ryzen7 5800H / GTX1650 / Windows10.0.26200; it is **not** the required i5-8400/GTX1050Ti reference machine. RAM/CIM queries were unavailable; no capacity is guessed. Light documentation/file audits occurred, no concurrent graphical jobs during full runs. This is not an exclusive reference-machine acceptance session.

## Original M4 · retained before

{table('before/perf')}

## Original M4 · final release

{table('after/perf-r1')}

## Approved P02 · retained before, final instrumentation

{table('before/perf-visual-r1')}

## Approved P02 · final release

{table('after/perf-visual-r1')}

P02 adds30 actual base48/100 arcs +100 moving friendly base homing stars, at original lifetimes, without reducing ordinary enemies/boss/companions/gems/corruption or altering the inherited workload validators. after mode requires≥30 new arcs,≥100 new stars,new actors present. Actual new/fallback minima/maxima are in JSON; raw frame CSV and logs retained. before expects no new art. Final P02 instrumentation additionally reports fallback counters; to avoid mixing versions, before was rerun in perf-visual-r1 with the same frozen fixture. Earlier before/perf-visual is retained as historical diagnostic evidence. Intermediate04a8 after/perf and after/perf-visual results are retained separately; they precede the prop-region fix and do not represent this final pack.

Original M4 raw CSV/OS process memory monitors are retained in before/perf and after/perf-r1. P02 uses Godot monitors; a missing/zero release static-memory counter is unavailable, not zero memory. No external profiler or physical latency device was attached. No attacks/counts were removed, no gameplay optimization or frame-target relaxation was performed.

Release pack before965f0e7b9a6254fc3ac5ecd5d92ec87a682410a44a604edc7c8c3c79703ff17b → after{pack}. The .console.exe thin launcher hash is not the embedded game hash. Raw before host metadata preserves the original export location; retained before/build/AbyssExpedition.exe matches its recorded hash.

```powershell
./tools/run_m4_benchmarks.ps1 -Release -EvidenceDirectory docs/validation/visual-vd01/after/perf-r1
./tools/run_visual_stress.ps1 -Mode before -Executable <retained-before-exe> -EvidenceDirectory docs/validation/visual-vd01/before/perf-visual-r1
./tools/run_visual_stress.ps1 -Mode after -Executable <final-release-exe> -EvidenceDirectory docs/validation/visual-vd01/after/perf-visual-r1
```

Displayed≤100ms feedback and human recognition are unmeasured. Existing before budget misses do not waive the candidate target; G2 remains pending.
'''
put(E/'performance.md',perf)
put(E/'phase-5-perf.md','''# Phase5 diagnostic only

Three source/debug smoke runs used1s warmup+2s active capture in phase-5-perf-smoke/. p95 26.839/26.651/25.939ms; valid captures, budget failures. Actual minimum new arcs30/new stars100/new actors present; fallback counts logged. These short samples are not acceptance. See [full release/before comparison](performance.md) for actual longer runs; reference-machine/latency gates remain open.
''')

checklists=[]
for p in sorted((R/'specs/002-2d-art-direction/checklists').glob('*.md')):
    text=p.read_text(encoding='utf-8');total=len(re.findall(r'^- \[[ xX]\]',text,re.M));done=len(re.findall(r'^- \[[xX]\]',text,re.M));checklists.append(f'| {p.name} | {done}/{total} | reviewer-owned; unchanged |')
put(E/'review-package.md',f'''# VD-01-P1 · 可玩视觉候选 / G2待审

2026-10-17 · 仅批准八件及支持范围；不扩展G3，不替换已接受视觉基线。

候选 SHA256 `{ch}`。实际嵌入游戏EXE SHA256 `{pack}`。[文件索引](candidate-files.json) · [原G1提交](approved-submission/docs/visual-design/mockups/vd01/package.json)（hash3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49不变）。

## 打开与查看

双击 `builds/windows/m4/AbyssExpedition.exe`，公会→Expedition→未晋升Aren。WASD/方向键走位，自动攻击；1/2/3或方向键+Enter选升级；Esc暂停查看seed，C看腐化。9:00首领。其他角色、晋升和首领仍是完整程序外观。已有存档若已晋升，可直接查看离线实机对照，不需修改正式档案。

[离线概念+REAL预览](../../visual-design/preview.html) · [18组实机对照/两秒采样/灰阶/倍率](../../visual-design/runtime-gallery.html) · [实际捕获索引](after/capture-manifest.json)。原生640×360视口，三种请求窗口；没有把视口图说成物理窗口截图。两秒动作是控制场景按tick采样，不是自然游玩录像或显示延迟测量。

## 已实现并自动验证

- Aren基础剑士、Thrall、Brinejaw、神殿、剑弧/基础追踪星、HUD和三卡升级；29独创格、16地砖槽、6道具、6个可编辑ORA。精确映射/完整回退，[素材来源/缺口](../../visual-design/ASSET_INVENTORY.md) · [交付检查](asset-acceptance.md)。
- [完整回归＋最终定向复验](final-regression.md)：12组当前覆盖5,275断言；debug69另列，合计5,344；零失败/跳过。源码/发布图形及F9隔离/禁用另[有记录](final-debug-release.md)。首轮固定路径截图保存错误未抹去，独立目录复验通过。
- [旧/新实际EXE120tick逐项对照](comparison/gameplay-r1/comparison.json)一致，战斗/AI/成长/转职/数值/保存代码保持边界。[22个旧文件修改](comparison/protected-source-changes.json)均为表现/接线/测试/导出范围；[原函数检查](comparison/unchanged-functions.json)及[像素diff](comparison.md)独立保存。
- HUD全部可见Control联合面积最大24.61%，脚锚在8个边缘/角落均不落入HUD矩形；[测量与限制](hud-acceptance.json)。普通捕获未观察到文字裁切；长值/独立glyph边界仍待测。原概念24.52%仅是六面板面积。
- [原生输入/队列](ui-interactions.md)、[像素/事件](pixel-motion.md)、[环境/边缘](environment-review.md)及[离线预览30项](offline-browser-checks.json)、[看板4项](dashboard-browser-checks.json)通过各自已执行范围；0网络请求。

## 未通过 / 待人工验收

[性能](performance.md)：{summary} 旧版和已完成候选采样均有预算失败；本机不是参考机。不能把有效采样或原版超标当作放宽门槛。

[显示延迟](latency.md)无设备测量；[十人辨识/五秒UI](recognition-results.md)0参与者，CSV只有表头。物理窗口黑边/像素抖动、完整死亡/暂停/倍速实录、长名称/巨大数值/长效果/tooltip边缘/长存档路径、完整自然操作会话未全部验收。M1–M4历史人工和性能门槛仍开放。

## 需要owner评审的具体画面

1. 六个代表地标对齐G1中央视口；全场潮纹/重复实例密度/枝纹按960×540移植，源像素未变。
2. P01已批准的上身裁切/面板避让在实机边角是否仍清楚定位；低亮紫符号与友方星弹能否辨认。自动面积检查不替代这个判断。
3. 三角色/两特效/原生字形与系统字体的成品观感是否接受。G2不能提前通过未测的人类/硬件条件；可记录视觉反馈而不授予新基线或G3扩批。

## 审阅清单

| checklist | checked | status |
| --- | --- | --- |
{chr(10).join(checklists)}

按[$speckit-implement](../../../.agents/skills/speckit-implement/SKILL.md)的“do NOT modify checklist files or markers”，reviewer清单保持只读；执行证据在本包单列，不把测试通过写成owner签批。用户已授权在未勾选清单下继续当前范围，不重复询问。

G2 reviewer/date/decision/new-baseline字段均pending。当前停止于可审阅候选；不继续其它Godot角色/玩法或G3批次。
''')

# A short current Chinese overview, preserving historical evidence through links.
put(R/'docs/IMPLEMENTATION_OVERVIEW.md','''# Abyss Expedition · 实现概览

[离线开发图鉴](game-development-dashboard.html) · [当前候选/验证](validation/visual-vd01/review-package.md) · [历史M4门槛](validation/m4-gate.md)

Godot4.5离线单人原型：走位自动战斗、拾取升级，局外成长/转职、双同伴、救援招募与腐化契约。M1–M4已接线；人工乐趣/普通通关/参考机性能仍待验收。

**What's New · 2026-10-17**：Aren基础剑士、两敌、神殿、剑弧/追踪星、HUD及三卡升级已接入原创像素。其余保留程序外观。29动画格、6份可编辑源；玩法数值未改。12组5,275＋debug69断言通过；源码/发布图形、原生输入、F9限制与离线浏览检查通过各自范围。性能仍超预算；十人辨识、显示延迟、完整手动/窗口验收未完成，G2待审。

| 范围 | 当前可玩 | 验收状态 |
| --- | --- | --- |
| M1 Combat | 三类自动攻击/12升级/首领 | 自动验证；人工待验收 |
| M2 Progression | 等级1–30/6分支/双同伴 | 自动验证；自然流程待验收 |
| M3 Recruitment | 救援/票券招募/兑换/历史 | 自动验证；完整手动待验收 |
| M4 Abyss | 腐化/事件/契约/章节保存 | 自动验证；体验/性能待验收 |
| VD-01-P1 | 八件视觉切片/完整程序回退 | 已实现并自动验证；G2待审 |

双击 `builds/windows/m4/AbyssExpedition.exe`。公会→Expedition；WASD移动、自动攻击，1/2/3升级，Esc暂停，C腐化。9:00首领，击败才胜利。开发源码F9为隔离沙盒，发布版禁用。

```powershell
& './tools/godot-4.5/Godot_v4.5-stable_win64.exe' --path .
./tools/run_validation.ps1 -M4 -Graphical -Export -DummyAudio
```

[概念+实机预览](visual-design/preview.html) · [素材/缺口](visual-design/ASSET_INVENTORY.md) · [审批](visual-design/APPROVALS.md) · [开发记录](development.md) · [Spec](../specs/001-abyss-expedition-mvp/spec.md) · [Plan](../specs/001-abyss-expedition-mvp/plan.md) · [Tasks](../specs/002-2d-art-direction/tasks.md)
''')

p=R/'README.md';s=p.read_text(encoding='utf-8')
s=s.replace('Original procedural placeholders; fully offline.','The approved first visual slice uses original pixel sprites and a coastal shrine; other identities retain procedural rendering. Fully offline.')
s=s.replace('[current evidence](docs/validation/convergence-2026-10-15.md)','[current evidence](docs/validation/visual-vd01/review-package.md)')
start=s.index('- Visual design /') if '- Visual design /' in s else s.index('- Visual design:');end=s.index('- Evidence:',start)
s=s[:start]+'''- Visual design: [离线概念与实机预览](docs/visual-design/preview.html) · [当前候选/验证](docs/validation/visual-vd01/review-package.md) · [素材/缺口](docs/visual-design/ASSET_INVENTORY.md) · [审批](docs/visual-design/APPROVALS.md)。
- Visual Spec Kit: [Spec](specs/002-2d-art-direction/spec.md) · [中文](specs/002-2d-art-direction/spec.zh-CN.html) · [Plan](specs/002-2d-art-direction/plan.md) · [Tasks](specs/002-2d-art-direction/tasks.md)。
'''+s[end:]
s=re.sub(r'\*\*Current build / 当前构建\*\*：.*?(?=\n\n)', '**Current build / 当前构建**：2026-10-17 VD-01-P1八件视觉切片已接入；原生当前覆盖5,275＋debug69断言，源码/发布受控图形与F9限制通过。性能未达预算；人工/参考机/延迟与G2验收开放。见[候选证据](docs/validation/visual-vd01/review-package.md)。',s,flags=re.S)
put(p,s)

p=R/'docs/game-development-dashboard.html';s=p.read_text(encoding='utf-8')
s=s.replace('after/release-r2','after/release-r3')
s=s.replace('5,266','5,275').replace('5,335','5,344')
s=s.replace('Field notes / 2026.10.16','Field notes / 2026.10.17').replace('离线开发图鉴 · 2026-10-16','离线开发图鉴 · 2026-10-17')
old='../screenshots/m4-release-boss-double-eruption-1280.png';new='../screenshots/visual-vd01/after/release-r3/combat-c100-1280.png'
# Only the hero preview; other historical evidence remains where it was.
start=s.index('<figure class="screen">',s.index('id="overview"'));end=s.index('</figure>',start)+len('</figure>');block=s[start:end].replace(old,new).replace('M4 发布版实测：腐化100时，Aren面对海岸首领的锥形与双圆预警','当前VD-01-P1发布候选原生视口：Aren基础剑士、两敌、神殿及完整HUD').replace('实测截图 · M4 发布版 / 受控场景','REAL · VD-01-P1 发布候选 / 受控视口');s=s[:start]+block+s[end:]
s=s.replace('现有美术为原创程序占位。','首批原创像素已接入，其余角色/晋升/首领保留程序外观。')
s=s.replace('原生视觉 UI：HUD、升级卡与共享 Theme','视觉切片：角色、神殿、特效与原生UI').replace('href="validation/visual-vd01/phase-4.md">视觉切片','href="validation/visual-vd01/review-package.md">视觉切片').replace('代码修复已验证','自动回归已验证')
s=s.replace('暂无独立角色立绘。下方字母框为中性占位；战斗中的外观按职业共用程序轮廓。','Aren基础剑士使用真实像素与24px裁剪；其余字母框为中性占位。独立立绘、其他英雄/晋升生产美术仍缺。')
s=s.replace('<div class="portrait" aria-label="Aren 无独立立绘">A</div>','<div class="portrait" aria-label="Aren实际基础剑士头像裁剪"><img src="../assets/ui/aren_portrait_vd01.png" alt="实际Aren24px头像裁剪" style="width:48px;height:48px;image-rendering:pixelated"></div>')
start=s.index('<h3>Art / 视觉表现</h3>');end=s.index('</article>',start);block=s[start:end]
block=block.replace('可辨认的原创程序轮廓与战斗反馈。','Aren、两敌、神殿与两特效已接入原创像素。').replace('用形状、颜色和预警辨识角色与危险；当前仍是占位画面。','用轮廓、脚环和预警辨识单位；其余英雄/晋升/首领保留程序外观。')
block=block.replace('实时绘制轮廓与姿态。','按运行tick采样精灵，完整程序回退保留。').replace('独立立绘与正式动画精灵表未实现。','首批29格动画与6份可编辑源已交付；独立立绘和其他家族未制作。').replace('../screenshots/m4-release-corruption-100-1280.png',new).replace('M4 腐化100下的程序占位海岸与敌人轮廓','VD-01-P1腐化100下的实际发布候选原生视口').replace('M4 发布版 · 原创程序占位画面','VD-01-P1 · 原创像素候选 / G2待验收');s=s[:start]+block+s[end:]
s=s.replace('正式动画精灵表、独立角色立绘；当前为程序占位。','首批以外的英雄/晋升/敌人/首领生产美术及独立立绘；当前保留程序外观。')
s=s.replace('最近原生复核：2026-10-16','最近原生复核：2026-10-17').replace('<strong>5,239</strong>','<strong>5,344</strong>')
s=s.replace('../screenshots/debug-xp-level-buttons.png','validation/visual-vd01/final-debug-r1/captures/source/debug-xp-level-buttons.png').replace('F9 XP 专题保留历史截图，角色字母框为立绘占位','F9 XP 图来自本轮受控检查，其余角色字母框为中性立绘占位')
s=s.replace('内容校验：51 份根 Resource、27 个场景、98 个交付脚本。另完整加载 145 脚本 / 29 场景，0 错误；升级配置与输入记录已更新。','内容校验：60份根Resource、27个场景、108个运行脚本。当前12组5,275＋debug69；完整回归与最终定向复验合并列示，图形检查另列。')
s=s.replace('2026-10-16 本次原生测试；以下各组均 0 失败','2026-10-17 最近一次各组证据；以下各组均0失败')
counts={'unit':223,'scene_smoke':175,'integration_m1':77,'replay':44,'full_run':9,'progression':13,'persistence':343,'abilities':123,'integration_m2':45,'recruitment':293,'integration_m3':196,'integration_m4':3734,'debug_panel':69}
for suite,count in counts.items():
    log='final-debug-r1/debug-panel.log' if suite=='debug_panel' else f'final-r4/{suite}.log'
    pattern=r'<tr><td><a href="[^"]*">'+re.escape(suite)+r'</a></td><td>\d+</td></tr>'
    s=re.sub(pattern,f'<tr><td><a href="validation/visual-vd01/{log}">{suite}</a></td><td>{count}</td></tr>',s)
after=[E/'after/perf-r1'/f'm4-{seed}.json' for seed in (101,202,303)]
if all(p.exists() for p in after):
    values=' / '.join(f"{read(p)['p95_ms']:.3f}" for p in after)
    s=re.sub(r'当前 release 三 seed p95：[\d. /]+ ms',f'当前 release 三 seed p95：{values} ms',s)
s=s.replace('本次已重跑三组完整采样，原始数据另存于<a href="validation/verification-2026-10-15.md">验证报告</a>；上图保留历史结果。','本轮完整采样与限制见<a href="validation/visual-vd01/performance.md">视觉切片性能报告</a>；上图保留历史结果。')
s=s.replace('href="validation/convergence-2026-10-15.md">本次检查记录','href="validation/visual-vd01/review-package.md">本次检查记录')
put(p,s)

p=R/'specs/002-2d-art-direction/tasks.md';s=p.read_text(encoding='utf-8')
s=s.replace('## Current execution record — 2026-10-16','## Historical design execution record — 2026-10-16')
for task in [32,44,71,72,83,85,86]+([87] if complete else []):s=s.replace(f'- [ ] T{task:03}',f'- [X] T{task:03}')
s=re.sub(r'\*\*Generated\*\*:.*?(?=\n)', '**Generated**: 2026-10-16 · **Current**: 2026-10-17 / VD-01-P1 native candidate. Phases1–3 approved; Phase4–5 native slice integrated. Partial verification remains listed below; automated evidence is linked. Human/reference/latency/physical-window and remaining visual acceptance tasks stay open.',s,count=1)
marker='## Latest candidate status — 2026-10-17'
if marker in s:s=s[:s.index(marker)]
s+='\n\n'+marker+f'''\n\n[Current review package](../../docs/validation/visual-vd01/review-package.md), candidate `{ch}`; embedded release `{pack}`.5,275 latest primary assertions plus69 debug, source/release graphical and native input passed.120 old/new EXE ticks identical. Full benchmark measurement {'finished; budget/reference acceptance separate' if complete else 'in progress'}; no G2/new-baseline/G3 approval inferred.\n\nPartial/unavailable: T033 physical-window/before clips; T046 long values/window details; T068/T073–077 full wall-clock/physical-window/glyph/manual matrix; T078 budget/reference target; T079 physical latency; T080 complete visual mismatch approval; T081/T082 actual ten-person answers; T084 reviewer checklist decisions. Captured native/control/edge/recognition evidence exists for their executed portions. Reviewer-owned checklist files/markers unchanged; independent evidence in review-package. Earlier no-runtime/unstarted notes are historical records, superseded here.\n'''
put(p,s)

p=R/'docs/development.md';s=p.read_text(encoding='utf-8');marker='## Visual slice · current candidate · 2026-10-17'
if marker in s:s=s[:s.index(marker)]
s+='\n\n'+marker+f'''\n\nApproved eight-item VD-01-P1 candidate integrated. Shared Theme/HUD/three-card upgrade, exact3 actor mappings, base arc/star, collision-free shrine and full fallback. Existing AI/combat/progression/save rules and data unchanged; source archive and before EXE retained. Full+final focused checks5,275 primary,debug69; source/export/release graphical,F9 denial,native queued input and120tick before/after executable observations passed. Screenshot wrappers now isolate evidence outputs after preserving failed overwrite logs. HUD all-control union24.61%; offline browser30 checks,zero network. Benchmark measurement {'finished' if complete else 'running'}; target/reference acceptance remains separate. Human recognition/UI,display latency,full physical-window/long-value/manual criteria and G2 remain open. [Exact files,build hash,commands and limits](validation/visual-vd01/review-package.md).\n'''
put(p,s)

p=R/'docs/visual-design/APPROVALS.md';s=p.read_text(encoding='utf-8');marker='## G2候选交付 · 2026-10-17'
s=s.replace('**G0/G1设计已批准；生产清稿、接线与G2验收未完成。**','**G0/G1设计已批准；原生候选已交付，G2验收待完成。**')
if marker in s:s=s[:s.index(marker)]
s+='\n\n'+marker+f'''\n\nVD-01-P1候选 `{ch}`；嵌入发布EXE `{pack}`。原G1提交hash保持不变。八件已接入，实际来源/自动检查/逐项差异/未过门槛详见[同版评审包](../validation/visual-vd01/review-package.md)与[REAL对照](runtime-gallery.html)。性能测量{'已完成，结果不等于验收' if complete else '进行中'}；十人辨识/UI答卷、物理延迟、参考机和完整窗口/长值/手动检查未验收。地标布局/腐化符号移植和实际P01边缘裁切需owner观看判断。\n\n| G2字段 | 当前状态 |\n| --- | --- |\n| Reviewer / date / decision | pending / — / pending |\n| New visual baseline | pending，未授权替换 |\n| Reference budgets / displayed latency | 未通过或未测，不以旧版超标豁免 |\n| Human recognition/UI |0参与者；CSV仅表头 |\n| G3 |未授权 |\n\n当前停止于可审阅候选。既有`approve all`仅授权范围内实施，不能提前成为这个未来候选的G2验收。可记录视觉反馈，但未满足的性能/人工条件继续保留。\n'''
put(p,s)
print(f'VD01 documentation refreshed: measurements_complete={complete}, candidate={ch}, primary=5275, debug=69')
