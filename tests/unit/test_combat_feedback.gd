extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
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
