"""Score frozen blind-listening responses; never generates participant answers."""
from pathlib import Path
import argparse
import json

def score(answer, key):
    if len(answer)!=20 or [item.get("question") for item in answer]!=list(range(1,21)):
        raise ValueError("Exactly20 ordered unique answers required")
    category=profession=0
    roles={"sword":0,"bow":0,"mage":0}
    for actual,expected in zip(answer,key):
        if actual.get("stimulus_hash")!=expected["sha256"]:
            raise ValueError("Stimulus hash mismatch")
        correct=actual.get("category")==expected["category"]
        category+=correct
        if correct and expected["category"]=="attack" and actual.get("profession")==expected["profession"]:
            profession+=1
            roles[expected["profession"]]+=1
    return {"category":category,"profession":profession,"roles":roles,
            "pass":category>=16 and profession>=4 and all(roles.values())}

def self_test():
    key=[{"question":i+1,"category":"attack" if i<5 else "hit","profession":["sword","sword","bow","bow","mage"][i] if i<5 else "","sha256":str(i)} for i in range(20)]
    answers=[{"question":i+1,"category":k["category"],"profession":k["profession"],"stimulus_hash":k["sha256"]} for i,k in enumerate(key)]
    assert score(answers,key)["pass"]
    missing_mage=[dict(x) for x in answers];missing_mage[4]["profession"]="sword"
    assert score(missing_mage,key)["profession"]==4 and not score(missing_mage,key)["pass"]
    wrong_category=[dict(x) for x in answers];wrong_category[0]["category"]="kill";wrong_category[1]["category"]="kill"
    assert score(wrong_category,key)["profession"]==3 and not score(wrong_category,key)["pass"]
    duplicate=[dict(x) for x in answers];duplicate[-1]["question"]=1
    try: score(duplicate,key)
    except ValueError: pass
    else: raise AssertionError("duplicate accepted")
    changed=[dict(x) for x in answers];changed[0]["stimulus_hash"]="wrong"
    try: score(changed,key)
    except ValueError: pass
    else: raise AssertionError("changed stimulus accepted")
    print("Listening scorer:5 in-memory contract checks pass; no human responses produced.")

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--self-test",action="store_true")
    parser.add_argument("--answers-directory",type=Path)
    parser.add_argument("--key",type=Path)
    parser.add_argument("--output",type=Path)
    args=parser.parse_args()
    if args.self_test: self_test();return
    if not args.answers_directory or not args.key or not args.output: parser.error("answers-directory/key/output required")
    if args.output.exists(): parser.error("output exists; preserve prior evidence")
    frozen=json.loads(args.key.read_text(encoding="utf-8-sig"))
    results={}
    for person in [f"P{i:02}" for i in range(1,6)]:
        raw=json.loads((args.answers_directory/(person+"-answers.json")).read_text(encoding="utf-8-sig"))
        if raw.get("participant")!=person: raise ValueError("Participant mismatch")
        results[person]=score(raw["answers"],frozen["participants"][person])
    report={"participants":results,"scoring_threshold_pass":sum(x["pass"] for x in results.values())>=4,
            "limitation":"Scoring only; organizer must attest actual blind human participation and retain raw responses. Combine with current recording for SC004."}
    args.output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")

if __name__=="__main__": main()
