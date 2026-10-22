class_name ProfileData
extends RefCounted

const SCHEMA = 4
const GAME = "m4.1"
const CONTENT = "m4.0"
const MAX_INTEGER = 9007199254740991
const STARTERS = ["aren", "lia", "milo"]
const BASES = {"aren": "swordsman", "lia": "archer", "milo": "mage", "sera": "mage", "brann": "swordsman", "nyra": "archer"}
const PASSIVES = {"aren": "resolute", "lia": "fleet_step", "milo": "arcane_pulse", "sera": "guiding_light", "brann": "bastion", "nyra": "far_sight"}
const BRANCHES = {"swordmaster": "swordsman", "abyss_swordsman": "swordsman", "sharpshooter": "archer", "star_hunter": "archer", "elemental_sage": "mage", "void_caster": "mage"}

static func fresh() -> Dictionary:
	var owned = {}
	for id in STARTERS: owned[id] = OwnedHero.record(id)
	return {"owned": owned, "active": "aren", "companions": [], "seed": 101, "receipt": {}, "tickets": 0, "tokens": 0, "history": [], "draw_rng": DrawRng.initial(), "chapters": {"coast": false}}

static func envelope(payload: Dictionary, revision: int, operation: String, profile_id: String = "default") -> Dictionary:
	var bytes = JSON.stringify(payload)
	return {"schema_version": SCHEMA, "game_version": GAME, "content_version": CONTENT, "profile_id": profile_id, "revision": revision, "saved_at_utc": Time.get_datetime_string_from_system(true), "operation_id": operation, "payload_json": bytes, "payload_sha256": bytes.sha256_text()}
