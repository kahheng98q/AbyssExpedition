extends RefCounted

func run(t) -> void:
	var rescue = RescueObjective.new()
	t.check(not rescue.offer(14399) and rescue.offer(14400), "rescue offered at exactly minute four")
	t.check(rescue.accept(Vector2(480, 270)), "accept pending rescue")
	for i in range(1800): rescue.advance(Vector2(576, 270), true)
	t.check(rescue.state == "succeeded" and rescue.elapsed == 1800, "inclusive radius boundary succeeds after 1800 continuous active ticks")
	rescue = RescueObjective.new()
	rescue.offer(14400)
	rescue.accept(Vector2.ZERO)
	rescue.advance(Vector2.ZERO, true, true)
	t.check(rescue.elapsed == 0, "paused rescue does not advance")
	rescue.advance(Vector2(96.01, 0), true)
	t.check(rescue.state == "failed" and not rescue.accept(Vector2.ZERO), "leaving once permanently fails this opportunity")
	rescue = RescueObjective.new()
	rescue.offer(14400)
	rescue.decline()
	t.check(not rescue.offer(14401) and not rescue.accept(Vector2.ZERO), "decline cannot restart until next expedition")
	rescue = RescueObjective.new()
	rescue.offer(14400)
	rescue.accept(Vector2.ZERO)
	rescue.advance(Vector2.ZERO, false)
	t.check(rescue.state == "failed" and rescue.elapsed == 0, "active hero death fails defense immediately")
	rescue = RescueObjective.new()
	t.check(rescue.offer(14400), "new expedition restores declined or failed rescue opportunity")
	for ticks in [17999, 18000]:
		var p = PermanentProgression.settle(ProfileData.fresh(), {"outcome": "defeat", "ticks": ticks, "hero": "aren"})
		t.check(p.get("tickets", -1) == (0 if ticks == 17999 else 1), "five minute ticket threshold " + str(ticks))
	for outcome in ["defeat", "victory", "abandonment"]:
		for ticks in [0, 17999, 18000, 36000]:
			for state in ["failed", "declined", "defending", "succeeded"]:
				for owned in [false, true]:
					var p = ProfileData.fresh()
					if owned: p.owned.sera = OwnedHero.record("sera", 400)
					var result = PermanentProgression.settle(p, {"outcome": outcome, "ticks": ticks, "hero": "aren", "rescue": {"state": state, "owned_at_start": owned}})
					var tickets = 0
					if outcome != "abandonment": tickets = (1 if ticks >= 18000 else 0) + (2 if outcome == "victory" else 0) + (1 if state == "succeeded" and owned else 0)
					t.check(result.tickets == tickets and result.owned.has("sera") == (owned or (state == "succeeded" and outcome != "abandonment")), "settlement reward matrix %s/%d/%s/%s" % [outcome, ticks, state, owned])
