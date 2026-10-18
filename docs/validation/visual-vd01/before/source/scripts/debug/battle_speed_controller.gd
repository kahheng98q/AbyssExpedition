extends RefCounted

var value: int = 1
var prior_time_scale: float = 1.0
var prior_tick_rate: int = 60
var captured: bool = false

func set_speed(speed: int) -> bool:
	if not OS.has_feature("debug") or speed not in [1, 2, 4]: return false
	if not captured:
		prior_time_scale = Engine.time_scale
		prior_tick_rate = Engine.physics_ticks_per_second
		captured = true
	# Keep each gameplay step at 1/60 simulation second. Projectiles and actor
	# movement use the same fixed step, while there are more steps per wall second.
	Engine.time_scale = float(speed)
	Engine.physics_ticks_per_second = 60 * speed
	value = speed
	return true

func reset() -> void:
	if not OS.has_feature("debug"): return
	if captured:
		Engine.time_scale = prior_time_scale
		Engine.physics_ticks_per_second = prior_tick_rate
	value = 1
	captured = false
