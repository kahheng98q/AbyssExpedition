extends CanvasLayer

const Actions = preload("res://scripts/debug/debug_action_service.gd")
var app
var service = Actions.new()
var overlay: Control
var banner: Label
var launcher: Button
var tabs: TabContainer
var feedback: Label
var character_choice: OptionButton
var companion_choice: OptionButton
var enemy_choice: OptionButton
var branch_choice: OptionButton
var xp_amount: SpinBox
var material_amount: SpinBox
var character_stats: Label
var run_stats: Label
var party_stats: Label
var system_stats: Label
var requirements: Label
var log_label: Label
var path_label: Label
var buttons: Array = []
var promotion_host: Control
var pause_token: int = -1
var paused_run
var prior_tree_pause: bool = false
var refresh_elapsed: float = 0
var focus_before: WeakRef

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.has_feature("debug") or app == null:
		queue_free()
		return
	service.bind(app)
	build()
	overlay.hide()

func build() -> void:
	launcher = Button.new()
	launcher.name = "OpenDebugPanel"
	launcher.text = "Debug · F9"
	launcher.position = Vector2(548, 45)
	launcher.size = Vector2(84, 24)
	launcher.theme = app.screen_host.theme
	launcher.tooltip_text = "Open developer panel. Press F9, or Fn + F9 on media-key keyboards."
	launcher.pressed.connect(open_panel)
	add_child(launcher)
	banner = Label.new()
	banner.position = Vector2(405, 75)
	banner.size = Vector2(227, 20)
	banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner.add_theme_font_size_override("font_size", 10)
	banner.add_theme_color_override("font_color", Color(1, 0.8, 0.35))
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banner)
	banner.text = "DEVELOPER BUILD · F9 or Debug"
	overlay = Control.new()
	overlay.name = "DebugOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var shade = ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.03, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + edge, 8)
	overlay.add_child(margin)
	var panel = PanelContainer.new()
	panel.theme = app.screen_host.theme
	margin.add_child(panel)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var header = HBoxContainer.new()
	column.add_child(header)
	var title = Label.new()
	title.text = "DEVELOPER DEBUG · isolated sandbox"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close = Button.new()
	close.text = "F9 · Close"
	close.pressed.connect(close_panel)
	header.add_child(close)
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(tabs)
	var sections = {}
	for section in ["Character", "Combat", "Progression", "System"]:
		var scroll = ScrollContainer.new()
		scroll.name = section
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		tabs.add_child(scroll)
		var content = VBoxContainer.new()
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.add_theme_constant_override("separation", 5)
		scroll.add_child(content)
		sections[section] = content
	var c = sections.Character
	character_choice = selector(c, "Character", app.catalog.characters)
	character_choice.item_selected.connect(func(_index): update_branches(); refresh())
	xp_amount = number(c, "XP amount", 100, 1000000)
	run_stats = text(c, "", 11)
	add_actions(c, ["level_one", "level_ten", "level_max", "character_xp", "run_xp", "heal_character", "cooldowns", "invincible"])
	character_stats = text(c, "", 11)
	var combat = sections.Combat
	enemy_choice = selector(combat, "Enemy type", app.catalog.enemies)
	var spawn_row = HBoxContainer.new()
	combat.add_child(spawn_row)
	for count in [1, 10, 50, 100]: action_button(spawn_row, "spawn", "Spawn %d" % count, {"count": count})
	text(combat, "Spawns respect safety/cap and appear after resuming their 45-tick warnings.", 10)
	add_actions(combat, ["boss", "kill_all", "clear_projectiles", "heal_team", "god_mode", "restart"])
	var speed_row = HBoxContainer.new()
	combat.add_child(speed_row)
	for speed_value in [1, 2, 4]: action_button(speed_row, "speed", "%dx battle speed" % speed_value, {"speed": speed_value})
	text(combat, "COMPANIONS · temporary edits · max two")
	companion_choice = selector(combat, "Companion", app.catalog.characters)
	companion_choice.item_selected.connect(func(_index): refresh())
	add_actions(combat, ["add_companion", "remove_companion", "heal_companions", "companion_ai"])
	party_stats = text(combat, "", 11)
	text(combat, "Revival is unsupported. Restart restores full health.", 10)
	var progression = sections.Progression
	material_amount = number(progression, "Material amount", 1, 1000000)
	add_actions(progression, ["materials", "eligibility"])
	var open = Button.new()
	open.text = "Open existing promotion UI"
	open.pressed.connect(func(): open_promotion(false))
	progression.add_child(open)
	buttons.append({"button": open, "action": "promotion_ui", "extra": {}})
	var bypass = Button.new()
	bypass.text = "Bypass requirements in sandbox / open promotion"
	bypass.pressed.connect(func(): open_promotion(true))
	progression.add_child(bypass)
	buttons.append({"button": bypass, "action": "promotion_ui", "extra": {}})
	branch_choice = OptionButton.new()
	progression.add_child(branch_choice)
	action_button(progression, "test_branch", "Test selected branch in this run only")
	text(progression, "Runtime branch testing ignores level/items and never changes the saved class.\nPermanent class reset is unsupported.", 10)
	requirements = text(progression, "", 11)
	var system = sections.System
	system_stats = text(system, "", 11)
	add_actions(system, ["save_test", "load_test", "retry_save", "collisions", "end_sandbox"])
	path_label = text(system, "", 10)
	text(system, "Recent debug actions")
	log_label = text(system, "", 10)
	feedback = Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_font_size_override("font_size", 11)
	column.add_child(feedback)
	promotion_host = Control.new()
	promotion_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	promotion_host.hide()
	overlay.add_child(promotion_host)
	update_branches()

func text(host: Node, value: String, font_size: int = 12) -> Label:
	var label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	host.add_child(label)
	return label

func selector(host: Node, label: String, definitions: Dictionary) -> OptionButton:
	text(host, label, 11)
	var choice = OptionButton.new()
	for id in definitions:
		choice.add_item(String(id).capitalize())
		choice.set_item_metadata(choice.item_count - 1, String(id))
	host.add_child(choice)
	return choice

func number(host: Node, label: String, value: int, maximum: int) -> SpinBox:
	var row = HBoxContainer.new()
	host.add_child(row)
	text(row, label, 11).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spin = SpinBox.new()
	spin.min_value = 1
	spin.max_value = maximum
	spin.step = 1
	spin.value = value
	row.add_child(spin)
	return spin

func add_actions(host: Node, ids: Array) -> void:
	var grid = GridContainer.new()
	grid.columns = 2
	host.add_child(grid)
	for id in ids:
		for definition in Actions.ACTIONS:
			if definition[0] == id: action_button(grid, id, definition[1])

func action_button(host: Node, id: String, label: String, extra: Dictionary = {}) -> void:
	var button = Button.new()
	button.text = label
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 26
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(func():
		xp_amount.apply()
		material_amount.apply()
		show_feedback(service.execute(id, arguments(extra)))
		refresh())
	host.add_child(button)
	buttons.append({"button": button, "action": id, "extra": extra})

func selected(choice: OptionButton) -> String:
	return String(choice.get_item_metadata(choice.selected)) if choice != null and choice.item_count > 0 else ""

func arguments(extra: Dictionary = {}) -> Dictionary:
	var args = {"character_id": selected(character_choice), "companion_id": selected(companion_choice), "enemy_id": selected(enemy_choice), "branch": selected(branch_choice), "amount": int(xp_amount.value), "materials": int(material_amount.value)}
	args.merge(extra, true)
	return args

func update_branches() -> void:
	if branch_choice == null: return
	branch_choice.clear()
	var id = selected(character_choice)
	var base = app.catalog.characters[StringName(id)].base_profession
	for branch in base.promotion_ids:
		branch_choice.add_item(String(branch).capitalize())
		branch_choice.set_item_metadata(branch_choice.item_count - 1, String(branch))

func _input(event: InputEvent) -> void:
	if not OS.has_feature("debug") or overlay == null: return
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_F9 or event.physical_keycode == KEY_F9):
		if overlay.visible: close_panel()
		else: open_panel()
		get_viewport().set_input_as_handled()
	elif overlay.visible and event is InputEventKey and event.keycode == KEY_ESCAPE:
		# Keep the existing manual/level pause shortcut from changing behind the panel.
		get_viewport().set_input_as_handled()

func open_panel() -> bool:
	if not OS.has_feature("debug") or overlay == null: return false
	var first_open = not service.active
	var outcome = service.ensure_session()
	if not outcome.ok:
		banner.text = "Debug unavailable: " + outcome.message
		return false
	if overlay.visible: return true
	if first_open:
		var run = service.current_run()
		var active_id = String(run.hero.definition.id) if run != null else String(service.writer.payload.active)
		for index in range(character_choice.item_count):
			if character_choice.get_item_metadata(index) == active_id: character_choice.select(index)
		update_branches()
	prior_tree_pause = get_tree().paused
	var focused = get_viewport().gui_get_focus_owner()
	focus_before = weakref(focused) if focused != null else null
	paused_run = service.current_run()
	if paused_run != null: pause_token = paused_run.pause.acquire("debug", "developer_panel")
	get_tree().paused = true
	overlay.show()
	capture_focus()
	show_feedback(outcome)
	refresh()
	return true

func close_panel(force: bool = false) -> bool:
	if not OS.has_feature("debug") or overlay == null: return false
	if not overlay.visible: return true
	if not force and service.active and service.writer.state != "ready":
		show_feedback({"ok": false, "message": "Resolve the pending sandbox save with Retry before resuming."})
		return false
	clear_promotion()
	if is_instance_valid(paused_run) and pause_token >= 0: paused_run.pause.release(pause_token, "developer_panel")
	pause_token = -1
	overlay.hide()
	if is_instance_valid(paused_run): get_tree().paused = paused_run.phase != "active" or paused_run.pause.is_blocked()
	else: get_tree().paused = prior_tree_pause
	paused_run = null
	var previous = focus_before.get_ref() if focus_before != null else null
	if is_instance_valid(previous) and previous.is_inside_tree() and previous.is_visible_in_tree(): previous.grab_focus()
	elif is_instance_valid(app) and app.modal_host.get_child_count() > 0:
		var next_focus = app.modal_host.find_next_valid_focus()
		if next_focus != null: next_focus.grab_focus()
	focus_before = null
	return true

func capture_focus() -> void:
	if not OS.has_feature("debug") or overlay == null or not overlay.visible: return
	var focused = get_viewport().gui_get_focus_owner()
	if focused == null or not overlay.is_ancestor_of(focused): character_choice.grab_focus()

func _unhandled_key_input(_event: InputEvent) -> void:
	if OS.has_feature("debug") and overlay != null and overlay.visible:
		get_viewport().set_input_as_handled()

func open_promotion(bypass: bool) -> void:
	if not OS.has_feature("debug") or not service.active or service.writer.state != "ready": return
	if bypass:
		var outcome = service.execute("eligibility", arguments())
		show_feedback(outcome)
		if not outcome.ok: return
	clear_promotion()
	var screen = app.catalog.scene("promotion").instantiate()
	screen.catalog = app.catalog
	screen.payload = service.writer.payload.duplicate(true)
	screen.hero_id = selected(character_choice)
	screen.revision = service.writer.revision()
	screen.confirmed.connect(func(id, branch, revision):
		show_feedback(service.promote(id, branch, revision))
		clear_promotion()
		refresh())
	screen.canceled.connect(func(): clear_promotion())
	promotion_host.add_child(screen)
	promotion_host.show()

func clear_promotion() -> void:
	if promotion_host == null: return
	for screen in promotion_host.get_children():
		promotion_host.remove_child(screen)
		screen.queue_free()
	promotion_host.hide()

func show_feedback(outcome: Dictionary) -> void:
	feedback.text = outcome.message
	feedback.add_theme_color_override("font_color", Color(0.6, 1, 0.75) if outcome.ok else Color(1, 0.6, 0.45))

func _process(delta: float) -> void:
	if not OS.has_feature("debug") or overlay == null: return
	if service.active: banner.text = "DEBUG SANDBOX · F9 · %.0f FPS" % Engine.get_frames_per_second()
	elif banner.text.begins_with("DEBUG SANDBOX"): banner.text = "DEVELOPER BUILD · F9 or Debug"
	refresh_elapsed += delta
	if overlay.visible and refresh_elapsed >= 0.25:
		refresh_elapsed = 0
		capture_focus()
		refresh()

func refresh() -> void:
	if not service.active:
		return
	var p = service.writer.payload
	var id = selected(character_choice)
	var h = p.owned[id]
	var definition = app.catalog.characters[StringName(id)]
	var actor = service.actor_for(id)
	var profession = actor.profession if actor != null else app.catalog.professions[StringName(h.promotion_id if h.promotion_id != "" else ProfileData.BASES[id])]
	character_stats.text = "%s · permanent Lv %d · XP %d / 2900\nBase %s · current %s · saved %s\nPassive: %s · Skills: %s" % [definition.display_name, h.level, h.total_xp, ProfileData.BASES[id].capitalize(), String(profession.id).capitalize(), h.promotion_id.capitalize() if h.promotion_id != "" else "base", String(definition.passive.id).capitalize(), profession.description if profession.description != "" else definition.description]
	if actor != null:
		character_stats.text += "\nHP %.1f / %.1f · attack %.2f · defense %.1f · speed %.2f\nAttack cooldown %d ticks · branch/passive activations %d/%d" % [actor.health.current, actor.health.maximum, actor.stats.damage, actor.stats.defense, actor.stats.speed, maxi(0, actor.next_ready - service.current_run().clock.tick), actor.activations, actor.passive_activations]
	else:
		var stats = CharacterFactory.progression_stats(definition, profession, int(h.level))
		character_stats.text += "\nStarting max HP %.1f · attack %.2f · defense %.1f · speed %.2f\nNot deployed. Heal/cooldown/runtime branch controls are unavailable." % [stats.max_health, stats.damage, stats.defense, stats.speed]
	var run = service.current_run()
	run_stats.text = "Shared run Lv %d · XP %d / %d · pending upgrades %d" % [run.progression.level, run.progression.xp, run.progression.level * 100, run.progression.pending] if run != null else "No active run. Permanent XP applies to the selected hero."
	var lines: PackedStringArray = []
	if run != null:
		for member in run.party:
			var state = "active"
			if member.is_companion:
				state = "AI disabled" if not member.debug_ai_enabled else ("recovery" if member.blocked_ticks >= 120 else ("following" if member.position.distance_to(CompanionController.formation(run.hero.position, member.companion_slot)) > 4 else "formation"))
			if member.health.dead: state = "DOWNED"
			lines.append("%s · Lv %d · %s · HP %.0f/%.0f · %s" % [member.definition.display_name, member.permanent_level, String(member.profession.id).capitalize(), member.health.current, member.health.maximum, state])
		system_stats.text = "FPS %.0f · enemies %d · pending warnings %d\nSeed %d · active time %s · battle speed %dx\nPlayer %s · invincible %s · team god mode %s" % [Engine.get_frames_per_second(), run.enemies.size(), run.spawns.reservations.size(), run.snapshot.seed_value, run.clock.display_time(), service.speed.value, run.hero.position, run.hero.health.debug_invincible, service.god_mode]
	else: system_stats.text = "FPS %.0f · no active run · speed %dx" % [Engine.get_frames_per_second(), service.speed.value]
	party_stats.text = "\n".join(lines) if not lines.is_empty() else "No deployed party."
	var reason = PromotionService.reason(p, id)
	requirements.text = "%s · level 15 + 1 item · items %d\n%s" % [id.capitalize(), p.promotion_items, "Eligible for permanent sandbox promotion." if reason == "" else reason]
	path_label.text = "TEST SAVE ONLY: " + ProjectSettings.globalize_path(service.writer.store.root) + "\nState: " + service.writer.state
	log_label.text = "\n".join(service.logs.slice(maxi(0, service.logs.size() - 8)))
	for entry in buttons:
		entry.button.disabled = service.writer.state != "ready" if entry.action == "promotion_ui" else not service.available(entry.action, arguments(entry.extra))

func on_run_exit() -> void:
	if not OS.has_feature("debug"): return
	service.on_run_exit()
	close_panel(true)

func shutdown() -> void:
	if OS.has_feature("debug"): service.shutdown()
