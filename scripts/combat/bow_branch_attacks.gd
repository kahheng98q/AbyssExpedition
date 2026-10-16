class_name BowBranchAttacks
extends RefCounted

static func fire(actor, run, tick: int, target, facing: Vector2, value: float) -> void:
	var p = actor.profession
	AttackExecutor.fire_shot(actor, run, tick, target, facing, value)
	if actor.activations % p.fifth_interval != 0: return
	if p.attack_policy == &"sharpshooter":
		for offset in [-p.volley_angle, 0.0, p.volley_angle]:
			AttackExecutor.fire_shot(actor, run, tick, target, facing.rotated(deg_to_rad(offset)), value)
	else:
		run.delayed_impacts.append({"due": tick + p.effect_period, "target": target.actor_id, "damage": value, "radius": 0.0})
		run.create_warning(target.position, "circle", 14, Vector2.RIGHT, 360, tick + p.effect_period)
