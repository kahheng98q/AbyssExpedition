from pathlib import Path
from PIL import Image,ImageFont
from html.parser import HTMLParser
from urllib.parse import unquote,urlsplit
import json, hashlib, zipfile, re, math
ROOT=Path(__file__).resolve().parents[5];OUT=Path(__file__).resolve().parents[1];E=ROOT/'docs/validation/visual-vd01'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
results=[]
def check(name,test,detail=''):
    results.append({'check':name,'passed':bool(test),'detail':detail})
    if not test:print('FAIL',name,detail)
baseline=json.loads((E/'audit-baseline.json').read_text(encoding='utf-8'))
changed=[r['path'] for r in baseline['runtime_files']+baseline['historical_images'] if not(ROOT/r['path']).exists() or sha(ROOT/r['path'])!=r['sha256']]
check('protected runtime and historical hashes unchanged',not changed,changed)
class Links(HTMLParser):
    def __init__(self):super().__init__();self.refs=[];self.ids=[]
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if 'id'in a:self.ids.append(a['id'])
        for k in ('href','src','poster'):
            if k in a:self.refs.append(a[k])
broken=[];remote=[]
pages=[ROOT/'docs/visual-design/preview.html',OUT/'motion-player.html',ROOT/'docs/game-development-dashboard.html']
for p in pages:
    parser=Links();parser.feed(p.read_text(encoding='utf-8'));check('unique IDs '+p.name,len(parser.ids)==len(set(parser.ids)))
    for ref in parser.refs:
        u=urlsplit(ref)
        if u.scheme in ('http','https'):remote.append((str(p),ref));continue
        if u.scheme or not u.path:continue
        target=(p.parent/unquote(u.path)).resolve()
        if not target.exists():broken.append(str(target))
check('offline HTML local links/media exist',not broken,broken)
check('offline pages contain no remote dependencies',not remote,remote)
markdown=[ROOT/'README.md',ROOT/'docs/IMPLEMENTATION_OVERVIEW.md',ROOT/'docs/visual-design/ART_DIRECTION.md',ROOT/'docs/visual-design/SPRITE_SPEC.md',ROOT/'docs/visual-design/ANIMATION_REQUIREMENTS.md',ROOT/'docs/visual-design/ASSET_INVENTORY.md',ROOT/'docs/visual-design/UI_DESIGN.md',ROOT/'docs/visual-design/APPROVALS.md',ROOT/'specs/002-2d-art-direction/visual-audit.md',ROOT/'specs/002-2d-art-direction/visual-audit.zh-CN.md']+list(E.glob('phase-*.md'))
brokenmd=[]
for p in markdown:
    for ref in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8')):
        u=urlsplit(ref)
        if u.scheme or not u.path:continue
        if not(p.parent/unquote(u.path)).resolve().exists():brokenmd.append({'from':p.relative_to(ROOT).as_posix(),'target':ref})
check('audit guides README overview evidence markdown links',not brokenmd,brokenmd)
script=(ROOT/'docs/visual-design/preview.js').read_text(encoding='utf-8')
check('no fetch/server requirement',not re.search(r'\bfetch\s*\(|XMLHttpRequest|https?://',script))
m=json.loads((OUT/'animation-manifest.json').read_text(encoding='utf-8'));counts={};framehashes=[]
for name,a in m['actors'].items():
    sheet=Image.open(OUT/a['sheet']).convert('RGBA');ax,ay=a['anchor'];w,h=a['canvas']
    check('anchor in canvas '+name,0<=ax<w and 0<=ay<h)
    check('five states '+name,len(a['states'])==5)
    hashes=[]
    for state,s in a['states'].items():
        for x,y,rw,rh in s['regions']:
            check('region bounds '+name+'/'+state,0<=x and 0<=y and x+rw<=sheet.width and y+rh<=sheet.height)
            cell=sheet.crop((x,y,x+rw,y+rh));hashes.append(hashlib.sha256(cell.tobytes()).hexdigest())
    counts[name]=len(set(hashes));check('distinct authored frames '+name,len(hashes)==counts[name]==a['unique_cells'],{'raw':len(hashes),'distinct':counts[name]});framehashes+=hashes
for name,a in m['effects'].items():
    im=Image.open(OUT/a['sheet']);hashes=[hashlib.sha256(im.crop((x,y,x+w,y+h)).tobytes()).hexdigest() for x,y,w,h in a['regions']];counts[name]=len(set(hashes));check('effective effect frames '+name,2<=counts[name]<=4)
check('authored unique budget',sum(counts.values())==m['authored_unique_cells']==29 and sum(counts.values())<=58,counts)
check('Thrall attack N/A',m['actors']['thrall']['states']['attack']['applicable'] is False)
check('tiles and prop dimensions',Image.open(OUT/'sprites/terrain-concept.png').size==(128,128) and Image.open(OUT/'sprites/props-concept.png').size==(256,96))
ora_reports=[]
for p in (OUT/'source').glob('*.ora'):
    with zipfile.ZipFile(p) as z:
        ok=z.read('mimetype')==b'image/openraster' and 'stack.xml'in z.namelist() and 'mergedimage.png'in z.namelist()
        check('editable layered ORA '+p.name,ok);ora_reports.append({'path':p.relative_to(OUT).as_posix(),'layer_count':len([n for n in z.namelist() if n.startswith('data/')])})
pkg=json.loads((OUT/'package.json').read_text(encoding='utf-8'))
for plate in pkg['scale_plates']:
    im=Image.open(OUT/plate['path']);check('plate size '+plate['path'],list(im.size)==plate['size'])
    if 'content'in plate:
        check('letterbox asymmetric margins '+plate['path'],plate['margins']==[45,46,29,30] and im.getpixel((44,28))[:3]==(0,0,0))
layout=json.loads((OUT/'hud-layout.json').read_text(encoding='utf-8'));mask=Image.new('1',(640,360));from PIL import ImageDraw
d=ImageDraw.Draw(mask)
for x,y,w,h in layout['rectangles'].values():d.rectangle((x,y,x+w-1,y+h-1),fill=1)
union=sum(mask.get_flattened_data());check('HUD union <=25%',union==56496 and union/230400<=.25)
f=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',12)
widths={t:math.ceil(f.getlength(t)) for t in ['HP 99999 / 99999','XP 99999 / 99999','99:59  Coins 999999','Long companion… 999/999']}
check('large value text fits proposed regions',widths['HP 99999 / 99999']<=151 and widths['XP 99999 / 99999']<=168 and widths['99:59  Coins 999999']<=215 and widths['Long companion… 999/999']<=184,widths)
def lum(h):
    a=[int(h[i:i+2],16)/255 for i in (1,3,5)];a=[v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in a];return sum(a[i]*[.2126,.7152,.0722][i] for i in range(3))
def contrast(a,b):x,y=sorted([lum(a),lum(b)],reverse=True);return(x+.05)/(y+.05)
pairs=[('Ivory / Panel','#E9E6D8','#191E2E',4.5),('Mist / Panel','#B8C6D1','#191E2E',4.5),('Gold / Panel','#D6AE68','#191E2E',4.5),('Ally focus / Panel','#A5F3E8','#191E2E',3),('Light border / Panel','#687C88','#191E2E',3),('Warning / bright ground','#FFB454','#3A4550',3),('Warning / abyss','#FFB454','#49315E',3)]
ratios=[]
for name,a,b,minratio in pairs:
    r=contrast(a,b);ratios.append({'pair':name,'ratio':round(r,3),'target':minratio});check('contrast '+name,r>=minratio,round(r,3))
(E/'contrast.json').write_text(json.dumps(ratios,indent=2),encoding='utf-8')
phase2='''# Phase 2 · Art direction · 2026-10-16

状态：**设计文档/数值检查已验证；G0未批准**。T007–T014完成；T015实际owner方向决定继续pending。用户授权制作阶段3待审样稿，不代表接受文字替代或方向。

五份共享设计文档明确18个语义色、2–3明度、上左光、quiet ground、纯2D/nearest/integer与零动态灯默认。角色32×48/32×48/32×32，脚锚16,40/16,40/16,24；地砖32×32。13+6+6+2+2=29概念独创格，生产上限58；地砖16/道具6/支持图标6。attack3格/15FPS=12ticks；hurt按真实截止；普通死亡3格/8FPS<24ticks；Brinejaw warning45ticks；剑cleanup>expires。数据/规格与manifest一致。

正文12px、标题16/20px、4/8/12间距；ValueBar max=0安全且不改原值。对比度只验证色对，不证明艺术/阅读速度或实际Godot混合底图。

| 色对 | 实测ratio | 阈值 |
| --- | ---: | ---: |
'''+''.join(f"| {r['pair']} | {r['ratio']}:1 | {r['target']}:1 |\n" for r in ratios)+'''
来源路径/画布/锚点/预算检查由`source/validate_package.py`执行，结果见[document-checks.json](document-checks.json)。[识别协议](recognition-protocol.json)于构图前写入并保留hash；明确正常4普通敌人vs密集14、两同伴、1boss、1剑弧、2友方星、2预警；位置/重叠/camera/答案逐项登记。此密集板不是100敌人M4 benchmark，未开展人工测试。

缺失：Concept2/3或书面替代批准、G0/G1、最终生产清稿、实机接线及人工/参考机证据。G0审阅入口见[APPROVALS](../../visual-design/APPROVALS.md)。所有正文规则仍为draft，不能据数值检查自批。
'''
(E/'phase-2.md').write_text(phase2,encoding='utf-8')
package_files=[]
for p in sorted(OUT.rglob('*')):
    if p.is_file() and p.name!='package.json':package_files.append({'path':p.relative_to(OUT).as_posix(),'sha256':sha(p),'status':'PROPOSED / original concept source or export'})
pkg['assets']=package_files;pkg['animation_counts']=counts;pkg['ora_sources']=ora_reports;pkg['motion_files']=[p.name for p in sorted(OUT.glob('*.webm'))]
review_paths=markdown+[ROOT/'docs/visual-design/preview.html',ROOT/'docs/visual-design/preview.js',ROOT/'specs/002-2d-art-direction/plan.md',ROOT/'specs/002-2d-art-direction/tasks.md',E/'recognition-protocol.json',E/'audit-baseline.json',E/'motion-recording.json',E/'browser-checks.json']
pkg['review_documents']=[{'path':p.relative_to(ROOT).as_posix(),'sha256':sha(p)} for p in review_paths]
pkg['review_document_hash_note']='Executed checker output and package-sha256.txt are external evidence, excluded to avoid recursive self-hashing. Approval decisions remain pending.'
(OUT/'package.json').write_text(json.dumps(pkg,indent=2),encoding='utf-8')
check('all eight primary deliveries indexed',len(pkg['deliveries'])==8)
(E/'package-sha256.txt').write_text(sha(OUT/'package.json')+'  docs/visual-design/mockups/vd01/package.json\n',encoding='utf-8')
report={'date':'2026-10-16','scope':'offline concept files only','passed':sum(r['passed'] for r in results),'failed':sum(not r['passed'] for r in results),'checks':results,'package_sha256':sha(OUT/'package.json')}
(E/'document-checks.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k!='checks'}));raise SystemExit(1 if report['failed'] else 0)
