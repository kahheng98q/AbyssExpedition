"""Offline links, original stimuli hashes, task markers and documentation audit."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import unquote, urlsplit
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / 'docs/validation/sword-promotion-identity'
FEATURE = ROOT / 'specs/003-sword-promotion-identity'


class Audit(HTMLParser):
    def __init__(self):
        super().__init__()
        self.refs, self.images, self.errors = [], 0, []

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        for field in ('src', 'href'):
            if field in a:
                self.refs.append(a[field])
                if field == 'src' and urlsplit(a[field]).scheme in ('http', 'https'):
                    self.errors.append('remote runtime: ' + a[field])
        if tag == 'img':
            self.images += 1
            if not a.get('alt', '').strip():
                self.errors.append('missing alt')


def audit_tasks(body):
    rows = re.findall(r'^- \[([ xX])\] (T\d{3,}) (\S.*)$', body, re.M)
    markers = [(state, task) for state, task, _ in rows]
    errors = []
    candidates = re.findall(r'^- \[[^\]]*\]\s+T\S*.*$', body, re.M)
    if len(candidates) != len(rows):
        errors.append('malformed task row')
    ids = [task for _, task in markers]
    if not ids or ids != [f'T{i:03d}' for i in range(1, len(ids) + 1)]:
        errors.append('task IDs must be unique and sequential in document order')
    phases = [int(n) for n in re.findall(r'^## Phase (\d+):', body, re.M)]
    if not phases or phases != list(range(1, len(phases) + 1)):
        errors.append('phase numbers must be sequential in document order')
    baseline = json.loads((ROOT / 'tools/003_task_baseline.json').read_text(encoding='utf-8'))
    for expected, actual in zip(baseline, rows):
        if expected['id'] != actual[1] or expected['description_sha256'] != hashlib.sha256(actual[2].rstrip().encode()).hexdigest():
            errors.append('original task changed: ' + expected['id'])
    if len(rows) < len(baseline):
        errors.append('original tasks removed')
    return markers, errors


def main():
    final = EVIDENCE / 'final'
    final.mkdir(exist_ok=True)
    report = final / 'docs-check.md'
    if not report.exists():
        report.write_text('# 离线检查待执行\n', encoding='utf-8')
    files = [ROOT / p for p in ('README.md', 'docs/game-development-dashboard.html',
             'docs/IMPLEMENTATION_OVERVIEW.md', 'docs/development.md',
             'docs/developer-debug-panel.md', 'docs/art-direction.md', 'assets/provenance.md')]
    files += list(FEATURE.rglob('*.md')) + list(EVIDENCE.rglob('*.md')) + list(EVIDENCE.rglob('*.html'))
    errors, refs, images = [], 0, 0
    for path in sorted(set(files)):
        body = path.read_text(encoding='utf-8-sig')
        if path.suffix == '.html':
            audit = Audit()
            audit.feed(body)
            targets = audit.refs
            images += audit.images
            errors.extend(audit.errors)
            if re.search(r'url\(\s*[\"\']?https?://', body):
                errors.append(str(path) + ': remote CSS asset')
        else:
            targets = re.findall(r'!?\[[^\]]*\]\(([^)\n]+)\)', body)
        for target in targets:
            split = urlsplit(target.strip().strip('<>'))
            if split.scheme or split.netloc or not split.path:
                continue
            refs += 1
            if not (path.parent / unquote(split.path)).resolve().exists():
                errors.append(f'{path.relative_to(ROOT)}: {target}')
    hashes = 0
    for manifest in (EVIDENCE / 'human').glob('*/stimuli.json'):
        data = json.loads(manifest.read_text(encoding='utf-8'))
        source = manifest.parent / data['source_directory']
        for file, expected in data['files_sha256'].items():
            actual = hashlib.sha256((source / file).read_bytes()).hexdigest()
            hashes += 1
            if actual != expected:
                errors.append('stimulus changed: ' + file)
    markers, task_errors = audit_tasks((FEATURE / 'tasks.md').read_text(encoding='utf-8-sig'))
    errors.extend(task_errors)
    overview = (ROOT / 'docs/IMPLEMENTATION_OVERVIEW.md').read_text(encoding='utf-8')
    main_summary = overview.split('| 范围')[0]
    chinese = len(re.findall(r'[\u4e00-\u9fff]', main_summary))
    if chinese > 600:
        errors.append('overview main summary >600 Chinese characters')
    checklist = {}
    for path in (FEATURE / 'checklists').glob('*.md'):
        states = re.findall(r'^\s*- \[([ xX])\]', path.read_text(encoding='utf-8-sig'), re.M)
        checklist[path.name] = {'total': len(states), 'unchecked': states.count(' ')}
    result = {'files': len(set(files)), 'local_refs': refs, 'images': images,
              'stimulus_hashes': hashes, 'overview_summary_chinese': chinese,
              'open_tasks': [m[1] for m in markers if m[0] == ' '],
              'task_count': len(markers),
              'checklists_read_only': checklist, 'errors': errors,
              'human_answers_generated': 0, 'browser_visual_validation': False}
    (final / 'docs-check.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    if errors:
        raise SystemExit(json.dumps(errors, ensure_ascii=False, indent=2))
    report.write_text(f'''# 离线文档检查 — 2026-10-21

实际执行`python -X utf8 tools/check_003_docs.py`退出0。检查{result['files']}份文件、{refs}本地链接／资源、{images}张图片alt、{hashes}个原始／处理帧hash；断链／缺alt／在线运行资源0。概览主摘要{chinese}汉字（≤600）。当前{len(markers)}项编号唯一有序、原54项描述未变，{len(result['open_tasks'])}项任务行未勾选（含原项与收敛承接项）；评审清单只读，未生成真人回答。未声称浏览器响应式／人类辨识验收。

[详细结果](docs-check.json)。游戏实际验证、导出身份与性能另见最终结果。
''', encoding='utf-8')
    print(f'DOCS PASS: {len(set(files))} files;{refs} refs;{images} images;{hashes} stimulus hashes;{len(result["open_tasks"])} open tasks')


if __name__ == '__main__':
    main()
