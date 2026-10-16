extends Node2D

var objective: RescueObjective

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if objective == null: return
	var color = Color(0.35, 1, 0.72, 0.8)
	if objective.state == "failed": color = Color(1, 0.4, 0.3, 0.8)
	draw_circle(Vector2.ZERO, objective.definition.zone_radius, Color(color, 0.08))
	draw_arc(Vector2.ZERO, objective.definition.zone_radius, 0, TAU, 64, color, 2)
	draw_line(Vector2(-8, 0), Vector2(8, 0), color, 2)
	draw_line(Vector2(0, -8), Vector2(0, 8), color, 2)
