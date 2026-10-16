"""Build a local screenshot guide from unmodified Godot frame captures."""
from html import escape
from pathlib import Path
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
CAPTURES = ROOT / "screenshots" / "m2-evidence"
report = json.loads((CAPTURES / "manifest.json").read_text(encoding="utf-8"))
assert report["failures"] == 0, "Do not publish a gallery with failed capture checks"

features = [
    ("FR-015", "Character roster", "Visible in the normal menu", "Look for the active/companion checkmarks, XP, levels, current class, passive names and promotion-item count. The entry is New Expedition → Character roster / companions / promotions."),
    ("FR-016", "Permanent character levels", "Visible in HUD and debug stats", "These four Aren examples show levels 1, 14, 15 and 30. Base max HP rises 250 → 315 → 320 → 395; base attack rises 36 → 45.36 → 46.08 → 56.88. Run Lv stays separate. Level 15 permits promotion; level 30 is the permanent cap."),
    ("FR-017", "Permanent expedition rewards", "Visible on the results screen", "Victory gives 20 XP per completed minute plus 100 XP and one promotion item. Defeat gives minute XP only; abandonment gives zero. The Saved line identifies the reward. Selected companions share permanent XP even if downed; unselected heroes are excluded. Duplicate settlement prevention and exact minute boundaries require tests."),
    ("FR-018", "Promotion confirmation", "Three screens; two choices each", "Aren has Swordmaster / Abyss Swordsman; Lia has Sharpshooter / Star Hunter; Milo has Elemental Sage / Void Caster. Promotion needs permanent level 15 and one item. Confirm saves the branch and spends one item. Cancel spends nothing. Failed-write Retry is shown later."),
    ("FR-019", "Six promoted branches", "Saved class plus real attack frames", "For each branch, compare the saved roster class with its attack frame. Expand the magnified view: current effects are small geometric placeholders, not finished character animations. These prepared fifth-attack examples make the differences easier to identify."),
    ("FR-020", "Character-specific passives", "Names and stats visible; damage behavior tested", "Aren: Resolute, 10% less incoming damage after defense (minimum 1). Lia: Fleet Step, +10% starting speed. Milo: Arcane Pulse, +50% damage on each fifth fired attack. Passives survive promotion. There is no dedicated passive effect icon or animation; a screenshot cannot prove the damage formula or counter independence."),
    ("FR-021", "Up to two AI companions", "Three party configurations", "These captures show zero, one and two companions from saved roster choices. Two companions occupy distinct formation slots and have separate HP readouts. A still frame shows the deployed party, while follow priority, target selection and blocked/separated recovery are established by behavior tests."),
    ("FR-022", "Companion combat and downing", "Downed state visible in party HUD", "A companion can be downed while the active hero continues. The body pose and DOWNED label are visible. Half outgoing damage, full healing/defense, separate 45-tick immunity, living-only shared upgrades, active-hero defeat and full restoration next run are implemented behavior covered by tests; this one frame does not establish all of them."),
    ("FR-023", "Save durability and Retry", "Real save-error / recovery interface", "A controlled publication failure opens the real save-error screen. Retry commits the same pending action once. The roster afterward shows the committed XP and saved party. Checksum/version validation, interrupted writes and two-process writer-lock behavior are backend guarantees verified through tests, not through the appearance of a screen."),
    ("SC-005", "Progress retained after reopening", "Reopened application and exact state checks", "The final roster is loaded by a new application instance from the same isolated test profile. Twenty exact payload close/reopen comparisons passed during capture. A screenshot shows the retained state; the comparisons establish that the complete payload matched."),
]

cards = []
for code, title, visibility, intro in features:
    figures = []
    for frame in report["frames"]:
        if frame["requirement"] != code:
            continue
        name = frame["id"] + ".png"
        assert (CAPTURES / name).is_file(), name
        src = "../screenshots/m2-evidence/" + name
        zoom = ""
        if frame["zoom"]:
            zoom = f'''<details class="zoom-panel" open><summary>Magnified combat detail · 2×, same screenshot</summary>
              <div class="zoom"><img src="{src}" alt="Magnified detail of {escape(frame['title'])}" loading="lazy"></div></details>'''
        figures.append(f'''<article class="shot" id="{escape(frame['id'])}">
          <h3>{escape(frame['title'])}</h3>
          <a class="full" href="{src}" target="_blank" rel="noopener" aria-label="Open original screenshot: {escape(frame['title'])}">
            <img src="{src}" alt="{escape(frame['title'])}" width="640" height="360" loading="lazy"></a>
          {zoom}<div class="caption"><p>{escape(frame['caption'])}</p>
          <p class="how"><b>Try it:</b> {escape(frame['how'])}</p></div></article>''')
    cards.append(f'''<section class="feature" id="{code}" data-requirement="{code}">
      <div class="feature-head"><span class="code">{code}</span><span class="status">Implemented</span></div>
      <h2>{escape(title)}</h2><p class="visibility">{escape(visibility)}</p><p class="intro">{escape(intro)}</p>
      <div class="shots">{''.join(figures)}</div></section>''')

nav = ''.join(f'<a href="#{code}" data-filter="{code}">{code} · {escape(title)}</a>' for code, title, _, _ in features)
rows = ''.join(f'<tr><td><a href="#{code}" data-filter="{code}">{code}</a></td><td>{escape(title)}</td><td><span class="status">Implemented</span></td><td>{escape(visibility)}</td></tr>' for code, title, visibility, _ in features)
checks = ''.join(f'<li>{escape(item["check"])}</li>' for item in report['checks'] if item['passed'] and not item['check'].startswith(('captured ', 'controlled screenshot profile')))

html = '''<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Milestone 2 — Screenshot Guide</title>
<style>
:root{color-scheme:dark;--bg:#081218;--surface:#101f28;--line:#2a424d;--text:#e6f0f3;--muted:#aec2cb;--accent:#87e5d2}
*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:85px}body{margin:0;background:var(--bg);color:var(--text);font:16px/1.65 system-ui,sans-serif}main{max-width:1400px;margin:auto;padding:42px 24px 70px}h1,h2,h3{line-height:1.25;margin:0 0 15px}h1{font-size:clamp(28px,4vw,48px);max-width:900px}h2{font-size:30px}h3{font-size:18px;padding:18px 20px 0}a{color:var(--accent)}p{margin:0 0 16px}.eyebrow{color:var(--accent);font-weight:700;letter-spacing:.14em;font-size:12px}.lead{font-size:20px;max-width:900px;color:var(--muted)}.notice,.quick{border:1px solid var(--line);border-radius:12px;background:var(--surface);padding:22px;margin:22px 0}.notice{border-left:4px solid #efbd6b}.notice p:last-child{margin:0}.quick ol{padding-left:24px;margin:10px 0}.quick li{margin:9px 0}.toolbar{position:sticky;top:0;z-index:5;background:#081218f5;border-block:1px solid var(--line);padding:12px 0;display:flex;gap:10px;align-items:center;flex-wrap:wrap;backdrop-filter:blur(8px)}select,button{font:inherit;background:#142e38;color:var(--text);border:1px solid #64828c;padding:9px 13px;border-radius:6px}button{cursor:pointer}nav{display:flex;gap:8px;flex-wrap:wrap;margin:22px 0}nav a{text-decoration:none;font-size:13px;padding:8px 12px;border:1px solid var(--line);border-radius:30px}table{border-collapse:collapse;width:100%;margin:20px 0 50px;font-size:14px}th,td{text-align:left;padding:12px;border-bottom:1px solid var(--line)}th{color:var(--muted)}.status{color:#95e9ba;font-weight:650;font-size:13px}.feature{padding-top:28px;margin:30px 0 65px;border-top:1px solid var(--line)}.feature-head{display:flex;gap:18px;align-items:center;margin-bottom:10px}.code{color:var(--accent);font-weight:700;letter-spacing:.06em}.visibility{color:#efbd6b;font-weight:600;margin-bottom:12px}.intro{max-width:1050px;color:var(--muted)}.shots{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px;margin-top:24px}.shot{min-width:0;background:var(--surface);border:1px solid var(--line);border-radius:10px;overflow:hidden}.shot .full{display:block;background:#050b10}.full img{display:block;width:100%;height:auto;image-rendering:pixelated}.caption{padding:18px 20px}.caption p{font-size:14px}.caption .how{color:var(--muted);border-top:1px solid var(--line);padding-top:12px;margin-bottom:0}.zoom-panel{border-block:1px solid var(--line)}summary{padding:10px 15px;cursor:pointer;color:var(--accent);font-size:13px}.zoom{height:240px;position:relative;overflow:hidden;background:#0b1a22}.zoom img{position:absolute;width:1280px;height:720px;max-width:none;left:calc(50% - 740px);top:calc(50% - 360px);image-rendering:pixelated}.evidence{padding:24px;border:1px solid var(--line);border-radius:12px}.evidence li{margin:8px 0;color:var(--muted);font-size:14px}.footer{color:var(--muted);font-size:13px;margin-top:40px}.hidden{display:none!important}@media(max-width:850px){.shots{grid-template-columns:1fr}main{padding:25px 14px}.table-wrap{overflow:auto}h2{font-size:25px}.zoom img{left:calc(50% - 700px)}}@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}}@media print{body{background:white;color:black}.toolbar,nav{display:none}.feature,.shot{break-inside:avoid}.shots{display:block}.shot{margin-bottom:20px}.zoom-panel{display:none}}
</style></head><body><main>
<p class="eyebrow">ABYSS EXPEDITION · MILESTONE 2 · 15 OCTOBER 2026</p>
<h1>What is implemented, and where to see it</h1>
<p class="lead">Actual screenshots mapped to the ten rows in your requirements table. Each example includes what to look for and how to reach it in the game.</p>
<div class="notice"><p><b>These are real game captures, not mockups.</b> Captured from the current exported developer build, using prepared levels, enemies and outcomes in isolated test profiles. Screenshots are unmodified; combat closeups simply magnify the same image.</p>
<p><b>Visible does not mean fully proven by a still.</b> Screens show the UI and captured state. Damage formulas, AI movement, duplicate-save prevention and crash safety are supported by behavior tests, described separately below. Current combat art and effects remain geometric placeholders.</p></div>
<div class="quick"><b>Start here in your game</b><ol>
<li>Close older game copies. Open <a href="../Play%20Debug.cmd">Play Debug.cmd</a> or <a href="../builds/windows/debug-panel-access-fix/AbyssExpedition-debug.exe">the verified developer executable</a>.</li>
<li>Choose <b>New Expedition → Character roster / companions / promotions</b> to manage owned heroes, party and permanent promotions.</li>
<li>During a run, click <b>Debug · F9</b> at the top right, or press <b>F9</b> (some keyboards need Fn + F9). Character edits levels/XP; Progression opens promotions; Combat edits temporary companions.</li>
<li>Close debug to observe attacks. <b>Hero Lv</b> is permanent character progression; <b>Run Lv / XP</b> is this expedition's temporary upgrade progression.</li>
</ol><p>Debug edits remain in the sandbox. Normal roster choices apply when you save the party and start the next run. <a href="developer-debug-panel.md">Full developer-panel guide</a>.</p></div>
<div class="toolbar"><label for="filter">Show requirement:</label><select id="filter"><option value="all">All screenshots</option>__OPTIONS__</select><button id="show-all" type="button">Show all</button><span id="count">__COUNT__ real screenshots</span></div>
<nav aria-label="Requirement shortcuts">__NAV__</nav>
<div class="table-wrap"><table><thead><tr><th>Requirement</th><th>Feature</th><th>Status</th><th>What you can see</th></tr></thead><tbody>__ROWS__</tbody></table></div>
__CARDS__
<section class="evidence"><h2>What the captures do and do not establish</h2>
<p>This capture run completed <b>__ASSERTIONS__ checks with zero failures</b> and produced __COUNT__ screenshots. It checked real attack objects, reward commitments, level scaling, downing, Retry and twenty saved-payload reopen comparisons alongside the images.</p>
<p>The preceding full validation passed 916 checks, including M1/M2 regression suites and source/exported native input checks. No gameplay implementation was changed to create this gallery. Automated fixtures are reproducible; these captures are not a claim of exhaustive human-play or performance acceptance.</p>
<details><summary>Show checks performed during these screenshots</summary><ul>__CHECKS__</ul></details>
<p><a href="../screenshots/m2-evidence/manifest.json">Capture manifest</a> · <a href="validation/m2-evidence-capture.log">Capture log</a> · <a href="validation/debug-access-fix.md">Previous full validation</a></p></section>
<p class="footer">Capture build: builds/windows/debug-panel-access-fix/AbyssExpedition-debug.exe. Keep this HTML file inside docs/ with the screenshots/ folder beside docs/. Click a full frame to open its original image.</p>
</main><script>
const select=document.getElementById('filter');
function show(value,scroll){select.value=value;document.querySelectorAll('.feature').forEach(section=>section.classList.toggle('hidden',value!=='all'&&section.dataset.requirement!==value));if(scroll&&value!=='all'){document.getElementById(value).scrollIntoView({block:'start'});}document.getElementById('count').textContent=value==='all'?'__COUNT__ real screenshots':document.querySelectorAll('.feature:not(.hidden) .shot').length+' screenshots for '+value;}
select.addEventListener('change',()=>show(select.value,true));document.getElementById('show-all').addEventListener('click',()=>show('all',false));
document.querySelectorAll('[data-filter]').forEach(link=>link.addEventListener('click',event=>{event.preventDefault();const value=link.dataset.filter;show(value,true);history.replaceState(null,'','#'+value);}));
if(/^#FR-0(15|16|17|18|19|20|21|22|23)$|^#SC-005$/.test(location.hash)){show(location.hash.slice(1),true);}
</script></body></html>'''

values = {
    "__OPTIONS__": ''.join(f'<option value="{code}">{code} — {escape(title)}</option>' for code, title, _, _ in features),
    "__NAV__": nav, "__ROWS__": rows, "__CARDS__": ''.join(cards),
    "__COUNT__": str(len(report['frames'])), "__ASSERTIONS__": str(report['assertions']), "__CHECKS__": checks,
}
for key, value in values.items():
    html = html.replace(key, value)
target = ROOT / "docs" / "milestone-2-screenshots.html"
target.write_text(html, encoding="utf-8")
assert "__" not in html, "Unexpanded template marker"
print(f"Gallery: {target}; {len(report['frames'])} original screenshots; 10 requirement sections")

# Keep the gallery portable without bundling game binaries or user saves.
portable = html.replace('../screenshots/m2-evidence/', 'images/')
portable = re.sub(r'<a href="../(?:Play%20Debug\.cmd|builds/windows/[^\"]+)">(.*?)</a>', r'<b>\1</b>', portable)
portable = portable.replace('Keep this HTML file inside docs/ with the screenshots/ folder beside docs/.', 'Extract the complete ZIP and open index.html; the game executable is not included.')
archive = ROOT / 'docs' / 'milestone-2-screenshots.zip'
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as bundle:
    bundle.writestr('index.html', portable)
    bundle.writestr('README.txt', 'Extract all files, then double-click index.html.\n35 original screenshots and their captions are included.\nThe game executable and user saves are not included.\nTo play, use Play Debug.cmd in your original project folder.\n')
    for frame in report['frames']:
        name = frame['id'] + '.png'
        bundle.write(CAPTURES / name, 'images/' + name)
    bundle.write(CAPTURES / 'manifest.json', 'images/manifest.json')
    for name in ['developer-debug-panel.md', 'validation/m2-evidence-capture.log', 'validation/debug-access-fix.md', 'validation/debug-xp-level-fix.md']:
        bundle.write(ROOT / 'docs' / name, name)
with zipfile.ZipFile(archive) as bundle:
    assert bundle.testzip() is None
print(f'Portable gallery: {archive} ({archive.stat().st_size:,} bytes)')
