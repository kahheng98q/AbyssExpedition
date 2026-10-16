extends RefCounted

const Speed = preload("res://scripts/debug/battle_speed_controller.gd")
const ACTIONS = [
	["level_one", "+1 permanent level", "Character", "_level_one", false],
	["level_ten", "+10 permanent levels", "Character", "_level_ten", false],
	["level_max", "Maximum permanent level", "Character", "_level_max", false],
	["character_xp", "Add permanent XP", "Character", "_character_xp", false],
	["run_xp", "Add XP to shared run", "Character", "_run_xp", true],
	["heal_character", "Fully heal selected character", "Character", "_heal_character", true],
	["cooldowns", "Reset selected cooldowns", "Character", "_cooldowns", true],
	["invincible", "Toggle active invincibility", "Character", "_invincible", true],
	["spawn", "Spawn enemies", "Combat", "_spawn", true],
	["boss", "Spawn chapter boss", "Combat", "_boss", true],
	["kill_all", "Kill all enemies", "Combat", "_kill_all", true],
	["clear_projectiles", "Clear enemy projectiles", "Combat", "_clear_projectiles", true],
	["heal_team", "Heal entire living team", "Combat", "_heal_team", true],
	["god_mode", "Toggle team god mode", "Combat", "_god_mode", true],
	["restart", "Restart run / same seed", "Combat", "_restart", true],
	["speed", "Battle speed", "Combat", "_speed", true],
	["add_companion", "Add selected companion", "Combat", "_add_companion", true],
	["remove_companion", "Remove selected companion", "Combat", "_remove_companion", true],
	["heal_companions", "Heal living companions", "Combat", "_heal_companions", true],
	["companion_ai", "Toggle selected companion AI", "Combat", "_companion_ai", true],
	["materials", "Grant promotion materials", "Progression", "_materials", false],
	["eligibility", "Grant promotion requirements", "Progression", "_eligibility", false],
	["test_branch", "Test branch / this run only", "Progression", "_test_branch", true],
	["save_test", "Save sandbox profile", "System", "_save_test", false],
	["load_test", "Reload sandbox profile", "System", "_load_test", false],
	["retry_save", "Retry pending sandbox save", "System", "_retry_save", false],
	["collisions", "Toggle collision shapes", "System", "_collisions", true],
	["end_sandbox", "Discard session / normal menu", "System", "_end_sandbox", false]
]
var app
var normal_writer: SaveCoordinator
var writer: SaveCoordinator
var active: bool = false
var clone_prepared: bool = false
var speed = Speed.new()
var actions: Dictionary = {}
var logs: Array[String] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var xp_serial: int = 0
var god_mode: bool = false
var collision_prior: bool = false
var collision_changed: bool = false
var runtime_branches: Dictionary = {}
var next_companion_id: int = -100

func _init() -> void:
	for entry in ACTIONS: register_action(entry[0], Callable(self, entry[3]), entry[4])

func register_action(id: String, handler: Callable, requires_run: bool = false) -> bool:
	if not OS.has_feature("debug") or actions.has(id): return false
	actions[id] = {"handler": handler, "requires_run": requires_run}
	return true

func bind(router) -> void:
	app = router

func current_run():
	if app != null and is_instance_valid(app.run) and app.run.phase == "active": return app.run
	return null

func ensure_session() -> Dictionary:
	if not OS.has_feature("debug"): return result(false, "Developer actions are disabled in release builds.")
	if app == null: return result(false, "Application is unavailable.")
	if active: return result(true, "Sandbox is active.")
	if app.writer.state != "ready": return result(false, "Resolve the normal profile error before opening debug.")
	if normal_writer == null: normal_writer = app.writer
	if writer == null:
		writer = SaveCoordinator.new("user://tests/developer-%d-%d/" % [OS.get_process_id(), Time.get_ticks_usec()])
	if writer.state != "ready":
		var ok = writer.retry() if not writer.pending_bytes.is_empty() else writer.open()
		if not ok: return result(false, "Sandbox creation failed: " + writer.error)
	if not clone_prepared:
		clone_prepared = true
		if not writer.mutate(normal_writer.payload, writer.revision(), writer.operation_id(), {"kind": "debug_session"}):
			return result(false, "Sandbox clone pending: " + writer.error)
	app.writer = writer
	active = true
	rng.seed = app.last_snapshot.seed_value if app.last_snapshot != null else int(writer.payload.seed)
	return result(true, "Isolated debug profile created. Normal progress will not change.")

func available(id: String, args: Dictionary = {}) -> bool:
	if not OS.has_feature("debug") or not active or not actions.has(id): return false
	if id in ["retry_save", "end_sandbox"]: return true
	if writer.state != "ready": return false
	if actions[id].requires_run and current_run() == null: return false
	if id in ["heal_character", "cooldowns", "test_branch"]:
		var actor = actor_for(character_id(args))
		return actor != null and not actor.health.dead
	if id in ["remove_companion", "companion_ai"]:
		var actor = actor_for(String(args.get("companion_id", character_id(args))))
		return actor != null and actor.is_companion and (id == "remove_companion" or not actor.health.dead)
	if id == "add_companion":
		var run = current_run()
		var target = String(args.get("companion_id", character_id(args)))
		return run.party.size() < 3 and writer.payload.owned.has(target) and actor_for(target) == null
	return true

func execute(id: String, args: Dictionary = {}) -> Dictionary:
	if not OS.has_feature("debug"): return result(false, "Developer actions are disabled in release builds.")
	if not available(id, args): return result(false, "Action unavailable; open a ready sandbox and its required living target/run.")
	var outcome = actions[id].handler.call(args)
	record(id, outcome)
	return outcome

func result(ok: bool, message: String) -> Dictionary:
	return {"ok": ok, "message": message}

func record(id: String, outcome: Dictionary) -> void:
	var run = current_run()
	logs.append("%s · %s · %s" % [run.clock.display_time() if run != null else "menu", id, outcome.message])
	if logs.size() > 20: logs.pop_front()

func character_id(args: Dictionary) -> String:
	return String(args.get("character_id", writer.payload.active))

func member_for(id: String) -> Dictionary:
	var h = writer.payload.owned[id]
	return {"id": id, "level": int(h.level), "profession": h.promotion_id if h.promotion_id != "" else ProfileData.BASES[id], "passive": ProfileData.PASSIVES[id]}

func actor_for(id: String):
	var run = current_run()
	if run != null:
		for actor in run.party:
			if String(actor.definition.id) == id: return actor
	return null

func refresh_party() -> void:
	if not OS.has_feature("debug") or not active: return
	var run = current_run()
	if run == null: return
	for actor in run.party:
		var id = String(actor.definition.id)
		var member = member_for(id)
		if runtime_branches.has(id): member.profession = runtime_branches[id]
		CharacterFactory.configure_progression(actor, member)
		UpgradeEffects.derive(actor, run.progression)
		actor.health.current = minf(actor.health.current, actor.health.maximum)
	run.state_changed.emit()

func commit(candidate: Dictionary, message: String) -> Dictionary:
	if not OS.has_feature("debug") or not active or writer == null or not writer.store.root.begins_with("user://tests/"):
		return result(false, "Isolated debug writer required.")
	if candidate.is_empty(): return result(false, "Invalid character or reward.")
	if not writer.mutate(candidate, writer.revision(), writer.operation_id(), {"kind": "debug_action", "description": message}):
		return result(false, "Sandbox save pending; Retry before continuing: " + writer.error)
	refresh_party()
	return result(true, message + " (sandbox only)")

func add_xp(args: Dictionary, amount: int) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var id = character_id(args)
	var candidate = PermanentProgression.add_character_xp(writer.payload, id, amount)
	if candidate.is_empty(): return result(false, "Invalid character or reward.")
	var before = writer.payload.owned[id]
	var after = candidate.owned[id]
	var message = "%s: permanent Lv %d → %d · XP %d → %d" % [id.capitalize(), before.level, after.level, before.total_xp, after.total_xp]
	if int(after.level) == 30: message += " · maximum level 30"
	return commit(candidate, message)

func _level_one(args: Dictionary) -> Dictionary: return add_xp(args, 100)
func _level_ten(args: Dictionary) -> Dictionary: return add_xp(args, 1000)
func _level_max(args: Dictionary) -> Dictionary: return add_xp(args, 2900)
func _character_xp(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	if not ProfileValidator.integer(args.get("amount", 100), 1, 1000000): return result(false, "XP must be a whole amount from 1 to 1000000.")
	return add_xp(args, int(args.get("amount", 100)))

func _run_xp(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	if not ProfileValidator.integer(args.get("amount", 100), 1, 1000000): return result(false, "Run XP must be a whole amount from 1 to 1000000.")
	var run = current_run()
	xp_serial += 1
	run.progression.collect_xp(-1000000 - xp_serial, int(args.get("amount", 100)))
	run.choices.present(run)
	run.state_changed.emit()
	return result(true, "Shared run Lv %d · XP %d / %d · %d pending upgrades. Close debug to choose upgrades." % [run.progression.level, run.progression.xp, run.progression.level * 100, run.progression.pending])

func _heal_character(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var actor = actor_for(character_id(args))
	if actor == null or actor.health.dead: return result(false, "Selected character is not living in this party. Revival is unsupported.")
	actor.health.heal(actor.health.maximum)
	current_run().state_changed.emit()
	return result(true, "Selected character fully healed.")

func _cooldowns(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var actor = actor_for(character_id(args))
	if actor == null or actor.health.dead: return result(false, "Selected character is not living in this party.")
	actor.next_ready = current_run().clock.tick
	return result(true, "Attack cooldown reset; activation counters are preserved.")

func _invincible(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var hero = current_run().hero
	hero.health.debug_invincible = not hero.health.debug_invincible
	return result(true, "Active invincibility " + ("ON" if hero.health.debug_invincible else "OFF"))

func _spawn(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var id = StringName(args.get("enemy_id", "saltbound_thrall"))
	var count = args.get("count", 1)
	var run = current_run()
	if not run.catalog.enemies.has(id) or count not in [1, 10, 50, 100]: return result(false, "Choose a registered enemy and count 1/10/50/100.")
	var reserved = 0
	for _index in range(int(count)):
		for _attempt in range(16):
			if run.spawns.reserve(run, id, SpawnDirector.edge_candidate(rng), run.clock.tick):
				reserved += 1
				break
	run.state_changed.emit()
	return result(reserved > 0, "Reserved %d/%d enemies; resume for the 45-tick warnings. Cap/safety rules apply." % [reserved, count])

func _boss(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var run = current_run()
	if run.boss_actor != null or run.spawns.boss_pending or run.spawns.boss_placed: return result(false, "Boss already present or scheduled.")
	for slot in run.spawns.reservations:
		if slot.boss: return result(false, "Boss warning already pending.")
	for point in [Vector2(480, 48), Vector2(912, 270), Vector2(480, 492), Vector2(48, 270), Vector2(48, 48), Vector2(912, 492)]:
		if run.spawns.reserve(run, run.catalog.boss.id, point, run.clock.tick, -1, true):
			run.spawns.boss_placed = true
			return result(true, "Chapter boss reserved with its existing warning and spawn logic.")
	return result(false, "No safe boss position. Clear space and try again.")

func _kill_all(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var run = current_run()
	var pending: Array[Dictionary] = run.damage.requests.duplicate()
	run.damage.requests.clear()
	var count = 0
	for actor in run.enemies.duplicate():
		if actor.health.dead: continue
		run.request_id += 1
		run.damage.enqueue_hit({"id": run.request_id, "generation": run.generation, "target": actor.actor_id, "damage": (actor.health.current + 1) / actor.resistance + actor.stats.defense, "direction": Vector2.ZERO})
		count += 1
	run.damage.resolve_tick_hits(run, run.clock.tick)
	run.damage.requests.append_array(pending)
	run.drop_rewards()
	for slot in run.spawns.reservations:
		if is_instance_valid(slot.warning): slot.warning.queue_free()
	run.spawns.reservations.clear()
	run.state_changed.emit()
	return result(true, "Killed %d enemies through DamageService. Boss victory resolves on resume." % count)

func _clear_projectiles(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var count = 0
	for shot in current_run().projectiles.get_children():
		if shot.hostile:
			shot.queue_free()
			count += 1
	return result(true, "Cleared %d hostile projectiles; friendly shots retained." % count)

func _heal_team(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	for actor in current_run().party: actor.health.heal(actor.health.maximum)
	current_run().state_changed.emit()
	return result(true, "Living team fully healed; downed actors cannot revive.")

func _heal_companions(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	for actor in current_run().party.slice(1): actor.health.heal(actor.health.maximum)
	current_run().state_changed.emit()
	return result(true, "Living companions fully healed.")

func _god_mode(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	god_mode = not god_mode
	for actor in current_run().party: actor.health.debug_god_mode = god_mode
	return result(true, "Team god mode " + ("ON" if god_mode else "OFF"))

func _speed(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	if args.get("speed", 1) not in [1, 2, 4]: return result(false, "Battle speed must be 1x, 2x or 4x.")
	return result(speed.set_speed(int(args.get("speed", 1))), "Battle speed %sx; active ticks remain 60 per simulation second." % args.get("speed", 1))

func _restart(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var run = current_run()
	var seed_value = run.snapshot.seed_value
	var ids: Array = []
	for actor in run.party.slice(1): ids.append(String(actor.definition.id))
	var selected = RosterService.selection(writer.payload, String(run.hero.definition.id), ids, seed_value)
	var saved = commit(selected, "Restart selection saved")
	if not saved.ok: return saved
	app.mount_saved_run(seed_value)
	return result(true, "Restarted with seed %d; temporary modifiers reset." % seed_value)

func _add_companion(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var id = String(args.get("companion_id", character_id(args)))
	var run = current_run()
	if not writer.payload.owned.has(id): return result(false, "Companion is not owned.")
	if run.party.size() >= 3: return result(false, "Party limit: one active hero and two companions.")
	if actor_for(id) != null: return result(false, "Character is already in the party.")
	var member = member_for(id)
	if runtime_branches.has(id): member.profession = runtime_branches[id]
	var companion = CharacterFactory.create(run.catalog.characters[StringName(id)], run, run.party.size(), member)
	var identity = next_companion_id
	next_companion_id -= 1
	companion.actor_id = identity
	companion.companion_slot = run.party.size() - 1
	companion.position = CompanionController.formation(run.hero.position, companion.companion_slot)
	companion.health.debug_god_mode = god_mode
	run.actors.add_child(companion)
	run.party.append(companion)
	run.registry[identity] = companion
	if not CompanionController.relocate(companion, run):
		run.party.erase(companion)
		run.registry.erase(identity)
		companion.queue_free()
		return result(false, "No safe companion placement; clear space and try again.")
	UpgradeEffects.derive(companion, run.progression)
	companion.health.current = companion.health.maximum
	run.state_changed.emit()
	return result(true, "Added owned companion to this run only.")

func _remove_companion(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var actor = actor_for(String(args.get("companion_id", character_id(args))))
	if actor == null or not actor.is_companion: return result(false, "Select a deployed companion.")
	var run = current_run()
	run.party.erase(actor)
	run.registry.erase(actor.actor_id)
	actor.queue_free()
	for index in range(1, run.party.size()): run.party[index].companion_slot = index - 1
	run.state_changed.emit()
	return result(true, "Removed companion from this run only.")

func _companion_ai(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var actor = actor_for(String(args.get("companion_id", character_id(args))))
	if actor == null or not actor.is_companion: return result(false, "Select a deployed companion.")
	actor.debug_ai_enabled = not actor.debug_ai_enabled
	return result(true, "Companion movement and attacks " + ("ON" if actor.debug_ai_enabled else "OFF"))

func _materials(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var amount = args.get("materials", 1)
	if not ProfileValidator.integer(amount, 1, 1000000) or writer.payload.promotion_items > ProfileData.MAX_INTEGER - int(amount): return result(false, "Invalid material amount or balance overflow.")
	var next = writer.payload.duplicate(true)
	next.promotion_items += int(amount)
	return commit(next, "Promotion materials granted")

func _eligibility(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var id = character_id(args)
	if not writer.payload.owned.has(id): return result(false, "Select an owned character.")
	var h = writer.payload.owned[id]
	var next = PermanentProgression.add_character_xp(writer.payload, id, maxi(0, 1400 - int(h.total_xp)))
	next.promotion_items = maxi(1, int(next.promotion_items))
	return commit(next, "Level 15/material requirements granted; production rules unchanged")

func _test_branch(args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	var id = character_id(args)
	var branch = String(args.get("branch", ""))
	if not ProfileData.BASES.has(id) or not ProfileData.BRANCHES.has(branch) or ProfileData.BRANCHES[branch] != ProfileData.BASES[id]: return result(false, "Branch must belong to this character's base class.")
	runtime_branches[id] = branch
	refresh_party()
	return result(true, "Testing " + branch.capitalize() + " in this run only; saved class/requirements unchanged.")

func promote(id: String, branch: String, revision: int) -> Dictionary:
	if not OS.has_feature("debug") or not active or writer.state != "ready": return result(false, "Promotion unavailable.")
	var ok = PromotionService.confirm(writer, id, branch, revision, writer.operation_id())
	if ok: refresh_party()
	var outcome = result(ok, "Promoted to " + branch.capitalize() + " in sandbox." if ok else writer.error)
	record("promotion", outcome)
	return outcome

func _save_test(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	return commit(writer.payload, "Sandbox profile saved")

func _load_test(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	if not writer.open(): return result(false, "Sandbox load blocked: " + writer.error)
	refresh_party()
	return result(true, "Sandbox profile reloaded. Temporary run state is not resumed.")

func _retry_save(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	if writer.pending_bytes.is_empty(): return result(false, "No pending sandbox save.")
	if not writer.retry(): return result(false, writer.error)
	refresh_party()
	return result(true, "Same pending sandbox action committed once.")

func _collisions(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	if not collision_changed:
		collision_prior = app.get_tree().debug_collisions_hint
		collision_changed = true
	app.get_tree().debug_collisions_hint = not app.get_tree().debug_collisions_hint
	return result(true, "Collision shape visualization toggled.")

func _end_sandbox(_args: Dictionary) -> Dictionary:
	if not OS.has_feature("debug") or not active: return result(false, "Developer action disabled.")
	app.leave_run()
	app.writer = normal_writer
	writer.close()
	writer = null
	normal_writer = null
	active = false
	clone_prepared = false
	app.show_menu()
	return result(true, "Sandbox ended. Normal profile restored without debug progress.")

func on_run_exit() -> void:
	if not OS.has_feature("debug"): return
	speed.reset()
	var run = current_run()
	if run != null:
		for actor in run.party:
			actor.health.debug_invincible = false
			actor.health.debug_god_mode = false
			actor.debug_ai_enabled = true
	god_mode = false
	runtime_branches.clear()
	next_companion_id = -100
	if collision_changed and is_instance_valid(app):
		app.get_tree().debug_collisions_hint = collision_prior
		collision_changed = false

func shutdown() -> void:
	if not OS.has_feature("debug"): return
	on_run_exit()
	if writer != null: writer.close()
	if normal_writer != null: normal_writer.close()
