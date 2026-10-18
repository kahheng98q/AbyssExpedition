"""One-time visual rollback archive. Never overwrites an earlier baseline."""
from pathlib import Path
import hashlib,json,shutil
R=Path(__file__).resolve().parents[1];O=R/'docs/validation/visual-vd01/before'
if (O/'rollback-manifest.json').exists():raise SystemExit('Baseline already exists; preserve it.')
O.mkdir(parents=True,exist_ok=True);(O/'.gdignore').write_text('')
files=[]
for d in ('scripts','scenes','data','assets','tests'):
    files += [p for p in (R/d).rglob('*') if p.is_file() and p.suffix not in ('.uid','.import')]
files += [R/'project.godot',R/'export_presets.cfg']
rows=[]
for p in files:
    rel=p.relative_to(R);target=O/'source'/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target)
    rows.append({'path':rel.as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
for folder,glob in [('screenshots','*.png'),('docs/validation','*.log')]:
    for p in (R/folder).glob(glob):
        dst=O/'fixed-output-history'/p.relative_to(R);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
for p in (R/'builds/windows/m4').glob('*.exe'):
    dst=O/'build'/p.name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
(O/'rollback-manifest.json').write_text(json.dumps({'date':'2026-10-16','method':'copied prior to any runtime implementation edit','files':rows,'engine':'4.5.stable.official.876b29033','restore':'Close game/editor. Restore only changed presentation scripts/scenes/resources from source/; remove new visual files listed by implementation record. Never restore profile data. Retain both old/new evidence.','fixed_outputs':'All root screenshots PNG and validation logs preserved under fixed-output-history/; before embedded release EXE retained under build/.','profiles':'No permanent profile opened or copied.'},indent=2),encoding='utf-8')
print('Archived',len(rows),'source files and prior screenshots/logs/builds')
