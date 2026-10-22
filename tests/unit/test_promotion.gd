extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	for id in ProfileData.BASES:
		for branch in ProfileData.BRANCHES:
			if ProfileData.BRANCHES[branch] != ProfileData.BASES[id]: continue
			var p = ProfileData.fresh()
			p.owned[id] = OwnedHero.record(id)
			p.active = id
			var f = Fixture.create_party(t, p)
			var run = f.run
			var actor = run.hero
			run.progression.level = 14
			t.check(not PromotionService.apply(run, id, branch), "Lv14 rejects " + id + branch)
			run.progression.level = 15
			actor.health.current = actor.health.maximum * 0.4
			actor.next_ready = 127
			actor.activations = 4
			actor.passive_activations = 9
			actor.contract_bonuses = {"damage": 0.15}
			UpgradeEffects.apply(f.catalog.upgrades[&"might"], actor, run.progression)
			t.check(not PromotionService.apply(run, id, "") and not PromotionService.apply(run, id, "unknown"), "invalid branches no mutation")
			t.check(PromotionService.apply(run, id, branch), "Lv15 promotes " + id + branch)
			t.check(actor.profession.id == StringName(branch) and actor.passive == actor.definition.passive, "profession and passive")
			t.check(is_equal_approx(actor.health.current / actor.health.maximum, 0.4), "live HP ratio retained")
			t.check(is_equal_approx(actor.stats.damage, actor.starting_stats.damage * 1.25), "upgrades and contract derived once")
			t.check(actor.next_ready == 127 and actor.activations == 4 and actor.passive_activations == 9, "cooldown and counters preserved")
			t.check(not PromotionService.apply(run, id, branch) and p.owned[id] == {"character_id": id}, "once per run, no profile mutation")
			var screen = f.catalog.scene("promotion").instantiate()
			screen.catalog = f.catalog
			screen.payload = p
			screen.selected = branch
			var submits = [0]
			screen.confirmed.connect(func(_id, _branch, _revision): submits[0] += 1)
			t.root.add_child(screen)
			screen.submit()
			t.check(submits[0] == 0 and screen.branch_previews.size() == 2, "gallery previews cannot commit")
			screen.free()
			Fixture.dispose(f)
	await t.process_frame
