extends Node2D

var corruption: int = 0
@export var visual_scene: PackedScene
var using_visual: bool = false
var visual_subtree: Node2D
var force_fallback: bool = false

func set_corruption(value: int) -> void:
	corruption = value
	if visual_subtree!=null:visual_subtree.set_corruption(value)
	queue_redraw()

func _ready() -> void:
	if visual_scene!=null:
		visual_subtree=visual_scene.instantiate()
		add_child(visual_subtree)
		using_visual=visual_subtree.is_complete()
		visual_subtree.visible=using_visual
	# Actual physics walls supplement continuous-coordinate movement clamping.
	for rectangle in [Rect2(-16, -16, 992, 16), Rect2(-16, 540, 992, 16), Rect2(-16, 0, 16, 540), Rect2(960, 0, 16, 540)]:
		var body = StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = rectangle.size
		collision.shape = shape
		body.position = rectangle.get_center()
		body.add_child(collision)
		add_child(body)

func _draw() -> void:
	if visual_subtree!=null:visual_subtree.visible=using_visual and not force_fallback
	if using_visual and not force_fallback:return
	draw_rect(Rect2(0, 0, 960, 540), Color(0.075, 0.14, 0.16))
	# Shallow tidal shelves are decorative, walkable and visually quiet.
	for shelf in range(4):
		draw_rect(Rect2(0, 412 + shelf * 32, 960, 32), Color(0.08, 0.19 + shelf * 0.015, 0.23 + shelf * 0.015))
	for y in range(0, 540, 16):
		for x in range(0, 960, 16):
			var pattern = (floori(x / 16.0) * 17 + floori(y / 16.0) * 31) % 13
			if pattern < 3: draw_rect(Rect2(x + 3, y + 5, 3, 2), Color(0.10, 0.18, 0.19))
			if pattern == 8: draw_line(Vector2(x + 4, y + 10), Vector2(x + 9, y + 10), Color(0.12, 0.2, 0.22))
	draw_rect(Rect2(0, 0, 960, 540), Color(0.25, 0.44, 0.47), false, 8)
	var tide = Color(0.13, 0.43, 0.52).lerp(Color(0.48, 0.24, 0.65), corruption / 100.0)
	for y in [16, 524]:
		draw_line(Vector2(16, y), Vector2(944, y), tide, 8)
	for x in range(48, 944, 96):
		draw_arc(Vector2(x, 24), 10, 0, PI, 8, Color(0.54, 0.73, 0.66), 2)
	for x in range(0, 960, 32):
		draw_line(Vector2(x, 8), Vector2(x + 18, 8), Color(0.5, 0.63, 0.6), 2)
	for point in [Vector2(240, 160), Vector2(720, 380), Vector2(800, 128), Vector2(160, 420)]:
		draw_rect(Rect2(point - Vector2(7, 11), Vector2(14, 22)), Color(0.18, 0.29, 0.3))
		draw_arc(point, 5, 0, TAU, 8, tide, 1)
		draw_line(point + Vector2(-8, 14), point + Vector2(12, 14), Color(0.42, 0.38, 0.29), 3)
