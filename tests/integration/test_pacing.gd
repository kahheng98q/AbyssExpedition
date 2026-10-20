extends RefCounted
const Observer = preload("res://tests/fixtures/pacing_observer.gd")

func run(t) -> void:
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/pacing-observer-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	var original = app.writer.payload.duplicate(true)
	app.mount_run(RunStartSnapshot.new(101, &"aren"))
	app.run.set_physics_process(false)
	var observer = Observer.new()
	observer.bind(app)
	var current = {"session_id":"aren-101","hero":"aren","seed":101,"engine":"4.5","simulation":ReplayTrace.SIMULATION_VERSION,"catalog":"catalog","build_hash":"build","fixture_hash":"fixture","party":[],"corruption":0,"fixture_mode":"Integrated"}
	t.check(Observer.metadata_error(JSON.parse_string(JSON.stringify(current)),current)=="", "session metadata roundtrips JSON")
	for key in current:
		var changed=current.duplicate(true)
		changed.erase(key)
		t.check(Observer.metadata_error(changed,current)!="", "missing session metadata rejected: "+key)
	var changed=current.duplicate(true)
	changed.build_hash="different"
	t.check(Observer.metadata_error(changed,current)!="", "changed source hash requires new recording")
	t.check(Observer.differences({"hp":[10,20]},{"hp":[10,19]},"final")[0].path=="final/hp/1", "replay reports exact differing gameplay field")
	var report = observer.report()
	t.check(report.first.hit == -1 and report.first.level == -1 and report.failures.has("hit_missing") and report.failures.has("level_missing"), "missing facts explicitly fail; never zero seconds")
	t.check(report.final.rng.size() == 4 and report.final.party[0].health.current == 250, "full starting gameplay state and all RNG streams captured")
	app.run.spawns.schedule_wave(app.run, 0)
	check_pending_snapshot(t, observer, app.run)
	t.check(app.run.spawns.reservations.all(func(slot): return slot.warning.get_parent() is CanvasLayer), "opening warnings escape HUD occlusion on presentation layer")
	app.run.spawns.simulate(app.run, 45)
	app.run.clock.tick = 46
	var enemy = app.run.enemies[0]
	app.run.queue_hit(enemy, 999, Vector2.RIGHT, 0, false, false)
	app.run.damage.resolve_tick_hits(app.run, 46)
	app.run.drop_rewards()
	t.check(observer.first.hit == 46 and observer.first.kill == 46, "accepted hit and actual lethal damage observed")
	app.run.progression.collect_xp(99999, 100)
	app.run.choices.present(app.run)
	await t.process_frame
	t.check(observer.first.level == 46 and app.modal_host.get_child_count() == 1, "level timestamp comes from real mounted App UI")
	report = observer.report()
	t.check(report.counts.planned == 4 and report.counts.warned == 4 and report.counts.activated == 4, "reservation lifecycle counters derive actual facts")
	t.check(app.writer.store.root.begins_with("user://tests/") and app.writer.payload.owned == original.owned, "observer cannot grant permanent progression or access normal store")
	app.run.choices.confirm(app.run, app.run.choices.offer_id, app.run.choices.offer[0])
	var brinejaw = app.run.spawn_enemy(&"skittering_brinejaw", app.run.hero.position + Vector2(100,0))
	brinejaw.ai_state = "warning"
	brinejaw.deadline = 100
	BrinejawBehavior.decide(brinejaw, app.run, 100)
	app.run.hostile_shot(Vector2(100,100), Vector2.RIGHT, 3, 200)
	t.check(observer.first.rush == 100 and observer.first.shot == 200, "observer records actual rush transition and hostile shot, not enemy spawn")
	var frozen = observer.final_state()
	t.check(JSON.parse_string(JSON.stringify(frozen)).rng == frozen.rng, "64-bit RNG states preserved as decimal strings")
	app.leave_run()
	app.free()
	t.paused = false
	await t.process_frame
	await check_us2_legacy_opening(t)
	await check_session_termination(t)

func check_pending_snapshot(t, observer, run) -> void:
	var baseline = observer.final_state()
	t.check(baseline.has("spawns") and baseline.has("boss_hits"), "final snapshot includes pending spawns and boss damage")
	if not baseline.has("spawns") or not baseline.has("boss_hits"): return
	for field in ["reservation_serial", "boss_pending", "boss_placed", "opening_initialized", "opening_origin", "disposed"]:
		var previous = run.spawns.get(field)
		var changed = not previous if previous is bool else (previous + Vector2.ONE if previous is Vector2 else previous + 1)
		run.spawns.set(field, changed)
		var diff = Observer.differences(baseline, observer.final_state(), "final")
		t.check(not diff.is_empty() and diff[0].path.begins_with("final/spawns/" + field), "snapshot detects spawn state change: " + field)
		run.spawns.set(field, previous)
	var slot = run.spawns.reservations[0]
	for field in ["due", "parent", "reservation_id", "point"]:
		var previous = slot[field]
		slot[field] = previous + Vector2.ONE if previous is Vector2 else previous + 1
		t.check(not Observer.differences(baseline, observer.final_state()).is_empty(), "snapshot detects reservation field: " + field)
		slot[field] = previous
	var warning = run.create_warning(Vector2(50,50), "cone", 90, Vector2.RIGHT, 60, 100)
	run.boss_hits.append({"warning":warning,"due":100,"damage":20.0,"source":999})
	baseline = observer.final_state()
	for field in ["position", "geometry", "radius", "direction", "angle", "expires", "impact"]:
		var previous = warning.get(field)
		var changed = "circle" if previous is String else (not previous if previous is bool else (previous + Vector2.ONE if previous is Vector2 else previous + 1))
		warning.set(field, changed)
		t.check(not Observer.differences(baseline, observer.final_state()).is_empty(), "snapshot detects warning geometry: " + field)
		warning.set(field, previous)
	for field in ["due", "damage", "source"]:
		run.boss_hits[0][field] += 1
		t.check(not Observer.differences(baseline, observer.final_state()).is_empty(), "snapshot detects pending boss hit: " + field)
		run.boss_hits[0][field] -= 1
	var json_diff = Observer.differences(baseline, JSON.parse_string(JSON.stringify(baseline,"",false,true)))
	t.check(json_diff.is_empty(), "complete snapshot is portable JSON without Node IDs: " + str(json_diff))
	run.boss_hits.clear()
	warning.queue_free()

func check_session_termination(t) -> void:
	var fixture = preload("res://tests/fixtures/run_fixture.gd")
	for reason in ["early_exit", "death", "watchdog"]:
		var f = fixture.create(t)
		var observer = Observer.new()
		observer.run = f.run
		f.run.spawns.schedule_wave(f.run, 0)
		f.run.clock.tick = 20
		t.check(observer.has_method("complete_report"), "session can report after terminating reservations: " + reason)
		if observer.has_method("complete_report"):
			var terminal = {}
			if reason == "death":
				f.run.hero.health.current = 0
				f.run.hero.health.dead = true
				f.run.finish("defeat")
				terminal = observer.report()
			var report = observer.call("complete_report", terminal)
			t.check(report.counts.get("canceled",0) == 4 and report.counts.get("warned",0) == 4, "final counters include all run_end cancellations: " + reason)
			t.check(report.trace.spawns.filter(func(event): return event.result == "canceled" and event.reason == "run_end").size() == 4, "each warned reservation terminates once: " + reason)
			t.check(report.failures.has("early_end") and report.failures.has("hit_missing"), "failed session never turns missing timing into zero-second pass")
			var again = observer.call("complete_report", report)
			t.check(again.trace == report.trace and again.counts == report.counts, "repeated finalization cannot double-cancel")
		fixture.dispose(f)
		await t.process_frame

func check_us2_legacy_opening(t) -> void:
	var fixture=preload("res://tests/fixtures/run_fixture.gd")
	var session=load("res://tests/fixtures/pacing_session.gd")
	var f=fixture.create(t,&"aren",101)
	var r=f.run
	r.spawns=session.LegacyEdgeSpawns.new()
	r.spawns.initialize_opening(r.hero.position)
	r.combat_audio.set_enabled(false)
	var rushes: Array=[]
	var shots: Array=[]
	r.rush_started.connect(func(tick,_identity): rushes.append(tick))
	r.hostile_shot_fired.connect(func(tick): shots.append(tick))
	# Predefined neutral input; this is a controlled US2 fixture, not natural9 input.
	while r.clock.tick<4501 and r.phase=="active":
		while not r.choices.offer.is_empty(): r.choices.confirm(r,r.choices.offer_id,r.choices.offer[0])
		r.simulation.advance(r,Vector2.ZERO)
		await t.physics_frame
	t.check(r.phase=="active" and r.clock.tick==4501,"US2 standalone legacy-edge fixture survives fixed75s input")
	t.check(not rushes.is_empty() and rushes[0]<2700,"legacy opening with new composition actually rushes before45s")
	t.check(not shots.is_empty() and shots[0]<4500,"legacy opening with new composition actually shoots before75s")
	t.check(r.combat_audio.allocator.accepted==0,"US2 independent fixture keeps sound disabled")
	fixture.dispose(f)
	await t.process_frame
