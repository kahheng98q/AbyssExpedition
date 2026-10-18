extends Node2D

var using_sprite: bool = false
var force_fallback: bool = false
var sprite: AnimatedSprite2D
var selected: VisualSet
var identity_key: String = ""
var facing_x: int = 1
var cue_key: Array = []

func _ready() -> void:
	sync_sprite()

func _process(_delta: float) -> void:
	sync_sprite()
	var actor = get_parent()
	if actor.health == null or actor.run == null: return
	var tick = actor.run.clock.tick
	if not using_sprite:
		# The transform follows physics every display frame, even when ink is cached.
		var bob: float = 1 if actor.velocity.length_squared() > 1 and tick % 12 < 6 else 0
		position = actor.position.round() - actor.position + Vector2(0, bob)
	var visual = actor.visual()
	var current = [using_sprite, selected, visual.silhouette, visual.palette,
		actor.corrupted, actor.health.dead, tick < actor.health.hurt_until,
		tick < actor.attack_until, actor.aim, actor.is_hero, actor.is_companion,
		actor.profession if actor.is_hero else null, actor.ai_state, actor.resistant,
		actor.is_boss, actor.health.current, actor.health.maximum,
		tick < actor.health.invulnerable_until,
		actor.is_hero and tick < actor.health.invulnerable_until and tick % 6 < 3]
	if current != cue_key:
		cue_key = current
		queue_redraw()

func sync_sprite() -> void:
	var actor=get_parent()
	if actor.health==null or actor.run==null:return
	var profession=actor.profession.id if actor.is_hero else &""
	var key=String(actor.definition.id)+":"+String(profession)
	if key!=identity_key:
		identity_key=key
		var catalog=actor.run.get("catalog")
		selected=catalog.actor_visuals.resolve("hero" if actor.is_hero else "enemy",actor.definition.id,profession) if catalog!=null and catalog.actor_visuals!=null else null
		if selected!=null and (selected.sprite_frames==null or not selected.validate().is_empty()):selected=null
	using_sprite=selected!=null and not force_fallback
	if sprite==null and using_sprite:
		sprite=AnimatedSprite2D.new();sprite.centered=false;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(sprite)
	if sprite!=null:sprite.visible=using_sprite
	if not using_sprite:return
	position=actor.position.round()-actor.position
	sprite.sprite_frames=selected.sprite_frames
	var pose=VisualAnimation.sample(actor,actor.run.clock.tick,selected)
	sprite.animation=pose.state;sprite.frame=pose.frame;sprite.pause()
	var facing_direction=actor.aim if actor.run.clock.tick<actor.attack_until or actor.ai_state=="warning" or actor.velocity.length_squared()<=1 else actor.velocity
	if absf(facing_direction.x)>0.001:facing_x=-1 if facing_direction.x<0 else 1
	sprite.scale=Vector2(facing_x,1)
	sprite.position=Vector2(-selected.anchor_px.x*facing_x,-selected.anchor_px.y)
	sprite.modulate=Color.WHITE
	if actor.run.clock.tick<actor.health.hurt_until:sprite.modulate=Color(1.6,1.6,1.6)
	elif actor.is_hero and actor.run.clock.tick<actor.health.invulnerable_until and actor.run.clock.tick%6<3:sprite.modulate.a=0.35

func draw_sprite_cues(actor,tick: int) -> void:
	# Fixed foot shadow is independent of facing and animation; it never moves physics.
	draw_ellipse_shadow()
	if actor.corrupted:
		draw_arc(Vector2.ZERO,18,0,TAU,16,Color("c99ae8"),1)
		for side in [-1,1]:draw_line(Vector2(side*7,-30),Vector2(side*13,-36),Color("c99ae8"),2)
	if actor.health.dead:
		draw_line(Vector2(-5,-2),Vector2(5,8),Color.WHITE,1)
		return
	if actor.is_hero:
		if actor.is_companion:
			for i in range(8):draw_arc(Vector2.ZERO,13,i*TAU/8.0,i*TAU/8.0+0.4,3,Color("a5f3e8"),1)
		else:draw_arc(Vector2.ZERO,13,0,TAU,24,Color("a5f3e8"),1)
		if tick<actor.health.invulnerable_until:draw_arc(Vector2.ZERO,16,0,TAU,24,Color.WHITE,2)
	# Warning remains independent of pose priority, including hurt.
	if actor.ai_state=="warning":draw_arc(Vector2.ZERO,16,0,TAU,24,Color(1,0.76,0.25),2)
	if actor.resistant:draw_arc(Vector2.ZERO,14,0.3,2.8,12,Color(0.65,0.8,1),2)
	if not actor.is_hero and actor.health.current<actor.health.maximum:
		var y=-38 if selected.canvas_px.y==48 else -26
		draw_rect(Rect2(-12,y,24,3),Color(0.14,0.07,0.1))
		draw_rect(Rect2(-12,y,24*actor.health.current/actor.health.maximum,3),Color("f37783"))

func draw_ellipse_shadow() -> void:
	draw_rect(Rect2(-9,-1,18,3),Color(0.06,0.07,0.11,0.6))

func _draw() -> void:
	var actor = get_parent()
	if actor.health == null: return
	var tick = actor.run.clock.tick
	if using_sprite:
		draw_sprite_cues(actor,tick)
		return
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
