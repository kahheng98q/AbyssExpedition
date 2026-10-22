extends RefCounted

func key(panel, code: int) -> void:
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	panel._input(event)

func delivered_f9() -> void:
	for down in [true, false]:
		var event = InputEventKey.new()
		event.physical_keycode = KEY_F9
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()

func access_regression(t, app) -> void:
	t.check(ResourceLoader.exists("res://scenes/debug/debug_panel.tscn") and FileAccess.file_exists("res://scripts/debug/debug_panel.gd") and FileAccess.file_exists("res://scripts/debug/debug_action_service.gd"), "protected debug scene and scripts exist")
	var panel = app.debug_panel
	t.check(InputMap.has_action("debug_panel_toggle"), "debug F9 action registered")
	var f9_registered = false
	if InputMap.has_action("debug_panel_toggle"):
		for event in InputMap.action_get_events("debug_panel_toggle"):
			if event is InputEventKey and event.physical_keycode == KEY_F9: f9_registered = true
	t.check(f9_registered, "registered debug shortcut includes physical F9")
	t.check(panel.launcher.text == "DEV" and panel.launcher.is_visible_in_tree(), "persistent DEV button is visible")
	t.check(panel.layer > app.get_node("ScreenLayer").layer and panel.layer > app.get_node("ModalHost").layer, "debug layer renders above screens and modals")
	t.check(panel.process_mode == Node.PROCESS_MODE_ALWAYS, "debug input and controls process while paused")
	if app.has_method("initialize_debug_ui"):
		for _attempt in range(3): app.initialize_debug_ui()
	t.check(app.debug_panel == panel and app.find_children("DeveloperDebug", "CanvasLayer", true, false).size() == 1, "repeated initialization keeps exactly one existing panel")
	for definition in panel.Actions.ACTIONS:
		var connected = false
		for entry in panel.buttons:
			if entry.action == definition[0] and not entry.button.pressed.get_connections().is_empty(): connected = true
		t.check(connected and panel.service.actions.has(definition[0]) and panel.service.actions[definition[0]].handler.is_valid(), "preserved debug action wired: " + definition[0])
	for route in ["show_menu", "show_guild", "show_selection", "show_roster", "show_recruitment", "show_promotion"]:
		if route == "show_promotion": app.show_promotion("aren")
		else: app.call(route)
		await t.process_frame
		t.check(app.debug_panel == panel and panel.launcher.is_visible_in_tree(), route + " preserves DEV and panel identity")
		panel.launcher.pressed.emit()
		t.check(panel.overlay.visible and t.paused, route + " DEV signal opens paused panel")
		delivered_f9()
		t.check(not panel.overlay.visible and not t.paused, route + " delivered F9 closes panel")
	# Also preserve a tree pause when there is no run/pause coordinator.
	t.paused = true
	delivered_f9()
	t.check(panel.overlay.visible, "delivered F9 opens while menu tree is paused")
	delivered_f9()
	t.check(not panel.overlay.visible and t.paused, "closing preserves prior menu tree pause")
	t.paused = false
	app.show_menu()
	t.check(panel.service.execute("end_sandbox").ok, "access regression restores normal profile")

func run(t) -> void:
	await preload("res://tests/integration/test_promotion_preview.gd").new().debug_hosts(t)
	t.check(OS.has_feature("debug"), "developer suite runs in a real debug engine")
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/debug-normal-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	await access_regression(t, app)
	app.mount_run(RunStartSnapshot.new(202, &"aren"))
	app.run.set_physics_process(false)
	var normal = app.writer
	var normal_payload = normal.payload.duplicate(true)
	var normal_path = normal.store.generations()[0].path
	var normal_bytes = normal.store.read(normal_path)
	var panel = app.debug_panel
	t.check(panel != null and not panel.overlay.visible, "debug panel starts hidden")
	var physical_f9 = InputEventKey.new()
	physical_f9.physical_keycode = KEY_F9
	physical_f9.pressed = true
	panel._input(physical_f9)
	t.check(panel.overlay.visible, "physical F9 opens debug when logical keycode is absent")
	if panel.overlay.visible: key(panel, KEY_F9)
	key(panel, KEY_F9)
	var run = app.run
	var service = panel.service
	t.check(panel.overlay.visible and t.paused and run.pause.is_blocked(), "F9 opens panel and acquires combat pause")
	t.check(app.writer != normal and service.writer.store.root.begins_with("user://tests/developer-"), "all debug actions and routed rewards use a dedicated sandbox")
	var tick = run.clock.tick
	await t.process_frame
	await t.physics_frame
	t.check(run.clock.tick == tick, "panel processes while active combat clock is paused")
	key(panel, KEY_ESCAPE)
	t.check(run.manual_token == -1, "Escape does not alter game pause behind debug overlay")
	t.check(service.execute("level_one", {"character_id": "aren"}).ok and service.writer.payload.owned.aren.level == 2, "one level uses permanent progression")
	t.check(service.execute("level_ten", {"character_id": "aren"}).ok and service.writer.payload.owned.aren.level == 12, "ten levels preserve capped permanent XP rules")
	t.check(service.execute("level_max", {"character_id": "aren"}).ok and service.writer.payload.owned.aren.total_xp == 2900 and run.hero.health.maximum == 395, "maximum level updates immutable starting stats")
	t.check(not service.execute("character_xp", {"amount": -1}).ok and not service.execute("character_xp", {"amount": 0.5}).ok, "invalid XP rejected")
	t.check(service.execute("character_xp", {"character_id": "lia", "amount": 100}).ok and service.writer.payload.owned.lia.level == 2, "configurable XP targets selected owned character")
	run.hero.health.current = 1
	t.check(service.execute("heal_character", {"character_id": "aren"}).ok and run.hero.health.current == 395, "fully heal through ActorHealth")
	run.hero.next_ready = 999
	run.hero.activations = 3
	t.check(service.execute("cooldowns", {"character_id": "aren"}).ok and run.hero.next_ready == tick and run.hero.activations == 3, "cooldown reset preserves activation identity")
	service.execute("invincible")
	t.check(not run.hero.health.receive(100, 0, true), "active invincibility blocks health damage")
	service.execute("invincible")
	t.check(run.hero.health.receive(10, 0, true), "turning invincibility off restores production immunity semantics")
	service.execute("god_mode")
	t.check(not run.hero.health.receive(100, 100, true), "god mode blocks damage independently")
	service.execute("god_mode")
	t.check(run.hero.health.receive(10, 100, true), "god mode can be disabled")
	t.check(service.execute("eligibility", {"character_id": "aren"}).ok and service.writer.payload.promotion_items == 1, "sandbox eligibility grants material without production rule changes")
	panel.open_promotion(false)
	var promotion = panel.promotion_host.get_child(0)
	t.check(promotion.get_script().resource_path == "res://scripts/ui/promotion.gd", "panel opens the existing promotion UI")
	promotion.selected = "abyss_swordsman"
	promotion.submit()
	t.check(service.writer.payload.owned.aren.promotion_id == "abyss_swordsman" and run.hero.profession.id == &"abyss_swordsman" and run.hero.stats.reach == 64, "normal promotion service updates saved sandbox class, live stats and visuals")
	t.check(service.execute("test_branch", {"character_id": "aren", "branch": "swordmaster"}).ok and run.hero.profession.id == &"swordmaster" and service.writer.payload.owned.aren.promotion_id == "abyss_swordsman", "runtime branch testing bypasses eligibility without a permanent class reset")
	t.check(not service.execute("test_branch", {"character_id": "aren", "branch": "void_caster"}).ok, "runtime branch must belong to correct base")
	t.check(service.execute("add_companion", {"companion_id": "lia"}).ok and service.execute("add_companion", {"companion_id": "milo"}).ok, "two owned companions added through factory")
	t.check(run.party.size() == 3 and not service.execute("add_companion", {"companion_id": "lia"}).ok and not service.execute("add_companion", {"companion_id": "sera"}).ok, "temporary party respects ownership/size/distinctness")
	t.check(service.writer.payload.companions.is_empty(), "temporary party does not persist roles or ownership")
	var companion = service.actor_for("lia")
	t.check(service.execute("test_branch", {"character_id": "lia", "branch": "star_hunter"}).ok and companion.profession.id == &"star_hunter", "promoted companion works without saved eligibility changes")
	run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(25, 0))
	var before = run.projectiles.get_child_count()
	t.check(AttackExecutor.try_activate(companion, run, 0) and run.projectiles.get_child_count() == before + 1 and run.projectiles.get_child(-1).bounces == 1, "promoted companion fires real branch ability")
	service.execute("companion_ai", {"companion_id": "lia"})
	companion.next_ready = 0
	var point = companion.position
	CompanionController.simulate(companion, run)
	t.check(not AttackExecutor.try_activate(companion, run, 200) and companion.position == point, "AI toggle stops follow and attacks")
	service.execute("companion_ai", {"companion_id": "lia"})
	t.check(AttackExecutor.try_activate(companion, run, 200), "re-enabled companion attacks again")
	service.execute("god_mode")
	t.check(not companion.health.receive(100, 200, true), "team god mode covers companions")
	var old_id = companion.actor_id
	t.check(service.execute("remove_companion", {"companion_id": "lia"}).ok and run.party.size() == 2, "temporary companion removal")
	t.check(service.execute("add_companion", {"companion_id": "lia"}).ok and service.actor_for("lia").actor_id != old_id, "removed actor ID is never reused within a run")
	service.execute("heal_team")
	t.check(run.party[1].health.current == run.party[1].health.maximum, "team heal uses full benefit")
	var milo = service.actor_for("milo")
	milo.health.current = 10
	service.execute("heal_companions")
	t.check(milo.health.current == milo.health.maximum, "companion heal uses existing full-heal API")
	milo.health.dead = true
	milo.health.current = 0
	run.mark_dead(milo)
	service.execute("heal_team")
	t.check(milo.health.dead and milo.health.current == 0, "debug healing does not invent revival")
	for multiplier in [1, 2, 4]:
		t.check(service.execute("speed", {"speed": multiplier}).ok and Engine.time_scale == multiplier and Engine.physics_ticks_per_second == multiplier * 60, "valid speed setting " + str(multiplier))
	t.check(service.execute("speed", {"speed": 4}).ok and Engine.time_scale == 4 and Engine.physics_ticks_per_second == 240, "one speed controller keeps 1/60 simulation steps at 4x")
	await t.process_frame
	t.check(run.clock.tick == tick, "speed does not advance paused combat")
	key(panel, KEY_F9)
	t.check(not panel.overlay.visible and not run.pause.is_blocked(), "F9 closes and releases only developer token")
	run.toggle_manual_pause()
	key(panel, KEY_F9)
	key(panel, KEY_F9)
	t.check(run.manual_token >= 0 and run.pause.is_blocked(), "existing manual pause survives debug open/close")
	run.toggle_manual_pause()
	key(panel, KEY_F9)
	t.check(service.execute("run_xp", {"amount": 300}).ok and run.progression.level == 3 and run.progression.pending == 2 and service.writer.payload.owned.aren.total_xp == 2900, "run XP uses shared progression independently of permanent XP")
	await t.process_frame
	await t.process_frame
	t.check(panel.overlay.is_ancestor_of(t.root.get_viewport().gui_get_focus_owner()), "deferred level-up cannot steal keyboard focus from debug")
	var number_key = InputEventKey.new()
	number_key.keycode = KEY_1
	number_key.pressed = true
	Input.parse_input_event(number_key)
	Input.flush_buffered_events()
	await t.process_frame
	t.check(run.progression.pending == 2, "number shortcut cannot confirm an upgrade behind debug UI")
	key(panel, KEY_F9)
	t.check(run.pause.is_blocked() and run.choices.offer.size() == 3, "closing panel retains earned upgrade pause")
	t.check(app.modal_host.is_ancestor_of(t.root.get_viewport().gui_get_focus_owner()), "closing debug restores level-up keyboard navigation")
	while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	key(panel, KEY_F9)
	service.execute("kill_all")
	t.check(run.enemies.is_empty() and run.kills == 1 and run.pickups.get_child_count() == 1, "kill action reuses damage/death/drop APIs")
	var rng_state = run.rng.stream("spawn_positions").state
	for count in [1, 10, 50, 100]:
		t.check(service.execute("spawn", {"enemy_id": "shellbound_husk", "count": count}).ok and run.spawns.reservations.size() == count, "warned spawn count " + str(count))
		service.execute("kill_all")
	t.check(run.rng.stream("spawn_positions").state == rng_state, "debug spawning does not consume seeded gameplay streams")
	t.check(service.execute("boss").ok and not service.execute("boss").ok, "only one boss may be reserved")
	panel.close_panel()
	run.clock.tick = 45
	run.spawns.simulate(run, 45)
	t.check(run.boss_actor != null and run.boss_actor.definition == app.catalog.boss, "boss uses registered chapter definition and spawn director")
	panel.open_panel()
	t.check(not service.execute("boss").ok, "living boss cannot be duplicated")
	run.hostile_shot(Vector2(20, 20), Vector2.RIGHT, 10, 45)
	service.execute("clear_projectiles")
	t.check(run.projectiles.get_child(-1).is_queued_for_deletion(), "hostile projectile cleanup supported")
	var old_hero = run.hero
	service.execute("invincible")
	service.execute("speed", {"speed": 2})
	t.check(service.execute("restart").ok, "restart through existing router")
	run = app.run
	run.set_physics_process(false)
	t.check(run.snapshot.seed_value == 202 and Engine.time_scale == 1 and Engine.physics_ticks_per_second == 60 and not old_hero.health.debug_invincible and not old_hero.health.debug_god_mode, "same-seed restart resets all temporary debug modifiers")
	t.check(run.hero.profession.id == &"abyss_swordsman" and service.runtime_branches.is_empty() and run.party.size() == 3, "restart restores saved sandbox class and current party")
	t.check(app.debug_panel == panel and panel.launcher.is_visible_in_tree() and app.find_children("DeveloperDebug", "CanvasLayer", true, false).size() == 1, "same-seed restart preserves a single accessible panel")
	panel.open_panel()
	t.check(service.execute("save_test").ok and service.execute("load_test").ok, "safe sandbox save/load uses validated generations")
	var fault = preload("res://tests/fixtures/fault_file_store.gd").new()
	fault.stage = "rename"
	service.writer.store.fault = fault
	var balance = service.writer.payload.promotion_items
	t.check(not service.execute("materials", {"materials": 3}).ok and service.writer.state == "save-blocked" and not panel.close_panel(), "failed sandbox save blocks continuation")
	var candidate = service.writer.pending_bytes
	t.check(not service.execute("god_mode").ok and candidate == service.writer.pending_bytes, "pending test action cannot be overwritten")
	t.check(service.execute("retry_save").ok and service.writer.payload.promotion_items == balance + 3, "sandbox Retry saves original action once")
	t.check(service.logs.size() <= 20, "recent action log stays bounded")
	service.execute("boss")
	panel.close_panel()
	run.clock.tick = 45
	run.spawns.simulate(run, 45)
	panel.open_panel()
	service.execute("kill_all")
	panel.close_panel()
	run.simulation.advance(run, Vector2.ZERO)
	await t.process_frame
	await t.process_frame
	t.check(app.run == null and app.writer == service.writer and service.writer.payload.promotion_items == balance + 4, "debug boss victory settles rewards only to isolated sandbox")
	t.check(normal.payload == normal_payload and normal.store.read(normal_path) == normal_bytes, "all debug actions leave normal profile byte-for-byte unchanged")
	t.check(service.execute("end_sandbox").ok and app.writer == normal and not panel.overlay.visible and not t.paused, "normal menu/profile restored after sandbox")
	app.free()
	await t.process_frame
	t.paused = false
