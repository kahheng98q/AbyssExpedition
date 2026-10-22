extends Node2D

var direction: Vector2 = Vector2.RIGHT
var reach: float = 48.0
var angle: float = 100.0
var expires: int = 0
var run
var color: Color = Color(0.7, 1, 0.95)
var sword_visual: Dictionary = {}

static func contains(origin: Vector2, facing: Vector2, radius: float, degrees: float, point: Vector2) -> bool:
	var difference = point - origin
	return difference.length() <= radius and (difference.is_zero_approx() or facing.dot(difference.normalized()) >= cos(deg_to_rad(degrees * 0.5)))

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not sword_visual.is_empty() and run != null and not (run is Node and run.get_meta("sword_presentation_disabled", false)):
		SwordPresentation.draw_arc(self, sword_visual, run.clock.tick, color)
		return
	var half = deg_to_rad(angle * 0.5)
	var phase = clampf((10.0 - (expires - run.clock.tick)) / 10.0, 0, 1) if run != null else 0.4
	var fade = 1.0 - phase
	var start = direction.angle() - half
	var end = direction.angle() + half
	# The complete rim appears on the actual hit tick; the blade sweeps through it.
	draw_arc(Vector2.ZERO, reach, start, end, 24, Color(color, fade * 0.6), 1)
	var blade = lerpf(start, end, minf(1, phase * 1.6))
	var tail = maxf(start, blade - half * 0.9)
	var points = PackedVector2Array()
	for i in range(13): points.append(Vector2.from_angle(lerpf(tail, blade, i / 12.0)) * reach)
	for i in range(12, -1, -1): points.append(Vector2.from_angle(lerpf(tail, blade, i / 12.0)) * (reach - 5 - i * 0.5))
	if blade > tail:
		draw_colored_polygon(points, Color(color, fade * 0.75))
		draw_arc(Vector2.ZERO, reach - 2, tail, blade, 18, Color(0.95, 1, 0.91, fade), 2)
	draw_line(Vector2.from_angle(blade) * 12, Vector2.from_angle(blade) * reach, Color(1, 0.96, 0.79, fade), 2)
