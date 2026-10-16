extends Node2D

var run
var expires: int
var next_tick: int
var period: int = 30
var radius: float = 24
var damage: float = 9
var pull: bool = false
var pull_speed: float = 30

func simulate(tick: int) -> void:
	if tick >= expires:
		queue_free()
		return
	for actor in run.enemies:
		if actor.health.dead or actor.position.distance_to(position) > radius: continue
		if pull:
			if not actor.resistant:
				actor.position = actor.position.move_toward(position, pull_speed / 60.0).clamp(Vector2(12, 12), Vector2(948, 528))
			else: actor.health.hurt_until = tick + 2
		elif tick >= next_tick:
			run.queue_hit(actor, damage, Vector2.ZERO, 0, false, false)
	if tick >= next_tick: next_tick = tick + period

func _draw() -> void:
	var color = Color(0.72, 0.36, 1, 0.6)
	draw_circle(Vector2.ZERO, radius, Color(0.34, 0.12, 0.5, 0.2))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, 2)
	if pull:
		for i in range(4):
			var direction = Vector2.RIGHT.rotated(i * PI / 2)
			draw_line(direction * radius, direction * radius * 0.3, color, 2)
