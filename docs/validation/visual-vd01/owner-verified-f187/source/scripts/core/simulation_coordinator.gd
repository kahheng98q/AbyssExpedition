class_name SimulationCoordinator
extends RefCounted

var stage: int = 0

func advance(run, direction: Vector2) -> void:
	if run.phase != "active" or run.pause.is_blocked(): return
	var tick = run.clock.tick
	if stage == 0:
		run.trace.record_movement(tick, direction.limit_length(1.0))
		PlayerController.simulate(run.hero, direction)
		for member in run.party.slice(1): CompanionController.simulate(member, run)
		for actor in run.enemies.duplicate(): EnemyController.simulate(actor, run, tick)
		for shot in run.projectiles.get_children():
			if not shot.is_queued_for_deletion(): shot.simulate(tick)
		for effect in run.effects.get_children():
			if effect.has_method("simulate") and not effect.is_queued_for_deletion(): effect.simulate(tick)
		for impact in run.delayed_impacts.duplicate():
			if tick < impact.due: continue
			var target = run.actor_by_id(impact.target)
			if target != null and not target.health.dead:
				for actor in run.enemies:
					if actor == target or (impact.radius > 0 and actor.position.distance_to(target.position) <= impact.radius):
						run.queue_hit(actor, impact.damage, Vector2.ZERO, 0, false, impact.get("frost", false))
				run.create_warning(target.position, "circle", maxf(14, impact.radius), Vector2.RIGHT, 360, tick + 10)
			run.delayed_impacts.erase(impact)
		for hit in run.boss_hits.duplicate():
			if tick < hit.due: continue
			var source = run.actor_by_id(hit.source)
			if source != null and not source.health.dead:
				for member in run.party:
					if not member.health.dead and hit.warning.contains(member.position): run.queue_hit(member, hit.damage, hit.warning.direction, 70, false, false)
				hit.warning.impact = true
				hit.warning.expires = tick + 12
				hit.warning.queue_redraw()
				source.ai_state = "recovery"
			else: hit.warning.queue_free()
			run.boss_hits.erase(hit)
		stage = 1
	if stage == 1:
		run.damage.resolve_tick_hits(run, tick)
		if run.hero.health.dead:
			run.finish("defeat")
			return
		if run.boss_actor != null and run.boss_actor.health.dead:
			run.finish("victory")
			return
		stage = 2
	if stage == 2:
		run.corruption.advance(tick)
		PassiveExecutor.periodic(run, tick)
		run.rescue.advance(run.hero.position, not run.hero.health.dead)
		run.drop_rewards()
		for gem in run.pickups.get_children():
			if gem.collected: continue
			if run.hero.position.distance_to(gem.position) <= run.hero.stats.pickup_radius:
				gem.collected = true
				run.coins += gem.coins
				run.progression.collect_xp(gem.pickup_id, gem.value)
				gem.queue_free()
		stage = 3
	if stage == 3:
		run.choices.present(run)
		if run.pause.is_blocked(): return
		stage = 4
	if stage == 4:
		run.choices.present_rescue(run)
		if run.pause.is_blocked(): return
		run.spawns.simulate(run, tick)
		if tick < 32400 and tick % 600 == 0: run.spawns.schedule_wave(run, tick)
		for followup in run.followups.duplicate():
			if tick >= followup.due:
				run.create_arc(followup, tick)
				run.followups.erase(followup)
		AttackExecutor.try_activate(run.hero, run, tick)
		for member in run.party.slice(1): AttackExecutor.try_activate(member, run, tick)
		run.cleanup_effects(tick)
		run.clock.advance_one_tick()
		stage = 0
		run.state_changed.emit()
