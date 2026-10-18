extends Node2D

var use_baked_enemies: bool = true
const ENEMY_ATLAS = preload("res://assets/actors/enemy-atlas.png")
const ENEMY_SHAPES = ["diamond", "crab", "lantern", "shell", "tentacles", "triangle", "crown"]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var actor = get_parent()
	if actor.health == null: return
	var tick = actor.run.clock.tick
	var shape = actor.visual().silhouette
	var color = actor.visual().palette
	if use_baked_enemies and not actor.is_hero and not actor.health.dead and shape in ENEMY_SHAPES:
		var bob: float = 1 if actor.velocity.length_squared() > 1 and tick % 12 < 6 else 0
		position = actor.position.round() - actor.position + Vector2(0, bob)
		var frame: int = (4 if actor.corrupted else 0) + (2 if tick < actor.health.hurt_until else 0) + (1 if tick % 36 >= 18 else 0)
		var row: int = ENEMY_SHAPES.find(shape)
		draw_texture_rect_region(ENEMY_ATLAS, Rect2(-32, -40, 64, 80), Rect2(frame * 64, row * 80, 64, 80))
		if actor.ai_state == "warning": draw_arc(Vector2.ZERO, 16, 0, TAU, 24, Color(1, 0.76, 0.25), 2)
		draw_enemy_health(actor)
		return
	if actor.corrupted:
		color = color.lerp(Color(0.72, 0.4, 0.95), 0.5)
		draw_arc(Vector2.ZERO, 18, 0, TAU, 12, Color(0.8, 0.54, 1), 1)
		for side in [-1, 1]: draw_line(Vector2(side * 7, -7), Vector2(side * 13, -14), Color(0.8, 0.54, 1), 2)
	var moving = actor.velocity.length_squared() > 1
	var bob: float = 1 if moving and tick % 12 < 6 else 0
	position = actor.position.round() - actor.position + Vector2(0, bob)
	if actor.health.dead:
		draw_line(Vector2(-8, 4), Vector2(8, 4), color.darkened(0.2), 4)
		draw_line(Vector2(-5, -2), Vector2(5, 8), Color.WHITE, 1)
		return
	# Ground shadow and strong outline separate the silhouette from tidal stone.
	draw_set_transform(Vector2(0, 10 - bob), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 25 if actor.is_boss else 12, Color(0.015, 0.025, 0.035, 0.65))
	draw_set_transform(Vector2.ZERO)
	if tick < actor.health.hurt_until: color = Color.WHITE
	elif tick < actor.attack_until:
		draw_line(actor.aim * 12, actor.aim * 21, color.lightened(0.4), 2)
	if actor.is_hero:
		draw_set_transform(Vector2(0, 10 - bob), 0, Vector2(1, 0.45))
		draw_arc(Vector2.ZERO, 15, 0, TAU, 24, Color(0.48, 0.65, 0.72) if actor.is_companion else Color("a9e8d2"), 1)
		draw_set_transform(Vector2.ZERO)
		if not actor.is_companion:
			draw_colored_polygon(PackedVector2Array([Vector2(-3, -22), Vector2(3, -22), Vector2(0, -18)]), Color("f3dc9e"))
		if actor.profession.is_promotion:
			match actor.profession.attack_policy:
				&"swordmaster":
					draw_line(Vector2(-10, 5), Vector2(-15, -10), Color(1, 0.9, 0.55), 3)
				&"abyss_swordsman":
					draw_arc(Vector2.ZERO, 19, 0.3, 2.8, 12, Color(0.7, 0.5, 1), 2)
				&"sharpshooter":
					draw_line(Vector2(14, -14), Vector2(14, 14), Color(0.7, 1, 0.5), 3)
				&"star_hunter":
					draw_line(Vector2(5, -16), Vector2(15, -6), Color(0.5, 0.8, 1), 2)
					draw_line(Vector2(5, -6), Vector2(15, -16), Color(0.5, 0.8, 1), 2)
				&"elemental_sage":
					for i in range(3): draw_rect(Rect2(-7 + i * 5, 6, 4, 6), [Color(1, 0.4, 0.2), Color(0.4, 0.8, 1), Color(0.8, 1, 0.4)][i])
				&"void_caster":
					draw_arc(Vector2(10, -10), 5, 0, TAU, 12, Color(0.85, 0.55, 1), 2)
		if tick < actor.health.invulnerable_until:
			draw_arc(Vector2.ZERO, 16, 0, TAU, 24, Color.WHITE, 2)
			if tick % 6 < 3: color.a = 0.35
	if actor.ai_state == "warning":
		draw_arc(Vector2.ZERO, 16, 0, TAU, 24, Color(1, 0.76, 0.25), 2)
	match shape:
		"sword", "bow", "star":
			draw_hero(actor, shape, color, tick, moving)
		"crab":
			for x in [-1, 1]:
				for leg in range(3):
					draw_line(Vector2(x * 6, leg * 3 - 2), Vector2(x * (12 + int(bob)), leg * 4 - 1), color.darkened(0.35), 2)
				draw_line(Vector2(x * 7, -2), Vector2(x * 14, -9), Color("09141d"), 5)
				draw_line(Vector2(x * 7, -2), Vector2(x * 14, -9), color, 3)
				draw_line(Vector2(x * 14, -9), Vector2(x * 9, -12), color.lightened(0.2), 2)
			draw_rect(Rect2(-9, -6, 18, 13), Color("09141d"))
			draw_rect(Rect2(-7, -5, 14, 10), color.darkened(0.15))
			draw_rect(Rect2(-5, -5, 10, 3), color.lightened(0.15))
			for x in [-4, 3]: draw_rect(Rect2(x, -2, 2, 2), Color("fff0bc"))
		"lantern":
			draw_colored_polygon(PackedVector2Array([Vector2(0, -15), Vector2(-9, 10), Vector2(-3, 7), Vector2(2, 12), Vector2(8, 9)]), color.darkened(0.6))
			draw_line(Vector2(0, -10), Vector2(-2, 7), color.darkened(0.2), 3)
			draw_rect(Rect2(-3, -8, 6, 4), Color("0b1920"))
			draw_rect(Rect2(-1, -7, 2, 1), Color("f6e1a1"))
			draw_line(Vector2(4, -1), Vector2(11, -3), color, 2)
			draw_rect(Rect2(7, -3, 8, 10), Color("09141d"))
			draw_rect(Rect2(8, -2, 6, 7), color)
			draw_rect(Rect2(10, -1, 2, 5), Color("fff1bf"))
		"shell":
			draw_circle(Vector2.ZERO, 12, Color("09141d"))
			draw_circle(Vector2.ZERO, 10, color.darkened(0.2))
			for x in [-5, 0, 5]: draw_line(Vector2(x, -8), Vector2(x, 8), color.darkened(0.4), 2)
			draw_arc(Vector2.ZERO, 8, PI, TAU, 8, color.lightened(0.3), 2)
			draw_rect(Rect2(-3, 3, 6, 4), Color("09141d"))
			draw_rect(Rect2(-2, 4, 4, 1), Color("e9c7ab"))
		"tentacles":
			for x in [-9, -3, 3, 9]:
				var tip = Vector2(x + (2 if tick % 24 < 12 else -2), 12)
				draw_line(Vector2(x / 2.0, 2), tip, Color("09141d"), 5)
				draw_line(Vector2(x / 2.0, 2), tip, color.darkened(0.2), 3)
			draw_circle(Vector2(0, -3), 10, Color("09141d"))
			draw_circle(Vector2(0, -4), 8, color.darkened(0.2))
			draw_arc(Vector2(0, -4), 6, 3.4, 5.5, 8, color.lightened(0.2), 2)
			draw_rect(Rect2(-4, -5, 8, 4), Color("e9d8bf"))
			draw_rect(Rect2(-1, -5, 2, 4), Color("1b192b"))
		"triangle":
			draw_colored_polygon(PackedVector2Array([Vector2(0, -6), Vector2(-6, 5), Vector2(6, 5)]), color)
		"crown":
			for x in [-24, -14, 14, 24]:
				var tip = Vector2(x + (2 if tick % 36 < 18 else -2), 26)
				var bend = Vector2(x, 15)
				var points = PackedVector2Array([Vector2(x / 3.0, 5), bend, tip, tip + Vector2(-signi(x) * 5, -2)])
				draw_polyline(points, Color("0c1422"), 7)
				draw_polyline(points, color.darkened(0.4), 4)
				draw_rect(Rect2(tip - Vector2(1, 2), Vector2(2, 2)), Color("a4bab0"))
			draw_colored_polygon(PackedVector2Array([Vector2(-21, 19), Vector2(-16, -13), Vector2(0, -22), Vector2(16, -13), Vector2(21, 19), Vector2(0, 26)]), Color("0c1422"))
			draw_colored_polygon(PackedVector2Array([Vector2(-17, 17), Vector2(-13, -11), Vector2(0, -18), Vector2(13, -11), Vector2(17, 17), Vector2(0, 22)]), color.darkened(0.55))
			for side in [-1, 1]:
				draw_line(Vector2(side * 14, -10), Vector2(side * 6, 17), color.darkened(0.15), 3)
				draw_line(Vector2(side * 6, 17), Vector2(0, 20), Color("c2ab7d"), 1)
				draw_line(Vector2(side * 18, -9), Vector2(side * 23, -3), Color("798f8b"), 3)
			draw_rect(Rect2(-7, -23, 14, 17), Color("40545a"))
			for x in [-10, 0, 10]:
				draw_line(Vector2(x * 0.6, -21), Vector2(x, -31), Color("15232c"), 5)
				draw_line(Vector2(x * 0.6, -21), Vector2(x, -31), Color("c3b083"), 3)
			draw_colored_polygon(PackedVector2Array([Vector2(-10, -15), Vector2(0, -21), Vector2(10, -15), Vector2(0, -8)]), Color("0b1722"))
			draw_colored_polygon(PackedVector2Array([Vector2(-7, -15), Vector2(0, -19), Vector2(7, -15), Vector2(0, -10)]), Color("b9d9c5"))
			draw_line(Vector2(0, -18), Vector2(0, -11), Color("293148"), 3)
			draw_line(Vector2(0, -3), Vector2(0, 10), Color("ac8dba"), 2)
		_:
			# Saltbound thrall: ragged cult robe, pale drowned face and hooked arms.
			draw_colored_polygon(PackedVector2Array([Vector2(-4, -5), Vector2(4, -5), Vector2(8, 12), Vector2(2, 9), Vector2(-3, 12), Vector2(-8, 9)]), Color("09141d"))
			draw_colored_polygon(PackedVector2Array([Vector2(-3, -4), Vector2(3, -4), Vector2(6, 10), Vector2(0, 7), Vector2(-6, 9)]), color.darkened(0.4))
			draw_rect(Rect2(-4, -11, 8, 7), color)
			draw_rect(Rect2(-3, -9, 6, 2), Color("172832"))
			for side in [-1, 1]:
				draw_line(Vector2(side * 4, -2), Vector2(side * 9, 4), color.darkened(0.2), 2)
				draw_line(Vector2(side * 9, 4), Vector2(side * 10, 0), color, 2)
	if actor.is_hero and actor.profession.attack_policy == &"elemental_sage":
		for i in range(3): draw_rect(Rect2(-7 + i * 5, 6, 4, 6), [Color(1, 0.4, 0.2), Color(0.4, 0.8, 1), Color(0.8, 1, 0.4)][i])
	if actor.resistant: draw_arc(Vector2.ZERO, 14 if not actor.is_boss else 29, 0.3, 2.8, 12, Color(0.65, 0.8, 1), 2)
	draw_enemy_health(actor)

func draw_enemy_health(actor) -> void:
	if not actor.is_hero and actor.health.current < actor.health.maximum:
		draw_rect(Rect2(-12, -18 if not actor.is_boss else -36, 24, 3), Color(0.14, 0.07, 0.1))
		draw_rect(Rect2(-12, -18 if not actor.is_boss else -36, 24 * actor.health.current / actor.health.maximum, 3), Color(1, 0.45, 0.5))

func draw_hero(actor, shape: String, color: Color, tick: int, moving: bool) -> void:
	var ink = Color("09131e")
	var step: int = (2 if tick % 12 < 6 else -2) if moving else 0
	var facing: float = -1 if actor.aim.x < 0 else 1
	var attack: bool = tick < actor.attack_until
	var lean: float = facing * (2 if attack else 0)
	draw_set_transform(Vector2(lean, 0))
	# Cloth behind torso; asymmetric hem and boots give the walk a readable gait.
	draw_colored_polygon(PackedVector2Array([Vector2(-6, -4), Vector2(5, -4), Vector2(8 - facing * 3, 12), Vector2(0, 9), Vector2(-8 - facing * 2, 11)]), ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-5, -3), Vector2(4, -3), Vector2(6 - facing * 3, 10), Vector2(0, 7), Vector2(-6 - facing * 2, 9)]), color.darkened(0.5))
	draw_rect(Rect2(-5, 7 + step, 4, 6), ink)
	draw_rect(Rect2(2, 7 - step, 4, 6), ink)
	draw_rect(Rect2(-5, 9 + step, 3, 2), Color("8796a2"))
	draw_rect(Rect2(2, 9 - step, 3, 2), Color("8796a2"))
	draw_rect(Rect2(-6, -5, 12, 13), ink)
	draw_rect(Rect2(-5, -4, 10, 10), color.darkened(0.15))
	draw_rect(Rect2(-4, -4, 3, 8), color.lightened(0.2))
	draw_rect(Rect2(-5, 4, 10, 2), Color("4a3d3b"))
	draw_rect(Rect2(-1, 4, 3, 2), Color("dfbd79"))
	draw_rect(Rect2(-5, -13, 10, 9), ink)
	draw_rect(Rect2(-4, -12, 8, 7), Color("e6c8a1"))
	draw_rect(Rect2(-5, -14, 10, 4), color.darkened(0.45))
	draw_rect(Rect2(facing * 2, -9, 2, 2), ink)
	if shape == "sword":
		draw_rect(Rect2(-7, -4, 4, 5), Color("b3ced3"))
		draw_rect(Rect2(3, -4, 4, 4), Color("b3ced3"))
		draw_rect(Rect2(-5, -14, 10, 3), Color("8caeb8"))
		var axis: Vector2 = actor.aim.rotated(-0.6 + (12 - actor.attack_until + tick) * 0.13) if attack else Vector2(facing * 0.35, -0.94)
		var hand: Vector2 = actor.aim * 9 if attack else Vector2(facing * 9, 2)
		draw_line(hand - axis * 4, hand + axis * 17, ink, 5)
		draw_line(hand, hand + axis * 17, Color("dbf0ea"), 3)
		draw_line(hand + axis.orthogonal() * 4, hand - axis.orthogonal() * 4, Color("d5b87b"), 2)
	elif shape == "bow":
		draw_line(Vector2(-6, 7), Vector2(5, -8), Color("c6a16d"), 2)
		var hand: Vector2 = actor.aim * 10
		var center: float = actor.aim.angle()
		draw_arc(hand, 9, center - 1.4, center + 1.4, 10, ink, 4)
		draw_arc(hand, 9, center - 1.4, center + 1.4, 10, Color("e1bc7c"), 2)
		draw_line(hand + actor.aim.rotated(-1.4) * 9, hand + actor.aim.rotated(1.4) * 9, Color("dce9d7"))
		if attack: draw_line(hand - actor.aim * 5, hand + actor.aim * 14, Color("eff2d8"), 1)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-7, -10), Vector2(-2, -18), Vector2(7, -10)]), color.darkened(0.3))
		draw_line(Vector2(-7, -10), Vector2(7, -10), Color("c0b5de"), 2)
		var hand: Vector2 = actor.aim * 11 if attack else Vector2(facing * 10, 0)
		draw_line(hand + Vector2(0, 10), hand - Vector2(0, 10), ink, 4)
		draw_line(hand + Vector2(0, 9), hand - Vector2(0, 10), Color("b8a0c2"), 2)
		draw_colored_polygon(PackedVector2Array([hand + Vector2(0, -14), hand + Vector2(4, -9), hand + Vector2(0, -4), hand + Vector2(-4, -9)]), color.lightened(0.4))
		draw_rect(Rect2(hand + Vector2(-1, -11), Vector2(2, 4)), Color("f5e5ff"))
	draw_set_transform(Vector2.ZERO)
