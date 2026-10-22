extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	for id in ["sera", "brann", "nyra"]:
		var branches = [""]
		for branch in ProfileData.BRANCHES:
			if ProfileData.BRANCHES[branch] == ProfileData.BASES[id]: branches.append(branch)
		for branch in branches:
			var p = ProfileData.fresh()
			p.owned[id] = OwnedHero.record(id, 1400, branch)
			p.active = id
			p.companions = ["aren", "lia"]
			var f = Fixture.create_party(t, p)
			f.run.progression.level = 15
			if branch != "": t.check(PromotionService.apply(f.run, id, branch), "live recruited branch")
			var a = f.run.hero
			t.check(String(a.passive.id) == ProfileData.PASSIVES[id], "new identity passive retained " + id + "/" + branch)
			if id == "nyra": t.check(is_equal_approx(a.stats.reach, a.profession.starting_stats.reach * 1.2), "Far Sight starting reach after promotion")
			if id == "brann":
				a.stats.defense = 5
				var hp = a.health.current
				for tick in [0, 45, 1200]:
					f.run.clock.tick = tick
					f.run.queue_hit(a, 25, Vector2.ZERO, 0, false, false)
					f.run.damage.resolve_tick_hits(f.run, tick)
				t.check(is_equal_approx(a.health.current, hp - 40), "Bastion first hit each fixed interval, later full post-defense damage")
			Fixture.dispose(f)
	var p = ProfileData.fresh()
	p.owned.sera = OwnedHero.record("sera")
	p.companions = ["sera", "lia"]
	var f = Fixture.create_party(t, p)
	var run = f.run
	for member in run.party: member.health.current = member.health.maximum * 0.5
	PassiveExecutor.periodic(run, 1199)
	t.check(run.hero.health.current == run.hero.health.maximum * 0.5, "Guiding Light waits full period")
	PassiveExecutor.periodic(run, 1200)
	t.check(is_equal_approx(run.hero.health.current, run.hero.health.maximum * 0.52), "Sera tie prioritizes active hero")
	PassiveExecutor.periodic(run, 1200)
	t.check(is_equal_approx(run.hero.health.current, run.hero.health.maximum * 0.52), "periodic heal once per deadline")
	PassiveExecutor.periodic(run, 2400)
	t.check(is_equal_approx(run.party[1].health.current, run.party[1].health.maximum * 0.52), "next tie selects first companion slot")
	run.party[1].health.dead = true
	var hp = run.party[2].health.current
	PassiveExecutor.periodic(run, 3600)
	t.check(run.party[2].health.current == hp, "downed Sera cannot heal")
	run.party[1].health.dead = false
	for member in run.party: member.health.current = member.health.maximum
	PassiveExecutor.periodic(run, 4800)
	var full = true
	for member in run.party:
		if member.health.current != member.health.maximum: full = false
	t.check(full, "full party produces no overheal")
	run.hero.health.current = run.hero.health.maximum * 0.5
	run.party[2].health.dead = true
	run.party[2].health.current = 0
	PassiveExecutor.periodic(run, 6000)
	t.check(run.party[2].health.dead and run.party[2].health.current == 0 and is_equal_approx(run.hero.health.current, run.hero.health.maximum * 0.52), "Guiding Light skips downed targets and never revives")
	Fixture.dispose(f)
	p = ProfileData.fresh()
	p.owned.brann = OwnedHero.record("brann")
	p.active = "brann"
	f = Fixture.create_party(t, p)
	var a = f.run.hero
	a.health.invulnerable_until = 1201
	f.run.clock.tick = 1200
	f.run.queue_hit(a, 20, Vector2.ZERO, 0, false, false)
	f.run.damage.resolve_tick_hits(f.run, 1200)
	t.check(a.bastion_interval == -1, "ignored immune hit cannot consume Bastion")
	f.run.clock.tick = 1201
	f.run.queue_hit(a, 20, Vector2.ZERO, 0, false, false)
	f.run.damage.resolve_tick_hits(f.run, 1201)
	t.check(a.bastion_interval == 1 and a.health.current == a.health.maximum - 10, "first eligible hit after immunity receives reduction")
	f.run.clock.tick = 2399
	var pause_token = f.run.pause.acquire("manual", "test")
	for i in range(120): f.run.simulation.advance(f.run, Vector2.ZERO)
	t.check(f.run.clock.tick == 2399 and a.bastion_interval == 1 and PassiveExecutor.incoming(a, f.run.clock.tick) == 1.0, "pause cannot reset Bastion or advance its fixed active interval")
	f.run.pause.release(pause_token, "test")
	Fixture.dispose(f)
