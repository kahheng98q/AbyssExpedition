extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	var f = Fixture.create(t)
	var probe = load("res://tests/performance/benchmark_capture.gd").new()
	probe.run = f.run
	probe.catalog = f.catalog
	for i in range(501):
		var gem = f.catalog.scene("xp_gem").instantiate()
		gem.value = 10
		gem.coins = 1
		f.run.pickups.add_child(gem)
	probe.replenish()
	var normals = 0
	var bosses = 0
	for actor in f.run.enemies:
		if actor.health.dead: continue
		if actor.is_boss: bosses += 1
		else: normals += 1
	t.check(normals == 100 and bosses == 1, "benchmark replenishes a real living boss independently of normal count")
	var xp = 0
	var coins = 0
	var gems = 0
	for gem in f.run.pickups.get_children():
		if gem.is_queued_for_deletion(): continue
		gems += 1
		xp += gem.value
		coins += gem.coins
	t.check(gems == 500 and xp == 5010 and coins == 501, "fixture merging preserves every reward exactly")
	probe.free()
	Fixture.dispose(f)
