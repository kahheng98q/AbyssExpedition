extends RefCounted

const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func fixture(t, branch: String) -> Dictionary:
	var p = ProfileData.fresh()
	var id = "aren" if ProfileData.BRANCHES[branch] == "swordsman" else ("lia" if ProfileData.BRANCHES[branch] == "archer" else "milo")
	p.active = id
	p.owned[id] = OwnedHero.record(id, 1400, branch)
	return Fixture.create_party(t, p)

func run(t) -> void:
	for branch in ProfileData.BRANCHES:
		var f = fixture(t, branch)
		var run = f.run
		var actor = run.hero
		t.check(actor.profession.id == StringName(branch) and actor.passive == actor.definition.passive, "factory uses promoted class and retains identity passive " + branch)
		t.check(is_equal_approx(actor.stats.max_health, actor.profession.starting_stats.max_health * 1.28), "permanent HP starting scale " + branch)
		t.check(not AttackExecutor.try_activate(actor, run, 0) and actor.activations == 0 and actor.passive_activations == 0, "no-target preserves both counters " + branch)
		var victim = run.spawn_enemy(&"saltbound_thrall", actor.position + Vector2(20, 0))
		victim.health = ActorHealth.new(10000)
		var rear = run.spawn_enemy(&"saltbound_thrall", actor.position + Vector2(-35, 0))
		rear.health = ActorHealth.new(10000)
		for i in range(5):
			actor.next_ready = 0
			AttackExecutor.try_activate(actor, run, i * 50)
			run.damage.resolve_tick_hits(run, i * 50)
		t.check(actor.activations == 5 and actor.passive_activations == 5, "one independent counter increment per fired attack " + branch)
		match branch:
			"swordmaster":
				t.check(run.effects.get_child_count() == 11 and rear.health.current < 10000, "two arcs per activation plus one fifth full-circle hit")
			"abyss_swordsman":
				actor.health.current = 100
				actor.activations = 9
				actor.next_ready = 0
				AttackExecutor.try_activate(actor, run, 250)
				run.damage.resolve_tick_hits(run, 250)
				t.check(is_equal_approx(actor.health.current, 100 + actor.health.maximum * 0.02), "fifth spectral activation heals once on accepted damage")
				actor.health.current = 100
				victim.health.invulnerable_until = 1000
				actor.activations = 14
				actor.next_ready = 0
				AttackExecutor.try_activate(actor, run, 300)
				run.damage.resolve_tick_hits(run, 300)
				t.check(actor.health.current == 100, "immune hit cannot trigger healing")
			"sharpshooter":
				t.check(run.projectiles.get_child_count() == 8, "fifth adds exactly three arrows alongside regular attack")
				var shot = run.projectiles.get_child(0)
				t.check(shot.hit_limit == 3, "pierce limit configured")
				for index in range(3):
					var target = victim if index == 0 else run.spawn_enemy(&"saltbound_thrall", actor.position + Vector2(40 + index * 20, 0))
					target.health = ActorHealth.new(1000)
					shot.position = target.position - Vector2(1, 0)
					shot.simulate(index + 1)
					run.damage.resolve_tick_hits(run, index + 1)
					t.check(target.health.current < 1000, "piercing arrow actually damages distinct target " + str(index))
				t.check(shot.hit_ids.size() == 3 and shot.is_queued_for_deletion(), "arrow ends at three distinct hits")
			"star_hunter":
				var shot = run.projectiles.get_child(0)
				shot.position = victim.position - Vector2(1, 0)
				shot.simulate(1)
				t.check(shot.bounces == 0 and shot.target_id == rear.actor_id and shot.expires == 180, "ricochet chooses different nearby living target without extending expiry")
				shot.position = rear.position + Vector2(1, 0)
				shot.direction = Vector2.LEFT
				shot.simulate(2)
				t.check(shot.hit_ids == [victim.actor_id, rear.actor_id] and shot.is_queued_for_deletion(), "ricochet ends after second distinct enemy")
				t.check(run.delayed_impacts.size() == 1 and run.delayed_impacts[0].due == 230, "fifth adds one delayed marked impact")
				for projectile in run.projectiles.get_children(): projectile.queue_free()
				victim.health.dead = true
				run.registry.erase(victim.actor_id)
				run.clock.tick = 230
				run.simulation.advance(run, Vector2.ZERO)
				t.check(run.delayed_impacts.is_empty(), "dead marked target cancels delayed impact")
			"elemental_sage":
				var fire = run.projectiles.get_child(0)
				var frost = run.projectiles.get_child(1)
				t.check(fire.element == "fire" and frost.element == "frost", "alternating fire/frost activations")
				t.check(is_equal_approx(run.projectiles.get_child(4).damage, actor.stats.damage * 1.5), "Milo fifth passive combines with promoted fifth effect")
				var splash = run.spawn_enemy(&"saltbound_thrall", victim.position + Vector2(0, 20))
				fire.position = victim.position - Vector2(1, 0)
				fire.simulate(1)
				t.check(run.damage.requests.size() == 2, "fire impact queues target plus nearby splash")
				run.damage.resolve_tick_hits(run, 1)
				frost.position = victim.position - Vector2(1, 0)
				frost.simulate(51)
				run.damage.resolve_tick_hits(run, 51)
				t.check(victim.statuses.slow_until == 171, "frost impact applies two active seconds of slow")
				t.check(run.delayed_impacts.size() == 1 and run.delayed_impacts[0].radius == 48, "fifth burst uses larger radius")
				var _unused = splash
			"void_caster":
				var shot = run.projectiles.get_child(0)
				shot.position = victim.position - Vector2(1, 0)
				shot.simulate(1)
				t.check(run.effects.get_child_count() == 2, "regular impact zone and fifth pull zone coexist")
				var pull = run.effects.get_child(0)
				var zone = run.effects.get_child(1)
				var point = victim.position
				pull.position = point + Vector2(20, 0)
				pull.simulate(201)
				t.check(victim.position.x > point.x, "pull actually moves susceptible enemy")
				victim.resistant = true
				point = victim.position
				pull.simulate(202)
				t.check(victim.position == point, "armored enemy resists pull")
				run.damage.requests.clear()
				zone.simulate(31)
				t.check(not run.damage.requests.is_empty() and actor.activations == 5, "zone ticks damage without advancing attack counters")
				zone.simulate(121)
				t.check(zone.is_queued_for_deletion(), "damage zone has finite immutable active expiry")
		# Extra shots/arcs never increment either activation counter.
		run.progression.stacks[&"echo_strike"] = 2
		actor.next_ready = 0
		var before = actor.activations
		var before_passive = actor.passive_activations
		AttackExecutor.try_activate(actor, run, 400)
		t.check(actor.activations == before + 1 and actor.passive_activations == before_passive + 1, "Echo never advances either counter per child attack " + branch)
		if actor.definition.base_profession.id == &"swordsman":
			actor.health.invulnerable_until = -1
			actor.stats.defense = 5
			var hp = actor.health.current
			run.queue_hit(actor, 15, Vector2.ZERO, 0, false, false)
			run.damage.resolve_tick_hits(run, 900)
			t.check(is_equal_approx(actor.health.current, hp - 9), "Resolute remains effective after promotion " + branch)
		elif actor.definition.base_profession.id == &"archer":
			t.check(is_equal_approx(actor.starting_stats.speed, 105.6), "Fleet Step remains effective after promotion " + branch)
		else:
			t.check(is_equal_approx(run.projectiles.get_child(4).damage, actor.starting_stats.damage * 1.5), "Arcane Pulse remains effective after promotion " + branch)
		Fixture.dispose(f)
	var independent = fixture(t, "elemental_sage")
	var mage = independent.run.hero
	independent.run.spawn_enemy(&"saltbound_thrall", mage.position + Vector2(20, 0))
	mage.activations = 4
	mage.passive_activations = 3
	AttackExecutor.try_activate(mage, independent.run, 0)
	t.check(independent.run.delayed_impacts.size() == 1 and independent.run.projectiles.get_child(0).damage == mage.stats.damage, "branch fifth can fire independently of passive fifth")
	mage.activations = 3
	mage.passive_activations = 4
	mage.next_ready = 0
	AttackExecutor.try_activate(mage, independent.run, 50)
	t.check(independent.run.delayed_impacts.size() == 1 and independent.run.projectiles.get_child(1).damage == mage.stats.damage * 1.5, "passive fifth can fire independently of branch fifth")
	Fixture.dispose(independent)
	# Passive math is independent of profession and applied after defense.
	var p = ProfileData.fresh()
	var f = Fixture.create_party(t, p)
	f.run.hero.stats.defense = 5
	f.run.queue_hit(f.run.hero, 15, Vector2.ZERO, 0, false, false)
	f.run.damage.resolve_tick_hits(f.run, 0)
	t.check(is_equal_approx(f.run.hero.health.current, 241), "Resolute reduces post-defense incoming damage by ten percent")
	t.check(DamageService.amount(0, 5, PassiveExecutor.incoming(f.run.hero)) == 1, "Resolute minimum eligible damage remains one")
	Fixture.dispose(f)
	p.active = "lia"
	f = Fixture.create_party(t, p)
	t.check(is_equal_approx(f.run.hero.stats.speed, 105.6), "Fleet Step adds ten percent starting speed")
	Fixture.dispose(f)
