"""Read-only project inventory; outputs only into docs/validation/visual-vd01."""
from pathlib import Path
import hashlib, json, re

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / 'docs/validation/visual-vd01'
OUT.mkdir(parents=True, exist_ok=True)
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def record(p):
    return {'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':digest(p)}
runtime = sorted(p for folder in ('scripts','scenes','data','assets','tests') for p in (ROOT/folder).rglob('*') if p.is_file() and p.suffix not in ('.import','.uid'))
runtime += [ROOT/'project.godot',ROOT/'export_presets.cfg']
historical = [ROOT/'screenshots'/n for n in ('m4-release-boss-double-eruption-1280.png','convergence-exe-m2-promotion-aren-1280.png','convergence-exe-m2-selection-1280.png','convergence-exe-m4-guild-1280.png','menu.png')]
base = OUT/'audit-baseline.json'
if not base.exists():
    payload = {'revision':'VD-01-M1','date':'2026-10-16','method':'read-only source inspection; no engine execution',
      'engine_pin':'4.5.stable.official.876b29033','viewport':[640,360],'camera_zoom':[1,1],'world':[960,540],
      'selectors':{'hero':['aren','swordsman'],'enemies':['saltbound_thrall','skittering_brinejaw']},
      'data_visuals_directory_exists':(ROOT/'data/visuals').exists(),
      'runtime_files':[record(p) for p in runtime], 'historical_images':[dict(record(p),status='REAL / historical; not newly captured') for p in historical],
      'benchmark_references':['docs/benchmarks/m4.md','docs/validation/convergence-2026-10-15.md'],
      'historical_p95_ms':[27.571,27.670,29.259], 'performance_status':'historical failure, no new measurement',
      'asset_files':[record(p) for p in (ROOT/'assets').rglob('*') if p.is_file()]}
    base.write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding='utf-8')
    (OUT/'preview-before.html').write_bytes((ROOT/'docs/visual-design/preview.html').read_bytes())
else:
    payload=json.loads(base.read_text(encoding='utf-8'))
    changed=[r['path'] for r in payload['runtime_files'] if not (ROOT/r['path']).exists() or digest(ROOT/r['path'])!=r['sha256']]
    assert not changed, changed
print(json.dumps({'protected_runtime_files':len(payload['runtime_files']),'historical_images':len(payload['historical_images']),'assets':len(payload['asset_files']),'runtime_unchanged':True}))
