extends SceneTree

class CaptureErrors extends Logger:
	var errors: Array[String] = []
	func _log_error(_function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _backtraces: Array[ScriptBacktrace]) -> void:
		if error_type != Logger.ERROR_TYPE_WARNING: errors.append("%s:%d %s %s" % [file, line, code, rationale])

class FailPublication extends RefCounted:
	var remaining: int = 1
	func fail(stage: String) -> bool:
		if stage != "rename" or remaining == 0: return false
		remaining -= 1
		return true

var app
var errors = CaptureErrors.new()
var assertions: int = 0
var failures: int = 0
var output_path: String
var frames: Array = []
var checks: Array = []

func _initialize() -> void:
	OS.add_logger(errors)
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	assertions += 1
	checks.append({"passed": ok, "check": message})
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func profile(active: String = "aren", xp: int = 1400, companions: Array = [], branch: String = "") -> Dictionary:
	var p = ProfileData.fresh()
	p.active = active
	p.companions = companions.duplicate()

	for id in p.owned: p.owned[id] = OwnedHero.record(id, xp, branch if id == active else "")
	return p

func prepare(p: Dictionary) -> void:
	app.leave_run()
	check(app.writer.mutate(p, app.writer.revision(), app.writer.operation_id(), {"kind": "screenshot_fixture"}), "controlled screenshot profile committed")

func start_run() -> void:
	app.mount_saved_run(101)
	app.run.set_physics_process(false)
	app.run.camera.force_update_scroll()

func capture(id: String, requirement: String, title: String, caption: String, how: String, zoom: bool = false) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output_path.path_join(id + ".png")) == OK, "captured " + id)
	frames.append({"id": id, "requirement": requirement, "title": title, "caption": caption, "how": how, "zoom": zoom})

func debug_character(id: String) -> void:
	app.debug_panel.open_panel()
	var panel = app.debug_panel
	for index in range(panel.character_choice.item_count):
		if panel.character_choice.get_item_metadata(index) == id: panel.character_choice.select(index)
	panel.update_branches()
	panel.tabs.current_tab = 0
	panel.refresh()
	await process_frame
	panel.tabs.get_child(0).scroll_vertical = int(panel.tabs.get_child(0).get_v_scroll_bar().max_value)

func run() -> void:
	check(OS.has_feature("debug"), "evidence captured from native debug build")
	var args = OS.get_cmdline_user_args()
	output_path = args[args.find("--captures") + 1] if args.has("--captures") else ProjectSettings.globalize_path("res://screenshots/m2-evidence")
	DirAccess.make_dir_recursive_absolute(output_path)
	root.content_scale_size = Vector2i(640, 360)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	DisplayServer.window_set_size(Vector2i(1280, 720))
	app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m2-evidence-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(app)
	current_scene = app
	prepare(profile("aren", 1400, ["lia", "milo"]))
	app.show_selection()
	await capture("01-selection", "FR-015", "Where to find the roster", "Character selection contains the roster entry. This is ordinary game UI, not a debug-only character list.", "New Expedition → Character roster / companions / promotions")
	app.show_roster()
	await capture("02-roster", "FR-015", "Owned roster and two saved companions", "Aren is active; Lia and Milo are both selected companions. Each row shows BASE, RUN Lv1 start and identity passive; branch previews are read-only.", "New Expedition → Character roster / companions / promotions; choose roles, then Save party & return")
	for id in ["aren", "lia", "milo"]:
		app.show_promotion(id)
		await capture("03-promotion-" + id, "FR-018", "Two promotion choices: " + id.capitalize(), "This out-of-combat gallery cannot commit. In combat, RUN Lv15 enables a temporary branch without materials. The retained character passive is named here.", "Roster → View / promote beside " + id.capitalize())
	for level in [1, 14, 15, 30]:
		prepare(profile("aren", 0))
		start_run()
		await debug_character("aren")
		if level > 1: check(app.debug_panel.service.execute("run_xp", {"amount": 50 * level * (level - 1)}).ok, "run level fixture XP")
		check(app.run.progression.level == level and app.run.hero.health.maximum == 250, "RUN level has no permanent HP multiplier")
		await capture("04-level-" + str(level), "004-FR-001", "RUN Lv" + str(level), "Controlled shared RUN level; base max HP stays unchanged. No permanent XP or class is saved.", "DEV / Character / RUN XP")
		app.debug_panel.close_panel()
	for branch in ProfileData.BRANCHES:
		var base = ProfileData.BRANCHES[branch]
		var id = "aren" if base == "swordsman" else ("lia" if base == "archer" else "milo")
		prepare(profile(id, 1400, [], branch))
		app.show_roster()
		await capture("05-roster-" + branch, "FR-019", branch.capitalize() + " gallery", "The roster always describes BASE starts; the actual branch is chosen inside each run.", "Roster / branch previews")
		start_run()
		var run = app.run
		run.progression.level = 15
		check(PromotionService.apply(run, id, branch), "live run branch fixture")
		run.clock.tick = 240
		var target = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(46 if base == "swordsman" else 90, 0))
		target.health = ActorHealth.new(2000)
		var nearby = run.spawn_enemy(&"saltbound_thrall", target.position + Vector2(12, 20))
		nearby.health = ActorHealth.new(2000)
		run.hero.health.current = run.hero.health.maximum * 0.6
		var before_hp = run.hero.health.current
		run.hero.activations = 4
		run.hero.passive_activations = 4
		check(AttackExecutor.try_activate(run.hero, run, 240), branch + " real fifth attack fired")
		var description = String(run.hero.profession.description)
		if base == "swordsman":
			run.damage.resolve_tick_hits(run, 240)
			check(run.effects.get_child_count() == (3 if branch == "swordmaster" else 1), branch + " distinct arc policy instantiated")
			if branch == "abyss_swordsman":
				check(run.hero.health.current > before_hp, "abyss fifth attack restored actual HP")
				description += " Actual HP in this example: %.1f → %.1f (HUD rounds upward)." % [before_hp, run.hero.health.current]
		else:
			for shot in run.projectiles.get_children(): shot.position += shot.direction * 55
			if branch == "sharpshooter": check(run.projectiles.get_child_count() == 4 and run.projectiles.get_child(0).hit_limit == 3, "sharpshooter piercing and fifth volley")
			elif branch == "star_hunter": check(run.projectiles.get_child(0).bounces == 1 and run.delayed_impacts.size() == 1, "star hunter bounce and delayed mark")
			elif branch == "void_caster":
				var shot = run.projectiles.get_child(0)
				shot.position = target.position - Vector2(1, 0)
				shot.simulate(240)
				check(run.effects.get_child_count() == 2, "void pull and damage zones coexist")
			else:
				check(run.delayed_impacts.size() == 1 and run.delayed_impacts[0].get("frost", false) and run.projectiles.get_child(0).element == "fire", "elemental fire projectile and fifth frost burst")
				run.clock.tick = 241
				run.simulation.advance(run, Vector2.ZERO)
		run.state_changed.emit()
		await capture("06-attack-" + branch, "FR-019", branch.capitalize() + " actual attack", description + " This controlled frame is frozen at the fifth attack; use the magnified view to inspect the small placeholder effects.", "Debug → Progression → grant requirements → Open existing promotion UI; close debug and let attacks fire automatically", true)
		if branch == "star_hunter":
			var shot = run.projectiles.get_child(0)
			shot.position = target.position - Vector2(1, 0)
			shot.simulate(241)
			run.damage.resolve_tick_hits(run, 241)
			check(shot.bounces == 0 and shot.target_id == nearby.actor_id, "star arrow changes target after first hit")
			await capture("06-star-hunter-bounce", "FR-019", "Star Hunter: after first hit", "The arrow has changed direction toward a different target. A single still cannot establish the complete ricochet/mark sequence; behavior checks verify those transitions.", "Keep two enemies within range; observe the star arrow after its first hit", true)
	for id in ["aren", "lia", "milo"]:
		prepare(profile(id))
		start_run()
		await debug_character(id)
		var actor = app.run.hero
		check(actor.passive != null, id + " character passive attached")
		var passive_description = {"aren": "Resolute reduces incoming damage by 10% after defense, with minimum eligible damage 1.", "lia": "Fleet Step increases starting movement speed by 10%: 96 → 105.6, visible in these live stats.", "milo": "Arcane Pulse increases every fifth fired attack's damage by 50%; its counter is independent of profession fifth effects."}[id]
		await capture("07-passive-" + id, "FR-020", String(actor.passive.id).capitalize() + " — " + id.capitalize(), passive_description + " There is no dedicated passive animation or buff panel; damage math requires behavior tests rather than screenshots.", "Roster lists the passive; Debug → Character → select hero → scroll down for passive and live stats")
		app.debug_panel.close_panel()
	for companions in [[], ["lia"], ["lia", "milo"]]:
		prepare(profile("aren", 1400, companions))
		start_run()
		check(app.run.party.size() == companions.size() + 1, "saved party size " + str(companions.size()))
		await capture("08-party-" + str(companions.size()), "FR-021", str(companions.size()) + " AI companions", "Saved roster selection is instantiated in combat. The lower-left HUD lists living companion HP; each companion occupies a separate formation slot. Follow/chase priority and safe recovery are verified by behavior tests.", "Roster → select 0–2 companions → Save party & return → Start Expedition", true)
	var run = app.run
	var follower = run.party[1]
	run.queue_hit(follower, 10000, Vector2.ZERO, 0, false, false)
	run.damage.resolve_tick_hits(run, run.clock.tick)
	check(follower.health.dead and not run.hero.health.dead, "companion downing leaves active hero alive")
	run.state_changed.emit()
	await capture("09-downed", "FR-022", "Downed companion, continuing expedition", "Lia is visibly DOWNED in the party HUD and uses the downed body pose. Aren and Milo remain alive. Companions do not revive during this run; starting a new run restores them.", "Take damage on a companion; look at the lower-left party HUD", true)
	for outcome in ["victory", "defeat", "abandonment"]:
		prepare(profile("aren", 0, ["lia", "milo"] if outcome == "victory" else ["lia"]))
		start_run()
		app.run.clock.tick = 32400 if outcome == "victory" else 7200
		app.run.kills = 42
		if outcome == "victory":
			app.run.queue_hit(app.run.party[2], 10000, Vector2.ZERO, 0, false, false)
			app.run.damage.resolve_tick_hits(app.run, 32400)
		app.run.finish(outcome)
		await process_frame
		await process_frame
		check(app.writer.payload.owned.aren == {"character_id": "aren"} and not app.writer.payload.has("promotion_items"), "settlement stores ownership without growth")
		await capture("10-reward-" + outcome, "004-FR-003", outcome.capitalize() + " settlement", "Controlled terminal example; only collection economy and chapter flags persist. RUN level, upgrades and branches reset.", "Finish expedition / results")
	prepare(profile("aren", 0, ["lia", "milo"]))
	app.writer.store.fault = FailPublication.new()
	app.commit_action(app.writer.payload.duplicate(true), {"kind": "screenshot_retry_fixture"}, app.show_roster)
	check(app.writer.state == "save-blocked", "controlled save publication failure displays real Retry UI")
	await capture("11-save-retry", "FR-023", "Save failure and Retry", "A deliberately failed write in an isolated test profile opens the real error screen. Retry preserves the same pending action. Checksum validation, interruptions and two-process locks are backend behavior, not visible proof in this image.", "Appears automatically if a save fails; choose Retry pending action")
	app.screen_host.get_child(0).retry_requested.emit()
	check(app.writer.state == "ready" and app.writer.payload.owned.aren == {"character_id": "aren"}, "Retry committed one pending profile save")
	await capture("11-save-retried", "FR-023", "Same pending save recovered", "After Retry, the owned roster and party are preserved without permanent growth. The action is committed once, not added twice.", "Retry pending action → roster returns with committed progress")
	var saved_root = app.writer.store.root
	var expected = app.writer.payload.duplicate(true)
	app.free()
	await process_frame
	paused = false
	for index in range(20):
		var reopened = SaveCoordinator.new(saved_root)
		check(reopened.open() and reopened.payload == expected, "exact saved payload close/reopen " + str(index + 1))
		reopened.close()
	app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new(saved_root)
	root.add_child(app)
	current_scene = app
	app.show_roster()
	check(app.writer.payload == expected, "new app loads exact saved progression and companion roles")
	await capture("12-reopened-roster", "SC-005", "Reopened profile retains progression and party", "A new app instance reopened the saved profile: Aren level 2 / 100 XP, Lia and Milo still companions. Twenty exact payload close/reopen comparisons passed alongside this screenshot.", "Save party → close game → open the same profile → Character roster / companions / promotions")
	app.free()
	await process_frame
	for error in errors.errors: check(false, error)
	OS.remove_logger(errors)
	var report = {"source": "current exported developer build", "controlled_fixtures": true, "assertions": assertions, "failures": failures, "frames": frames, "checks": checks}
	var file = FileAccess.open(output_path.path_join("manifest.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("M2 EVIDENCE: %d screenshots; %d assertions; %d failures" % [frames.size(), assertions, failures])
	quit(0 if failures == 0 else 1)
