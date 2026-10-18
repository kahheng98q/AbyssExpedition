"""Record executed local evidence without changing approvals or reviewer checklists."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
HERE = ROOT / 'docs/validation/visual-vd01/completion-r2'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def put(name, value):
    (HERE / name).write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')


def functions(text):
    starts = list(re.finditer(r'^(?:static )?func (\w+)\(', text, re.M))
    return {match[1]: text[match.start():starts[i+1].start() if i+1 < len(starts) else len(text)].strip()
            for i, match in enumerate(starts)}


def main():
    candidate = read(HERE / 'candidate-files.json')
    assert sha(ROOT / 'builds/windows/m4/AbyssExpedition.exe') == candidate['embedded_release_sha256']
    methods = []
    for file in ['scripts/combat/actor_presentation.gd', 'scripts/combat/melee_arc.gd']:
        before = functions((HERE / 'retained-p2' / file).read_text(encoding='utf-8'))
        after = functions((ROOT / file).read_text(encoding='utf-8'))
        assert before.keys() == after.keys()
        changed = [key for key in before if before[key] != after[key]]
        assert changed == ['_process'], changed
        methods.append({'file': file, 'changed_functions': changed, 'all_other_function_bodies_identical': True})
    put('function-boundaries.json', methods)
    for row in read(HERE / 'reviewer-checklist-hashes.json'):
        assert sha(ROOT / row['path']) == row['sha256']
    suites = {}
    for name in ['unit','scene_smoke','integration_m1','replay','full_run','progression','persistence','abilities','integration_m2','recruitment','integration_m3','integration_m4']:
        text = (HERE / 'regression' / (name+'.log')).read_text(encoding='utf-8')
        match = re.search(r'SUITE '+name+r': (\d+) assertions; (\d+) failures; (\d+) skipped', text)
        assert match and match.group(2,3) == ('0','0'), name
        suites[name] = int(match[1])
    assert sum(suites.values()) == 5278
    debug_text = (HERE / 'debug/debug-panel.log').read_text(encoding='utf-8')
    assert '69 assertions; 0 failures; 0 skipped' in debug_text
    put('regression-summary.json', {'primary_suites': suites, 'primary_assertions':5278,'debug_assertions':69,
        'total_unique_functional_assertions':5347,'failures':0,'skipped':0,
        'limits':'Rendered comparisons, font scans, repeated GUI probes and tool tests are separate observations, not extra gameplay assertions.'})
    perf_rows = []
    for folder, label in [('perf','M4'),('perf-visual','P02')]:
        host = read(HERE / folder / 'host.json')
        pack_hash = host.get('pack_sha256') or host.get('embedded_pack_sha256')
        assert pack_hash.lower() == candidate['embedded_release_sha256']
        for seed in [101,202,303]:
            result = read(HERE / folder / f'm4-{seed}.json')
            assert result['capture_valid'] and result['warmup_active_seconds'] >= 30 and result['capture_active_seconds'] >= 120
            assert not result['debug_build'] and result['window_observed'] == [1920,1080] and result['vsync_observed'] == 0
            assert result['engine_max_fps'] == 0
            perf_rows.append({'workload':label,**result})
    put('performance-summary.json', {'embedded_release_sha256':candidate['embedded_release_sha256'],
        'reference_acceptance':False,'latency_measured':False,'rows':perf_rows,
        'passed_budget_runs':sum(x['frame_budget_pass'] for x in perf_rows)})
    lines = ['# 本机完整性能 · VD-01-P3','',
        '2026-10-18。当前5800H/GTX1650主机是补充证据，非i5-8400/1050Ti参考机。原M4与P02分别测量，所有6组为release、Compatibility1920×1080、VSync0、uncapped、30主动秒预热+120主动秒采样，负载检查有效。Dummy音频仅诊断。', '',
        '| 负载 | seed | p50 ms | p95 ms | p99 ms | max ms | 预算 |', '| --- | --- | --- | --- | --- | --- | --- |']
    for r in perf_rows:
        lines.append(f"| {r['workload']} | {r['seed']} | {r['p50_ms']:.3f} | {r['p95_ms']:.3f} | {r['p99_ms']:.3f} | {r['max_ms']:.3f} | {'PASS' if r['frame_budget_pass'] else 'FAIL'} |")
    lines += ['', '每组同时要求p95≤16.67ms且p99≤25ms。1组达标不能代表其余5组或参考机通过；T078整体仍open。P02新版/回退actor、arc、star数量均在原始JSON范围中，原M4夹具和两组负载不变。', '',
        '[原始M4/主机与OS内存](perf/) · [原始P02](perf-visual/) · [完整摘要](performance-summary.json)。release静态内存0表示监视器不可用，不是占用为0。电源有效模式/OS前台状态、外部CPU/GPU细分Profiler仍未独立观测；没有物理延迟或参考机结论。', '',
        '基准期间没有并发运行其它图形测试或浏览器检查；进行了轻量文档/文件操作。主机其它活动/功率/温度未独立控制，P02波动明显，不把历史P2与当前P3差值自动归因于代码。完整采样不因失败被替换。', '',
        '[短时ABBA诊断](cache-abba/comparison.json)只用于比较父版/缓存版，不替代完整预算检查；[四模式诊断](cost-probe/)关闭绘制/外观更新的画面不用于美术验收。', '',
        '[P2完整历史采样](../completion-r1/performance.md)及[原始before基线](../before/manifest.json)保留；G1样稿与原玩法/随机/保存/负载条件不变。']
    (HERE/'performance.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    text = (ROOT/'specs/002-2d-art-direction/tasks.md').read_text(encoding='utf-8')
    pending = re.findall(r'^- \[ \] (T\d+)',text,re.M)
    checked = len(re.findall(r'^- \[[xX]\] T\d+',text,re.M))
    assert checked == 77 and len(pending) == 10
    put('remaining-tasks.json', {'checked':checked,'total':checked+len(pending),'tasks':pending,
        'external_resources':'Owner explicitly reports no reference machine, high-frame-rate equipment or ten participants; local work only.',
        'glyph_ink':'187 Labels per source/release measured; six intentional scroll cases separated; overflow canary detected. Human/natural/window acceptance remains separate.',
        'scope':'current eight-item slice; no G3'})
    print('Local evidence recorded: 5347 assertions; six valid full captures; 77/87 tasks; human/hardware gates preserved.')


if __name__ == '__main__':
    main()
