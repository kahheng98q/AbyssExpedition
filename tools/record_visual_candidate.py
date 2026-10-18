"""Record the actual final VD01 build/captures; derives evidence, never approval."""
from pathlib import Path
import json,hashlib,re
from PIL import Image,ImageChops
R=Path(__file__).resolve().parents[1];E=R/'docs/validation/visual-vd01'
if (E/'completion-r1/candidate-files.json').exists():
 raise SystemExit('Legacy P1 recorder stopped: owner-verified reference is frozen. Use tools/record_visual_completion.py for current P2 evidence.')
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def put(name,value):
 p=E/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(value if isinstance(value,str) else json.dumps(value,indent=2),encoding='utf-8')
def entry(path):p=R/path;assert p.exists(),path;return {'path':path,'sha256':sha(p)}
files=[]
for directory in ['scripts','scenes','data','assets']:
 for p in sorted((R/directory).rglob('*')):
  rel=p.relative_to(R).as_posix()
  if p.is_file() and not rel.startswith('assets/source/') and p.suffix in ['.gd','.tscn','.tres','.png','.import']:files.append(entry(rel))
files += [entry('project.godot'),entry('export_presets.cfg')]
pack=sha(R/'builds/windows/m4/AbyssExpedition.exe')
payload={'runtime_files':sorted(files,key=lambda x:x['path']),'embedded_release_sha256':pack,'engine':'4.5.stable.official.876b29033'}
ch=hashlib.sha256(json.dumps(payload,sort_keys=True,separators=(',',':')).encode()).hexdigest()
payload.update(candidate_sha256=ch,revision='VD-01-P1 / corrected props',status='candidate; G2 pending; no new baseline',concept_package_sha256='3c20729e329026ce012ab1a8f252d8aba059565f4b349491b6f8b7566072ba49')
put('candidate-files.json',payload);put('candidate-sha256.txt',ch+'\n')
cap={'candidate_sha256':ch,'release_pack_sha256':pack,'kind':'REAL controlled viewport; physical-window capture pending','sets':[]}
for role,folder in [('before','before/release-r1'),('source','after/source-r3'),('release','after/release-r3')]:
 p=R/'screenshots/visual-vd01'/folder/'capture-manifest.json';m=read(p);context=read(p.with_name('capture-context.json'));assert m['failures']==0
 cap['sets'].append({'role':role,'manifest':p.relative_to(R).as_posix(),'manifest_sha256':sha(p),'context':context,'records':len(m['records']),'engine':m['engine'],'renderer':m['renderer'],'failures':m['failures']})
 if role=='release':assert context['embedded_pack_sha256'].lower()==pack
put('after/capture-manifest.json',cap)
before=R/'screenshots/visual-vd01/before/release-r1';after=R/'screenshots/visual-vd01/after/release-r3'
diffs=[];destination=E/'comparison/images-r1';destination.mkdir(exist_ok=True)
for p in sorted(before.glob('*.png')):
 a=Image.open(p).convert('RGB');b=Image.open(after/p.name).convert('RGB');diff=ImageChops.difference(a,b);channels=diff.split();mask=ImageChops.lighter(ImageChops.lighter(channels[0],channels[1]),channels[2]).point(lambda v:255 if v else 0);diff.save(destination/p.name)
 diffs.append({'name':p.name,'before_sha256':sha(p),'after_sha256':sha(after/p.name),'changed_pixels':mask.histogram()[255],'total_pixels':230400,'derived_diff':'comparison/images-r1/'+p.name})
put('comparison/pixel-differences.json',{'kind':'DERIVED difference analysis, not gameplay screenshot','pairs':diffs,'visual_acceptance':'pending owner/human review'})
clips=[]
for condition in ['normal','dense','max-corruption','motion']:
 folder=after/('motion' if condition=='motion' else 'recognition/'+condition)
 frames=[entry(p.relative_to(R).as_posix()) for p in sorted(folder.glob('frame-*.png'))];assert len(frames)==60
 clips.append({'condition':condition,'frames':frames,'playback_fps':30,'seconds':2,'kind':'REAL controlled tick-sampled frames, not wall-clock video'})
put('recognition-frame-index.json',{'protocol':'VD-01-M1-recognition-01','clips':clips,'human_results':'0 participants; not conducted'})
def union(boxes):
 rects=[(max(0,x),max(0,y),min(640,x+w),min(360,y+h)) for x,y,w,h in boxes];xs=sorted(set(v for a,b,c,d in rects for v in (a,c)));area=0
 for left,right in zip(xs,xs[1:]):
  intervals=sorted((b,d) for a,b,c,d in rects if a<right and c>left);end=-1;length=0
  for bottom,top in intervals:
   if top>end:length+=max(0,top-max(bottom,end));end=top
  area+=(right-left)*length
 return area
rows=[]
for v in read(after/'capture-manifest.json')['records']:
 if v['name'].startswith(('combat','rescue','edge')):
  a=union(v['hud_rects'].values());row={'name':v['name'],'area_px':a,'fraction':a/230400,'within_25_percent':a<=57600,'visible_control_rectangles':v['hud_rects']}
  if v['name'].startswith('edge'):
   x,y=v['hero_position'];foot=[x-min(640,max(320,x))+320,y-min(360,max(180,y))+180];row.update(foot_in_viewport=foot,foot_occluded_by_hud=any(bx<=foot[0]<bx+w and by<=foot[1]<by+h for bx,by,w,h in v['hud_rects'].values()))
  rows.append(row)
hud=read(E/'hud-acceptance.json');hud.update(candidate_sha256=ch,captures=rows,max_fraction=max(x['fraction'] for x in rows),all_area_within_25_percent=all(x['within_25_percent'] for x in rows));put('hud-acceptance.json',hud)
changes=[]
for f in read(E/'before/rollback-manifest.json')['files']:
 p=R/f['path'];current=sha(p) if p.exists() else None
 if current!=f['sha256']:changes.append({'path':f['path'],'before_sha256':f['sha256'],'after_sha256':current})
put('comparison/protected-source-changes.json',changes)
specs=[
 ('A01','hero aren+swordsman',['assets/source/visual-vd01/aren.ora','assets/source/visual-vd01/aren.manifest.json'],['assets/sprites/actors/aren/base_swordsman_vd01.png','data/visuals/aren_frames_vd01.tres','data/visuals/aren_vd01.tres']),
 ('E01','enemy saltbound_thrall',['assets/source/visual-vd01/thrall.ora','assets/source/visual-vd01/thrall.manifest.json'],['assets/sprites/enemies/thrall_vd01.png','data/visuals/thrall_frames_vd01.tres','data/visuals/thrall_vd01.tres']),
 ('E02','enemy skittering_brinejaw',['assets/source/visual-vd01/brinejaw.ora','assets/source/visual-vd01/brinejaw.manifest.json'],['assets/sprites/enemies/brinejaw_vd01.png','data/visuals/brinejaw_frames_vd01.tres','data/visuals/brinejaw_vd01.tres']),
 ('W01','coast visual only',['assets/source/visual-vd01/shrine.ora','assets/source/visual-vd01/shrine.manifest.json'],['assets/tiles/coast_shrine/terrain_vd01.png','assets/tiles/coast_shrine/props_vd01.png','assets/tiles/coast_shrine/corruption_vd01.png','data/visuals/coast_shrine_tileset.tres']),
 ('F01','base arc48/100',['assets/source/visual-vd01/effects.ora','assets/source/visual-vd01/effects.manifest.json'],['assets/effects/slice/sword_arc_vd01.png','data/visuals/sword_frames_vd01.tres']),
 ('F02','existing friendly base homing',['assets/source/visual-vd01/effects.ora','assets/source/visual-vd01/effects.manifest.json'],['assets/effects/slice/homing_star_vd01.png','data/visuals/star_frames_vd01.tres']),
 ('U01','CombatHUD',['scripts/ui/combat_hud.gd','data/themes/expedition_theme.tres'],['scenes/ui/combat_hud.tscn']),
 ('U02','level_up',['scripts/ui/level_up.gd','scripts/ui/components/choice_card.gd','data/themes/expedition_theme.tres'],['scenes/ui/level_up.tscn','scenes/ui/components/choice_card.tscn'])]
delivery=read(E/'asset-delivery.json');delivery['deliveries']=[{'id':id,'selector':selector,'creator':'Codex / original local pixel geometry and native UI','concept_date':'2026-10-16','production_date':'2026-10-17','rights':'original project assets; no external artwork or font binaries copied','source':[entry(p) for p in source],'exports':[entry(p) for p in exports],'state_anchor_manifest':'see source manifest; native region/state checks passed','G1':'approved original concept','integration':'current candidate','G2':'pending'} for id,selector,source,exports in specs];delivery['source_files']=[entry(p.relative_to(R).as_posix()) for p in sorted((R/'assets/source/visual-vd01').glob('*')) if p.is_file()];delivery['candidate_sha256']=ch;put('asset-delivery.json',delivery)
lighting=read(E/'lighting-budget.json');lighting.update(painted_prop_details=1,ground_overlay_instances=3,ground_overlay_crop='native branch-only64x32; shrine eye stays on prop at finalZ-10',static_prop_designs=6,prop_regions=[[0,0,64,96]]+[[64+32*i,0,32,64] for i in range(5)]);put('lighting-budget.json',lighting)
counts={}
for p in (E/'final-r4').glob('*.log'):
 for name,count,fail in re.findall(r'SUITE (\w+): (\d+) assertions; (\d+) failures;',p.read_text(errors='replace')):
  assert fail=='0',(p,fail);counts[name]=int(count)
assert len(counts)==12 and sum(counts.values())==5275,counts
put('final-regression.md',f'''# Final corrected candidate · 2026-10-17

`run_validation.ps1 -M4 -Graphical -Export -DummyAudio -EvidenceDirectory docs/validation/visual-vd01/final-r4` completed the pinned4.5 import/parse/content, all12 suites, all four source graphical checks, release export and actual release graphical check. Primary **5,275** assertions,0 failures/skips in this full run; debug69 separately. Counts:{json.dumps(counts,sort_keys=True)}.

New fixtures execute in their designated suites. Scene175 includes original-master prop regions, all6 nonblank independently cropped cells,0/100 painted shrine detail and depth. Original queued-input/keyboard/pause assertions remain. Red/green4-failure prop-region proof retained. Three automated starter outcomes match previous observations. Current content digest1eb094cd5188983e9a8890e4ffa43ad87a39ffd2d657a90b5c8886f439008fe5; simulation m4-convergence-1 unchanged.

Previous failed runs are retained: fixed historical PNG overwrites were solved by independent capture destinations; final-r3 import treated evidence CSV as localization and failed. docs/validation and screenshots now have .gdignore, keeping test evidence outside Godot resource import/export. No engine error was waived. The final-r4 clean run includes the corrected six-prop regions and original painted shrine eye/branches. Earlier04a8 pack/measurements remain explicitly intermediate.

Native captures are controlled engine views, not physical-window photos. Headless/native input tests are not a human play session. G2/reference-machine/latency/human criteria remain open. [Actual old/new EXE120tick comparison](comparison/gameplay-r1/comparison.json) retains separate catalog hashes and replay protection.
''')
print('RECORDED FINAL CANDIDATE',ch,'PACK',pack,'ASSERTIONS',sum(counts.values()))
