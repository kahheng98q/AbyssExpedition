extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")
const Fault = preload("res://tests/fixtures/fault_file_store.gd")

func run(t) -> void:
	await migration(t)
	await arbitration(t)
	await app_flow(t)
	handoff(t)
	var recorded = replay(t)
	t.check(recorded == replay(t, JSON.parse_string(JSON.stringify(recorded.trace))), "recorded promotion decisions replay exact trace and combat state")

func migration(t) -> void:
	for version in [1, 2, 3]:
		var original = populated_legacy() if version == 3 else FileAccess.get_file_as_string("res://tests/fixtures/profiles/v%d.json" % version)
		var old = ProfileValidator.decode(original)
		t.check(old.error == "", "legacy validates before migration")
		for stage in ["rename", "readback"]:
			var root = "user://tests/run-promotion-migrate-%d-%d/" % [version, Time.get_ticks_usec()]
			DirAccess.make_dir_recursive_absolute(root)
			var file = FileAccess.open(root.path_join("profile-1.json"), FileAccess.WRITE)
			file.store_string(original)
			file.close()
			var fault = Fault.new()
			fault.stage = stage
			var writer = SaveCoordinator.new(root, fault)
			t.check(not writer.open() and writer.state == "save-blocked", "migration failure holds prior profile")
			var pending = writer.pending_bytes
			t.check(writer.retry() and writer.envelope.schema_version == 4, "schema4 retry succeeds")
			t.check(writer.envelope.payload_json == JSON.parse_string(pending).payload_json, "migration retry freezes exact candidate")
			t.check(writer.store.read(root.path_join("profile-1.json")) == original, "legacy bytes preserved")
			for key in ["active", "companions", "seed"]:
				t.check(writer.payload[key] == old.payload[key], "selection survives migration " + key)
			if version >= 2:
				for key in ["tickets", "tokens", "history", "draw_rng"]:
					t.check(writer.payload[key] == old.payload[key], "collection survives migration " + key)
			if version == 3: t.check(writer.payload.chapters == old.payload.chapters, "chapter flags preserved")
			t.check(not writer.payload.has("promotion_items") and writer.payload.owned.keys() == old.payload.owned.keys(), "materials removed, roster retained")
			for id in writer.payload.owned:
				t.check(writer.payload.owned[id] == {"character_id": id}, "owned identity only " + id)
			t.check(writer.payload.receipt.result.previous_receipt == old.payload.receipt, "legacy receipt preserved as evidence")
			var saved = writer.payload.duplicate(true)
			writer.close()
			writer = SaveCoordinator.new(root)
			t.check(writer.open() and writer.payload == saved, "migrated exact profile survives reopen")
			writer.close()
	var f = Fixture.create_party(t, ProfileData.fresh())
	t.check(f.run.hero.profession.id == &"swordsman" and f.run.progression.level == 1, "BASE and RUN Lv1")
	Fixture.dispose(f)
	await t.process_frame

func arbitration(t) -> void:
	var p = ProfileData.fresh()
	p.companions = ["lia", "milo"]
	var f = Fixture.create_party(t, p)
	var run = f.run
	run.progression.collect_xp(888, 9100) # Exact Lv14 total.
	t.check(run.progression.level == 14 and PromotionService.eligible(run).is_empty(), "actual XP Lv14 no promotion")
	run.choices.present(run)
	var old_offer = run.choices.offer_id
	run.progression.collect_xp(889, 1400) # Lv15 while existing upgrade is open.
	run.choices.present(run)
	t.check(run.progression.level == 15 and run.choices.promotion_token < 0 and run.choices.offer_id == old_offer, "existing card finishes before promotion")
	run.toggle_manual_pause()
	var manual = run.manual_token
	t.check(run.choices.confirm(run, old_offer, run.choices.offer[0]), "card accepted once")
	t.check(run.choices.promotion_hero == "aren" and run.choices.offer.is_empty(), "Lv15 interrupts remaining cards in stable party order")
	var nonce = run.choices.promotion_id
	var trace = run.trace.snapshot()
	t.check(not run.choices.confirm_promotion(run, nonce, "aren", "void_caster") and not run.choices.confirm_promotion(run, nonce + 1, "aren", "swordmaster"), "foreign branch and stale nonce rejected")
	t.check(run.trace.snapshot() == trace and run.hero.profession.id == &"swordsman", "invalid confirmations leave all state unchanged")
	t.check(run.choices.confirm_promotion(run, nonce, "aren", "swordmaster"), "first party member confirms")
	t.check(not run.choices.confirm_promotion(run, nonce, "aren", "abyss_swordsman") and run.choices.promotion_hero == "lia", "double click cannot confirm next member")
	run.choices.cancel_promotion(run, run.choices.promotion_id)
	t.check(run.choices.promotion_deferred and run.progression.branches.size() == 1 and not run.choices.offer.is_empty(), "cancel defers remaining members and continues cards")
	while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	t.check(run.pause.tokens.has(manual) and run.choices.promotion_token < 0, "choice closes without releasing manual pause")
	run.toggle_manual_pause()
	run.choices.request_promotion(run)
	t.check(run.choices.promotion_hero == "lia", "HUD reopen retains pending member")
	run.choices.confirm_promotion(run, run.choices.promotion_id, "lia", "star_hunter")
	run.choices.confirm_promotion(run, run.choices.promotion_id, "milo", "void_caster")
	t.check(run.progression.branches.size() == 3 and not run.pause.is_blocked(), "all three promote once without leaked tokens")
	run.progression.collect_xp(890, 10000)
	run.choices.present(run)
	t.check(run.choices.promotion_token < 0, "later level gains never repeat promotion")
	run.finish("abandonment")
	t.check(run.choices.promotion_token < 0 and not run.pause.is_blocked(), "terminal cancel releases all choices")
	Fixture.dispose(f)
	f = Fixture.create_party(t, p)
	t.check(f.run.progression.level == 1 and f.run.progression.branches.is_empty() and f.run.progression.stacks.is_empty() and f.run.party.all(func(actor): return actor.profession.id == actor.definition.base_profession.id), "restart resets all run growth for entire party")
	# Overshoot and downed members: no missed threshold or revival.
	f.run.party[1].health.current = 0
	f.run.party[1].health.dead = true
	f.run.progression.collect_xp(1, 20000)
	f.run.choices.present(f.run)
	t.check(f.run.progression.level > 15 and PromotionService.eligible(f.run) == ["aren", "milo"], "large pickup catches threshold, downed excluded")
	f.run.choices.cancel(f.run)
	Fixture.dispose(f)
	# Event owns its screen until resolved, even when debug grants Lv15.
	f = Fixture.create(t)
	f.run.clock.tick = 7200
	f.run.choices.present_rescue(f.run)
	f.run.progression.level = 15
	f.run.choices.present(f.run)
	t.check(f.run.choices.promotion_token < 0, "active rescue serializes promotion")
	if f.run.rescue.state == "offered": f.run.choices.resolve_rescue(f.run, false)
	else: f.run.choices.resolve_event(f.run, f.run.events.current.id, &"leave" if f.run.events.current.kind == "mysterious_merchant" else &"decline")
	t.check(f.run.choices.promotion_hero == "aren", "event resolution immediately schedules pending promotion")
	Fixture.dispose(f)
	await t.process_frame

func app_flow(t) -> void:
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/promotion-app-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	app.mount_saved_run(202)
	app.run.set_physics_process(false)
	UpgradeEffects.apply(app.catalog.upgrades[&"might"], app.run.hero, app.run.progression)
	app.run.progression.collect_xp(1, 10500)
	app.run.choices.present(app.run)
	await t.process_frame
	await t.process_frame
	var page = app.modal_host.get_child(0)
	t.check(page.get_script().resource_path.ends_with("promotion.gd") and page.run == app.run and app.run.pause.is_blocked(), "real App mounts paused promotion with live run")
	var normal = app.writer
	var payload = normal.payload.duplicate(true)
	var panel = app.debug_panel
	t.check(panel.open_panel() and panel.overlay.visible and app.run.pause.is_blocked(), "F9 panel available above promotion")
	var service = panel.service
	t.check(service.execute("add_companion", {"companion_id": "lia"}).ok, "late join at shared Lv15")
	var companion = service.actor_for("lia")
	t.check(is_equal_approx(companion.stats.damage, companion.starting_stats.damage * 1.1), "late join inherits existing shared upgrades once")
	t.check(companion.profession.id == &"archer" and PromotionService.reason(app.run, "lia") == "", "late join BASE and eligible, shares RUN level")
	panel.close_panel()
	page.selected = "swordmaster"
	page.submit()
	page.submit()
	await t.process_frame
	await t.process_frame
	var next = app.modal_host.get_child(0)
	t.check(next.hero_id == "lia" and app.run.hero.profession.id == &"swordmaster", "UI double submit promotes once then next member")
	next.selected = "star_hunter"
	next.submit()
	await t.process_frame
	while not app.run.choices.offer.is_empty(): app.run.choices.confirm(app.run, app.run.choices.offer_id, app.run.choices.offer[0])
	panel.open_panel()
	service.execute("remove_companion", {"companion_id": "lia"})
	service.execute("add_companion", {"companion_id": "lia"})
	t.check(service.actor_for("lia").profession.id == &"star_hunter" and PromotionService.reason(app.run, "lia") != "", "rejoining identity keeps run branch, cannot promote twice")
	t.check(normal.payload == payload, "all UI and late join debug actions preserve normal profile")
	var old_nonce = app.run.choices.promotion_id
	service.execute("restart")
	app.run.set_physics_process(false)
	t.check(app.run.progression.level == 1 and app.run.hero.profession.id == &"swordsman" and app.run.party[1].profession.id == &"archer", "debug restart resets classes and RUN level")
	t.check(not app.run.choices.confirm_promotion(app.run, old_nonce, "aren", "swordmaster"), "old run confirmation cannot affect restart")
	service.execute("end_sandbox")
	app.free()
	t.paused = false
	await t.process_frame

func replay(t, recorded: Dictionary = {}) -> Dictionary:
	var p = ProfileData.fresh()
	p.companions = ["lia", "milo"]
	var f = Fixture.create_party(t, p, 303)
	var run = f.run
	run.progression.collect_xp(1, 12000)
	run.choices.present(run)
	if recorded.is_empty():
		run.choices.cancel_promotion(run, run.choices.promotion_id)
		while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
		run.choices.request_promotion(run)
		while run.choices.promotion_token >= 0:
			var id = run.choices.promotion_hero
			var branch = String(run.catalog.characters[StringName(id)].base_profession.promotion_ids[1])
			run.choices.confirm_promotion(run, run.choices.promotion_id, id, branch)
	else:
		t.check(run.trace.compatible(recorded), "replay uses matching simulation metadata")
		for action in recorded.decisions:
			match action.get("kind", "upgrade"):
				"promotion_cancel": t.check(run.choices.cancel_promotion(run, int(action.offer)), "replay cancel accepted")
				"promotion_reopen": run.choices.request_promotion(run)
				"promotion": t.check(run.choices.confirm_promotion(run, int(action.offer), String(action.hero), String(action.branch)), "replay branch accepted")
				"upgrade": t.check(run.choices.confirm(run, int(action.offer), StringName(action.upgrade)), "replay upgrade accepted")
	var victim = run.spawn_enemy(&"shellbound_husk", run.hero.position + Vector2(30, 0))
	victim.health = ActorHealth.new(10000)
	for i in range(120): run.simulation.advance(run, Vector2.ZERO)

	var state = []
	for actor in run.party: state.append([actor.profession.id, actor.health.current, actor.health.maximum, actor.stats.damage, actor.activations])
	var result = {"trace": run.trace.snapshot(), "party": state, "branches": run.progression.branches.duplicate(true), "combat": preload("res://tests/fixtures/pacing_observer.gd").new().actor_state(victim), "kills": run.kills}
	Fixture.dispose(f)
	return result

func populated_legacy() -> String:
	var p = ProfileData.fresh()
	p.tickets = 20
	p.draw_rng = DrawRng.initial("12345")
	p = RecruitmentService.candidate(p, 10, "legacy-ten")
	p.owned.sera = OwnedHero.record("sera")
	p.owned.brann = OwnedHero.record("brann")
	p.owned.nyra = OwnedHero.record("nyra")
	p.active = "brann"
	p.companions = ["sera", "nyra"]
	p.seed = 303
	p.chapters.coast = true
	p["promotion_items"] = 27
	for id in p.owned:
		var branches = ProfileData.BRANCHES.keys().filter(func(branch): return ProfileData.BRANCHES[branch] == ProfileData.BASES[id])
		p.owned[id] = {"character_id": String(id), "total_xp": 2900, "level": 30, "progress_to_next": 0, "promotion_id": branches[0]}
	p.receipt = {"operation_id": "legacy-operation", "base_revision": 0, "result_revision": 1, "result": {"kind": "draw", "draw": "legacy-ten"}}
	var envelope = ProfileData.envelope(p, 1, "legacy-operation")
	envelope.schema_version = 3
	envelope.game_version = "m4.0"
	return JSON.stringify(envelope)

func handoff(t) -> void:
	var p = ProfileData.fresh()
	p.companions = ["lia", "milo"]
	var f = Fixture.create_party(t, p)
	var run = f.run
	run.progression.collect_xp(1, 10500)
	run.choices.present(run)
	var unblocked: Array = []
	run.pause.changed.connect(func(state): unblocked.append(state.is_empty()))
	run.choices.confirm_promotion(run, run.choices.promotion_id, "aren", "swordmaster")
	run.choices.cancel_promotion(run, run.choices.promotion_id)
	run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	t.check(not unblocked.has(true), "promotion/member/card handoff never reports a false resume")
	while not run.choices.offer.is_empty(): run.choices.confirm(run, run.choices.offer_id, run.choices.offer[0])
	t.check(unblocked.count(true) == 1 and not run.pause.is_blocked(), "final choice releases pause exactly once")
	Fixture.dispose(f)
