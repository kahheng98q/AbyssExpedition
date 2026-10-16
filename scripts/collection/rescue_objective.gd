class_name RescueObjective
extends RefCounted

var state: String = "pending"
var center: Vector2 = Vector2.ZERO
var elapsed: int = 0
var owned_at_start: bool = false
var definition: RescueDefinition = load("res://data/events/sera_rescue.tres")

func offer(tick: int) -> bool:
	if state != "pending" or tick < 14400 or tick >= 32400: return false
	state = "offered"
	return true

func accept(point: Vector2) -> bool:
	if state != "offered": return false
	center = point
	state = "defending"
	return true

func decline() -> void:
	if state == "offered": state = "declined"

func advance(point: Vector2, alive: bool, paused: bool = false) -> void:
	if state != "defending" or paused: return
	if not alive or point.distance_to(center) > definition.zone_radius:
		state = "failed"
		return
	elapsed += 1
	if elapsed >= definition.duration_ticks: state = "succeeded"

func result() -> Dictionary:
	return {"state": state, "owned_at_start": owned_at_start}
