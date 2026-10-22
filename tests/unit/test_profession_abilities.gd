extends RefCounted

const Fixture = preload("res://tests/fixtures/run_fixture.gd")

class ZeroLossHealth extends ActorHealth:
	func receive(_value: float, _tick: int, _hero: bool) -> bool:
		return true

func fixture(t, branch: String) -> Dictionary:
	var p = ProfileData.fresh()
	var id = "aren" if ProfileData.BRANCHES[branch] == "swordsman" else ("lia" if ProfileData.BRANCHES[branch] == "archer" else "milo")
	p.active = id
	p.owned[id] = OwnedHero.record(id, 1400, branch)
	return Fixture.create_party(t, p)

func run(t) -> void:
	check_branch_heal_facts(t)
	await check_sword_presentation(t)
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

func check_sword_presentation(t) -> void:
	var path = "res://scripts/combat/sword_presentation.gd"
	t.check(FileAccess.file_exists(path), "shared sword renderer exposes pure pose geometry")
	if FileAccess.file_exists(path):
		var drawing = load(path)
		t.check(drawing.state_for(true, true, true, true) == &"death", "death overrides hurt/attack/movement")
		t.check(drawing.state_for(false, true, true, true) == &"hurt", "hurt overrides attack/movement")
		t.check(drawing.state_for(false, false, true, true) == &"attack", "attack overrides movement")
		t.check(drawing.state_for(false, false, false, true) == &"move" and drawing.state_for(false, false, false, false) == &"idle", "move and idle remain distinct")
		var single = drawing.weapon_segments(&"single", &"idle", Vector2.RIGHT, 0, 0)
		var dual = drawing.weapon_segments(&"dual", &"idle", Vector2.RIGHT, 0, 0)
		var long_blade = drawing.weapon_segments(&"long", &"idle", Vector2.RIGHT, 0, 0)
		t.check(single.size() == 1 and dual.size() == 2 and long_blade.size() == 1, "single/dual/long keep grayscale geometry distinction")
		t.check(long_blade[0][0].distance_to(long_blade[0][1]) > single[0][0].distance_to(single[0][1]), "long blade is geometrically longer without color")
	for hero in ["aren", "brann"]:
		for companion in [false, true]:
			for branch in ["swordsman", "swordmaster", "abyss_swordsman"]:
				var payload = ProfileData.fresh()
				payload.owned[hero] = OwnedHero.record(hero, 1400, branch if branch != "swordsman" else "")
				payload.active = "lia" if companion else hero
				payload.companions = [hero] if companion else []
				var f = Fixture.create_party(t, payload)
				var run = f.run
				var actor = run.party[1] if companion else run.hero
				var victim = run.spawn_enemy(&"shellbound_husk", actor.position + Vector2(20, 0))
				victim.health = ActorHealth.new(100000)
				var rear = run.spawn_enemy(&"shellbound_husk", actor.position - Vector2(20, 0))
				rear.health = ActorHealth.new(100000)
				run.progression.stacks[&"echo_strike"] = 1
				for activation in range(1, 7):
					run.clock.tick = activation * 50
					actor.next_ready = 0
					var before: int = run.effects.get_child_count()
					t.check(AttackExecutor.try_activate(actor, run, run.clock.tick) and actor.activations == activation, "one real activation per attack " + hero + "/" + branch)
					var arcs = run.effects.get_children().slice(before)
					t.check(arcs.size() == (3 if activation == 5 else 2) if branch == "swordmaster" else arcs.size() == 1, "fourth/fifth/sixth real arc count " + branch)
					var has_visual = arcs[0].get_property_list().any(func(item): return item.name == "sword_visual")
					t.check(has_visual, "actual sword arc has isolated presentation metadata")
					if has_visual:
						var visual = arcs[0].get("sword_visual")
						t.check(visual.is_read_only() and visual.source_id == actor.actor_id and visual.activation_id == activation and visual.born_tick == run.clock.tick and visual.expires_tick == run.clock.tick + 10, "metadata is immutable and tied to real source/activation/tick")
						if branch == "swordmaster":
							t.check(is_equal_approx(rad_to_deg(arcs[0].direction.angle_to(arcs[1].direction)), 20), "both real arcs retain simultaneous 0/+20 degree geometry")
							if activation == 5: t.check(arcs[2].angle == 360 and arcs[2].get("sword_visual").arc_kind == &"spin", "fifth is complete 360 spin")
					run.damage.resolve_tick_hits(run, run.clock.tick)
				var followup = run.followups[0]
				t.check(not followup.has("heal_source"), "Echo cannot inherit branch heal permission")
				t.check(followup.has("sword_visual"), "Echo preserves original sword activation identity")
				actor.health.dead = true
				var activations: int = actor.activations
				run.create_arc(followup, followup.due)
				t.check(actor.activations == activations, "source death/Echo drawing adds no activation")
				Fixture.dispose(f)
	var stage = Fixture.create(t)
	var victim = stage.run.spawn_enemy(&"shellbound_husk", stage.run.hero.position + Vector2(20, 0))
	victim.health = ActorHealth.new(10000)
	stage.run.simulation.advance(stage.run, Vector2.ZERO)
	t.check(victim.health.current == 10000 and not stage.run.damage.requests.is_empty(), "stage4 attack queues existing next-tick damage")
	stage.run.simulation.advance(stage.run, Vector2.ZERO)
	t.check(victim.health.current < 10000, "next tick stage1 applies original queued damage")
	Fixture.dispose(stage)
	var fast = Fixture.create(t)
	fast.run.hero.stats.frequency = 100
	var durable = fast.run.spawn_enemy(&"shellbound_husk", fast.run.hero.position + Vector2(20, 0))
	durable.health = ActorHealth.new(1000000)
	for ignored in range(20): fast.run.simulation.advance(fast.run, Vector2.ZERO)
	t.check(fast.run.hero.activations == 20 and fast.run.hero.next_ready == 20, "high frequency uses real one-tick cooldown without animation gating")
	t.check(fast.run.effects.get_children().filter(func(effect): return not effect.is_queued_for_deletion()).size() <= 12, "high frequency arcs retain the original ten-tick cleanup bound")
	Fixture.dispose(fast)

func check_branch_heal_facts(t) -> void:
	var probe = Fixture.create(t)
	var supported: bool = probe.run.has_signal("branch_heal_applied")
	t.check(supported, "actual branch healing publishes an immutable result fact")
	Fixture.dispose(probe)
	if not supported: return
	for hero in ["aren", "brann"]:
		for companion in [false, true]:
			var profile = ProfileData.fresh()
			profile.owned[hero] = OwnedHero.record(hero, 1400, "abyss_swordsman")
			profile.active = "lia" if companion else hero
			profile.companions = [hero] if companion else []
			var f = Fixture.create_party(t, profile)
			var r = f.run
			var actor = r.party[1] if companion else r.hero
			var facts: Array = []
			r.connect("branch_heal_applied", func(fact): facts.append(fact))
			var victims: Array = []
			for offset in [20, 24]:
				var victim = r.spawn_enemy(&"shellbound_husk", actor.position + Vector2(offset, 0))
				victim.health = ActorHealth.new(100000)
				victims.append(victim)
			for activation in [4, 5, 6, 10, 15, 20]:
				r.clock.tick = activation * 50
				actor.next_ready = 0
				actor.activations = activation - 1
				var missing: float = 1.25 if activation == 10 else (0.0 if activation == 15 else 10.0)
				actor.health.current = actor.health.maximum - missing
				var hp: float = actor.health.current
				var before = facts.size()
				t.check(AttackExecutor.try_activate(actor, r, r.clock.tick), "real branch attack commits " + str(activation))
				if activation == 20: victims[0].health.current = 1 # lethal accepted damage still qualifies
				r.damage.resolve_tick_hits(r, r.clock.tick)
				var expected: float = minf(missing, actor.health.maximum * actor.profession.heal_fraction) if activation % 5 == 0 else 0.0
				t.check(is_equal_approx(actor.health.current - hp, expected), "unchanged full companion/base heal and actual HP clipping " + str(activation))
				t.check(facts.size() - before == (1 if expected > 0 else 0), "one positive fact only for a successful fifth " + str(activation))
				if expected > 0:
					var fact = facts[-1]
					t.check(fact.is_read_only() and fact.generation == r.generation and fact.tick == r.clock.tick and fact.source_id == actor.actor_id and fact.is_companion == companion and fact.activation_id == activation and fact.request_id > 0 and is_equal_approx(fact.actual_heal, expected) and fact.source_position == actor.position, "result fact is immutable, exact, attributed and unclipped by display rounding")
				if activation == 15:
					actor.health.current -= 10
					var hit = {"origin": actor.position, "direction": Vector2.RIGHT, "reach": 64.0, "angle": 100.0, "damage": 36.0, "knockback": 0.0, "burn": false, "frost": false, "heal_source": actor.actor_id, "activation": 15, "heal_fraction": 0.02}
					r.create_arc(hit, r.clock.tick)
					r.damage.resolve_tick_hits(r, r.clock.tick)
					t.check(actor.health.current == actor.health.maximum - 10 and facts.size() == before, "full-health fifth consumes key; later injury cannot retry healing")
			var before = facts.size()
			actor.health.current = actor.health.maximum - 10
			actor.activations = 24
			actor.next_ready = 0
			r.clock.tick = 1250
			for victim in victims:
				if not victim.health.dead: victim.health.invulnerable_until = 2000
			AttackExecutor.try_activate(actor, r, r.clock.tick)
			r.damage.resolve_tick_hits(r, r.clock.tick)
			t.check(facts.size() == before and actor.health.current == actor.health.maximum - 10, "rejected hits emit no success and do not heal")
			var saved = r.enemies.duplicate()
			r.enemies.clear()
			actor.next_ready = 0
			var count: int = actor.activations
			t.check(not AttackExecutor.try_activate(actor, r, 1300) and actor.activations == count and facts.size() == before, "no target is no activation/heal fact")
			r.enemies.assign(saved)
			for victim in victims:
				if not victim.health.dead: victim.health.invulnerable_until = -1
			actor.activations = 29
			actor.next_ready = 0
			r.clock.tick = 1500
			AttackExecutor.try_activate(actor, r, 1500)
			actor.health.dead = true
			r.damage.resolve_tick_hits(r, 1500)
			t.check(facts.size() == before and actor.health.dead, "queued accepted damage never heals/revives a dead source")
			Fixture.dispose(f)
	var boundary = fixture(t, "abyss_swordsman")
	var r = boundary.run
	var facts: Array = []
	r.connect("branch_heal_applied", func(fact): facts.append(fact))
	r.hero.health.current = 100
	r.hero.activations = 4
	r.progression.stacks[&"echo_strike"] = 1
	var zero = r.spawn_enemy(&"shellbound_husk", r.hero.position + Vector2(20, 0))
	zero.health = ZeroLossHealth.new(1000)
	AttackExecutor.try_activate(r.hero, r, 0)
	r.damage.resolve_tick_hits(r, 0)
	t.check(facts.is_empty(), "synthetic accepted zero-loss target cannot create a success fact; original heal path remains unchanged")
	zero.health = ActorHealth.new(1000)
	r.hero.health.current = 100
	r.clock.tick = r.followups[0].due
	r.create_arc(r.followups[0], r.clock.tick)
	r.damage.resolve_tick_hits(r, r.clock.tick)
	t.check(facts.is_empty() and r.hero.health.current == 100 and r.hero.activations == 5, "real Echo damages but never grants a new heal or activation")
	r.damage.enqueue_hit({"generation": r.generation - 1, "id": 99999, "target": zero.actor_id, "damage": 100.0, "direction": Vector2.RIGHT, "heal_source": r.hero.actor_id, "activation": 10, "heal_fraction": 0.02})
	t.check(r.damage.requests.is_empty() and facts.is_empty(), "old-generation damage cannot produce branch healing")
	Fixture.dispose(boundary)
