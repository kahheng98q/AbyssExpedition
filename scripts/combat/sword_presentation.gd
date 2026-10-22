class_name SwordPresentation
extends RefCounted

# Pure drawing/value helpers shared by combat and independent UI examples.
# No retained actor, run, profile, clock, random stream or damage service.
static func state_for(dead: bool, hurt: bool, attack: bool, moving: bool) -> StringName:
	if dead: return &"death"
	if hurt: return &"hurt"
	if attack: return &"attack"
	return &"move" if moving else &"idle"

static func weapon_segments(identity: StringName, state: StringName, aim: Vector2, active_tick: int, attack_age: int) -> Array:
	if state == &"death": return []
	var facing: float = -1.0 if aim.x < 0 else 1.0
	var attacking = state == &"attack"
	var stride = (1 if active_tick % 12 < 6 else -1) if state == &"move" else 0
	var hand = aim * 9 if attacking else Vector2(facing * 9, 2 + stride)
	var axis = aim.rotated(-0.65 + clampi(attack_age, 0, 11) * 0.13) if attacking else Vector2(facing * 0.35, -0.94)
	if state == &"hurt": axis = Vector2(facing * 0.6, 0.8)
	if identity == &"dual":
		var other_hand = -aim.orthogonal() * 8 if attacking else Vector2(-facing * 9, 2 - stride)
		var other_axis = axis.rotated(-0.75) if attacking else Vector2(-facing * 0.4, -0.92)
		return [[hand.round(), (hand + axis * 17).round()], [other_hand.round(), (other_hand + other_axis * 17).round()]]
	if identity == &"long":
		if not attacking and state != &"hurt": axis = Vector2(facing * 0.08, -1)
		return [[hand.round(), (hand + axis * 26).round()]]
	return [[hand.round(), (hand + axis * 17).round()]]

static func draw_pose(canvas: CanvasItem, pose: Dictionary) -> void:
	var state: StringName = pose.state
	var tint: Color = Color.WHITE if state == &"hurt" else pose.palette
	var ink = Color("09131e")
	var facing: float = -1 if pose.aim.x < 0 else 1
	if state == &"death":
		canvas.draw_line(Vector2(-8, 5), Vector2(8, 5), tint.darkened(0.25), 4)
		canvas.draw_line(Vector2(-6, 1), Vector2(5, 8), Color("d8e7df"), 1)
	else:
		var step: int = (2 if pose.active_tick % 12 < 6 else -2) if pose.moving else 0
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(-7, -4), Vector2(5, -4), Vector2(7, 12), Vector2(0, 9), Vector2(-8, 11)]), ink)
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(-5, -3), Vector2(4, -3), Vector2(5, 10), Vector2(0, 7), Vector2(-6, 9)]), tint.darkened(0.55))
		canvas.draw_rect(Rect2(-5, 7 + step, 4, 6), ink)
		canvas.draw_rect(Rect2(2, 7 - step, 4, 6), ink)
		canvas.draw_rect(Rect2(-5, 9 + step, 3, 2), Color("8796a2"))
		canvas.draw_rect(Rect2(2, 9 - step, 3, 2), Color("8796a2"))
		canvas.draw_rect(Rect2(-6, -5, 12, 13), ink)
		canvas.draw_rect(Rect2(-5, -4, 10, 10), tint.darkened(0.15))
		canvas.draw_rect(Rect2(-4, -4, 3, 8), tint.lightened(0.2))
		canvas.draw_rect(Rect2(-5, 4, 10, 2), Color("4a3d3b"))
		canvas.draw_rect(Rect2(-1, 4, 3, 2), Color("dfbd79"))
		canvas.draw_rect(Rect2(-5, -13, 10, 9), ink)
		canvas.draw_rect(Rect2(-4, -12, 8, 7), Color("e6c8a1"))
		canvas.draw_rect(Rect2(-5, -14, 10, 4), Color("8caeb8"))
		canvas.draw_rect(Rect2(facing * 2, -9, 2, 2), ink)
		for segment in weapon_segments(pose.identity, state, pose.aim, pose.active_tick, pose.attack_age):
			var axis: Vector2 = segment[0].direction_to(segment[1])
			canvas.draw_line((segment[0] - axis * 4).round(), segment[1], ink, 5)
			canvas.draw_line(segment[0], segment[1], Color("e2f3eb"), 3)
			canvas.draw_line((segment[0] + axis.orthogonal() * 4).round(), (segment[0] - axis.orthogonal() * 4).round(), Color("d5b87b"), 2)
	# Draw ownership last; blade, hurt and death do not hide the marker.
	if pose.owner_marker:
		var marker = Color("8aa9b1") if pose.is_companion else Color("f3dc9e")
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(-3, -23), Vector2(3, -23), Vector2(0, -19)]), marker)

static func arc_visual(generation: int, source: int, activation: int, profession: StringName, identity: StringName, kind: StringName, hit: Dictionary, tick: int) -> Dictionary:
	if identity not in [&"single", &"dual", &"long"]: return {}
	if not hit.origin.is_finite() or not hit.direction.is_finite() or not is_finite(hit.reach) or hit.reach < 0 or not is_finite(hit.angle): return {}
	var visual = {"generation": generation, "source_id": source, "activation_id": activation, "profession_id": profession, "identity": identity, "arc_kind": kind, "born_tick": tick, "expires_tick": tick + 10, "origin": Vector2(hit.origin), "direction": Vector2(hit.direction), "reach": float(hit.reach), "angle": float(hit.angle)}
	visual.make_read_only()
	return visual

static func draw_arc(canvas: CanvasItem, visual: Dictionary, tick: int, tint: Color) -> void:
	var age: int = tick - visual.born_tick
	if age < 0 or age >= 10: return
	var reach: float = visual.reach
	if reach <= 0: return
	var half: float = deg_to_rad(visual.angle * 0.5)
	var center: float = visual.direction.angle()
	var start: float = center - half
	var end: float = center + half
	var fade: float = 1.0 - age / 10.0
	var secondary = visual.arc_kind == &"secondary"
	var stroke = Color("d4f0ec") if secondary else tint.lightened(0.2)
	# Full real range is visible immediately; sweep is decoration, not another hit.
	canvas.draw_arc(Vector2.ZERO, maxf(0, reach - 0.5), start, end, 48 if visual.angle >= 360 else 24, Color(stroke, fade * 0.85), 1)
	var blade = lerpf(start, end, minf(1, age / 6.0))
	var inner: float = maxf(0, reach - (11 if secondary else 6))
	var tail = maxf(start, blade - half * 0.65)
	if blade > tail:
		var points = PackedVector2Array()
		for i in range(13): points.append((Vector2.from_angle(lerpf(tail, blade, i / 12.0)) * (reach - 1)).round())
		for i in range(12, -1, -1): points.append((Vector2.from_angle(lerpf(tail, blade, i / 12.0)) * inner).round())
		canvas.draw_colored_polygon(points, Color(stroke, fade * 0.6))
	canvas.draw_line((Vector2.from_angle(blade) * minf(12, reach)).round(), (Vector2.from_angle(blade) * maxf(0, reach - 1)).round(), Color("e9f4e8", fade), 2)

static func heal_text(actual: float) -> String:
	return "+%.1f" % actual

static func draw_heal(canvas: CanvasItem, font: Font, point: Vector2, actual: float, age: int, companion: bool = false) -> void:
	if age < 0 or age >= 36 or actual <= 0 or not is_finite(actual): return
	var tint = Color("8fc9c9") if companion else Color("9ee9ca")
	tint.a = clampf((36 - age) / 12.0, 0, 1)
	var phase: float = minf(age / 18.0, 1)
	for side in [-1, 1]:
		var from = (point + Vector2(side * (17 - phase * 10), 4 - phase * 9)).round()
		var to = (point + Vector2(side * (11 - phase * 7), -2 - phase * 8)).round()
		canvas.draw_line(from, to, Color(tint, tint.a * 0.65), 1)
	var text = heal_text(actual)
	var at = (point + Vector2(-font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x / 2, -30 - minf(age, 24) * 0.4)).round()
	canvas.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 3, Color(0.02, 0.04, 0.06, tint.a))
	canvas.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, tint)
