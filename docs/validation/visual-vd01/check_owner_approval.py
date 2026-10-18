"""Read-only validation of approval records and immutable submission."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit,unquote
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[3];E=Path(__file__).resolve().parent;ART=ROOT/'docs/visual-design/mockups/vd01'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
record=json.loads((E/'owner-approval-2026-10-16.json').read_text(encoding='utf-8'));expected=record['submitted_package_sha256']
package=json.loads((ART/'package.json').read_text(encoding='utf-8'))
assert sha(ART/'package.json')==expected
for r in package['assets']:assert sha(ART/r['path'])==r['sha256'],r['path']
archive=E/'approved-submission'
assert sha(archive/'docs/visual-design/mockups/vd01/package.json')==expected
for r in package['assets']:assert sha(archive/'docs/visual-design/mockups/vd01'/r['path'])==r['sha256']
for r in package['review_documents']:assert sha(archive/r['path'])==r['sha256'],r['path']
baseline=json.loads((E/'audit-baseline.json').read_text(encoding='utf-8'))
drift=[dict(r,current_sha256=sha(ROOT/r['path'])) for r in baseline['runtime_files'] if sha(ROOT/r['path'])!=r['sha256']]
assert all(r['path']=='project.godot' for r in drift),drift
assert all(sha(ROOT/r['path'])==r['sha256'] for r in baseline['historical_images'])
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
tasks=(ROOT/'specs/002-2d-art-direction/tasks.md').read_text(encoding='utf-8');checked=re.findall(r'^- \[[xX]\] (T\d{3})\b',tasks,re.M)
assert len(checked)==30 and all(int(t[1:])<=30 for t in checked)
report={'date':'2026-10-16','scope':'approval documentation only','approved_package_sha256':expected,'submitted_package_unchanged':True,'artifacts_unchanged':len(package['assets']),'archive_verified':True,'archived_files':record['archived_files'],'protected_runtime_files_matching_original_baseline':len(baseline['runtime_files'])-len(drift),'runtime_baseline_drift':drift,'drift_note':'Initial approval checker stopped on project.godot drift. Current config/features says 4.7 versus original 4.5; no tool in this approval task wrote project.godot. Difference preserved, not repaired or silently accepted. Verify pinned engine before later implementation.','historical_images_unchanged':len(baseline['historical_images']),'local_links_checked':count,'broken_links':broken,'completed_phase1_3_tasks':len(checked),'future_tasks_started':0,'godot_tests_run':False,'prior_file_browser_results':'retained historical evidence, not rerun'}
(E/'approval-checks-2026-10-16.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
