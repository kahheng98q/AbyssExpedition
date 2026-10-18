"""Summarize the external UI audit without rebuilding or accepting a candidate."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / 'docs/validation/visual-vd01'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


candidate = read(EVIDENCE / 'candidate-files.json')
unchanged = all(sha(ROOT / row['path']) == row['sha256'] for row in candidate['runtime_files'])
pack = sha(ROOT / 'builds/windows/m4/AbyssExpedition.exe')
assert unchanged and pack == candidate['embedded_release_sha256']
assert sha(ROOT / 'docs/visual-design/mockups/vd01/package.json') == candidate['concept_package_sha256']
sets = []
for role, folder in [('source', 'source-r3'), ('release', 'release-r2')]:
    path = EVIDENCE / 'ui-boundary' / folder / 'audit.json'
    audit = read(path)
    context = read(path.with_name('context.json'))
    assert not audit['failures'] and audit['catalog_unchanged']
    if role == 'release':
        assert context['embedded_pack_sha256'].lower() == pack
    current = [r for r in audit['records'] if r['fixture'] == 'current catalog values']
    synthetic = [r for r in audit['records'] if r not in current]
    assert len(current) == 30 and len(synthetic) == 21
    assert all(r['missing_glyph_labels'] == 0 for r in current)
    assert all(r.get('panel_inside_viewport', True) and r.get('horizontal_content_fits', True) for r in current)
    huge = [r for r in synthetic if 'huge-values' in r['name'] or 'int64-coins' in r['name']]
    numeric = [label for r in huge for label in r['labels'] if label['text'].startswith(('HP ', 'XP ')) or 'Coins ' in label['text']]
    assert all(not label['crosses_container'] for label in numeric)
    effects = [r for r in synthetic if 'long-effects' in r['name']]
    assert all(r['horizontal_content_fits'] and r['scroll_max_y'] > r['scroll_page_y'] for r in effects)
    glyphs = {ord(c) for r in current for label in r['labels'] for c in label['text'] if ord(c) > 32}
    sets.append({'role': role, 'audit': path.relative_to(ROOT).as_posix(), 'audit_sha256': sha(path),
                 'context': context, 'records': len(audit['records']), 'current_catalog_cases': len(current),
                 'synthetic_boundary_cases': len(synthetic), 'unique_current_text_codepoints': len(glyphs),
                 'strict_failures': audit['failures'], 'catalog_unchanged': audit['catalog_unchanged'],
                 'current_missing_glyph_labels': 0, 'numeric_samples_within_containers': len(numeric),
                 'long_effects_wrap_and_vertical_scroll': True})
assert sets[0]['context']['harness_sha256'] == sets[1]['context']['harness_sha256']
result = {'candidate_sha256': candidate['candidate_sha256'], 'embedded_release_sha256': pack,
          'production_files_unchanged': unchanged, 'concept_package_unchanged': True, 'sets': sets,
          'strict_scope': 'Font.has_char coverage, current modal panel position and horizontal content extent only. Not zero clipped ink, full manual acceptance or a new unique assertion total.',
          'confirmed_synthetic_limits': ['Long hero name extends beyond hero panel and is occluded by XP panel.',
                                         'Long upgrade heading extends beyond its button and is clipped at scroll viewport.'],
          'existing_geometry_diagnostic': 'Abyss label Control extends one native pixel below its panel; no clipping ancestor. This is not an ink-clipping verdict or new area pass.',
          'not_measured': ['pixel ink bounds', 'physical window margins', 'natural manual session', 'tooltip edge matrix',
                           'long save paths', 'physical feedback latency', 'ten-person recognition/UI review'],
          'first_attempt': 'source-r1 is superseded: shallow-copy effects contaminated later synthetic samples; panel-rectangle overhang was also incorrectly classified as fatal. Source-r3/release-r2 duplicate the effects array, verify unchanged labels/effects, and separate diagnostics from strict checks.',
          'gate': 'G2 remains pending; no baseline replacement or G3 authorization inferred.'}
(EVIDENCE / 'ui-boundary/summary.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print('UI AUDIT: 102 observations; 60 current/42 synthetic; strict checks pass; 2 synthetic limitations; frozen production hashes unchanged.')
