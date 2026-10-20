extends Node2D

var direction: Vector2 = Vector2.RIGHT
var reach: float = 48.0
var angle: float = 100.0
var expires: int = 0
var run
var color: Color = Color(0.7, 1, 0.95)

static func contains(origin: Vector2, facing: Vector2, radius: float, degrees: float, point: Vector2) -> bool:
	var difference = point - origin
	return difference.length() <= radius and (difference.is_zero_approx() or facing.dot(difference.normalized()) >= cos(deg_to_rad(degrees * 0.5)))

func _draw() -> void:
	var half = deg_to_rad(angle * 0.5)
	draw_arc(Vector2.ZERO, reach, direction.angle() - half, direction.angle() + half, 18, color, 3)
	draw_arc(Vector2.ZERO, reach - 8, direction.angle() - half, direction.angle() + half, 18, Color(0.3, 0.8, 0.76, 0.4), 4)
