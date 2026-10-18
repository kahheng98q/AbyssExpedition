extends Node2D

var direction: Vector2 = Vector2.RIGHT
var reach: float = 48.0
var angle: float = 100.0
var expires: int = 0
var run
var color: Color = Color(0.7, 1, 0.95)
var using_sprite: bool = false
var force_fallback: bool = false
var sprite_frames: SpriteFrames = preload("res://data/visuals/sword_frames_vd01.tres")
var draw_key: Array = []

func _ready() -> void:
	_process(0)

func _process(_delta: float) -> void:
	using_sprite=not force_fallback and is_equal_approx(reach,48) and is_equal_approx(angle,100) and sprite_frames!=null and sprite_frames.has_animation(&"active") and sprite_frames.get_frame_count(&"active")>=2
	var frame = mini(1,maxi(0,floori((run.clock.tick-(expires-10))/5.0))) if using_sprite and run!=null else -1
	var current = [using_sprite, sprite_frames, frame, direction, reach, angle, color]
	if current != draw_key:
		draw_key = current
		queue_redraw()

static func contains(origin: Vector2, facing: Vector2, radius: float, degrees: float, point: Vector2) -> bool:
	var difference = point - origin
	return difference.length() <= radius and (difference.is_zero_approx() or facing.dot(difference.normalized()) >= cos(deg_to_rad(degrees * 0.5)))

func _draw() -> void:
	var half = deg_to_rad(angle * 0.5)
	if using_sprite and run!=null:
		var frame=mini(1,maxi(0,floori((run.clock.tick-(expires-10))/5.0)))
		draw_set_transform(Vector2.ZERO,direction.angle())
		draw_texture(sprite_frames.get_frame_texture(&"active",frame),Vector2(-8,-48))
		draw_set_transform(Vector2.ZERO)
		# Exact simulation radius/angle boundary remains visible.
		draw_arc(Vector2.ZERO,reach,direction.angle()-half,direction.angle()+half,18,color,1)
		return
	draw_arc(Vector2.ZERO, reach, direction.angle() - half, direction.angle() + half, 18, color, 3)
	draw_arc(Vector2.ZERO, reach - 8, direction.angle() - half, direction.angle() + half, 18, Color(0.3, 0.8, 0.76, 0.4), 4)
