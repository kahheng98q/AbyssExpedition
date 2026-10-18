"""Evidence for the scoped VD01 text/motion completion; never fabricates acceptance."""
from pathlib import Path
import hashlib
import json
import re
from PIL import Image, ImageChops

R = Path(__file__).resolve().parents[1]
E = R / 'docs/validation/visual-vd01'
C = E / 'completion-r1'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def put(name, data):
    path = C / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')


def rectangle_union(boxes):
    rects = [(max(0, x), max(0, y), min(640, x+w), min(360, y+h)) for x, y, w, h in boxes]
    xs = sorted({value for left, bottom, right, top in rects for value in [left, right]})
    area = 0
    for left, right in zip(xs, xs[1:]):
        end = -1
        length = 0
        for bottom, top in sorted((b, t) for l, b, r, t in rects if l < right and r > left):
            if top > end:
                length += max(0, top - max(bottom, end))
                end = top
        area += (right-left) * length
    return area


prior = read(E / 'owner-verified-f187/evidence/candidate-files.json')
runtime = [{'path': row['path'], 'sha256': sha(R / row['path'])} for row in prior['runtime_files']]
pack = sha(R / 'builds/windows/m4/AbyssExpedition.exe')
payload = {'runtime_files': runtime, 'embedded_release_sha256': pack, 'engine': prior['engine']}
candidate = hashlib.sha256(json.dumps(payload, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
payload.update(candidate_sha256=candidate, revision='VD-01-P2 / text containment completion',
               owner_verified_parent=prior['candidate_sha256'],
               concept_package_sha256=prior['concept_package_sha256'],
               status='current scoped fixes; no quantitative acceptance or G3 inferred')
assert sha(R / 'docs/visual-design/mockups/vd01/package.json') == prior['concept_package_sha256']
changes = [row for old, row in zip(prior['runtime_files'], runtime) if old['sha256'] != row['sha256']]
assert {row['path'] for row in changes} == {'scripts/ui/combat_hud.gd', 'scripts/ui/components/choice_card.gd', 'scripts/ui/pause_menu.gd'}
put('candidate-files.json', payload)
put('production-changes.json', changes)

counts = {}
for path in (C / 'regression').glob('*.log'):
    for name, count, fail in re.findall(r'SUITE (\w+): (\d+) assertions; (\d+) failures;', path.read_text(errors='replace')):
        assert fail == '0'
        counts[name] = int(count)
assert len(counts) == 12 and sum(counts.values()) == 5278
debug = (C / 'debug/debug-panel.log').read_text()
assert '69 assertions; 0 failures' in debug
put('regression-summary.json', {'suites': counts, 'primary_assertions': sum(counts.values()), 'debug_assertions': 69,
                               'total': sum(counts.values()) + 69, 'graphical_checks': 'source/release/debug logs retained separately',
                               'limits': 'automated execution, not human acceptance'})

audit_sets = []
for role in ['source', 'release']:
    folder = C / ('text-' + role)
    audit = read(folder / 'audit.json')
    context = read(folder / 'context.json')
    assert not audit['failures'] and audit['catalog_unchanged'] and len(audit['records']) == 54
    if role == 'release':
        assert context['embedded_pack_sha256'].lower() == pack
    names = [row for row in audit['records'] if 'name_and_level_contained' in row]
    headings = [row for row in audit['records'] if 'full_headings_wrap_inside_cards' in row]
    assert len(names) == 3 and all(row['name_and_level_contained'] for row in names)
    assert len(headings) == 6 and all(row['full_headings_wrap_inside_cards'] for row in headings)
    audit_sets.append({'role': role, 'context': context, 'records': len(audit['records']), 'failures': [],
                       'long_name_containment': True, 'full_heading_wrap': True,
                       'manifest': (folder / 'audit.json').relative_to(R).as_posix()})
assert audit_sets[0]['context']['harness_sha256'] == audit_sets[1]['context']['harness_sha256']
put('text-summary.json', {'candidate_sha256': candidate, 'sets': audit_sets, 'observations': 108,
                         'red_proof': 'text-red/audit.json: 12 failures before fix',
                         'scope': 'current catalog and named synthetic fixtures; not arbitrary future text or ink-bound acceptance'})

capture_sets = []
margins = []
for role in ['source', 'release']:
    folder = R / 'screenshots/visual-vd01/completion-r1' / (role + '-r2')
    capture = read(folder / 'capture-manifest.json')
    context = read(folder / 'capture-context.json')
    assert capture['failures'] == 0 and len(capture['records']) == 287
    if role == 'release':
        assert context['embedded_pack_sha256'].lower() == pack
    capture_sets.append({'role': role, 'context': context, 'records': 287,
                         'manifest': (folder / 'capture-manifest.json').relative_to(R).as_posix()})
    for row in capture['records']:
        if row['name'].startswith('combat-c100-'):
            a, b, c, d, x, y = row['window_content_transform']
            width, height = row['window_observed']
            assert b == c == 0 and a == d and a in [2, 3]
            margins.append({'role': role, 'window': [width, height], 'integer_scale': a,
                            'left_top_right_bottom': [x, y, width - 640 * a - x, height - 360 * d - y],
                            'method': 'observed engine Window final transform; not physical-window screenshot'})
put('capture-summary.json', {'candidate_sha256': candidate, 'sets': capture_sets, 'observations': 574})
put('window-transforms.json', margins)

hud_rows = []
for row in capture['records']:
    if not row['name'].startswith(('combat-', 'rescue-', 'edge-')):
        continue
    area = rectangle_union(row['hud_rects'].values())
    entry = {'name': row['name'], 'area_px': area, 'fraction': area/230400,
             'within_25_percent': area <= 57600, 'visible_control_rectangles': row['hud_rects']}
    if row['name'].startswith('edge-'):
        x, y = row['hero_position']
        cx, cy = row['camera']
        foot = [x-min(640, max(320, cx))+320, y-min(360, max(180, cy))+180]
        entry.update(foot_derived_from_world_and_camera_limits=foot,
                     foot_occluded_by_hud=any(bx <= foot[0] < bx+w and by <= foot[1] < by+h for bx, by, w, h in row['hud_rects'].values()))
    hud_rows.append(entry)
assert all(row['within_25_percent'] and not row.get('foot_occluded_by_hud', False) for row in hud_rows)
hud = read(E / 'owner-verified-f187/evidence/hud-acceptance.json')
hud.update(candidate='VD-01-P2', candidate_sha256=candidate, captures=hud_rows,
           max_fraction=max(row['fraction'] for row in hud_rows), all_area_within_25_percent=True,
           current_report='completion-r1.md', physical_window_verified=False,
           glyph_clipping='Current catalog and named long-name/heading/large-number fixtures inspected in source/release; independent pixel-ink bounds and complete manual matrix remain open.',
           physical_window_letterbox='Actual engine Window integer transforms/margins recorded; physical-window screenshots and display shimmer remain open.')
put('hud-acceptance.json', hud)
(E / 'hud-acceptance.json').write_text(json.dumps(hud, indent=2), encoding='utf-8')
layout = {'historical_phase4': read(E / 'owner-verified-f187/evidence/ui-layout.json')}
layout.update(current_revision='VD-01-P2', candidate_sha256=candidate,
              method='Current union of all visible HUD panels/descendant Controls; historical panel-only measurements are nested separately.',
              current_native_evidence='completion-r1/capture-summary.json',
              actual_engine_window_transforms='completion-r1/window-transforms.json',
              current_text_evidence='completion-r1/text-summary.json',
              long_values='Named large-number and long-text source/release fixtures verified; details in text-summary.',
              nearby_edge_warning='Dedicated actual8 edge/corner fixtures at three requested sizes, native inspection and derived foot/HUD checks complete.',
              max_fraction=hud['max_fraction'], limitations='Native layout and named fixtures verified; physical window/shimmer, full natural manual session and ten-person tasks remain open.')
(E / 'ui-layout.json').write_text(json.dumps(layout, indent=2), encoding='utf-8')

auxiliary = []
for role in ['source', 'release']:
    folder = C / ('aux-' + role)
    auxiliary_manifest = read(folder / 'manifest.json')
    assert not auxiliary_manifest['failures'] and len(auxiliary_manifest['records']) == 24
    saves = [row for row in auxiliary_manifest['records'] if row['name'].startswith('save-')]
    tips = [row for row in auxiliary_manifest['records'] if row['name'].startswith('tooltip-')]
    assert all(row['panel_inside_viewport'] and row['full_path_preserved'] and not row['writes_attempted'] for row in saves)
    assert all(row['tooltip_observed'] and row['bounds_in_640x360'] for row in tips)
    context = read(folder / 'context.json')
    if role == 'release':
        assert context['embedded_pack_sha256'].lower() == pack
    auxiliary.append({'role': role, 'records': 24, 'save_states': len(saves), 'observed_tooltip_corners': len(tips),
                      'context': context, 'manifest': (folder / 'manifest.json').relative_to(R).as_posix()})
put('auxiliary-ui-summary.json', auxiliary)

delivery = read(E / 'owner-verified-f187/evidence/asset-delivery.json')
delivery['revision'] = 'VD-01-P2'
delivery['pixel_asset_revision'] = 'VD-01-P1 / owner-approved VD-01-M1 pixels unchanged'
delivery['production_note'] = 'Original pixel sources/exports unchanged from owner-verified f187 reference. P2 changes only3 native UI text presentation scripts; actual hashes refreshed. Quantitative/physical/ten-person gates remain open.'
delivery['candidate_sha256'] = candidate
delivery['owner_verified_parent'] = prior['candidate_sha256']
for item in delivery['deliveries']:
    for group in ['source', 'exports']:
        for row in item[group]:
            row['sha256'] = sha(R / row['path'])
    item['G2'] = 'Owner verified parent visual reference; current scoped UI fixes automatically verified; quantitative gates open.'
put('asset-delivery.json', delivery)

diffs = []
original = R / 'screenshots/visual-vd01/after/release-r3'
current = R / 'screenshots/visual-vd01/completion-r1/release-r2'
for path in sorted(original.glob('*.png')):
    fresh = current / path.name
    if not fresh.exists():
        continue
    diff = ImageChops.difference(Image.open(path).convert('RGB'), Image.open(fresh).convert('RGB'))
    red, green, blue = diff.split()
    mask = ImageChops.lighter(ImageChops.lighter(red, green), blue).point(lambda value: 255 if value else 0)
    diffs.append({'name': path.name, 'changed_pixels': mask.histogram()[255], 'prior_sha256': sha(path), 'current_sha256': sha(fresh)})
put('verified-parent-image-comparison.json', {'pairs': diffs, 'kind': 'DERIVED pixel comparison, not a fabricated screenshot'})

gallery = {}
frame_index = []
for role, folder_name, label in [('release', 'wallclock-release', '当前发布版'), ('source', 'wallclock-source-r2', '当前源码 · 含开发倍速'), ('before', 'wallclock-before', '原版 · 保留EXE')]:
    folder = R / 'screenshots/visual-vd01/completion-r1' / folder_name
    capture = read(folder / 'manifest.json')
    context = read(folder / 'context.json')
    assert not capture['failures']
    frame_index.append({'role': role, 'frames': [{'path': (folder / row['image']).relative_to(R).as_posix(),
                                                'sha256': sha(folder / row['image']), 'elapsed_usec': row['elapsed_usec'],
                                                'segment': row['segment']} for row in capture['records']]})
    if role == 'release':
        assert context['embedded_pack_sha256'].lower() == pack
    gallery[role] = {'label': label, 'folder': '../../screenshots/visual-vd01/completion-r1/' + folder_name + '/',
                     'context': context, 'segments': capture['segments'], 'records': capture['records']}
assert len({row['context']['harness_sha256'] for row in gallery.values()}) == 1
assert gallery['before']['context']['embedded_pack_sha256'].lower() == sha(E / 'before/build/AbyssExpedition.exe')
put('wallclock-frame-index.json', frame_index)
(R / 'docs/visual-design/wallclock-data.js').write_text('window.VD_WALLCLOCK=' + json.dumps(gallery, ensure_ascii=False) + ';\n', encoding='utf-8')
put('wallclock-summary.json', {'sets': [{'role': role, 'context': row['context'], 'records': len(row['records']), 'segments': row['segments']} for role, row in gallery.items()],
                              'method': 'elapsed Time.get_ticks_usec timestamps, native process/render loop, actual simulation clock; explicit injected observer events are named',
                              'limits': 'not physical display/video latency, reference performance, natural manual session or ten-person review'})

performance = []
for workload, folder_name in [('M4', 'perf'), ('P02', 'perf-visual')]:
    folder = C / folder_name
    for seed in [101, 202, 303]:
        path = folder / f'm4-{seed}.json'
        if not path.exists():
            continue
        row = read(path)
        assert row['capture_valid'] and row['capture_active_seconds'] >= 120 and row['warmup_active_seconds'] >= 30 and not row['debug_build']
        assert row['window_observed'] == [1920, 1080] and row['vsync_observed'] == 0 and row['engine_max_fps'] == 0
        if workload == 'P02':
            assert row['minimums']['new_arcs'] >= 30 and row['minimums']['new_stars'] >= 100 and row['minimums']['new_actors'] >= 1
        performance.append({'workload': workload, 'seed': seed, 'p50_ms': row['p50_ms'], 'p95_ms': row['p95_ms'],
                            'p99_ms': row['p99_ms'], 'max_ms': row['max_ms'], 'budget_pass': row['frame_budget_pass'],
                            'raw': path.relative_to(R).as_posix()})
put('performance-summary.json', {'candidate_sha256': candidate, 'embedded_release_sha256': pack,
                               'full_results': performance, 'measurement_complete': len(performance) == 6,
                               'reference_acceptance': False, 'latency_measured': False})
if len(performance) == 6:
    assert read(C / 'perf/host.json')['pack_sha256'].lower() == pack
    assert read(C / 'perf-visual/host.json')['embedded_pack_sha256'].lower() == pack
    assert read(C / 'perf-visual/host.json')['fixture_sha256'] == read(E / 'before/perf-visual-r1/host.json')['fixture_sha256']
    lines = ['# VD-01-P2 full performance measurement', '',
             'Current embedded pack `' + pack + '`. Current host AMD Ryzen7 5800H / GTX1650; not the required i5-8400/1050Ti reference. Balanced power scheme; effective power/OS foreground not independently observed; RAM query unavailable. Compatibility1920x1080, VSync0, uncapped, Dummy diagnostic audio. All six captures:30active seconds warmup +120active seconds measurement; release; valid populations. No other graphical test was run concurrently with either measurement set; light document/file work occurred.', '',
             '| workload | seed | p50 ms | p95 ms | p99 ms | max ms | budget |', '| --- | --- | --- | --- | --- | --- | --- |']
    for row in performance:
        lines.append('| {workload} | {seed} | {p50_ms:.3f} | {p95_ms:.3f} | {p99_ms:.3f} | {max_ms:.3f} | '.format(**row) + ('PASS' if row['budget_pass'] else 'FAIL') + ' |')
    lines += ['', 'Each seed requires p95<=16.67ms AND p99<=25ms. Valid capture does not mean budget acceptance. No reference-machine or physical latency pass claimed. Current measurements are not causally attributed to the text fix; compare workload/host/runner conditions and raw data before drawing that inference.', '',
              'P02 preserves the inherited population targets and verifies >=30 actual new base arcs, >=100 actual new friendly basic stars, >=1 matched new actor and separate fallback counts. Real effect lifetimes remain unchanged. Matching retained-before fixture SHA256 is checked. Original M4 and P02 are independent workloads; values are never pooled.', '',
              'Raw current data: [M4 results/OS memory metadata](perf/results.json), [M4 host](perf/host.json), [P02 host](perf-visual/host.json), per-seed JSON/CSV/logs in both folders. Zero release static-memory monitor means unavailable; M4 process CSV records OS memory. No external profiler/video device was attached.', '',
              'Retained original before results and prior f187 measurements remain in [the previous performance ledger](../performance.md); no historic sample was relabeled. P02 before fixture hash remains frozen; no claim that the source-only short diagnostic is full acceptance.']
    (C / 'performance.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print('CURRENT', candidate, 'PACK', pack, 'ASSERTIONS', sum(counts.values()) + 69,
      'TEXT', 108, 'NATIVE', 574, 'FULL_PERF', len(performance), '/6')
