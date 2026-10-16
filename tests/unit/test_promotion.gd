extends RefCounted

func run(t) -> void:
	for xp in [1300, 1400, 2900]:
		for items in [0, 1]:
			var p = ProfileData.fresh()
			p.owned.aren = OwnedHero.record("aren", xp)
			p.promotion_items = items
			var next = PromotionService.candidate(p, "aren", "swordmaster")
			var eligible = xp >= 1400 and items > 0
			t.check(not next.is_empty() == eligible, "level/item promotion boundary " + str([xp, items]))
			if eligible:
				t.check(next.promotion_items == 0 and next.owned.aren.total_xp == xp and next.owned.aren.promotion_id == "swordmaster", "one item and preserved XP")
				t.check(PromotionService.candidate(next, "aren", "abyss_swordsman").is_empty(), "permanent branch cannot be replaced")
			t.check(p.owned.aren.promotion_id == "" and p.promotion_items == items, "preview/cancellation leaves profile unchanged")
	var p = ProfileData.fresh()
	p.owned.aren = OwnedHero.record("aren", 1400)
	p.promotion_items = 1
	t.check(PromotionService.candidate(p, "aren", "star_hunter").is_empty(), "wrong base rejected")
	t.check(PromotionService.candidate(p, "sera", "elemental_sage").is_empty(), "unowned rejected")
	t.check(PromotionService.candidate(p, "aren", "").is_empty(), "no selected branch rejected")
	var fault = preload("res://tests/fixtures/fault_file_store.gd").new()
	fault.remaining = 0
	var writer = SaveCoordinator.new("user://tests/promotion-%d/" % Time.get_ticks_usec(), fault)
	t.check(writer.open() and writer.mutate(p, writer.revision(), "eligibility"), "promotion fixture committed")
	var before = writer.revision()
	t.check(not PromotionService.confirm(writer, "aren", "swordmaster", before - 1, "stale"), "stale confirmation rejected")
	fault.stage = "readback"
	fault.remaining = 1
	t.check(not PromotionService.confirm(writer, "aren", "swordmaster", before, "promote"), "promotion failed readback holds pending mutation")
	t.check(writer.payload.promotion_items == 1 and writer.payload.owned.aren.promotion_id == "", "failed promotion preserves committed item/class")
	t.check(writer.retry() and writer.payload.promotion_items == 0, "promotion Retry commits complete action")
	t.check(PromotionService.confirm(writer, "aren", "swordmaster", before, "promote") and writer.revision() == before + 1, "double-confirm spends once")
	var root = writer.store.root
	writer.close()
	var catalog = ContentCatalog.new()
	t.root.add_child(catalog)
	t.check(catalog.load_all(), "promotion UI catalog loads")
	var screen = catalog.scene("promotion").instantiate()
	screen.catalog = catalog
	screen.payload = p
	screen.selected = "swordmaster"
	var submissions = [0]
	screen.confirmed.connect(func(_hero, _branch, _revision): submissions[0] += 1)
	t.root.add_child(screen)
	screen.submit()
	screen.submit()
	t.check(submissions[0] == 1 and screen.confirm_button.disabled, "promotion screen submits only one permanent action")
	screen.free()
	catalog.free()
	writer = SaveCoordinator.new(root)
	t.check(writer.open() and writer.payload.owned.aren.promotion_id == "swordmaster", "promoted data persists")
	writer.close()
