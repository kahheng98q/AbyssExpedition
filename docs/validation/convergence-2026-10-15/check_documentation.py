"""Check local evidence/documentation references without network access."""
import hashlib
import json
import re
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
FILES = ["README.md", "docs/game-development-dashboard.html", "docs/IMPLEMENTATION_OVERVIEW.md", "docs/development.md", "docs/validation/convergence-2026-10-15.md", "docs/validation/m1-gate.md", "docs/validation/m2-gate.md", "docs/validation/m3-gate.md", "docs/validation/m4-gate.md", "docs/benchmarks/m4.md", "specs/001-abyss-expedition-mvp/quickstart.md", "specs/001-abyss-expedition-mvp/tasks.md"]
errors = []
checked = {}


class Dashboard(HTMLParser):
    def __init__(self):
        super().__init__()
        self.references = []
        self.ids = []
        self.images = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.append(attrs["id"])
        if tag == "img":
            self.images += 1
            if not attrs.get("alt", "").strip():
                errors.append("Dashboard image lacks alt text")
        for name in ["href", "src"]:
            if name in attrs:
                self.references.append(attrs[name])


def check_reference(file, target, ids=None):
    target = target.strip("<>")
    parsed = urlsplit(target)
    if parsed.scheme in ["http", "https", "mailto", "codex"]:
        if file.suffix == ".html":
            errors.append(f"Dashboard external dependency/link: {target}")
        return
    if not parsed.path:
        if ids is not None and parsed.fragment not in ids:
            errors.append(f"Missing dashboard anchor: {target}")
        return
    destination = file.parent / unquote(parsed.path)
    if not destination.exists():
        errors.append(f"{file.relative_to(ROOT)} -> missing {target}")


for name in FILES:
    file = ROOT / name
    source = file.read_text(encoding="utf-8-sig")
    if file.suffix == ".html":
        dashboard = Dashboard()
        dashboard.feed(source)
        assert dashboard.images == 16
        if len(dashboard.ids) != len(set(dashboard.ids)):
            errors.append("Duplicate dashboard IDs")
        for target in dashboard.references:
            check_reference(file, target, dashboard.ids)
        checked[name] = len(dashboard.references)
        checked["dashboard_images"] = dashboard.images
        assert "5,239" in source
        assert len(re.findall(r'final-replay-disclosure/\w+\.log', source)) == 13
    else:
        links = re.findall(r'(?<!!)\[[^\]]+\]\(([^)]+)\)', source)
        for target in links:
            check_reference(file, target)
        checked[name] = len(links)

before = json.loads((BASE / "before-hashes.json").read_text(encoding="utf-8-sig"))
preserved = {}
for name in ["specs/001-abyss-expedition-mvp/spec.md", "specs/001-abyss-expedition-mvp/plan.md"]:
    digest = hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
    preserved[name] = digest == before[name]
    if not preserved[name]:
        errors.append(f"Approved artifact changed: {name}")

results = json.loads((BASE / "results.json").read_text(encoding="utf-8-sig"))
assert results["assertions"] == sum(row["assertions"] for row in results["suites"].values()) == 5239
for row in results["suites"].values():
    if not (BASE / row["log"]).exists():
        errors.append(f"Missing native log: {row['log']}")
review = json.loads((BASE / "acceptance-review.json").read_text(encoding="utf-8-sig"))
for key in ["acceptance_scenarios", "edge_cases", "technical_plan_groups"]:
    for row in review[key]:
        refs = row["executed_evidence"]
        for ref in refs if isinstance(refs, list) else [refs]:
            if not (BASE / ref).exists():
                errors.append(f"Missing review evidence: {ref}")
fr = json.loads((BASE / "requirements-status.json").read_text(encoding="utf-8-sig"))
assert len(fr["functional_requirements"]) == 42 and len(fr["success_criteria"]) == 12
for row in fr["functional_requirements"]:
    if not (BASE / row["evidence"]).exists():
        errors.append(f"Missing FR evidence: {row['id']}")
output = {"review_date": "2026-10-16", "checked": checked, "approved_artifacts_unchanged": preserved, "errors": errors, "error_count": len(errors), "scope": "offline paths/images/alt/IDs and evidence references; no claim of browser rendering or human gameplay acceptance"}
(BASE / "documentation-checks.json").write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(output, ensure_ascii=True))
raise SystemExit(1 if errors else 0)
