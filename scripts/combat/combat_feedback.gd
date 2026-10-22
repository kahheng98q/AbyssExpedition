extends Node2D

# Presentation only: bounded records, no gameplay RNG or simulation writes.
const LIMIT: int = 48
const LIFETIME: int = 36
var run
var bursts: Array[Dictionary] = []
var last_tick: int = -1
var font: Font = ThemeDB.fallback_font
var heal_records: Dictionary = {}
var last_heal_activation: Dictionary = {}

func bind_run(expedition) -> void:
	unbind_run()
	run = expedition
	run.hit_confirmed.connect(on_hit)
	run.branch_heal_applied.connect(on_branch_heal)

func unbind_run() -> void:
	if is_instance_valid(run):
		if run.hit_confirmed.is_connected(on_hit): run.hit_confirmed.disconnect(on_hit)
		if run.branch_heal_applied.is_connected(on_branch_heal): run.branch_heal_applied.disconnect(on_branch_heal)
	clear_heals()
	run = null

func clear_heals() -> void:
	heal_records.clear()
	last_heal_activation.clear()
	queue_redraw()

static func format_heal(actual: float) -> String:
	return SwordPresentation.heal_text(actual)

func heal_position(source_id: int) -> Vector2:
	var source = run.actor_by_id(source_id) if is_instance_valid(run) else null
	return Vector2(source.position) if source != null and not source.health.dead else Vector2.INF

func on_branch_heal(fact: Dictionary) -> void:
	if not is_instance_valid(run) or run.phase != "active" or not fact.is_read_only(): return
	for key in ["generation", "tick", "source_id", "is_companion", "activation_id", "request_id", "actual_heal", "source_position"]:
		if not fact.has(key): return
	if fact.generation != run.generation or fact.tick != run.clock.tick: return
	if not (fact.actual_heal is float or fact.actual_heal is int) or not is_finite(fact.actual_heal) or fact.actual_heal <= 0: return
	var source = run.actor_by_id(fact.source_id)
	if source == null or source.health.dead or not run.party.has(source) or fact.is_companion != source.is_companion: return
	if fact.activation_id <= last_heal_activation.get(fact.source_id, 0): return
	last_heal_activation[fact.source_id] = fact.activation_id
	# Drop paused facts instead of keeping a queue to replay on resume.
	if run.pause.is_blocked(): return
	heal_records[fact.source_id] = {"generation": fact.generation, "source_id": fact.source_id, "activation_id": fact.activation_id, "actual_heal": float(fact.actual_heal), "born_tick": fact.tick, "expires_tick": fact.tick + LIFETIME}
	queue_redraw()

func on_hit(point: Vector2, direction: Vector2, amount: float, fatal: bool, friendly: bool) -> void:
	if bursts.size() >= LIMIT: bursts.pop_front()
	bursts.append({"point": point, "direction": direction, "amount": ceili(amount), "fatal": fatal, "friendly": friendly, "born": run.clock.tick})
	queue_redraw()

func _process(_delta: float) -> void:
	if not is_instance_valid(run): return
	var removed = false
	for identity in heal_records.keys():
		if run.phase != "active" or not heal_position(identity).is_finite() or run.clock.tick >= heal_records[identity].expires_tick:
			heal_records.erase(identity)
			removed = true
	if removed: queue_redraw()
	if run.clock.tick == last_tick: return
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
	if run.get_meta("sword_presentation_disabled", false): return
	for record in heal_records.values():
		var point = heal_position(record.source_id)
		if not point.is_finite(): continue
		var source = run.actor_by_id(record.source_id)
		SwordPresentation.draw_heal(self, font, point, record.actual_heal, run.clock.tick - record.born_tick, source.is_companion)

func _exit_tree() -> void:
	unbind_run()
