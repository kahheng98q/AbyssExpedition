extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	for origin in [Vector2(8, 8), Vector2(8, 532), Vector2(952, 8), Vector2(952, 532), Vector2(8, 270), Vector2(952, 270), Vector2(480, 8), Vector2(480, 532)]:
		var left = CompanionController.formation(origin, 0)
		var right = CompanionController.formation(origin, 1)
		t.check(left.distance_to(origin) >= 16 and right.distance_to(origin) >= 16 and left.distance_to(right) >= 16, "edge/corner formation remains distinct: " + str(origin))
		t.check(left.distance_to(origin) <= 32 and right.distance_to(origin) <= 32, "edge/corner formation stays near hero")
	var p = ProfileData.fresh()
	for members in [[], ["lia"], ["lia", "milo"]]:
		t.check(ProfileValidator.party(p, "aren", members) == "", "0/1/2 distinct owned companions")
	for members in [["aren"], ["lia", "lia"], ["lia", "milo", "aren"], ["sera"], [1]]:
		t.check(ProfileValidator.party(p, "aren", members) != "", "invalid party rejected " + str(members))
	p.companions = ["lia", "milo"]
	var f = Fixture.create_party(t, p)
	var run = f.run
	t.check(run.party.size() == 3 and run.registry.has(-1) and run.registry.has(-2), "stable separate active/companion actor IDs")
	var a = run.party[1]
	var b = run.party[2]
	t.check(a.position != b.position and a.position.distance_to(run.hero.position) <= 32 and b.position.distance_to(run.hero.position) <= 32, "distinct formation slots within two hero widths")
	var initial = a.position
	run.spawn_enemy(&"saltbound_thrall", a.position + Vector2(90, 0))
	CompanionController.simulate(a, run)
	t.check(a.position == initial, "companion does not chase attack target")
	a.position = Vector2(100, 100)
	a.health.current = 42
	a.next_ready = 123
	t.check(CompanionController.relocate(a, run) and a.position.distance_to(run.hero.position) <= 32 and a.health.current == 42 and a.next_ready == 123, "safe relocation preserves health/cooldown")
	a.position = Vector2(100, 100)
	a.blocked_ticks = 120
	CompanionController.simulate(a, run)
	t.check(a.position.distance_to(run.hero.position) <= 32 and a.blocked_ticks == 0, "two blocked seconds initiates recovery")
	# Cover all candidates with enemies: no teleport into damage.
	for offset in [Vector2(-24, -16), Vector2(-24, 16), Vector2(24, -16), Vector2(24, 16), Vector2(0, -32), Vector2(0, 32)]:
		run.spawn_enemy(&"saltbound_thrall", run.hero.position + offset)
	a.position = Vector2(100, 100)
	t.check(not CompanionController.relocate(a, run) and a.position == Vector2(100, 100), "unsafe relocation is deferred")
	a.health.dead = true
	CompanionController.simulate(a, run)
	t.check(a.position == Vector2(100, 100) and not AttackExecutor.try_activate(a, run, 200), "downed companion cannot relocate or attack")
	Fixture.dispose(f)
