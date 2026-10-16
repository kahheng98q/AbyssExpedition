extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var f = Fixture.create(t)
	var changed = f.catalog.upgrades[&"battle_mend"].duplicate(true)
	for effect in changed.effects:
		if effect.kind == &"heal": effect.amount = 0.1
	f.catalog.upgrades[&"battle_mend"] = changed
	f.run.hero.health.current = 1
	UpgradeEffects.apply(changed, f.run.hero, f.run.progression)
	t.check(is_equal_approx(f.run.hero.health.current, 26), "Battle Mend healing reads its configured fraction")
	t.check(changed.has_method("effect_preview") and String(changed.call("effect_preview")).contains("10%"), "preview reads the same configured healing fraction")
	var burn_upgrade = f.catalog.upgrades[&"ember_touch"]
	var original = burn_upgrade.effects[0]
	var burn = original.duplicate(true)
	burn.amount = 0.6
	burn.duration_ticks = 120
	var status = StatusEffects.new()
	status.apply({"damage": 20.0, "burn": true}, 0, burn)
	t.check(status.burn_until == 120 and is_equal_approx(status.burn_damage, 6), "burn snapshots configured total and duration")
	Fixture.dispose(f)
