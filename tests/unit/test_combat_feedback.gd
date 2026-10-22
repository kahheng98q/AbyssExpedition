extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	check_healing_feedback(t)
	var f = Fixture.create(t)
	var run = f.run
	var feedback = run.get_node("CombatWorld/CombatFeedback")
	var enemy = run.spawn_enemy(&"saltbound_thrall", run.hero.position + Vector2(30, 0))
	var rng_before: int = run.rng.stream("upgrade_offers").state
	run.queue_hit(enemy, 1000, Vector2.RIGHT, 0, false, false)
	run.damage.resolve_tick_hits(run, 0)
	t.check(feedback.bursts.size() == 1 and feedback.bursts[0].fatal, "accepted lethal damage emits one kill feedback")
	t.check(feedback.bursts[0].amount == 35, "feedback shows actual health removed, not overkill")
	run.queue_hit(run.hero, 5, Vector2.LEFT, 0, false, false)
	run.damage.resolve_tick_hits(run, 0)
	t.check(feedback.bursts.size() == 2 and feedback.bursts[1].friendly, "hero damage is separately marked")
	run.queue_hit(run.hero, 5, Vector2.LEFT, 0, false, false)
	run.damage.resolve_tick_hits(run, 0)
	t.check(feedback.bursts.size() == 2, "immune hits do not invent feedback")
	var token = run.pause.acquire("test", "test")
	for i in range(4):
		run.simulation.advance(run, Vector2.RIGHT)
		await t.process_frame
	t.check(run.clock.tick == 0 and feedback.bursts.size() == 2, "pause freezes the feedback clock and lifetime")
	run.pause.release(token, "test")
	for i in range(200): feedback.on_hit(Vector2(i, 0), Vector2.RIGHT, 2, false, false)
	t.check(feedback.bursts.size() == 48, "dense combat has a hard 48-record feedback bound")
	t.check(run.rng.stream("upgrade_offers").state == rng_before, "presentation consumes no gameplay random state")
	run.clock.tick = 36
	await t.process_frame
	await t.process_frame
	t.check(feedback.bursts.is_empty(), "feedback expires after 36 active ticks")
	var ref = weakref(feedback)
	Fixture.dispose(f)
	t.check(ref.get_ref() == null, "feedback is destroyed with the expedition")

func healing_fact(run, source, activation: int, amount: float, generation_offset: int = 0) -> Dictionary:
	var fact = {"generation": run.generation + generation_offset, "tick": run.clock.tick, "source_id": source.actor_id, "is_companion": source.is_companion, "activation_id": activation, "request_id": activation, "actual_heal": amount, "source_position": Vector2(source.position)}
	fact.make_read_only()
	return fact

func check_healing_feedback(t) -> void:
	var p = ProfileData.fresh()
	p.owned.brann = OwnedHero.record("brann", 1400, "abyss_swordsman")
	p.companions = ["brann", "lia"]
	var f = Fixture.create_party(t, p)
	var r = f.run
	r.progression.level = 15
	t.check(PromotionService.apply(r, "brann", "abyss_swordsman"), "live feedback companion branch")
	var feedback = r.get_node("CombatWorld/CombatFeedback")
	var supported = feedback.get_property_list().any(func(item): return item.name == "heal_records") and feedback.has_method("on_branch_heal")
	t.check(supported, "healing owns a separate bounded exact-value feedback collection")
	if not supported: Fixture.dispose(f); return
	var formatter = load("res://scripts/combat/combat_feedback.gd")
	for value in [0.001, 0.049, 0.05, 0.14999, 0.15, 1.24999, 1.25, 6.4]:
		var text: String = formatter.format_heal(value)
		t.check(text.begins_with("+") and absf(text.substr(1).to_float() - value) <= 0.050001, "one-decimal actual heal error bound " + str(value))
	t.check(formatter.format_heal(0.001) == "+0.0", "small real positive amount is not inflated to 0.1")
	var hero = r.hero
	feedback.call("on_branch_heal", healing_fact(r, hero, 5, 2.0))
	t.check(feedback.get("heal_records").size() == 1 and feedback.get("heal_records")[hero.actor_id].actual_heal == 2.0, "positive real amount retained without rounding")
	for amount in [0.0, -1.0, INF, NAN]: feedback.call("on_branch_heal", healing_fact(r, hero, 10, amount))
	feedback.call("on_branch_heal", healing_fact(r, hero, 10, 3.0, -1))
	feedback.call("on_branch_heal", healing_fact(r, hero, 5, 9.0))
	feedback.call("on_branch_heal", healing_fact(r, hero, 4, 9.0))
	t.check(feedback.get("heal_records")[hero.actor_id].actual_heal == 2.0, "invalid/old/duplicate/out-of-order facts never replace display")
	feedback.call("on_branch_heal", healing_fact(r, hero, 10, 1.25))
	t.check(feedback.get("heal_records").size() == 1 and feedback.get("heal_records")[hero.actor_id].actual_heal == 1.25, "same source replaces; amounts are never accumulated")
	for member in r.party.slice(1): feedback.call("on_branch_heal", healing_fact(r, member, 5, 0.01))
	t.check(feedback.get("heal_records").size() == 3 and feedback.bursts.is_empty(), "at most three party records, independent of damage budget")
	var companion = r.party[1]
	companion.position += Vector2(13, 7)
	t.check(feedback.call("heal_position", companion.actor_id) == companion.position, "feedback follows current companion position")
	var token = r.pause.acquire("manual", "healing-test")
	for ignored in range(3): r.simulation.advance(r, Vector2.RIGHT); feedback.call("_process", 0.0)
	t.check(r.clock.tick == 0 and feedback.get("heal_records").size() == 3, "pause freezes active-time ages")
	feedback.call("on_branch_heal", healing_fact(r, hero, 15, 4.0))
	r.pause.release(token, "healing-test")
	feedback.call("on_branch_heal", healing_fact(r, hero, 15, 4.0))
	t.check(feedback.get("heal_records")[hero.actor_id].actual_heal == 1.25, "paused facts are dropped, never replayed after resume")
	companion.health.dead = true
	feedback.call("_process", 0.0)
	t.check(not feedback.get("heal_records").has(companion.actor_id), "death clears healing immediately even without a new tick")
	r.registry.erase(r.party[2].actor_id)
	feedback.call("_process", 0.0)
	t.check(not feedback.get("heal_records").has(r.party[2].actor_id), "departed source clears without waiting for another tick")
	r.clock.tick = 36
	feedback.call("_process", 0.0)
	t.check(feedback.get("heal_records").is_empty(), "36 active ticks expires all healing records")
	feedback.call("on_branch_heal", healing_fact(r, hero, 20, 1.0))
	r.finish("abandonment")
	t.check(feedback.get("heal_records").is_empty(), "terminal run clears healing synchronously")
	Fixture.dispose(f)
	var restarted = Fixture.create(t)
	restarted.run.generation = 2
	var fresh_feedback = restarted.run.get_node("CombatWorld/CombatFeedback")
	fresh_feedback.call("on_branch_heal", healing_fact(restarted.run, restarted.run.hero, 5, 2.0, -1))
	t.check(fresh_feedback.get("heal_records").is_empty(), "restart cannot accept old-generation healing")
	Fixture.dispose(restarted)
