"""Count independently scored raw responses; missing people/answers never become passes."""
from pathlib import Path
import argparse
import csv
import json
import math

ROOT = Path(__file__).resolve().parents[1]
MATERIAL = ROOT / 'docs/validation/visual-vd01/completion-r2/review-material-index.json'
ITEMS = ['hero', 'thrall', 'brinejaw', 'direction', 'friendly_magic', 'danger']


def summarize(material, rows, reviewer=None):
    cells = {}
    for size in ['1280x720', '1920x1080']:
        for condition in material['frames']:
            for item in ITEMS:
                cells[('recognition', condition, size, item)] = {}
        for task in material['ui']:
            cells[('ui', task, size, 'answer')] = {}
    if rows:
        if not reviewer or not reviewer.get('reviewer') or not reviewer.get('date'):
            raise ValueError('Actual scoring requires a named reviewer and date; no automatic human approval.')
        if reviewer.get('material_sha256') != material['material_sha256']:
            raise ValueError('Reviewer record does not identify these frozen materials.')
        cohort = reviewer.get('participants', [])
        if len(set(cohort)) != len(cohort) or len(cohort) > 10 or not cohort:
            raise ValueError('Specify a unique cohort of at most ten actual participants.')
    seen = set()
    raw_count = len(rows)
    scored = 0
    for row in rows:
        key = (row['kind'], row['condition_or_task'], row['size'], row['item'])
        if key not in cells:
            raise ValueError('Unknown condition, size or item: ' + repr(key))
        person = row['participant']
        if person not in reviewer['participants']:
            raise ValueError('Participant is outside the declared cohort.')
        if (person, key) in seen:
            raise ValueError('Duplicate answer for the same person/condition/size/item.')
        seen.add((person, key))
        expected = material['frames'][key[1]]['sha256'] if key[0] == 'recognition' else material['ui'][key[1]]['sha256']
        if row['clip_sha256'] != expected:
            raise ValueError('Changed or wrong clip/image hash.')
        correct = row.get('correct', '').strip().lower()
        if not correct:
            continue
        if correct not in ['true', 'false']:
            raise ValueError('Correct must be blank, true or false; it is supplied by an independent reviewer.')
        if row.get('valid', '').lower() != 'true':
            raise ValueError('Invalid or missing exposure cannot be scored as an accepted trial.')
        if not row.get('response', '').strip():
            raise ValueError('A scored answer must retain the original response.')
        if key[0] == 'ui':
            elapsed = float(row['response_signal_ms'])
            if not math.isfinite(elapsed) or not 0 <= elapsed <= 5000:
                raise ValueError('UI response signal must be finite and within five seconds.')
        cells[key][person] = correct == 'true'
        scored += 1
    result = []
    for key, answers in cells.items():
        count = len(answers)
        correct = sum(answers.values())
        result.append({'kind': key[0], 'condition_or_task': key[1], 'size': key[2], 'item': key[3],
                       'scored_participants': count, 'correct': correct,
                       'status': 'pending' if count < 10 else 'pass' if correct >= 8 else 'fail'})
    return {'material_sha256': material['material_sha256'], 'candidate_sha256': material['candidate_sha256'],
            'reviewer_record': reviewer, 'raw_rows': raw_count, 'scored_rows': scored,
            'required_participants': 10, 'cells': result,
            'overall': 'pass' if all(c['status'] == 'pass' for c in result) else
                       'fail' if any(c['status'] == 'fail' for c in result) else 'pending',
            'limits': 'Counts reviewer-supplied judgments only; does not authenticate participants, exact-value/save omissions, physical latency or G2 approval.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input-csv', action='append', default=[])
    parser.add_argument('--reviewer-json')
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    material = json.loads(MATERIAL.read_text(encoding='utf-8'))
    rows = []
    for name in args.input_csv:
        with Path(name).open(encoding='utf-8-sig', newline='') as stream:
            rows.extend(csv.DictReader(stream))
    reviewer = json.loads(Path(args.reviewer_json).read_text(encoding='utf-8')) if args.reviewer_json else None
    result = summarize(material, rows, reviewer)
    output = Path(args.output)
    if output.exists():
        raise ValueError('Preserve prior scoring; choose a fresh output file.')
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f"REVIEW: {result['raw_rows']} raw rows, {result['scored_rows']} scored; {result['overall']}.")


if __name__ == '__main__':
    main()
