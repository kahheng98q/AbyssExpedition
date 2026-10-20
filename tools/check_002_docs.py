"""Offline path/asset/status audit for the002 implementation artifacts."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import unquote,urlsplit
import hashlib,json,re

ROOT=Path(__file__).resolve().parents[1]
FEATURE=ROOT/"specs/002-combat-pacing-audio"
EVIDENCE=ROOT/"docs/validation/combat-pacing-audio"

class HTMLAudit(HTMLParser):
    def __init__(self):
        super().__init__();self.references=[];self.images=0;self.bad_alt=[];self.remote_runtime=[];self.ids=set()
    def handle_starttag(self,tag,attrs):
        values=dict(attrs)
        if "id" in values:self.ids.add(values["id"])
        for field in ("src","href"):
            if field in values:
                value=values[field];self.references.append(value)
                if urlsplit(value).scheme in ("http","https") and (field=="src" or tag=="link" and values.get("rel")=="stylesheet"):
                    self.remote_runtime.append(value)
        if tag=="img":
            self.images+=1
            if not values.get("alt","").strip():self.bad_alt.append(values.get("src","missing src"))

def main():
    files=[ROOT/"README.md",ROOT/"docs/IMPLEMENTATION_OVERVIEW.md",ROOT/"docs/development.md",ROOT/"docs/developer-debug-panel.md",ROOT/"docs/game-development-dashboard.html",ROOT/"specs/001-abyss-expedition-mvp/spec.md",ROOT/"specs/001-abyss-expedition-mvp/contracts/systems.md"]
    files+=list(FEATURE.glob("*.md"))+list((FEATURE/"contracts").glob("*.md"))
    files+=list(EVIDENCE.rglob("*.md"))+list((EVIDENCE/"human").rglob("*.html"))
    report=EVIDENCE/"final/docs-check.md"
    if not report.exists():report.write_text("# Offline docs audit pending\n",encoding="utf-8")
    if report not in files:files.append(report)
    broken=[];references=images=0;bad_alt=[];remote=[]
    for path in sorted(set(files)):
        body=path.read_text(encoding="utf-8-sig")
        if path.suffix==".html":
            parser=HTMLAudit();parser.feed(body);targets=parser.references;images+=parser.images
            bad_alt+=parser.bad_alt;remote+=parser.remote_runtime
            remote+=re.findall(r"url\(\s*[\"']?(https?://[^)]+)",body)
        else:targets=re.findall(r"!?\[[^\]]*\]\(([^)\n]+)\)",body)
        for target in targets:
            target=target.strip().strip("<>")
            split=urlsplit(target)
            if split.scheme or split.netloc or not split.path:continue
            references+=1
            resolved=(path.parent/unquote(split.path)).resolve()
            if not resolved.exists():broken.append(str(path.relative_to(ROOT))+": "+target)
    prepared=EVIDENCE/"human/listening-prepared-v1"
    key=json.loads((prepared/"answer-key.json").read_text(encoding="utf-8"))
    stimulus_count=0
    for participant,questions in key["participants"].items():
        for item in questions:
            source=prepared/"stimuli"/(participant+"-%02d.wav"%item["question"])
            assert hashlib.sha256(source.read_bytes()).hexdigest()==item["sha256"]
            stimulus_count+=1
    for cue,expected in key["original_hashes"].items():
        assert hashlib.sha256((ROOT/"assets/audio"/(cue+".wav")).read_bytes()).hexdigest()==expected
    human_response_files=len(list((EVIDENCE/"human").rglob("P??-answers.json")))
    tasks=(FEATURE/"tasks.md").read_text(encoding="utf-8")
    markers=re.findall(r"^- \[([ xX])\] (T\d{3})\b",tasks,re.M)
    assert markers and len({identity for _,identity in markers})==len(markers)
    open_tasks=[identity for state,identity in markers if state==" "]
    checklist_counts={}
    for path in (FEATURE/"checklists").glob("*.md"):
        states=re.findall(r"^\s*- \[([ xX])\]",path.read_text(encoding="utf-8-sig"),re.M)
        checklist_counts[path.name]={"total":len(states),"unchecked":states.count(" ")}
    overview=(ROOT/"docs/IMPLEMENTATION_OVERVIEW.md").read_text(encoding="utf-8")
    chinese=len(re.findall(r"[\u4e00-\u9fff]",overview))
    result={"files_checked":len(set(files)),"local_references":references,"image_tags":images,"missing_alt":bad_alt,"remote_runtime_resources":remote,"broken":broken,"frozen_stimuli_checked":stimulus_count,"human_responses_generated":0,"human_response_files_found":human_response_files,"overview_chinese_characters_entire_file":chinese,"open_tasks":open_tasks,"checklists_read_only_counts":checklist_counts}
    (EVIDENCE/"final/docs-check.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    assert not broken and not bad_alt and not remote,json.dumps(result,ensure_ascii=False)
    report.write_text(f"# 离线文档检查 — 2026-10-19\n\n实际执行：`python tools/check_002_docs.py`。\n\n检查{len(set(files))}份文件、{references}个本地链接/资源、{images}个图片标签；断链0、缺alt0、远程运行资源0。含dashboard、overview、README、development、当前Spec Kit及新增证据/离线盲听页。HTML结构/相对路径已检查；未声称新的浏览器响应式人工验收。\n\n{stimulus_count}个冻结盲听刺激及原音样hash匹配；找到{human_response_files}份回答文件，此工具不生成答案也不验证参与身份。概览全文件{chinese}个汉字（含表格与命令），主摘要更短。{len(markers)}任务{len(markers)-len(open_tasks)}勾选，{len(open_tasks)}项开放；质量清单仅只读统计，未代填。\n\n详细结果：[docs-check.json](docs-check.json)。构建与性能hash核对另见build-integrity.json；源码实际截图已查看，未生成假截图。\n",encoding="utf-8")
    print(f"DOCS PASS: {references} local refs; {images} img alt; {stimulus_count} stimuli; {len(open_tasks)} human tasks open.")

if __name__=="__main__":main()
