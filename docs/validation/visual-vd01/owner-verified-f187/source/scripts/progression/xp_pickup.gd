extends Node2D

var value: int = 10
var collected: bool = false
var pickup_id: int = 0
var coins: int = 1

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(0, -4), Vector2(-3, 0), Vector2(0, 4), Vector2(3, 0)]), Color(0.3, 0.9, 1))
	draw_line(Vector2(0, -3), Vector2(0, 2), Color(0.8, 1, 1))
