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
	t.check(probe.has_method("audio_validation_error"), "benchmark validates realaudio comparison contract")
	if probe.has_method("audio_validation_error"):
		var good={"enabled":true,"driver":"WASAPI","device":"Default","sample_rate":48000,"same_machine_target":true,"cue_count":20,"peak_voices":8,"debug_build":false,"debugger_active":false,"warmup":30.0,"capture":120.0,"samples":7200,"size":Vector2i(1920,1080),"vsync":DisplayServer.VSYNC_DISABLED}
		t.check(probe.audio_validation_error(good)=="", "valid real audio stress accepted")
		for entry in [["driver","Dummy"],["cue_count",0],["peak_voices",9],["debug_build",true],["debugger_active",true],["warmup",1.0],["capture",2.0],["samples",0],["size",Vector2i(1280,720)],["vsync",DisplayServer.VSYNC_ENABLED]]:
			var bad=good.duplicate()
			bad[entry[0]]=entry[1]
			t.check(probe.audio_validation_error(bad)!="", "reject invalid audio benchmark "+str(entry))
		for entry in [["same_machine_target",false],["device",""],["sample_rate",0]]:
			var bad=good.duplicate()
			bad[entry[0]]=entry[1]
			t.check(probe.audio_validation_error(bad)!="", "reject wrong target/unknown device: "+str(entry))
	probe.free()
	Fixture.dispose(f)
