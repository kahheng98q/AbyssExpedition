extends Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var actor = get_parent()
	if actor.health == null: return
	var tick = actor.run.clock.tick
	var shape = actor.visual().silhouette
	var color = actor.visual().palette
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
	if tick < actor.health.hurt_until: color = Color.WHITE
	elif tick < actor.attack_until:
		draw_line(actor.aim * 12, actor.aim * 21, color.lightened(0.4), 2)
	if actor.is_hero:
		draw_arc(Vector2.ZERO, 13, 0, TAU, 24, Color(0.6, 0.75, 0.85) if actor.is_companion else Color(0.85, 1, 1), 1)
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
	draw_rect(Rect2(-8, -11, 16, 22), Color(0.015, 0.025, 0.04), true)
	match shape:
		"sword", "bow", "star":
			draw_rect(Rect2(-6, -3, 12, 12), color)
			draw_rect(Rect2(-4, -10, 8, 7), Color(0.94, 0.84, 0.66))
			draw_rect(Rect2(-6, -13, 12, 4), color.darkened(0.3))
			draw_rect(Rect2(-5, 9, 4, 4), color.darkened(0.3))
			draw_rect(Rect2(2, 9, 4, 4), color.darkened(0.3))
			if shape == "sword":
				draw_line(Vector2(9, 5), Vector2(15, -10), Color(0.85, 0.95, 1), 3)
				draw_line(Vector2(7, 2), Vector2(14, 5), color, 2)
			elif shape == "bow":
				draw_arc(Vector2(7, 0), 10, -1.3, 1.3, 8, Color(0.82, 0.65, 0.39), 2)
				draw_line(Vector2(10, -10), Vector2(10, 10), Color.WHITE)
			else:
				draw_line(Vector2(10, -8), Vector2(10, 8), Color.WHITE, 2)
				draw_line(Vector2(3, 0), Vector2(17, 0), color, 2)
		"crab":
			draw_rect(Rect2(-9, -5, 18, 10), color)
			for x in [-1, 1]:
				draw_line(Vector2(x * 7, -2), Vector2(x * 14, -9), color, 3)
				draw_line(Vector2(x * 6, 4), Vector2(x * 12, 10), color, 2)
		"lantern":
			draw_rect(Rect2(-5, -11, 10, 22), color.darkened(0.35))
			draw_rect(Rect2(-8, -5, 16, 10), color)
			draw_rect(Rect2(-3, -2, 6, 4), Color(1, 1, 0.7))
		"shell":
			draw_circle(Vector2.ZERO, 11, color)
			for x in [-5, 0, 5]: draw_line(Vector2(x, -8), Vector2(x, 8), color.darkened(0.4), 2)
		"tentacles":
			draw_circle(Vector2(0, -3), 9, color)
			for x in [-9, -3, 3, 9]: draw_line(Vector2(x / 2.0, 2), Vector2(x, 13), color, 3)
		"triangle":
			draw_colored_polygon(PackedVector2Array([Vector2(0, -6), Vector2(-6, 5), Vector2(6, 5)]), color)
		"crown":
			for x in [-24, -12, 12, 24]:
				draw_line(Vector2(x / 2.0, 12), Vector2(x, 28), color, 3)
			draw_circle(Vector2(0, -9), 8, Color(0.6, 0.9, 0.78))
			draw_circle(Vector2(0, -9), 3, Color(0.04, 0.02, 0.08))
			draw_colored_polygon(PackedVector2Array([Vector2(-20, 23), Vector2(-12, -18), Vector2(12, -18), Vector2(20, 23)]), color.darkened(0.25))
			draw_rect(Rect2(-10, -24, 20, 16), color)
			for x in [-12, 0, 12]: draw_line(Vector2(x, -21), Vector2(x, -31), Color(1, 0.8, 0.4), 4)
			draw_circle(Vector2(0, -15), 6, Color(0.7, 0.95, 0.83))
			draw_line(Vector2(0, -19), Vector2(0, -11), Color(0.07, 0.03, 0.12), 3)
		_:
			draw_colored_polygon(PackedVector2Array([Vector2(0, -12), Vector2(-9, 0), Vector2(0, 12), Vector2(9, 0)]), color)
	if actor.is_hero and actor.profession.attack_policy == &"elemental_sage":
		for i in range(3): draw_rect(Rect2(-7 + i * 5, 6, 4, 6), [Color(1, 0.4, 0.2), Color(0.4, 0.8, 1), Color(0.8, 1, 0.4)][i])
	if actor.resistant: draw_arc(Vector2.ZERO, 14 if not actor.is_boss else 29, 0.3, 2.8, 12, Color(0.65, 0.8, 1), 2)
	if not actor.is_hero and actor.health.current < actor.health.maximum:
		draw_rect(Rect2(-12, -18 if not actor.is_boss else -36, 24, 3), Color(0.14, 0.07, 0.1))
		draw_rect(Rect2(-12, -18 if not actor.is_boss else -36, 24 * actor.health.current / actor.health.maximum, 3), Color(1, 0.45, 0.5))
