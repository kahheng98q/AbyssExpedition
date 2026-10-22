extends RefCounted

func run(t) -> void:
	t.check(PermanentProgression.preview("victory", 36000) == {"tickets": 3, "sera": false}, "victory keeps tickets, no XP or materials")
	t.check(PermanentProgression.preview("defeat", 3600) == {"tickets": 0, "sera": false}, "no permanent growth on defeat")
	t.check(PermanentProgression.preview("abandonment", 36000) == {"tickets": 0, "sera": false}, "abandonment has no rewards")
	var p = ProfileData.fresh()
	var s = {"outcome": "victory", "ticks": 36000, "hero": "aren", "participants": ["aren", "lia"]}
	var next = PermanentProgression.settle(p, s)
	t.check(next.owned == p.owned and next.tickets == 3 and next.chapters.coast, "settlement preserves roster and earned economy")
	t.check(not next.has("promotion_items") and next.owned.aren == {"character_id": "aren"}, "no permanent progression fields")
	s.participants = ["aren", "aren"]
	t.check(PermanentProgression.settle(p, s).is_empty(), "duplicate participant rejected")
	p.tickets = ProfileData.MAX_INTEGER
	s.participants = ["aren"]
	t.check(PermanentProgression.settle(p, s).is_empty(), "ticket overflow rejected")
