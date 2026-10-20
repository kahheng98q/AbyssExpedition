extends Node

@onready var catalog: ContentCatalog = $ContentCatalog
@onready var screen_host: Control = $ScreenLayer/ScreenHost
@onready var expedition_host: Node = $ExpeditionHost
@onready var modal_host: Control = $ModalHost/Container
var run
var last_snapshot: RunStartSnapshot
var generation: int = 0
var writer: SaveCoordinator = SaveCoordinator.new()
var save_continuation: Callable
var settled_generations: Dictionary = {}
var debug_panel
var focus_token: int = -1
var window_focused: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	# Headless has no physical window; graphical sessions use actual initial focus.
	window_focused = DisplayServer.get_name() == "headless" or get_window().has_focus()
	configure_input()
	configure_theme()
	if not catalog.load_all():
		printerr("Content validation failed: " + "\n".join(catalog.errors))
		var error = Label.new()
		error.text = "Content validation failed.\n" + "\n".join(catalog.errors)
		screen_host.add_child(error)
		return
	print("Profile storage: " + ProjectSettings.globalize_path(writer.store.root))
	if writer.open(): show_menu()
	else:
		save_continuation = show_menu
		show_save_error()
	initialize_debug_ui()

func initialize_debug_ui() -> void:
	# App survives every implemented screen/run transition. Keep the existing
	# panel outside the replaceable screen, modal and expedition hosts.
	if not OS.has_feature("debug") or is_instance_valid(debug_panel): return
	get_window().title = "Abyss Expedition — Developer Build · F9 / DEV"
	debug_panel = load("res://scenes/debug/debug_panel.tscn").instantiate()
	debug_panel.app = self
	add_child(debug_panel)

func configure_theme() -> void:
	var theme = Theme.new()
	theme.default_font_size = 12
	for state in ["normal", "hover", "pressed", "focus"]:
		var box = StyleBoxFlat.new()
		box.bg_color = Color(0.1, 0.19, 0.23) if state == "normal" else Color(0.17, 0.31, 0.35)
		box.border_color = Color(0.58, 0.93, 0.86) if state == "focus" else Color(0.28, 0.5, 0.52)
		box.set_border_width_all(2 if state == "focus" else 1)
		box.content_margin_top = 5
		box.content_margin_bottom = 5
		theme.set_stylebox(state, "Button", box)
	screen_host.theme = theme
	modal_host.theme = theme

func configure_input() -> void:
	if OS.has_feature("debug"):
		if not InputMap.has_action("debug_panel_toggle"): InputMap.add_action("debug_panel_toggle")
		var shortcut = InputEventKey.new()
		shortcut.physical_keycode = KEY_F9
		if not InputMap.action_has_event("debug_panel_toggle", shortcut):
			InputMap.action_add_event("debug_panel_toggle", shortcut)
	for entry in [["move_left", KEY_A, KEY_LEFT], ["move_right", KEY_D, KEY_RIGHT], ["move_up", KEY_W, KEY_UP], ["move_down", KEY_S, KEY_DOWN]]:
		if not InputMap.has_action(entry[0]): InputMap.add_action(entry[0])
		for code in entry.slice(1):
			var event = InputEventKey.new()
			event.physical_keycode = code
			InputMap.action_add_event(entry[0], event)
	for entry in [["ui_left", KEY_A], ["ui_right", KEY_D], ["ui_up", KEY_W], ["ui_down", KEY_S]]:
		var event = InputEventKey.new()
		event.physical_keycode = entry[1]
		InputMap.action_add_event(entry[0], event)

func clear_host(host: Node) -> void:
	for child in host.get_children():
		host.remove_child(child)
		child.queue_free()

func leave_run() -> void:
	# Disconnect audio before debug cleanup can release a token and drain its FIFO.
	if is_instance_valid(run) and is_instance_valid(run.combat_audio): run.combat_audio.shutdown()
	if is_instance_valid(debug_panel): debug_panel.on_run_exit()
	get_tree().paused = false
	clear_host(modal_host)
	if is_instance_valid(run):
		run.spawns.terminate(run)
		run.phase = "disposed"
		run.pause.cancel_all()
		expedition_host.remove_child(run)
		run.queue_free()
	run = null
	focus_token = -1

func show_menu() -> void:
	show_guild()

func show_guild() -> void:
	if writer.state != "ready": return
	if not RecruitmentHistory.awaiting(writer.payload).is_empty():
		show_recruitment()
		return
	leave_run()
	clear_host(screen_host)
	var screen = catalog.scene("guild").instantiate()
	screen.catalog = catalog
	screen.payload = writer.payload.duplicate(true)
	screen.expedition_requested.connect(func(): call_deferred("show_selection"))
	screen.roster_requested.connect(func(): call_deferred("show_roster"))
	screen.recruitment_requested.connect(func(): call_deferred("show_recruitment"))
	screen.quit_requested.connect(quit_game)
	screen_host.add_child(screen)

func show_recruitment() -> void:
	if writer.state != "ready": return
	leave_run()
	clear_host(screen_host)
	var screen = catalog.scene("recruitment").instantiate()
	screen.payload = writer.payload.duplicate(true)
	var revision = writer.revision()
	var operation = writer.operation_id()
	screen.draw_requested.connect(func(count):
		save_continuation = show_recruitment
		if RecruitmentService.confirm(writer, count, revision, operation): call_deferred("show_recruitment")
		elif writer.state == "save-blocked": call_deferred("show_save_error")
		else: call_deferred("show_recruitment"))
	screen.exchange_requested.connect(func(hero_id):
		save_continuation = show_recruitment
		if TokenExchangeService.confirm(writer, hero_id, revision, operation): call_deferred("show_recruitment")
		elif writer.state == "save-blocked": call_deferred("show_save_error")
		else: call_deferred("show_recruitment"))
	screen.acknowledged.connect(func(draw):
		save_continuation = show_recruitment
		if RecruitmentHistory.acknowledge(writer, draw, revision, operation): call_deferred("show_recruitment")
		elif writer.state == "save-blocked": call_deferred("show_save_error")
		else: call_deferred("show_recruitment"))
	screen.back_requested.connect(func(): call_deferred("show_guild"))
	screen_host.add_child(screen)

func show_selection() -> void:
	if writer.state != "ready": return
	if not RecruitmentHistory.awaiting(writer.payload).is_empty():
		show_recruitment()
		return
	leave_run()
	clear_host(screen_host)
	var screen = catalog.scene("character_selection").instantiate()
	screen.catalog = catalog
	screen.profile = writer.payload.duplicate(true)
	screen.selected = StringName(writer.payload.active)
	screen.saved_seed = int(writer.payload.seed)
	screen.roster_requested.connect(func(): call_deferred("show_roster"))
	screen.start_requested.connect(func(hero_id, seed_value): call_deferred("mount_run", RunStartSnapshot.new(seed_value, hero_id)))
	screen.back_requested.connect(func(): call_deferred("show_menu"))
	screen_host.add_child(screen)

func mount_run(snapshot: RunStartSnapshot) -> void:
	if writer.state != "ready": return
	if not RecruitmentHistory.awaiting(writer.payload).is_empty():
		show_recruitment()
		return
	var selection = RosterService.selection(writer.payload, String(snapshot.hero_id), writer.payload.companions.filter(func(id): return id != String(snapshot.hero_id)), snapshot.seed_value)
	commit_action(selection, {"kind": "selection"}, func(): mount_saved_run(snapshot.seed_value))

func show_roster() -> void:
	if writer.state != "ready": return
	if not RecruitmentHistory.awaiting(writer.payload).is_empty():
		show_recruitment()
		return
	leave_run()
	clear_host(screen_host)
	var screen = catalog.scene("roster").instantiate()
	screen.catalog = catalog
	screen.payload = writer.payload.duplicate(true)
	screen.confirmed.connect(func(active, companions):
		commit_action(RosterService.selection(writer.payload, active, companions, int(writer.payload.seed)), {"kind": "party"}, show_selection))
	screen.promotion_requested.connect(func(hero_id): call_deferred("show_promotion", hero_id))
	screen.back_requested.connect(func(): call_deferred("show_guild"))
	screen_host.add_child(screen)

func show_promotion(hero_id: String) -> void:
	if writer.state != "ready": return
	if not RecruitmentHistory.awaiting(writer.payload).is_empty():
		show_recruitment()
		return
	clear_host(screen_host)
	var screen = catalog.scene("promotion").instantiate()
	screen.catalog = catalog
	screen.payload = writer.payload.duplicate(true)
	screen.hero_id = hero_id
	screen.revision = writer.revision()
	var promotion_operation = writer.operation_id()
	screen.confirmed.connect(func(hero_value, branch, revision):
		save_continuation = show_roster
		if PromotionService.confirm(writer, hero_value, branch, revision, promotion_operation): call_deferred("show_roster")
		else: call_deferred("show_save_error"))
	screen.canceled.connect(func(): call_deferred("show_roster"))
	screen_host.add_child(screen)

func mount_saved_run(seed_value: int) -> void:
	if writer.state != "ready": return
	if not RecruitmentHistory.awaiting(writer.payload).is_empty():
		show_recruitment()
		return
	var snapshot = RosterService.snapshot(writer.payload, seed_value)
	leave_run()
	clear_host(screen_host)
	generation += 1
	last_snapshot = snapshot
	run = catalog.scene("expedition").instantiate()
	var mounted_generation = generation
	run.process_mode = Node.PROCESS_MODE_PAUSABLE
	expedition_host.add_child(run)
	run.choice_presented.connect(func(identity, options): call_deferred("show_choice", identity, options, mounted_generation))
	run.choice_closed.connect(func(): call_deferred("refresh_modal", mounted_generation))
	run.rescue_presented.connect(func(): call_deferred("show_rescue", mounted_generation))
	run.event_presented.connect(func(): call_deferred("show_event", mounted_generation))
	run.run_finished.connect(func(summary): call_deferred("show_results", summary, mounted_generation))
	run.start(catalog, snapshot, generation)
	set_window_focused(window_focused)

func _process(_delta: float) -> void:
	if is_instance_valid(run): get_tree().paused = run.phase != "active" or run.pause.is_blocked()

func show_choice(identity: int, options: Array, expected_generation: int = -1) -> void:
	if expected_generation >= 0 and expected_generation != generation: return
	if not is_instance_valid(run) or run.phase != "active": return
	if identity != run.choices.offer_id or options != run.choices.offer or options.is_empty(): return
	clear_host(modal_host)
	var screen = catalog.scene("level_up").instantiate()
	screen.run = run
	screen.identity = identity
	screen.options = options
	screen.confirmed.connect(func(offer_id, upgrade_id): run.choices.confirm(run, offer_id, upgrade_id))
	modal_host.add_child(screen)
	run.combat_audio.present_level(run.generation, identity)
	if is_instance_valid(debug_panel): debug_panel.capture_focus()

func show_event(expected_generation: int = -1) -> void:
	if expected_generation >= 0 and expected_generation != generation: return
	if not is_instance_valid(run) or run.phase != "active" or run.choices.event_token < 0: return
	clear_host(modal_host)
	var screen = catalog.scene("event_choice").instantiate()
	screen.run = run
	screen.offer = run.events.current.duplicate(true)
	screen.confirmed.connect(func(identity, choice):
		if is_instance_valid(run): run.choices.resolve_event(run, identity, choice))
	modal_host.add_child(screen)
	if is_instance_valid(debug_panel): debug_panel.capture_focus()

func show_rescue(expected_generation: int = -1) -> void:
	if expected_generation >= 0 and expected_generation != generation: return
	if not is_instance_valid(run) or run.phase != "active" or run.rescue.state != "offered": return
	clear_host(modal_host)
	var screen = catalog.scene("rescue_prompt").instantiate()
	screen.owned = run.rescue.owned_at_start
	screen.resolved.connect(func(accepted):
		if is_instance_valid(run): run.choices.resolve_rescue(run, accepted))
	modal_host.add_child(screen)
	if is_instance_valid(debug_panel): debug_panel.capture_focus()

func refresh_modal(expected_generation: int = -1) -> void:
	if expected_generation >= 0 and expected_generation != generation: return
	if not is_instance_valid(run) or run.phase != "active": return
	if not run.choices.offer.is_empty():
		show_choice(run.choices.offer_id, run.choices.offer.duplicate())
		return
	if run.choices.event_token >= 0:
		show_event(expected_generation)
		return
	if run.rescue.state == "offered":
		show_rescue(expected_generation)
		return
	clear_host(modal_host)
	if run.manual_token < 0: return
	var screen = catalog.scene("pause_menu").instantiate()
	screen.resume_requested.connect(func():
		run.toggle_manual_pause()
		call_deferred("refresh_modal"))
	screen.abandon_requested.connect(func(): run.finish("abandonment"))
	screen.quit_requested.connect(quit_game)
	modal_host.add_child(screen)
	if is_instance_valid(debug_panel): debug_panel.capture_focus()

func show_results(summary: Dictionary, expected_generation: int = -1) -> void:
	if expected_generation >= 0 and expected_generation != generation: return
	if settled_generations.has(generation): return
	settled_generations[generation] = true
	leave_run()
	var result = summary.duplicate(true)
	result["rewards"] = PermanentProgression.preview(result.outcome, result.ticks, result.get("rescue", {}))
	var candidate = PermanentProgression.settle(writer.payload, result)
	if not candidate.is_empty(): result["participant_gains"] = PermanentProgression.settlement_gains(writer.payload, candidate, result.participants)
	result["starting_changed"] = false
	if not candidate.is_empty():
		var next_snapshot = RosterService.snapshot(candidate, int(result.seed))
		result["starting_changed"] = next_snapshot.members != last_snapshot.members or next_snapshot.sera_owned != last_snapshot.sera_owned
	commit_action(candidate, PermanentProgression.settlement_receipt(result), func(): display_results(result))

func display_results(summary: Dictionary) -> void:
	clear_host(screen_host)
	var screen = catalog.scene("run_results").instantiate()
	screen.summary = summary
	screen.retry_requested.connect(func(): call_deferred("mount_run", RunStartSnapshot.new(last_snapshot.seed_value, last_snapshot.hero_id)))
	screen.new_requested.connect(func(): call_deferred("mount_run", RunStartSnapshot.new(randi_range(0, 2147483647), last_snapshot.hero_id)))
	screen.selection_requested.connect(func(): call_deferred("show_guild"))
	screen_host.add_child(screen)

func commit_action(candidate: Dictionary, result: Dictionary, continuation: Callable) -> void:
	save_continuation = continuation
	if writer.mutate(candidate, writer.revision(), writer.operation_id(), result):
		continuation.call()
	else: show_save_error()

func show_save_error() -> void:
	leave_run()
	clear_host(screen_host)
	var screen = load("res://scenes/ui/save_error.tscn").instantiate()
	screen.writer = writer
	screen.retry_requested.connect(func():
		var ok = writer.retry() if not writer.pending_bytes.is_empty() else writer.open()
		if ok: save_continuation.call()
		else: show_save_error())
	screen.recovery_requested.connect(func(fresh):
		if ProfileLoader.recover(writer, true, fresh): save_continuation.call()
		else: show_save_error())
	screen.stale_lock_requested.connect(func():
		writer.error = writer.lock.recover_stale(writer.store.root, true)
		if writer.error == "" and writer.open(): save_continuation.call()
		else: show_save_error())
	screen.close_requested.connect(quit_game)
	screen_host.add_child(screen)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_C:
		if is_instance_valid(run) and run.phase == "active" and not run.pause.is_blocked():
			var token = run.pause.acquire("summary", "abyss-summary")
			clear_host(modal_host)
			var screen = catalog.scene("corruption_summary").instantiate()
			screen.run = run
			screen.closed.connect(func(): run.pause.release(token, "abyss-summary"); refresh_modal())
			modal_host.add_child(screen)
			get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if is_instance_valid(run) and run.phase == "active":
			if run.choices.event_token >= 0: return # Event UI owns Escape and its input guard.
			if run.rescue.state == "offered":
				run.choices.resolve_rescue(run, false)
			elif run.choices.offer.is_empty():
				run.toggle_manual_pause()
				call_deferred("refresh_modal")
			get_viewport().set_input_as_handled()

func settle_before_close() -> void:
	# Terminal routing is deferred; a window-close event can arrive before it.
	if is_instance_valid(run) and run.phase == "results" and not settled_generations.has(generation):
		show_results(run.summary, generation)

func quit_game() -> void:
	settle_before_close()
	if not writer.pending_bytes.is_empty():
		var dialog = ConfirmationDialog.new()
		dialog.dialog_text = "Saving failed. Closing may lose this pending progress. Close anyway?"
		dialog.confirmed.connect(func(): writer.close(); get_tree().quit())
		dialog.canceled.connect(func(): dialog.queue_free())
		add_child(dialog)
		dialog.popup_centered()
		return
	if is_instance_valid(run) and run.phase == "active": run.finish("abandonment")
	get_tree().paused = false
	writer.close()
	get_tree().quit()

func _exit_tree() -> void:
	if is_instance_valid(debug_panel): debug_panel.shutdown()
	writer.close()

func set_window_focused(focused: bool) -> void:
	window_focused = focused
	if not is_instance_valid(run) or run.phase != "active":
		focus_token = -1
		return
	if not focused and focus_token < 0:
		focus_token = run.pause.acquire("focus", "app-focus")
	elif focused and focus_token >= 0:
		run.pause.release(focus_token, "app-focus")
		focus_token = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: set_window_focused(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN: set_window_focused(true)
	if what == NOTIFICATION_WM_CLOSE_REQUEST: quit_game()
