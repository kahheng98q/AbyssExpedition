class_name PauseCoordinator
extends RefCounted

signal changed(state: Dictionary)

var tokens: Dictionary = {}
var serial: int = 0

func acquire(reason: String, owner_id: String) -> int:
	serial += 1
	tokens[serial] = {"reason": reason, "owner": owner_id}
	changed.emit(snapshot())
	return serial

func release(token: int, owner_id: String) -> bool:
	if not tokens.has(token) or tokens[token].owner != owner_id: return false
	tokens.erase(token)
	changed.emit(snapshot())
	return true

func is_blocked() -> bool:
	return not tokens.is_empty()

func cancel_all() -> void:
	if tokens.is_empty(): return
	tokens.clear()
	changed.emit(snapshot())

func snapshot() -> Dictionary:
	var state = tokens.duplicate(true)
	for token in state: state[token].make_read_only()
	state.make_read_only()
	return state
