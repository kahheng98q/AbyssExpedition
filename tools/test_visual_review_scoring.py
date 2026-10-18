"""Synthetic scorer tests; these are never actual participant results."""
import copy
import importlib.util
from pathlib import Path

path = Path(__file__).with_name('score_visual_reviews.py')
spec = importlib.util.spec_from_file_location('scorer', path)
scorer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(scorer)
material = {'material_sha256': 'TEST', 'candidate_sha256': 'TEST',
            'frames': {key: {'sha256': key} for key in ['normal', 'dense', 'max-corruption']},
            'ui': {key: {'sha256': key} for key in ['hp', 'levels', 'focus']}}
reviewer = {'reviewer': 'SYNTHETIC TEST ONLY', 'date': 'TEST', 'material_sha256': 'TEST',
            'participants': [f'TEST-{i}' for i in range(10)]}
empty = scorer.summarize(material, [])
assert empty['overall'] == 'pending' and len(empty['cells']) == 42
rows = []
for cell in empty['cells']:
    for i, person in enumerate(reviewer['participants']):
        rows.append({**{key: cell[key] for key in ['kind', 'condition_or_task', 'size', 'item']},
                     'participant': person, 'response': 'SYNTHETIC', 'correct': str(i < 8).lower(),
                     'valid': 'true', 'clip_sha256': cell['condition_or_task'], 'response_signal_ms': '4000'})
assert scorer.summarize(material, rows, reviewer)['overall'] == 'pass'
assert scorer.summarize(material, rows[:-1], reviewer)['overall'] == 'pending'
failed = copy.deepcopy(rows)
failed[0]['correct'] = 'false'
assert scorer.summarize(material, failed, reviewer)['overall'] == 'fail'
unscored = copy.deepcopy(rows)
for row in unscored: row['correct'] = ''
assert scorer.summarize(material, unscored, reviewer)['scored_rows'] == 0
for kind in ['duplicate', 'hash', 'invalid', 'late', 'outside', 'missing-reviewer']:
    bad = copy.deepcopy(rows)
    owner = reviewer
    if kind == 'duplicate': bad.append(bad[0])
    if kind == 'hash': bad[0]['clip_sha256'] = 'WRONG'
    if kind == 'invalid': bad[0]['valid'] = 'false'
    if kind == 'late': next(r for r in bad if r['kind'] == 'ui')['response_signal_ms'] = '5001'
    if kind == 'outside': bad[0]['participant'] = 'NOT IN COHORT'
    if kind == 'missing-reviewer': owner = None
    try:
        scorer.summarize(material, bad, owner)
    except ValueError:
        continue
    raise AssertionError('Failed to reject ' + kind)
print('SCORER: 11 synthetic checks passed; no actual human results created.')
