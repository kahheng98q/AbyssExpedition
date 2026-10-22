class_name PromotionPreview
extends Control

# Owned example state only. No run, actor, profile, save, audio or RNG service.
var hero_id: String = ""
var branch_id: StringName
var session_id: int
var configuration: Dictionary = {}
var now_usec: Callable = Time.get_ticks_usec
var tick: int = 0
var total_ticks: int = 0
var cycle_ticks: int = 360
var cycle_count: int = 0
var activation_count: int = 0
var sample_max_hp: float = 0
var sample_hp: float = 0
var focused: bool = false
var host_occluded: bool = false
var stopped: bool = false
var arcs: Array[Dictionary] = []
var heal_record: Dictionary = {}
var playback_usec: int = 0
var cycle_playback_usec: Array[int] = [] # bounded diagnostics; not an unlimited log
var last_attack_tick: int = -100
var _last_usec: int = -1
var _fraction: int = 0
var _window: Window
var _font: Font = ThemeDB.fallback_font

func setup(profession: ProfessionDefinition, hero: String = "") -> void:
	hero_id = hero
	branch_id = profession.id
	session_id = get_instance_id()
	configuration = {"profession": profession.id, "identity": profession.visual_set.sword_identity, "palette": Color(profession.visual_set.palette), "max_hp": float(profession.starting_stats.max_health), "heal_fraction": float(profession.heal_fraction), "reach": float(profession.starting_stats.reach), "angle": float(profession.weapon.arc_angle), "spin_radius": float(profession.effect_radius)}
	configuration.make_read_only()
	sample_max_hp = configuration.max_hp
	reset_cycle()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	clip_contents = true
	custom_minimum_size = Vector2(160, 156)
	_window = get_window()
	focused = _window.has_focus()
	_window.focus_entered.connect(_on_window_focus_entered)
	_window.focus_exited.connect(_on_window_focus_exited)
	reset_time_base()

func reset_time_base() -> void:
	_last_usec = int(now_usec.call())

func _on_window_focus_entered() -> void:
	focused = true
	reset_time_base()

func _on_window_focus_exited() -> void:
	focused = false
	reset_time_base()

func set_occluded(value: bool) -> void:
	host_occluded = value
	reset_time_base()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and now_usec.is_valid(): reset_time_base()

func _process(_delta: float) -> void:
	var now: int = int(now_usec.call())
	if stopped or not focused or host_occluded or not is_visible_in_tree():
		_last_usec = now
		return
	if _last_usec < 0: _last_usec = now; return
	var elapsed: int = maxi(0, now - _last_usec)
	_last_usec = now
	playback_usec += elapsed
	# Integer tick units avoid floating point drift at exact 6/60 second boundaries.
	_fraction += elapsed * 60
	while _fraction >= 1000000:
		_fraction -= 1000000
		advance_tick()
	queue_redraw()

func advance_tick() -> void:
	if stopped or configuration.is_empty(): return
	tick += 1
	total_ticks += 1
	for arc in arcs.duplicate():
		if tick >= arc.expires_tick: arcs.erase(arc)
	if not heal_record.is_empty() and tick >= heal_record.expires_tick: heal_record.clear()
	if tick in [30, 90, 150, 210, 270]:
		activation_count += 1
		last_attack_tick = tick
		var hit = {"origin": Vector2.ZERO, "direction": Vector2.RIGHT, "reach": configuration.reach, "angle": configuration.angle}
		arcs.append(SwordPresentation.arc_visual(session_id, 0, activation_count, branch_id, configuration.identity, &"primary" if configuration.identity == &"dual" else &"base", hit, tick))
		if configuration.identity == &"dual":
			var second = hit.duplicate()
			second.direction = Vector2.RIGHT.rotated(deg_to_rad(20))
			arcs.append(SwordPresentation.arc_visual(session_id, 0, activation_count, branch_id, configuration.identity, &"secondary", second, tick))
			if activation_count == 5:
				var spin = hit.duplicate()
				spin.angle = 360.0
				spin.reach = configuration.spin_radius
				arcs.append(SwordPresentation.arc_visual(session_id, 0, activation_count, branch_id, configuration.identity, &"spin", spin, tick))
	if tick == 271 and configuration.identity == &"long":
		var before = sample_hp
		sample_hp = minf(sample_max_hp, sample_hp + sample_max_hp * configuration.heal_fraction)
		var actual = sample_hp - before
		if actual > 0: heal_record = {"actual_heal": actual, "born_tick": tick, "expires_tick": tick + 36}
	if tick == cycle_ticks:
		cycle_count += 1
		cycle_playback_usec.append(playback_usec)
		if cycle_playback_usec.size() > 16: cycle_playback_usec.pop_front()
		reset_cycle()

func reset_cycle() -> void:
	tick = 0
	activation_count = 0
	last_attack_tick = -100
	sample_hp = maxf(0, sample_max_hp - 10)
	arcs.clear()
	heal_record.clear()

func stop() -> void:
	stopped = true
	_fraction = 0
	_last_usec = -1
	arcs.clear()
	heal_record.clear()
	if is_instance_valid(_window):
		if _window.focus_entered.is_connected(_on_window_focus_entered): _window.focus_entered.disconnect(_on_window_focus_entered)
		if _window.focus_exited.is_connected(_on_window_focus_exited): _window.focus_exited.disconnect(_on_window_focus_exited)
	queue_redraw()

func _exit_tree() -> void:
	stop()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("101c28"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("34515c"), false, 1)
	if configuration.is_empty() or stopped: return
	var center = Vector2(floorf(size.x * 0.5), 70)
	draw_set_transform(center)
	# Neutral original example target, never a live enemy or reward source.
	draw_rect(Rect2(36, -11, 16, 23), Color("09131e"))
	draw_rect(Rect2(38, -9, 12, 17), Color("5e7280"))
	draw_rect(Rect2(40, -7, 8, 2), Color("b6d0cb"))
	var attacking = tick - last_attack_tick >= 0 and tick - last_attack_tick < 12
	SwordPresentation.draw_pose(self, {"identity": configuration.identity, "state": &"attack" if attacking else &"idle", "aim": Vector2.RIGHT, "active_tick": tick, "attack_age": tick - last_attack_tick, "moving": false, "palette": configuration.palette, "is_companion": false, "owner_marker": true})
	for arc in arcs: SwordPresentation.draw_arc(self, arc, tick, configuration.palette)
	if not heal_record.is_empty(): SwordPresentation.draw_heal(self, _font, Vector2.ZERO, heal_record.actual_heal, tick - heal_record.born_tick)
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(10, 136, size.x - 20, 3), Color("23313b"))
	draw_rect(Rect2(10, 136, (size.x - 20) * sample_hp / sample_max_hp, 3), Color("97d7c7"))
	draw_string(_font, Vector2(10, 151), "%d / 5 · 示例 HP %.0f / %.0f" % [activation_count, sample_hp, sample_max_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("abc5c7"))
