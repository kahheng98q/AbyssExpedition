extends RefCounted

func run(t) -> void:
	for owned in [false, true]:
		var sequences = {}
		var types = {}
		for seed_value in [0, 1, 2, 42, 101, 202, 303, 8675309, 2147483646, 2147483647]:
			var e = EventDirector.new()
			var rng = RandomNumberGenerator.new()
			rng.seed = SeedStreams.derive(seed_value, "event_offers")
			t.check(e.offer(7199, owned, rng).is_empty(), "no event before minute two")
			var sequence = []
			for tick in [7200, 14400, 21600]:
				var o = e.offer(tick, owned, rng)
				t.check(not o.is_empty(), "every event slot has one immutable offer")
				if o.is_empty(): continue
				sequence.append(o.kind)
				types[o.kind] = true
				if not owned and tick == 14400: t.check(o.kind == "lost_adventurer", "unowned rescue guaranteed minute four")
				var state = rng.state
				t.check(e.offer(tick, owned, rng) == o and rng.state == state, "offer reread never rerolls")
				t.check(e.resolve(o.id) and not e.resolve(o.id), "one resolution per opportunity")
			print("M4 EVENTS owned=%s seed=%d sequence=%s" % [owned, seed_value, sequence])
			sequences[str(sequence)] = true
			t.check(e.offer(32400, owned, rng).is_empty(), "boss phase has no new events")
		t.check(types.size() == 3 and sequences.size() >= 3, "frozen seeds contain all types and at least three ordered sequences")
