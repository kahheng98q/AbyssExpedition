extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var progression = RunProgression.new()
	t.check(progression.collect_xp(1, 650), "XP consumed")
	t.check(progression.level == 4 and progression.xp == 50 and progression.pending == 3, "multi-level overflow preserved")
	t.check(not progression.collect_xp(1, 650), "pickup consumed once")
	var f = Fixture.create(t)
	var run = f.run
	var catalog = f.catalog.upgrades
	t.check(catalog.size() == 12, "twelve upgrade definitions")
	var capped: Dictionary = {}
	for definition in catalog.values():
		if definition.max_stacks > 0: capped[definition.id] = definition.max_stacks
	var eligible = UpgradeOfferService.eligible(catalog, capped)
	t.check(eligible.size() == 3 and eligible.has(&"battle_mend") and eligible.has(&"might") and eligible.has(&"vitality"), "useful uncapped fallback trio: " + str(eligible))
	t.check(String(eligible[0]) == "battle_mend" and String(eligible[1]) == "might" and String(eligible[2]) == "vitality", "eligibility is explicitly lexicographic")
	var rng = SeedStreams.new(202)
	for i in range(20):
		var offer = UpgradeOfferService.sample(catalog, {}, rng.stream("upgrade_offers"))
		t.check(offer.size() == 3 and offer[0] != offer[1] and offer[0] != offer[2] and offer[1] != offer[2], "three distinct eligible offers")
	run.hero.health.current = 50
	UpgradeEffects.apply(catalog[&"vitality"], run.hero, run.progression)
	t.check(run.hero.health.maximum == 275 and run.hero.health.current == 75, "Vitality heals exact added starting-health amount")
	UpgradeEffects.apply(catalog[&"might"], run.hero, run.progression)
	UpgradeEffects.apply(catalog[&"battle_mend"], run.hero, run.progression)
	t.check(is_equal_approx(run.hero.stats.damage, 41.4), "percent damage modifiers add against baseline")
	t.check(run.hero.health.current == 130, "Battle Mend heals 20% current maximum")
	for id_value in [&"quick_hands", &"reach", &"ironhide", &"swift_boots", &"magnet", &"force"]:
		UpgradeEffects.apply(catalog[id_value], run.hero, run.progression)
	t.check(is_equal_approx(run.hero.stats.frequency, 1.32), "Quick Hands +10% frequency")
	t.check(is_equal_approx(run.hero.stats.reach, 55.2), "Reach +15%")
	t.check(run.hero.stats.defense == 1, "Ironhide flat defense")
	t.check(is_equal_approx(run.hero.stats.speed, 105.6), "Boots +10%")
	t.check(run.hero.stats.pickup_radius == 30 and run.hero.stats.knockback == 96, "Magnet +25%; Force +20%")
	t.check(f.catalog.characters[&"aren"].base_profession.starting_stats.damage == 36, "definition never mutated")
	var status = StatusEffects.new()
	status.apply({"damage": 20.0, "burn": true, "frost": true}, 0)
	status.apply({"damage": 30.0, "burn": true}, 30)
	t.check(status.next_burn == 60 and status.burn_until == 210 and status.burn_damage == 3, "burn refresh does not stack/reset tick deadline")
	t.check(status.speed_multiplier(119, false) == 0.8 and status.speed_multiplier(120, false) == 1, "frost 20% / 120 ticks")
	t.check(status.speed_multiplier(1, true) == 1, "resistant enemy ignores slow")
	Fixture.dispose(f)
