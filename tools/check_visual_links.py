"""Offline-only local reference audit for the current VD01 handoff."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import unquote,urlsplit
import json,re,hashlib
R=Path(__file__).resolve().parents[1];E=R/'docs/validation/visual-vd01'
targets=[R/'README.md',R/'docs/IMPLEMENTATION_OVERVIEW.md',R/'docs/development.md',R/'docs/game-development-dashboard.html']
targets+=list((R/'docs/visual-design').glob('*.md'))+[R/'docs/visual-design/preview.html',R/'docs/visual-design/runtime-gallery.html',R/'docs/visual-design/wallclock-gallery.html',R/'docs/visual-design/review-session.html']
targets+=list(E.glob('*.md'))
targets+=[E/'completion-r1/performance.md'] if (E/'completion-r1/performance.md').exists() else []
targets+=list((E/'completion-r2').glob('*.md'))
class Links(HTMLParser):
 def __init__(self):super().__init__();self.refs=[]
 def handle_starttag(self,tag,attrs):
  for key,value in attrs:
   if key in ('href','src','poster') and value:self.refs.append(value)
missing=[];checked=0
for p in targets:
 text=p.read_text(encoding='utf-8');refs=[]
 if p.suffix=='.html':parser=Links();parser.feed(text);refs=parser.refs
 else:refs=re.findall(r'\[[^\]\n]*\]\(([^)\n]+)\)',text)
 for ref in refs:
  ref=ref.strip('<>');url=urlsplit(ref)
  if url.scheme or not url.path:continue
  checked+=1
  if not (p.parent/unquote(url.path)).resolve().exists():missing.append({'source':p.relative_to(R).as_posix(),'reference':ref})
package=R/'docs/visual-design/mockups/vd01/package.json'
original_hash=hashlib.sha256(package.read_bytes()).hexdigest()
result={'files':len(targets),'local_references_checked':checked,'missing':missing,'approved_package_sha256':original_hash,'approved_package_unchanged':original_hash=='3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49','network_accessed':False}
(E/'offline-links.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False))
raise SystemExit(0 if not missing and result['approved_package_unchanged'] else 1)
