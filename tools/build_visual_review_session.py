"""Freeze existing engine renders for an offline, uncoached review; no new artwork."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / 'docs/validation/visual-vd01/completion-r2'
CAPTURE = ROOT / 'screenshots/visual-vd01/completion-r2/cache-release'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def canonical(data):
    return json.dumps(data, sort_keys=True, separators=(',', ':')).encode()


def build():
    previous = json.loads((EVIDENCE.parent / 'completion-r1/candidate-files.json').read_text(encoding='utf-8'))
    runtime = [{'path': row['path'], 'sha256': sha(ROOT / row['path'])} for row in previous['runtime_files']]
    changes = [row for old, row in zip(previous['runtime_files'], runtime) if old != row]
    assert {row['path'] for row in changes} == {'scripts/combat/actor_presentation.gd', 'scripts/combat/melee_arc.gd'}
    payload = {'runtime_files': runtime, 'embedded_release_sha256': sha(ROOT / 'builds/windows/m4/AbyssExpedition.exe'), 'engine': previous['engine']}
    candidate = hashlib.sha256(canonical(payload)).hexdigest()
    payload.update(candidate_sha256=candidate, revision='VD-01-P3 / retained draw commands',
                   parent_candidate_sha256=previous['candidate_sha256'],
                   concept_package_sha256=previous['concept_package_sha256'],
                   status='current local validation; no G2 quantitative acceptance or G3 inferred')
    assert sha(ROOT / 'docs/visual-design/mockups/vd01/package.json') == previous['concept_package_sha256']
    (EVIDENCE / 'candidate-files.json').write_text(json.dumps(payload, indent=2), encoding='utf-8')
    (EVIDENCE / 'production-changes.json').write_text(json.dumps(changes, indent=2), encoding='utf-8')
    protocol = EVIDENCE.parent / 'recognition-protocol.json'
    frames = {}
    for condition in ['normal', 'dense', 'max-corruption']:
        rows = [{'file': f'recognition/{condition}/frame-{i:03d}.png',
                 'sha256': sha(CAPTURE / f'recognition/{condition}/frame-{i:03d}.png')} for i in range(60)]
        frames[condition] = {'frames': rows, 'sha256': hashlib.sha256(canonical(rows)).hexdigest()}
    ui = {name: {'file': filename, 'sha256': sha(CAPTURE / filename)} for name, filename in
          [('hp', 'combat-c100-1280.png'), ('levels', 'combat-c100-1280.png'), ('focus', 'level-up-1280.png')]}
    data = {'revision': 'VD-01-P3-review-01', 'candidate_sha256': candidate,
            'embedded_release_sha256': payload['embedded_release_sha256'],
            'protocol_sha256': sha(protocol), 'protocol_revision': 'VD-01-M1-recognition-01',
            'folder': '../../screenshots/visual-vd01/completion-r2/cache-release/',
            'frames': frames, 'ui': ui, 'results': 'none; preparation only'}
    data['material_sha256'] = hashlib.sha256(canonical(data)).hexdigest()
    (EVIDENCE / 'review-material-index.json').write_text(json.dumps(data, indent=2), encoding='utf-8')
    (ROOT / 'docs/visual-design/review-session-data.js').write_text('window.VD_REVIEW_DATA=' + json.dumps(data) + ';\n', encoding='utf-8')
    print('Review materials frozen: 180 actual frames, 3 UI tasks; zero participant results.')


if __name__ == '__main__':
    build()
