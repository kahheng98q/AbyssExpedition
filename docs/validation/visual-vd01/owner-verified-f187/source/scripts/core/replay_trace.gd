class_name ReplayTrace
extends RefCounted

const SIMULATION_VERSION = "m4-convergence-1"
var metadata: Dictionary
var inputs: Array = []
var waves: Array = []
var spawns: Array = []
var offers: Array = []
var decisions: Array = []
var events: Array = []

func _init(start_state: RunStartSnapshot, digest: String = "") -> void:
	metadata = {"engine": start_state.engine_version, "game": start_state.game_version, "catalog": digest, "seed": start_state.seed_value, "hero": start_state.hero_id, "derivation": "abyss-rng-v1"}
	metadata["party"] = start_state.members
	metadata["sera_owned"] = start_state.sera_owned
	metadata["simulation"] = SIMULATION_VERSION
	metadata["input_encoding"] = "movement-changes-v1"

func record_movement(tick: int, direction: Vector2) -> void:
	var movement = [direction.x, direction.y]
	if not inputs.is_empty() and inputs[-1].direction == movement: return
	inputs.append({"tick": tick, "direction": movement})

func snapshot() -> Dictionary:
	return {"start": metadata.duplicate(true), "inputs": inputs.duplicate(true), "waves": waves.duplicate(true), "spawns": spawns.duplicate(true), "offers": offers.duplicate(true), "decisions": decisions.duplicate(true), "events": events.duplicate(true)}
