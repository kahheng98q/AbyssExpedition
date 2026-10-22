"""Streaming standard-library implementation of the frozen sword-gameplay-v1 comparison.

Raw captures are read-only. PowerShell owns capture/export orchestration and has
the same projection/negative tests; this avoids materializing millions of PS objects.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import itertools
import json
from pathlib import Path

PIN = "4.5.stable.official.876b29033"
SWORDS = ("swordsman", "swordmaster", "abyss_swordsman")
STATE_FIELDS = "tick stage phase kills coins corruption level xp pending stacks sequence request_id party enemies projectiles pickups rng snapshot_format spawns boss_hits rescue corruption_last_minute pending_rewards registry boss_actor_id pause_reasons followups delayed_impacts damage_requests consumed_damage activation_heals collected_pickups offer events effects".split()
RNG = ("wave_types", "spawn_positions", "upgrade_offers", "event_offers")
GROUPS = {f"{hero}-{profession}-{role}" for hero, profession, role in itertools.product(("aren", "brann"), SWORDS, ("hero", "companion"))}
GROUPS.update(("lia-archer-hero", "lia-sharpshooter-hero", "lia-star_hunter-hero", "milo-mage-hero", "milo-elemental_sage-hero", "milo-void_caster-hero"))
EXPECTED = {f"{group}-{seed}" for group in GROUPS for seed in (101, 202, 303)}
LIFECYCLES = {f"lifecycle-aren-{profession}-{seed}" for profession in SWORDS[1:] for seed in (101, 202, 303)}


def validate_lifecycle(record):
    """Reject empty coverage even when both versions have identical empty fields."""
    assert record['fixture'] == {'start_tick': 7190, 'end_tick': 7550, 'xp_pickup': 100, 'termination': 'queued_lethal_damage'}
    assert len(record['states']) >= 360 and record['final']['tick'] == 7550
    ticks = [state['tick'] for state in record['states']]
    assert ticks[0] == 7190 and ticks[-1] == 7550
    assert all(b - a in (0, 1) for a, b in zip(ticks, ticks[1:])), 'skipped/reversed active ticks'
    assert record['final']['phase'] == 'results' and record['final']['level'] >= 2
    trace = record['trace']
    assert trace['offers'] and trace['decisions'], 'upgrade offer/confirmation never exercised'
    for choice in trace['decisions']:
        assert any(offer['id'] == choice['offer'] and choice['upgrade'] in offer['options'] for offer in trace['offers']), 'unoffered upgrade'
    offers = [item['offer'] for item in trace['events'] if 'offer' in item]
    choices = [item for item in trace['events'] if 'choice' in item]
    assert offers and choices, 'event generation/resolution never exercised'
    assert any(offer['tick'] == 7200 and offer['kind'] in ('mysterious_merchant', 'forbidden_altar') and any(choice['id'] == offer['id'] and choice['tick'] == 7200 and choice['choice'] == ('leave' if offer['kind'] == 'mysterious_merchant' else 'decline') for choice in choices) for offer in offers)
    assert record['summary']['outcome'] == 'defeat' and record['summary']['ticks'] == 7550
    assert record['summary']['seed'] == record['metadata']['seed']
    saved = record['save']
    assert saved['state'] == 'ready' and saved['settlement_count'] == 1
    assert saved['revision'] == saved['before_revision'] + 1
    assert saved['round_trip_payload'] == record['profile_after'], 'persisted payload differs'
    assert record['profile_after']['receipt']['result']['kind'] == 'settlement'
    assert record['profile_after']['owned']['aren']['total_xp'] == record['initial_profile']['owned']['aren']['total_xp'] + 40


def read(path: Path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def manifest(directory: Path):
    record = read(directory / "manifest.json")
    assert record["format"] == "sword-identity-captures-v2" and record["projection"] == "sword-gameplay-v1"
    assert record["engine"] == PIN
    for key in ("build_hash", "fixture_hash", "engine_sha256", "catalog"):
        assert len(record[key]) == 64 and all(c in "0123456789abcdef" for c in record[key]), key
    source = "\n".join(f"{row['path']}:{row['sha256']}" for row in record["source_files"])
    assert digest(source.encode()) == record["build_hash"], "source manifest digest"
    assert digest("\n".join(record["fixture_files"]).encode()) == record["fixture_hash"], "fixture manifest digest"
    assert len(record["samples"]) == 54
    assert {row["id"] for row in record["samples"]} == EXPECTED, "incomplete hero/role/seed matrix"
    assert len(record['lifecycle_samples']) == 6 and {row['id'] for row in record['lifecycle_samples']} == LIFECYCLES, 'incomplete lifecycle/seed matrix'
    return record


def sample(directory: Path, row: dict, identity: dict, lifecycle=False):
    assert row["file"] == row["id"] + ".json" and row["seed"] in (101, 202, 303)
    raw = (directory / row["file"]).read_bytes()
    assert digest(raw) == row["sha256"], "sample hash: " + row["id"]
    record = json.loads(raw.decode("utf-8-sig"))
    meta = record["metadata"]
    for key in ("build_hash", "fixture_hash", "catalog"):
        assert meta[key] == identity[key], "sample identity: " + key
    assert meta["session_id"] == row["id"] and meta["seed"] == row["seed"]
    assert meta["engine"] == "4.5-stable (official)" and meta["protocol"] == ('sword-lifecycle-v1' if lifecycle else 'sword-controlled-v1')
    assert record["trace"]["start"]["catalog"] == identity["catalog"]
    if lifecycle:
        validate_lifecycle(record)
    else:
        assert len(record["states"]) == 360 and record["final"]["tick"] == 360
    for state in itertools.chain(record["states"], (record["final"],)):
        assert all(key in state for key in STATE_FIELDS), "missing original gameplay container"
        assert all(isinstance(state["rng"][key], str) for key in RNG), "missing/imprecise RNG"
    return record


def project(record: dict, diagnostics: dict):
    """Only V3 named fields; every unknown field remains in the comparison."""
    def remove(obj, key, path):
        if key in obj:
            diagnostics[path + "/" + key] = obj.pop(key)
    for key in ("build_hash", "catalog", "session_id"):
        remove(record["metadata"], key, "metadata")
    remove(record["trace"]["start"], "catalog", "trace/start")
    for index, state in enumerate(itertools.chain(record.get("states", ()), (record.get("final", {}),))):
        prefix = "states/" + str(index) if index < len(record.get("states", ())) else "final"
        for effect_index, effect in enumerate(state.get("effects", ())):
            for key in ("color", "sword_visual"):
                remove(effect, key, f"{prefix}/effects/{effect_index}")
        for effect_index, effect in enumerate(state.get("followups", ())):
            remove(effect, "sword_visual", f"{prefix}/followups/{effect_index}")
    for name in SWORDS:
        if name in record.get("professions", {}):
            remove(record["professions"][name], "visual_set", "professions/" + name)
    remove(record, "presentation", "")
    return record


def differences(a, b, path="", limit=256):
    found = []
    def visit(left, right, location):
        if len(found) >= limit or left == right:
            return
        if isinstance(left, dict) and isinstance(right, dict):
            for key in sorted(left.keys() | right.keys()):
                if key not in left or key not in right:
                    found.append({"path": location + "/" + key, "expected": left.get(key), "actual": right.get(key), "missing": True})
                else:
                    visit(left[key], right[key], location + "/" + key)
                if len(found) >= limit:
                    break
        elif isinstance(left, list) and isinstance(right, list):
            if len(left) != len(right):
                found.append({"path": location + "/length", "expected": len(left), "actual": len(right)})
            for index, (x, y) in enumerate(zip(left, right)):
                visit(x, y, location + "/" + str(index))
                if len(found) >= limit:
                    break
        else:
            found.append({"path": location, "expected": left, "actual": right})
    visit(a, b, path)
    return found


def self_test():
    original = {"metadata": {"seed": 101, "build_hash": "old", "catalog": "old", "session_id": "old"}, "trace": {"start": {"catalog": "old"}, "decisions": ["might"]}, "states": [{"hp": 42, "activations": 5, "rng": dict.fromkeys(RNG, "1"), "effects": [{"direction": [1, 0], "reach": 48, "angle": 100, "expires": 10, "color": "old"}], "followups": [{"due": 10, "origin": [0, 0], "direction": [1, 0], "reach": 48, "angle": 100, "damage": 36, "knockback": 80, "burn": False, "frost": False}], "damage_requests": [], "activation_heals": {"0:5": True}}], "professions": {"swordsman": {"damage": 36, "visual_set": "old"}, "mage": {"visual_set": "same"}}}
    def equal(a, b):
        return project(copy.deepcopy(a), {}) == project(copy.deepcopy(b), {})
    changed = copy.deepcopy(original)
    for key in ("build_hash", "catalog", "session_id"):
        changed["metadata"][key] = "new"
    changed["trace"]["start"]["catalog"] = "new"
    changed["states"][0]["effects"][0].update(color="new", sword_visual={"identity": "dual"})
    changed["states"][0]["followups"][0]["sword_visual"] = {"identity": "dual"}
    changed["professions"]["swordsman"]["visual_set"] = "new"
    assert equal(original, changed)
    count = 1
    for container, keys in (("effects", ("direction", "reach", "angle", "expires", "unknown")), ("followups", ("due", "origin", "direction", "reach", "angle", "damage", "knockback", "burn", "frost", "unknown"))):
        for key in keys:
            bad = copy.deepcopy(original)
            bad["states"][0][container][0][key] = "changed"
            assert not equal(original, bad), (container, key)
            count += 1
    for key in ("hp", "activations", "damage_requests", "activation_heals", "unknown"):
        bad = copy.deepcopy(original); bad["states"][0][key] = "changed"
        assert not equal(original, bad); count += 1
    for key in RNG:
        bad = copy.deepcopy(original); bad["states"][0]["rng"][key] = "changed"
        assert not equal(original, bad); count += 1
    bad = copy.deepcopy(original); bad["professions"]["mage"]["visual_set"] = "changed"
    assert not equal(original, bad); count += 1
    print(f"Python sword projection: {count} checks; 0 failures")


def compare(left_dir: Path, right_dir: Path, output: Path):
    assert not output.exists(), "new EvidenceDirectory required"
    left = manifest(left_dir); right = manifest(right_dir)
    for key in ("fixture_hash", "engine_sha256", "engine", "projection"):
        assert left[key] == right[key], "comparison identity: " + key
    output.mkdir(parents=True)
    results = []
    try:
        pairs = [(a, b, False) for a, b in zip(left['samples'], right['samples'])]
        pairs += [(a, b, True) for a, b in zip(left['lifecycle_samples'], right['lifecycle_samples'])]
        for a, b, lifecycle in pairs:
            assert a["id"] == b["id"] and a["seed"] == b["seed"]
            raw_a = sample(left_dir, a, left, lifecycle); raw_b = sample(right_dir, b, right, lifecycle)
            diag_a = {}; diag_b = {}
            projected_a = project(raw_a, diag_a); projected_b = project(raw_b, diag_b)
            delta = differences(projected_a, projected_b)
            diagnostic_name = a["id"] + "-diagnostics.json"
            (output / diagnostic_name).write_text(json.dumps({"baseline": diag_a, "candidate": diag_b}, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
            results.append({"id": a["id"], "equal": not delta, "differences": delta, "baseline_sha256": a["sha256"], "candidate_sha256": b["sha256"], "diagnostics": diagnostic_name})
    finally:
        (output / "comparison.json").write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    invalid = sum(not row["equal"] for row in results)
    print(f"Sword Compare: {len(results)} samples; {invalid} divergent", flush=True)
    assert len(results) == 60 and invalid == 0, "gameplay differs; raw data and exact differences retained"


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--candidate", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument('--validate', type=Path)
    args = parser.parse_args()
    if args.self_test:
        self_test()
    elif args.validate:
        identity = manifest(args.validate)
        for row in identity['samples']: sample(args.validate, row, identity)
        for row in identity['lifecycle_samples']: sample(args.validate, row, identity, True)
        print('Sword Capture validated: 54 combat + 6 non-empty lifecycle samples')
    else:
        parser.error("baseline/candidate/output required") if not all((args.baseline, args.candidate, args.output)) else compare(args.baseline, args.candidate, args.output)
