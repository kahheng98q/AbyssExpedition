class_name PauseCoordinator
extends RefCounted

var tokens: Dictionary = {}
var serial: int = 0

func acquire(reason: String, owner_id: String) -> int:
	serial += 1
	tokens[serial] = {"reason": reason, "owner": owner_id}
	return serial

func release(token: int, owner_id: String) -> bool:
	if not tokens.has(token) or tokens[token].owner != owner_id: return false
	tokens.erase(token)
	return true

func is_blocked() -> bool:
	return not tokens.is_empty()

func cancel_all() -> void:
	tokens.clear()
