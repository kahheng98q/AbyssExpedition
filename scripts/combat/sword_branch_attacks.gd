class_name SwordBranchAttacks
extends RefCounted

static func fire(actor, run, tick: int, facing: Vector2, value: float) -> void:
	var p = actor.profession
	var hit = {"origin": actor.position, "direction": facing, "reach": actor.stats.reach, "angle": p.weapon.arc_angle, "damage": value, "knockback": actor.stats.knockback, "burn": run.progression.has(&"ember_touch"), "frost": run.progression.has(&"frost_mark")}
	var fifth = actor.activations % p.fifth_interval == 0
	if p.attack_policy == &"abyss_swordsman" and fifth:
		hit.merge({"heal_source": actor.actor_id, "activation": actor.activations, "heal_fraction": p.heal_fraction})
	attach_visual(actor, run, hit, tick, &"primary" if p.attack_policy == &"swordmaster" else &"base")
	run.create_arc(hit, tick)
	run.effects.get_child(-1).color = p.visual_set.palette
	if p.attack_policy == &"swordmaster":
		var second = hit.duplicate()
		second.direction = facing.rotated(deg_to_rad(20))
		second.damage *= p.secondary_damage
		attach_visual(actor, run, second, tick, &"secondary")
		run.create_arc(second, tick)
		if fifth:
			var spin = hit.duplicate()
			spin.angle = 360.0
			spin.reach = p.effect_radius
			attach_visual(actor, run, spin, tick, &"spin")
			run.create_arc(spin, tick)

static func attach_visual(actor, run, hit: Dictionary, tick: int, kind: StringName) -> void:
	var visual = SwordPresentation.arc_visual(run.generation, actor.actor_id, actor.activations, actor.profession.id, actor.profession.visual_set.sword_identity, kind, hit, tick)
	if not visual.is_empty(): hit["sword_visual"] = visual
