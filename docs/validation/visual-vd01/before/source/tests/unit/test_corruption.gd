extends RefCounted

func run(t) -> void:
	var c = CorruptionService.new()
	t.check(c.value == 0, "corruption starts at zero")
	c.advance(3599)
	t.check(c.value == 0, "partial active minute has no gain")
	c.advance(3600)
	t.check(c.value == 5, "full active minute adds five")
	c.advance(3600)
	t.check(c.value == 5, "minute is applied once")
	for threshold in [0, 25, 50, 75, 100]:
		c = CorruptionService.new()
		if threshold > 0: c.add(threshold)
		var m = c.modifiers()
		t.check(c.value == threshold, "exact threshold " + str(threshold))
		t.check(is_equal_approx(m.xp, 1.0 + (threshold / 25) * 0.1), "total gem multiplier")
		t.check(m.brood == (threshold >= 50) and m.second_circle == (threshold == 100), "threshold capabilities")
		t.check(is_equal_approx(m.damage, 1.15 if threshold >= 75 else 1.0), "future damage total")
	c = CorruptionService.new()
	t.check(c.add(75) and not c.add(35) and c.value == 75, "full bargain cost rejected without headroom")
	t.check(c.add(25) and c.value == 100 and not c.add(1), "cap exact boundary")
	c.advance(360000)
	t.check(c.value == 100, "minute gains clamp")
