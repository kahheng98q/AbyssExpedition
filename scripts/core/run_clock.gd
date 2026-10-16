class_name RunClock
extends RefCounted

var tick: int = 0

func advance_one_tick() -> void:
	tick += 1

func display_time() -> String:
	return "%02d:%02d" % [floori(tick / 3600.0), floori(tick / 60.0) % 60]
