class_name MageBranchAttacks
extends RefCounted

static func fire(actor, run, tick: int, target, facing: Vector2, value: float) -> void:
	AttackExecutor.fire_shot(actor, run, tick, target, facing, value)
	var p = actor.profession
	if actor.activations % p.fifth_interval != 0: return
	if p.attack_policy == &"elemental_sage":
		run.delayed_impacts.append({"due": tick + 1, "target": target.actor_id, "damage": value, "radius": p.fifth_radius, "frost": true})
	else:
		create_zone(run, target.position, value, tick, p, true)

static func impact(shot, victim, tick: int) -> void:
	var p = shot.profession
	if p == null: return
	if p.attack_policy == &"elemental_sage" and shot.element == "fire":
		for actor in shot.run.enemies:
			if actor != victim and not actor.health.dead and actor.position.distance_to(victim.position) <= p.effect_radius:
				shot.run.queue_hit(actor, shot.damage * p.secondary_damage, Vector2.ZERO, 0, false, false)
		shot.run.create_warning(victim.position, "circle", p.effect_radius, Vector2.RIGHT, 360, tick + 10)
	elif p.attack_policy == &"void_caster":
		create_zone(shot.run, victim.position, shot.damage, tick, p, false)

static func create_zone(run, point: Vector2, value: float, tick: int, p: ProfessionDefinition, pull: bool) -> void:
	var zone = run.catalog.scene("pull_zone" if pull else "damage_zone").instantiate()
	zone.run = run
	zone.position = point
	zone.radius = p.effect_radius * (2.0 if pull else 1.0)
	zone.damage = value * p.secondary_damage
	zone.expires = tick + p.effect_ticks
	zone.next_tick = tick + p.effect_period
	zone.period = p.effect_period
	zone.pull_speed = p.pull_speed
	zone.pull = pull
	run.effects.add_child(zone)
