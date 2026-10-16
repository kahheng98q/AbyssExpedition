extends RefCounted

func run(t) -> void:
	t.check(SeedStreams.derive(0, "wave_types") == 3688308203924553699, "SHA-256 stream seed matches independent .NET reference")
	for value in ["0", "101", "2147483647"]: t.check(SeedStreams.valid_seed(value), "valid seed " + value)
	for value in ["", "-1", "+1", "3.5", "abc", "2147483648", "999999999999999999"]: t.check(not SeedStreams.valid_seed(value), "invalid seed " + value)
	var a = SeedStreams.new(101)
	var b = SeedStreams.new(101)
	for label in SeedStreams.LABELS:
		for i in range(10): t.check(a.stream(label).randi() == b.stream(label).randi(), "independent deterministic stream")
	var before = a.stream("upgrade_offers").state
	for i in range(100): randf()
	t.check(a.stream("upgrade_offers").state == before, "cosmetic/global RNG isolation")
	var pause = PauseCoordinator.new()
	var token = pause.acquire("manual", "owner")
	t.check(not pause.release(token, "other") and pause.is_blocked(), "foreign pause release rejected")
	t.check(pause.release(token, "owner") and not pause.is_blocked(), "owner releases pause")
