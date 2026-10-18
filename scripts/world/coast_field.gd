extends Node2D

var corruption: int = 0
var use_baked_art: bool = true
const COAST = preload("res://assets/world/coast-0.png")
const CORRUPTED_COAST = preload("res://assets/world/coast-100.png")

func set_corruption(value: int) -> void:
	corruption = value
	queue_redraw()

func _ready() -> void:
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
	if use_baked_art:
		# Same original drawing, rasterized offline; replaces 1,341 field draw calls.
		draw_texture(COAST, Vector2.ZERO)
		if corruption > 0: draw_texture(CORRUPTED_COAST, Vector2.ZERO, Color(1, 1, 1, corruption / 100.0))
		return
	draw_field()

func draw_field() -> void:
	var tide = Color("23434d").lerp(Color("3b304d"), corruption / 100.0)
	draw_rect(Rect2(0, 0, 960, 540), Color("14242b"))
	# Dry shelf, cracked flagstones and shallow water are all walkable.
	# Integer coordinate hashes produce original stable detail without an RNG stream.
	for y in range(16, 528, 16):
		for x in range(16, 944, 16):
			var hash_value: int = (x * 73 + y * 137 + x * y * 3) % 101
			var shore: int = 360 + int(sin(x * 0.012) * 24) + int(cos(x * 0.026) * 12)
			if y > shore:
				draw_rect(Rect2(x, y, 16, 16), tide.darkened(0.12 if y < shore + 24 else 0.25))
				if hash_value < 22: draw_line(Vector2(x + 2, y + 7), Vector2(x + 11, y + 7), tide.lightened(0.06), 1)
				if y < shore + 16: draw_line(Vector2(x, y + 1), Vector2(x + 16, y + 1), Color("385458"), 2)
			elif hash_value < 35:
				draw_rect(Rect2(x + hash_value % 9, y + 5, 2, 1), Color("2a3b3e"))
				if hash_value < 9: draw_line(Vector2(x + 5, y + 10), Vector2(x + 7, y + 6), Color("30453f"), 1)
	# Remains of an imperial causeway, broken into staggered 16px stone courses.
	for row in range(4, 29):
		for col in range(5, 55):
			var p = Vector2(col * 16 + (row % 2) * 8, row * 16)
			var path_center: float = 268 + sin(p.x * 0.008) * 36
			var in_path: bool = absf(p.y - path_center) < 43 or (absf(p.x - 480) < 45 and p.y > 165)
			var variant: int = (row * 31 + col * 19) % 17
			if not in_path or variant < 2: continue
			draw_rect(Rect2(p + Vector2(0, 2), Vector2(15, 14)), Color("101e26"))
			draw_rect(Rect2(p, Vector2(14, 12)), Color("26373c") if variant < 10 else Color("2b3b3e"))
			draw_line(p, p + Vector2(13, 0), Color("364748"))
			if variant == 3 or variant == 12:
				draw_polyline(PackedVector2Array([p + Vector2(5, 0), p + Vector2(7, 4), p + Vector2(4, 7), p + Vector2(6, 12)]), Color("16282e"))
	# Inlaid compass / drowned sanctuary: low contrast so warnings retain priority.
	for radius in [54, 64]: draw_arc(Vector2(480, 270), radius, 0, TAU, 48, Color("3c4b48"), 1)
	for i in range(8):
		var axis = Vector2.from_angle(i * TAU / 8)
		draw_line((Vector2(480, 270) + axis * 56).round(), (Vector2(480, 270) + axis * 62).round(), Color("657063"), 2)
	for point in [Vector2(240, 160), Vector2(720, 380), Vector2(800, 128), Vector2(160, 420)]:
		draw_ruin(point, tide)
	# Edge stones mark the actual boundary; scattered small details never block.
	draw_rect(Rect2(4, 4, 952, 532), Color("34494b"), false, 8)
	for x in range(16, 944, 32):
		for y in [8, 520]:
			draw_rect(Rect2(x, y, 27, 9), Color("25363d"))
			draw_line(Vector2(x, y), Vector2(x + 27, y), Color("4b5e5d"), 1)
	for point in [Vector2(302, 144), Vector2(620, 157), Vector2(345, 350), Vector2(660, 318)]:
		draw_line(point, point + Vector2(12, 3), Color("101d25"), 4)
		draw_rect(Rect2(point, Vector2(9, 3)), Color("40504d"))
		draw_rect(Rect2(point + Vector2(14, 6), Vector2(4, 2)), Color("304441"))

func draw_ruin(point: Vector2, tide: Color) -> void:
	draw_rect(Rect2(point + Vector2(-20, 12), Vector2(43, 7)), Color("0e1c24"))
	for i in range(3):
		draw_rect(Rect2(point + Vector2(-18 + i * 3, 9 - i * 4), Vector2(36 - i * 6, 4)), Color("344548").lightened(i * 0.025))
	draw_colored_polygon(PackedVector2Array([point + Vector2(-10, 0), point + Vector2(-9, -29), point + Vector2(-3, -34), point + Vector2(2, -28), point + Vector2(8, -30), point + Vector2(10, 0)]), Color("101f29"))
	draw_colored_polygon(PackedVector2Array([point + Vector2(-7, -1), point + Vector2(-6, -28), point + Vector2(-2, -30), point + Vector2(3, -25), point + Vector2(6, -26), point + Vector2(7, -1)]), Color("3d5052"))
	draw_line(point + Vector2(-6, -26), point + Vector2(-6, -2), Color("5c6c65"), 2)
	draw_line(point + Vector2(3, -25), point + Vector2(3, -2), Color("253940"), 2)
	draw_arc(point + Vector2(0, -14), 4, 0, TAU, 8, tide.lightened(0.24), 1)
	draw_line(point + Vector2(0, -17), point + Vector2(0, -11), Color("b7b99b"), 1)
