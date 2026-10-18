extends Node2D

# Presentation only: bounded records, no gameplay RNG or simulation writes.
const LIMIT: int = 48
const LIFETIME: int = 36
var run
var bursts: Array[Dictionary] = []
var last_tick: int = -1
var font: Font = ThemeDB.fallback_font

func bind_run(expedition) -> void:
	run = expedition
	run.hit_confirmed.connect(on_hit)

func on_hit(point: Vector2, direction: Vector2, amount: float, fatal: bool, friendly: bool) -> void:
	if bursts.size() >= LIMIT: bursts.pop_front()
	bursts.append({"point": point, "direction": direction, "amount": ceili(amount), "fatal": fatal, "friendly": friendly, "born": run.clock.tick})
	queue_redraw()

func _process(_delta: float) -> void:
	if run == null or run.clock.tick == last_tick: return
	last_tick = run.clock.tick
	for i in range(bursts.size() - 1, -1, -1):
		if last_tick - bursts[i].born >= LIFETIME: bursts.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if run == null: return
	for burst in bursts:
		var age: int = run.clock.tick - burst.born
		if age < 0 or age >= LIFETIME: continue
		var point: Vector2 = burst.point.round()
		var tint = Color("ff9387") if burst.friendly else (Color("f8dfa0") if burst.fatal else Color("bbf5e2"))
		tint.a = clampf((LIFETIME - age) / 12.0, 0, 1)
		# Short impact core; dispersed debris communicates a confirmed kill.
		if age < 12:
			var radius: float = 3 + age * (1.3 if burst.fatal else 0.7)
			for i in range(6 if burst.fatal else 4):
				var ray = Vector2.from_angle(i * TAU / (6 if burst.fatal else 4) + burst.direction.angle())
				var start = (point + ray * radius).round()
				draw_line(start, (start + ray * (5 - age / 3.0)).round(), tint, 2)
			if age < 4:
				draw_line(point - Vector2(5, 0), point + Vector2(5, 0), Color("fff6dc"), 2)
				draw_line(point - Vector2(0, 5), point + Vector2(0, 5), Color("fff6dc"), 2)
		var text = ("-" if burst.friendly else "") + str(burst.amount)
		var at = (point + Vector2(-font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x / 2, -19 - minf(age, 24) * 0.5)).round()
		draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 3, Color(0.02, 0.04, 0.06, tint.a))
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, tint)
