extends Node2D

var geometry: String = "circle"
var radius: float = 13.0
var direction: Vector2 = Vector2.RIGHT
var angle: float = 70.0
var expires: int = 0
var impact: bool = false

func contains(point: Vector2) -> bool:
	if geometry == "cone": return load("res://scripts/combat/melee_arc.gd").contains(position, direction, radius, angle, point)
	return position.distance_to(point) <= radius

func _draw() -> void:
	var color = Color(1, 0.25, 0.22, 0.55) if impact else Color(1, 0.75, 0.2, 0.28)
	var outline = Color(1, 0.35, 0.3) if impact else Color(1, 0.8, 0.3)
	if geometry == "cone":
		var points = PackedVector2Array([Vector2.ZERO])
		for i in range(19):
			points.append(direction.rotated(deg_to_rad(-angle / 2.0 + angle * i / 18.0)) * radius)
		draw_colored_polygon(points, color)
		points.append(Vector2.ZERO)
		draw_polyline(points, outline, 2)
	else:
		draw_circle(Vector2.ZERO, radius, color)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline, 2)
		draw_line(Vector2(-5, 0), Vector2(5, 0), outline)
		draw_line(Vector2(0, -5), Vector2(0, 5), outline)
