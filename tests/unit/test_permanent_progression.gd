extends RefCounted

func run(t) -> void:
	t.check(PermanentProgression.preview("victory", 36000) == {"xp": 300, "items": 1, "tickets": 3, "sera": false}, "victory grants minute XP plus bonus and one item and earned tickets")
	t.check(PermanentProgression.preview("defeat", 3599).xp == 0, "partial minute gives no permanent XP")
	t.check(PermanentProgression.preview("defeat", 3600).xp == 20, "full minute grants permanent XP on defeat")
	t.check(PermanentProgression.preview("abandonment", 36000) == {"xp": 0, "items": 0, "tickets": 0, "sera": false}, "abandonment has no rewards")
	for pair in [[0, 1], [1299, 13], [1300, 14], [1400, 15], [2900, 30]]:
		t.check(OwnedHero.level(pair[0]) == pair[1], "derived permanent level " + str(pair))
	var p = ProfileData.fresh()
	p.owned.aren = OwnedHero.record("aren", 2850)
	var s = {"outcome": "victory", "ticks": 36000, "hero": "aren", "participants": ["aren", "lia"]}
	var next = PermanentProgression.settle(p, s)
	t.check(next.owned.aren.total_xp == 2900 and next.owned.lia.total_xp == 300 and next.owned.milo.total_xp == 0, "participants gain equal XP, cap, no unselected reward")
	t.check(next.promotion_items == 1 and p.promotion_items == 0, "item remains even at cap; original unchanged")
	s.participants = ["aren", "aren"]
	t.check(PermanentProgression.settle(p, s).is_empty(), "duplicate settlement participant rejected")
	p.promotion_items = ProfileData.MAX_INTEGER
	s.participants = ["aren"]
	t.check(PermanentProgression.settle(p, s).is_empty(), "balance overflow rejected")
