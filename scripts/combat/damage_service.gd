class_name DamageService
extends RefCounted

var requests: Array[Dictionary] = []
var consumed: Dictionary = {}
var generation: int = 0

static func amount(outgoing: float, defense: float, multiplier: float = 1.0) -> float:
	return maxf(1.0, (outgoing - defense) * multiplier)

func enqueue_hit(request: Dictionary) -> void:
	if request.generation == generation and not consumed.has(request.id):
		consumed[request.id] = true
		requests.append(request)

func resolve_tick_hits(run, tick: int) -> void:
	requests.sort_custom(func(a, b): return a.id < b.id)
	for hit in requests:
		var target = run.actor_by_id(hit.target)
		if target == null or target.health.dead: continue
		var value = amount(hit.damage, target.stats.defense, target.resistance * PassiveExecutor.incoming(target, tick))
		var health_before: float = target.health.current
		if target.health.receive(value, tick, target.is_hero):
			var role: StringName = &"companion" if target.is_companion else (&"hero" if target.is_hero else (&"boss" if target.is_boss else &"enemy"))
			var fact = {"generation":generation,"tick":tick,"request_id":hit.id,"target_id":target.actor_id,"target_role":role,"actual_damage":health_before-target.health.current,"fatal":target.health.dead}
			fact.make_read_only()
			run.damage_accepted.emit(fact)
			run.hit_confirmed.emit(target.position, hit.direction, health_before - target.health.current, target.health.dead, target.is_hero)
			PassiveExecutor.accepted_hit(target, tick)
			if not target.resistant:
				target.knockback += hit.direction * hit.get("knockback", 0.0)
			if not target.is_hero:
				if not target.health.dead: target.statuses.apply(hit, tick, run.catalog.upgrades[&"ember_touch"].effects[0], run.catalog.upgrades[&"frost_mark"].effects[0])
			if target.health.dead: run.mark_dead(target)
			if hit.has("heal_source"):
				var source = run.actor_by_id(hit.heal_source)
				var key = str(hit.heal_source) + ":" + str(hit.activation)
				if source != null and not source.health.dead and not run.activation_heals.has(key):
					var before_heal: float = source.health.current
					source.health.heal(source.health.maximum * hit.heal_fraction)
					run.activation_heals[key] = true
					var actual_heal: float = source.health.current - before_heal
					if fact.actual_damage > 0 and is_finite(actual_heal) and actual_heal > 0:
						var healed = {"generation": run.generation, "tick": tick, "source_id": source.actor_id, "is_companion": source.is_companion, "activation_id": hit.activation, "request_id": hit.id, "actual_heal": actual_heal, "source_position": Vector2(source.position)}
						healed.make_read_only()
						run.branch_heal_applied.emit(healed)
	requests.clear()
	# Keep accepted IDs for the run: a late duplicate can never damage again.
