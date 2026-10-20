extends RefCounted

const SNAPSHOT_FORMAT = "pacing-final-v2"

var app
var run
var first: Dictionary = {"hit": -1, "kill": -1, "level": -1, "rush": -1, "shot": -1}
var pauses: Array = []

func bind(owner) -> void:
	app = owner
	run = app.run
	run.hit_confirmed.connect(on_hit)
	run.rush_started.connect(func(tick, _id):
		if first.rush < 0: first.rush = tick)
	run.hostile_shot_fired.connect(func(tick):
		if first.shot < 0: first.shot = tick)
	run.pause.changed.connect(on_pause)
	app.modal_host.child_entered_tree.connect(on_modal)
	on_pause(run.pause.snapshot())

func on_hit(_point: Vector2, _direction: Vector2, _amount: float, fatal: bool, friendly: bool) -> void:
	if friendly: return
	if first.hit < 0: first.hit = run.clock.tick
	if fatal and first.kill < 0: first.kill = run.clock.tick

func on_pause(state: Dictionary) -> void:
	pauses.append({"tick": run.clock.tick, "stage": run.simulation.stage, "tokens": state.duplicate(true)})

func on_modal(screen: Node) -> void:
	if screen.get_script() == load("res://scripts/ui/level_up.gd"):
		if screen.identity == run.choices.offer_id and screen.is_inside_tree() and first.level < 0:
			first.level = run.clock.tick

static func portable(value):
	if value is Vector2: return [value.x, value.y]
	if value is StringName: return String(value)
	if value is Array:
		return value.map(func(item): return portable(item))
	if value is Dictionary:
		var result = {}
		for key in value: result[str(key)] = portable(value[key])
		return result
	return value

static func values(object, names: Array) -> Dictionary:
	var result = {}
	for key in names:
		var value = object.get(key)
		result[key] = portable(value)
	return result

static func actor_state(actor) -> Dictionary:
	var result = values(actor, ["actor_id", "position", "knockback", "next_ready", "activations", "passive_activations", "bastion_interval", "last_passive_tick", "attack_until", "ai_state", "deadline", "aim", "parent_id", "dead_at", "blocked_ticks", "contract_bonuses"])
	result["health"] = values(actor.health, ["current", "maximum", "invulnerable_until", "hurt_until", "dead"])
	result["statuses"] = values(actor.statuses, ["burn_until", "next_burn", "burn_damage", "slow_until", "burn_period", "slow_fraction"])
	result["stats"] = values(actor.stats, ["max_health", "damage", "defense", "frequency", "speed", "reach", "pickup_radius", "knockback"])
	result["identity"] = {"definition":String(actor.definition.id),"profession":String(actor.profession.id) if actor.profession != null else "","passive":String(actor.passive.id) if actor.passive != null else ""}
	result["roles"] = values(actor,["is_hero","is_companion","companion_slot","is_boss","permanent_level","corrupted","resistant","resistance"])
	return result

static func warning_state(warning) -> Dictionary:
	if not is_instance_valid(warning): return {}
	return values(warning,["position","geometry","radius","direction","angle","expires","impact"])

func pending_state() -> Dictionary:
	var state = values(run.spawns,["reservation_serial","boss_pending","boss_placed","opening_origin","opening_initialized","disposed"])
	state["reservations"] = []
	for slot in run.spawns.reservations:
		var record = portable(run.spawns.trace_slot(slot))
		record["warning"] = warning_state(slot.warning)
		state.reservations.append(record)
	return state

func final_state() -> Dictionary:
	var result = {"tick": run.clock.tick, "stage": run.simulation.stage, "phase": run.phase, "kills": run.kills, "coins": run.coins, "corruption": run.corruption.value, "level": run.progression.level, "xp": run.progression.xp, "pending": run.progression.pending, "stacks": run.progression.stacks.duplicate(true), "sequence": run.sequence, "request_id": run.request_id, "party": [], "enemies": [], "projectiles": [], "pickups": [], "rng": {}}
	result["snapshot_format"] = SNAPSHOT_FORMAT
	result["spawns"] = pending_state()
	result["boss_hits"] = []
	for hit in run.boss_hits:
		var record = hit.duplicate()
		record["warning"] = warning_state(hit.warning)
		result.boss_hits.append(portable(record))
	result["corruption_last_minute"] = run.corruption.last_minute
	result["rescue"] = values(run.rescue,["state","center","elapsed","owned_at_start"])
	result["rescue_results"] = portable(run.rescue_results)
	result["pending_rewards"] = run.deaths.map(func(actor): return actor_state(actor))
	result["registry"] = run.registry.keys()
	result.registry.sort()
	result["boss_actor_id"] = run.boss_actor.actor_id if is_instance_valid(run.boss_actor) else -1
	result["pause_reasons"] = []
	for token in run.pause.snapshot().values(): result.pause_reasons.append(token)
	result.pause_reasons.sort_custom(func(a,b): return str(a.owner)+":"+str(a.reason) < str(b.owner)+":"+str(b.reason))
	for member in run.party: result.party.append(actor_state(member))
	var enemies = run.enemies.duplicate()
	enemies.sort_custom(func(a,b): return a.actor_id < b.actor_id)
	for enemy in enemies: result.enemies.append(actor_state(enemy))
	for shot in run.projectiles.get_children():
		if not shot.is_queued_for_deletion():
			var record = values(shot, ["position", "direction", "speed", "damage", "reach", "target_id", "expires", "homing", "hostile", "burn", "frost", "knockback", "hit_limit", "hit_ids", "bounces", "element"])
			record["profession"] = String(shot.profession.id) if shot.profession != null else ""
			result.projectiles.append(record)
	for gem in run.pickups.get_children():
		if not gem.collected: result.pickups.append(values(gem, ["pickup_id", "position", "value", "coins"]))
	result["followups"] = portable(run.followups)
	result["delayed_impacts"] = portable(run.delayed_impacts)
	result["damage_requests"] = portable(run.damage.requests)
	result["consumed_damage"] = portable(run.damage.consumed)
	result["activation_heals"] = portable(run.activation_heals)
	result["collected_pickups"] = portable(run.progression.pickups)
	result["offer"] = {"id": run.choices.offer_id, "options": portable(run.choices.offer)}
	result["events"] = {"next_slot": run.events.next_slot, "current": portable(run.events.current)}
	result["effects"] = []
	for effect in run.effects.get_children():
		if effect.is_queued_for_deletion(): continue
		var fields = {}
		for property in effect.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.name != "run":
				var value = effect.get(property.name)
				if not value is Object: fields[property.name] = portable(value)
		result.effects.append(fields)
	# RNG states are decimal strings: JSON numbers cannot preserve all 64 bits.
	for label in SeedStreams.LABELS: result.rng[label] = str(run.rng.stream(label).state)
	return result

func report() -> Dictionary:
	var counts = spawn_counts(run.trace.snapshot())
	var failures: Array = []
	for pair in [["hit", 300], ["kill", 600], ["level", 1800]]:
		if first[pair[0]] < 0: failures.append(pair[0] + "_missing")
		elif first[pair[0]] > pair[1]: failures.append(pair[0] + "_late")
	if run.hero.health.dead: failures.append("death")
	if run.clock.tick < 7260: failures.append("early_end")
	return {"first": first.duplicate(true), "counts": counts, "failures": failures, "trace": run.trace.snapshot(), "pauses": pauses.duplicate(true), "final": final_state()}

static func spawn_counts(trace: Dictionary) -> Dictionary:
	var counts = {}
	for event in trace.spawns: counts[event.result] = counts.get(event.result,0) + 1
	return counts

func complete_report(saved: Dictionary = {}) -> Dictionary:
	# Read counters only after the final run_end events have been recorded.
	# Terminal snapshots are captured synchronously before deferred scene cleanup.
	run.spawns.terminate(run)
	var result = report() if saved.is_empty() else saved.duplicate(true)
	result.trace = run.trace.snapshot()
	result.counts = spawn_counts(result.trace)
	return result

static func metadata_error(recorded: Dictionary, current: Dictionary) -> String:
	for key in ["session_id","hero","seed","engine","simulation","catalog","build_hash","fixture_hash","party","corruption","fixture_mode"]:
		if not recorded.has(key) or recorded[key] != JSON.parse_string(JSON.stringify(current.get(key))): return "metadata mismatch: " + key
	return ""

static func differences(expected, actual, path: String="") -> Array:
	var result: Array=[]
	if expected is Dictionary and actual is Dictionary:
		var keys=expected.keys()
		for key in actual:
			if not keys.has(key): keys.append(key)
		keys.sort()
		for key in keys:
			if not expected.has(key) or not actual.has(key): result.append({"path":path+"/"+str(key),"expected":expected.get(key),"actual":actual.get(key)})
			else: result.append_array(differences(expected[key],actual[key],path+"/"+str(key)))
			if result.size()>=256: return result.slice(0,256)
	elif expected is Array and actual is Array:
		if expected.size()!=actual.size(): result.append({"path":path+"/length","expected":expected.size(),"actual":actual.size()})
		for index in mini(expected.size(),actual.size()):
			result.append_array(differences(expected[index],actual[index],path+"/"+str(index)))
			if result.size()>=256: return result.slice(0,256)
	elif expected!=actual: result.append({"path":path,"expected":expected,"actual":actual})
	return result
