class_name AttackExecutor
extends RefCounted

static func cooldown(frequency: float) -> int:
	return maxi(1, ceili(60.0 / frequency))

static func try_activate(actor, run, tick: int) -> bool:
	if OS.has_feature("debug") and actor.is_companion and not actor.debug_ai_enabled: return false
	if actor.health.dead or tick < actor.next_ready: return false
	var target = TargetingService.nearest(actor.position, actor.stats.reach, run.enemies)
	if target == null: return false
	var weapon = actor.profession.weapon
	var facing = actor.position.direction_to(target.position)
	actor.aim = facing
	actor.activations += 1
	actor.next_ready = tick + cooldown(actor.stats.frequency)
	actor.attack_until = tick + 12
	var value = actor.stats.damage * PassiveExecutor.activation_damage(actor) * (0.5 if actor.is_companion else 1.0)
	var policy = actor.profession.attack_policy
	if policy in [&"swordmaster", &"abyss_swordsman"]: SwordBranchAttacks.fire(actor, run, tick, facing, value)
	elif policy in [&"sharpshooter", &"star_hunter"]: BowBranchAttacks.fire(actor, run, tick, target, facing, value)
	elif policy in [&"elemental_sage", &"void_caster"]: MageBranchAttacks.fire(actor, run, tick, target, facing, value)
	var echo = run.catalog.upgrades[&"echo_strike"].effects[0]
	var extras = int(echo.amount) * run.progression.stacks.get(&"echo_strike", 0)
	for i in range(1 + extras):
		if i == 0 and policy != &"base": continue
		if weapon.mode == "arc":
			if i == 0: fire_arc(actor, run, tick, facing, value / actor.stats.damage)
			else: run.followups.append({"due": tick + i * echo.followup_ticks, "origin": actor.position, "direction": facing, "reach": actor.stats.reach, "angle": weapon.arc_angle, "damage": value * echo.secondary_scale, "knockback": actor.stats.knockback, "burn": run.progression.has(&"ember_touch"), "frost": run.progression.has(&"frost_mark")})
		else:
			fire_shot(actor, run, tick, target, facing, value, facing.orthogonal() * (i * 6 - extras * 3))
	var fact = {"generation":run.generation,"tick":tick,"source_id":actor.actor_id,"is_companion":actor.is_companion,"weapon_mode":StringName(weapon.mode),"activation_id":actor.activations}
	fact.make_read_only()
	run.attack_committed.emit(fact)
	return true

static func fire_shot(actor, run, tick: int, target, facing: Vector2, value: float, offset: Vector2 = Vector2.ZERO) -> void:
	var weapon = actor.profession.weapon
	var shot = run.catalog.scene("projectile").instantiate()
	shot.run = run
	shot.position = actor.position + offset
	shot.direction = facing
	shot.speed = weapon.speed
	shot.damage = value
	shot.reach = actor.stats.reach
	shot.target_id = target.actor_id
	shot.homing = weapon.mode == "homing"
	shot.expires = tick + weapon.lifetime_ticks
	shot.knockback = actor.stats.knockback
	shot.burn = run.progression.has(&"ember_touch")
	shot.frost = run.progression.has(&"frost_mark")
	shot.profession = actor.profession
	if actor.profession.attack_policy == &"sharpshooter": shot.hit_limit = actor.profession.pierce_limit
	if actor.profession.attack_policy == &"star_hunter": shot.bounces = 1
	if actor.profession.attack_policy == &"elemental_sage":
		shot.element = "fire" if actor.activations % 2 else "frost"
		shot.frost = shot.frost or shot.element == "frost"
	run.projectiles.add_child(shot)

static func fire_arc(actor, run, tick: int, direction: Vector2, scale: float) -> void:
	run.create_arc({"origin": actor.position, "direction": direction, "reach": actor.stats.reach, "angle": actor.profession.weapon.arc_angle, "damage": actor.stats.damage * scale, "knockback": actor.stats.knockback, "burn": run.progression.has(&"ember_touch"), "frost": run.progression.has(&"frost_mark")}, tick)
