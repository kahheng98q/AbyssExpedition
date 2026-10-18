class_name SwordBranchAttacks
extends RefCounted

static func fire(actor, run, tick: int, facing: Vector2, value: float) -> void:
	var p = actor.profession
	var hit = {"origin": actor.position, "direction": facing, "reach": actor.stats.reach, "angle": p.weapon.arc_angle, "damage": value, "knockback": actor.stats.knockback, "burn": run.progression.has(&"ember_touch"), "frost": run.progression.has(&"frost_mark")}
	var fifth = actor.activations % p.fifth_interval == 0
	if p.attack_policy == &"abyss_swordsman" and fifth:
		hit.merge({"heal_source": actor.actor_id, "activation": actor.activations, "heal_fraction": p.heal_fraction})
	run.create_arc(hit, tick)
	run.effects.get_child(-1).color = p.visual_set.palette
	if p.attack_policy == &"swordmaster":
		var second = hit.duplicate()
		second.direction = facing.rotated(deg_to_rad(20))
		second.damage *= p.secondary_damage
		run.create_arc(second, tick)
		if fifth:
			var spin = hit.duplicate()
			spin.angle = 360.0
			spin.reach = p.effect_radius
			run.create_arc(spin, tick)
