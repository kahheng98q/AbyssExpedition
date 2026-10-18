"""Record the human's design approval; never writes runtime files or regenerates art."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit,unquote
import hashlib,json,re,shutil

ROOT=Path(__file__).resolve().parents[3]
E=Path(__file__).resolve().parent
ART=ROOT/'docs/visual-design/mockups/vd01'
EXPECTED='3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(ART/'package.json')==EXPECTED,'Submitted package changed; do not bind approval to a different revision'
package=json.loads((ART/'package.json').read_text(encoding='utf-8'))
archive=E/'approved-submission'
assert not archive.exists(),'Approval archive already exists; do not overwrite'
files={ART/'package.json'}
for r in package['assets']:
    p=ART/r['path'];assert sha(p)==r['sha256'],str(p);files.add(p)
for r in package['review_documents']:
    p=ROOT/r['path'];assert sha(p)==r['sha256'],str(p);files.add(p)
for p in files:
    dest=archive/p.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest)
record={
 'revision':'VD-01-M1','date':'2026-10-16','reviewer':'user / project owner','received_text':'approve',
 'source':'direct human reply to the preceding VD-01-M1 design handoff in this chat',
 'decision':'approve','submitted_package_sha256':EXPECTED,
 'approved':['G0 written direction and written substitute for missing Concept Images 2/3','G1 exact eight-item concept package and UI rules','P01 edge relocation and upper-body viewport cropping proposal, with readable foot anchor and relevant danger retained','P02 supplemental 30 new base sword arcs and 100 new friendly base homing stars; inherited M4 workload and targets unchanged','P03 mirror-safe near-symmetric actor shading with independent foot shadows and in-budget semantic correction','recognition-protocol VD-01-M1-recognition-01','documented eight-item replacement plan and scope'],
 'scope':['aren+swordsman','saltbound_thrall','skittering_brinejaw','coast shrine visuals','base sword reach48 angle100','existing friendly base homing star','CombatHUD','level_up'],
 'support':['shared Theme and border','six shared icons','Aren portrait crop','read-only seed disclosure in existing pause screen'],
 'remaining':['production cleanup and delivery validation','native UI / sprite / environment integration','G2 source/release regression, human readability, latency and performance acceptance','G3 expansion requires separate scope'],
 'execution':'Approval recorded only in this turn. Original Phases1–3-only delivery is closed; T031–T087 not started. Approval of designs does not label them integrated or runtime verified.',
 'archive':'docs/validation/visual-vd01/approved-submission','archived_files':len(files)
}
(E/'owner-approval-2026-10-16.json').write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding='utf-8')
def edit(rel,changes):
    p=ROOT/rel;s=p.read_text(encoding='utf-8')
    for old,new in changes:
        assert old in s,(rel,old[:80]);s=s.replace(old,new)
    p.write_text(s,encoding='utf-8')
def append(rel,body):
    p=ROOT/rel;p.write_text(p.read_text(encoding='utf-8')+'\n\n'+body+'\n',encoding='utf-8')

edit('specs/002-2d-art-direction/tasks.md',[
 ('T015 actual G0 and T030 actual G1/P01–03/protocol decisions remain pending.','T015 actual G0 and T030 actual G1/P01–03/protocol decisions approved by owner on 2026-10-16.'),
 ('T015 remains pending. Review packet preparation in T030 is delivered, but its actual owner decisions remain pending; keep its checkbox open.','Owner subsequently replied `approve` to the submitted VD-01-M1 handoff. G0/G1, the listed P01–03/protocol and exact design scope are now approved; T015/T030 are complete. This is an approval-record update, not execution of T031+.'),
 ('| T015 | actual owner G0/ref substitution decision | pending owner |','| T015 | actual owner G0/ref substitution decision | approved 2026-10-16 |'),
 ('| assembled; approval incomplete |','| approved 2026-10-16; exact submitted hash archived |'),
 ('28 task deliveries checked; 2 owner-decision tasks pending; 57 future tasks unstarted. Stop at Gate A.','30 Phase1–3 tasks checked, including the actual owner decisions; 57 future tasks unstarted. Design approval recorded; no Phase4 execution in this turn.'),
 ('- [ ] T015 ','- [X] T015 '),('- [ ] T030 ','- [X] T030 ')])
append('specs/002-2d-art-direction/tasks.md','Approval evidence: [owner decision](../../docs/validation/visual-vd01/owner-approval-2026-10-16.json). Submitted SHA256 `'+EXPECTED+'`; original submission and documents are archived before updating approval labels. Future implementation must still start with T031 backup and T032/T033 before captures; G2/G3 remain open.')

# Preserve prior pending tables as historical submission evidence, adding an authoritative current decision.
edit('docs/visual-design/APPROVALS.md',[
 ('Package **VD-01-M1** · 2026-10-16 · 原创概念样稿可评审，非生产美术批准。','Package **VD-01-M1** · 2026-10-16 · **G0/G1设计已批准；生产清稿、接线与G2验收未完成。**\n\n下方原提交中的pending表保留为历史；当前owner决定见本文末节。'),
 ('| pending owner | — | pending | Concept2/3图片或文字替代须明确批准 |','| user / project owner | 2026-10-16 | approve | 接受当前书面替代；不声称比较过缺失原图 |'),
 ('| pending owner | — | pending | 像素boards/strips/视频已交付；生产清稿/参考替代/P01–03未批准；禁止live替换；仍需计划/tasks批准 |','| user / project owner | 2026-10-16 | approve | 本修订八件概念及列明P01–03/协议/替换方案接受；本轮未开始原生实施，G2/G3开放 |')])
append('docs/visual-design/APPROVALS.md',f'''## 当前owner决定 · 2026-10-16

Reviewer：user / project owner。直接回复：`approve`。对象是上一条交付的**VD-01-M1**，提交package SHA256：`{EXPECTED}`。

批准内容：G0整体方向及缺失Concept2/3的当前书面替代、G1八件概念与UI规则、P01边缘重排/视口上部身体裁切、P02补充30新版基础剑弧+100新版友方基础星、P03近对称明暗/独立脚影/预算内语义校正、当前识别fixture/答案协议及列明八件替换计划范围。P01仍须保留脚锚/危险可读；P02不减原负载、不降低门槛、不增加Aren技能；批准概念不等于接受未知未来生产清稿。

记录：[机器可读决定](../validation/visual-vd01/owner-approval-2026-10-16.json)。原提交package及其源/图片/视频/评审文档已按hash核对并存入[归档索引](../validation/visual-vd01/approved-submission/docs/visual-design/mockups/vd01/package.json)。现有package.json保留原提交内容与旧状态，不能重生成后冒充同一个获批hash；当前状态以此决定为准。

T015/T030完成，Phases1–3共30项交付关闭。原请求仅实施Phases1–3，本次仅登记设计批准，T031–T087没有开始。下一实施阶段按已列明范围从备份和before基线启动。G2实机/人工/延迟/性能、生产交付检查及G3扩批仍开放；不改现有视觉运行基线或玩法验收。''')

edit('docs/visual-design/preview.html',[
 ('G0 / G1 待批准','G0 / G1 设计已批准'),('像素概念样稿已交付，等待你的方向与样稿审批。','VD-01-M1方向与样稿已由owner批准（2026-10-16）；尚未接入Godot。'),
 ('Esc/C详情与seed迁移仅是待审批方案。','Esc/C详情与seed迁移已获设计批准，尚未实施。'),('P01 待审批','P01 设计已批准'),
 ('是否接受须你明确决定。不是实机遮挡验收。','该候选已获设计批准；实际遮挡仍须实机验收。'),('镜像明暗P03待审批。','镜像明暗P03设计已批准，尚未实施。'),('图标为未批准概念。','图标为已批准概念，生产清稿另验。'),
 ('G0 / G1 · 待你的批准','G0 / G1 · 设计已批准'),('<span class="number">待审</span><h3>方向与取舍</h3><p>文字代替缺失参考图？<br>边缘裁切与HUD避让？<br>镜像明暗与额外压力样本？','<span class="number">已批</span><h3>设计决定已登记</h3><p>当前书面参考替代<br>边缘裁切与HUD避让<br>镜像明暗与压力样本'),
 ('审批包与待决事项 ↗','审批记录与剩余验收 ↗'),('完成本次设计交付后停止。G0/G1、计划/tasks与精确替换范围获批后，才可进入第4阶段。生产清稿与人工/实机/性能验收继续开放。','Phases1–3设计交付与审批已关闭；第4阶段尚未开始。原提交索引按hash保留，当前决定见审批记录。生产清稿与人工/实机/性能验收继续开放。'),
 ('生产清稿待批准','生产清稿待交付验收')])
edit('docs/game-development-dashboard.html',[
 ('VD-01-M1：像素样稿与交互预览已交付','VD-01-M1：视觉设计已获owner批准'),('G0 / G1待批准','G0 / G1设计已批准'),
 ('生产清稿、原生集成未实现；参考替代、边缘、容量、镜像与G0/G1仍待owner决定。','G0/G1及参考替代、边缘、容量、镜像已获owner批准；生产清稿和原生集成未实现。'),
 ('待审批方案</a>','审批记录</a>')])
edit('docs/IMPLEMENTATION_OVERVIEW.md',[
 ('G0/G1、参考替代及边缘/容量/镜像[待批准](visual-design/APPROVALS.md)；','G0/G1、参考替代及边缘/容量/镜像[已获owner批准](visual-design/APPROVALS.md)；')])
edit('README.md',[
 ('mockup 待批准；未改游戏。','VD-01-M1概念已获owner批准；未改游戏。'),('Godot未改，G0/G1及第4阶段实施待批准。','G0/G1设计与列明范围已获owner批准；Godot未改，第4阶段尚未开始。')])
for rel in ['docs/visual-design/ART_DIRECTION.md','docs/visual-design/SPRITE_SPEC.md','docs/visual-design/ASSET_INVENTORY.md','docs/visual-design/UI_DESIGN.md','docs/visual-design/ANIMATION_REQUIREMENTS.md']:
    p=ROOT/rel;s=p.read_text(encoding='utf-8');lines=s.splitlines();lines.insert(2,'> **当前状态 · 2026-10-16**：VD-01-M1的G0/G1及列明设计决定已获owner `approve`。[审批记录](APPROVALS.md)。下文pending是原提交状态；生产清稿/接线/G2未完成。')
    p.write_text('\n'.join(lines)+'\n',encoding='utf-8')
append('docs/development.md','''## VD-01-M1 owner design approval — 2026-10-16

The owner directly replied `approve` to the submitted visual design handoff. Recorded G0/G1, written-reference substitution, P01/P02/P03, recognition protocol and the exact eight-item design/replacement scope. T015/T030 are checked; all30 Phase1–3 tasks are now closed. Submitted package SHA256 and complete referenced files were verified and archived before approval-label edits. See [decision](validation/visual-vd01/owner-approval-2026-10-16.json) and [approval register](visual-design/APPROVALS.md).

This turn records design approval only. Original Phases1–3-only delivery remains the execution boundary; T031–T087 have not started. No production cleanup, runtime changes, engine tests, performance or human acceptance is claimed. G2/G3 remain open. Offline links and protected hashes are checked separately in the approval evidence.''')
append('specs/002-2d-art-direction/plan.md','## 当前审批更新 · 2026-10-16\n\nOwner已直接回复`approve`，接受提交的VD-01-M1设计、八件范围及P01–03/识别协议；见[审批记录](../../docs/visual-design/APPROVALS.md)。上文pending反映提交时状态。设计批准已登记，Phases1–3结束；本轮没有启动T031+或修改Godot。G2/G3与生产/实机/人工/性能检查仍开放。')
for rel in ['specs/002-2d-art-direction/spec.md','specs/002-2d-art-direction/spec.zh-CN.md']:
    append(rel,'当前审批 / Approval update · 2026-10-16：owner `approve` 已登记为VD-01-M1的G0/G1及列明设计范围接受；历史pending不再是当前审批状态。[决定](../../docs/visual-design/APPROVALS.md)。Godot集成与G2/G3未完成。')

# Read-only checks; do not run the old package generator, which would change the approved hash.
baseline=json.loads((E/'audit-baseline.json').read_text(encoding='utf-8'))
protected=[r for r in baseline['runtime_files']+baseline['historical_images'] if sha(ROOT/r['path'])!=r['sha256']]
assert not protected
class LinkParser(HTMLParser):
    def __init__(self):super().__init__();self.refs=[]
    def handle_starttag(self,tag,attrs):
        d=dict(attrs);self.refs.extend(d[k] for k in ('href','src','poster') if k in d)
broken=[];count=0
live=[ROOT/'docs/visual-design/preview.html',ROOT/'docs/game-development-dashboard.html',ROOT/'README.md',ROOT/'docs/IMPLEMENTATION_OVERVIEW.md',ROOT/'docs/visual-design/APPROVALS.md']
for p in live:
    s=p.read_text(encoding='utf-8')
    if p.suffix=='.html':parser=LinkParser();parser.feed(s);refs=parser.refs
    else:refs=re.findall(r'\]\(([^)]+)\)',s)
    for ref in refs:
        u=urlsplit(ref)
        if u.scheme or not u.path:continue
        count+=1
        if not(p.parent/unquote(u.path)).resolve().exists():broken.append({'path':str(p),'ref':ref})
assert not broken,broken
assert sha(ART/'package.json')==EXPECTED
for r in package['assets']:assert sha(ART/r['path'])==r['sha256']
tasks=(ROOT/'specs/002-2d-art-direction/tasks.md').read_text(encoding='utf-8')
checked=re.findall(r'^- \[[xX]\] (T\d{3})\b',tasks,re.M);assert len(checked)==30 and all(int(t[1:])<=30 for t in checked)
report={'date':'2026-10-16','scope':'approval documentation only','approved_package_sha256':EXPECTED,'submitted_package_unchanged':True,'artifacts_unchanged':len(package['assets']),'archived_files':len(files),'protected_runtime_files_unchanged':len(baseline['runtime_files']),'historical_images_unchanged':len(baseline['historical_images']),'local_links_checked':count,'broken_links':broken,'completed_phase1_3_tasks':len(checked),'future_tasks_started':0,'godot_tests_run':False,'prior_file_browser_results':'retained historical evidence, not rerun'}
(E/'approval-checks-2026-10-16.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
