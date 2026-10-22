extends RefCounted
const Fault = preload("res://tests/fixtures/fault_file_store.gd")

func run(t) -> void:
	await check_preview_save_failure(t)
	var golden = ProfileValidator.decode(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v3.json"))
	var legacy = ProfileValidator.decode(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v2.json"))
	var before = legacy.payload.duplicate(true)
	var migrated = ProfileMigrations.v2_to_v3(legacy.payload)
	t.check(golden.error == "" and migrated == golden.payload and legacy.payload == before, "pure golden v2-v3 migration defaults coast false and preserves every prior field")
	for field in ["health", "xp", "upgrades", "time", "enemies", "coins", "corruption", "active_rescue", "pending_event"]:
		var invalid = ProfileData.fresh()
		invalid[field] = 1
		t.check(ProfileValidator.payload_error(invalid) != "", "profile cannot persist expedition " + field)
	for flags in [null, {}, {"coast": 1}, {"coast": false, "extra": false}]:
		var invalid = ProfileData.fresh()
		invalid.chapters = flags
		t.check(ProfileValidator.payload_error(invalid) != "", "invalid chapter completion schema rejected")
	var unknown = ProfileData.fresh()
	unknown.owned["unknown_hero"] = OwnedHero.record("aren")
	t.check(ProfileValidator.payload_error(unknown) != "", "unknown hero rejected")
	var migrated_root = "user://tests/m4-v2-%d/" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(migrated_root)
	var file = FileAccess.open(migrated_root.path_join("profile-1.json"), FileAccess.WRITE)
	var original_bytes = FileAccess.get_file_as_string("res://tests/fixtures/profiles/v2.json")
	file.store_string(original_bytes)
	file.close()
	var fault = Fault.new()
	fault.stage = "rename"
	var writer = SaveCoordinator.new(migrated_root, fault)
	t.check(not writer.open() and writer.state == "save-blocked" and writer.envelope.schema_version == 2, "migration failure preserves complete legacy state")
	var bytes = writer.pending_bytes
	t.check(writer.retry() and writer.envelope.schema_version == 3 and writer.payload.chapters.coast == false, "same migration candidate retries")
	t.check(writer.envelope.payload_json == JSON.parse_string(bytes).payload_json and writer.store.read(migrated_root.path_join("profile-1.json")) == original_bytes, "migration retains frozen bytes and source generation")
	writer.close()
	# Twenty faults cover publication before/after commit and retries of chapter + rewards.
	var stages = ["open", "short_write", "flush", "close", "temp_read", "read", "rename", "readback", "cleanup"]
	for i in range(20):
		var location = "user://tests/m4-integrity-%d-%d/" % [Time.get_ticks_usec(), i]
		fault = Fault.new()
		fault.remaining = 0
		writer = SaveCoordinator.new(location, fault)
		t.check(writer.open(), "isolated integrity profile created")
		var old = writer.payload.duplicate(true)
		var candidate = PermanentProgression.settle(old, {"hero": "aren", "outcome": "victory", "ticks": 33000, "rescue": {"state": "succeeded", "owned_at_start": false}})
		fault.stage = stages[i % stages.size()]
		fault.remaining = 1
		var operation = "m4-integrity-" + str(i)
		var ok = writer.mutate(candidate, writer.revision(), operation)
		if not ok:
			t.check(writer.state == "save-blocked" and writer.payload == old, "failed settlement exposes no partial chapter/rewards")
			bytes = writer.pending_bytes
			# Reopen after simulated process interruption before Retry.
			writer.close()
			var observer = SaveCoordinator.new(location)
			t.check(observer.open(), "interruption reopens a complete generation")
			var observed = observer.payload.duplicate(true)
			observed.receipt = {}
			var expected = candidate.duplicate(true)
			expected.receipt = {}
			var previous = old.duplicate(true)
			previous.receipt = {}
			t.check(observed == JSON.parse_string(JSON.stringify(expected)) or observed == JSON.parse_string(JSON.stringify(previous)), "reopen yields exact complete prior or committed settlement")
			observer.close()
			t.check(writer.lock.acquire(location) == "" and writer.retry(), "original frozen settlement Retry succeeds")
			t.check(writer.envelope.payload_json == JSON.parse_string(bytes).payload_json, "Retry preserves exact rewards, ownership and chapter")
		var revision = writer.revision()
		t.check(writer.mutate(candidate, revision - 1, operation) and writer.revision() == revision, "duplicate settlement operation cannot double grant")
		var saved = writer.payload.duplicate(true)
		writer.close()
		writer = SaveCoordinator.new(location)
		t.check(writer.open() and writer.payload == saved and writer.payload.chapters.coast and writer.payload.owned.has("sera") and writer.payload.tickets == 3, "chapter, rescue, XP, tickets and item survive exact reopen")
		writer.close()

func check_preview_save_failure(t) -> void:
	var available = FileAccess.file_exists("res://scripts/ui/promotion_preview.gd")
	t.check(available, "preview lifecycle is available for blocked-save isolation")
	if not available: return
	var catalog = ContentCatalog.new()
	t.root.add_child(catalog)
	t.check(catalog.load_all(), "preview save fixture content")
	var fault = Fault.new()
	fault.remaining = 0
	var writer = SaveCoordinator.new("user://tests/preview-save-%d/" % Time.get_ticks_usec(), fault)
	t.check(writer.open(), "preview save fixture opens isolated profile")
	var profile = ProfileData.fresh()
	profile.owned.aren = OwnedHero.record("aren", 1400)
	profile.promotion_items = 1
	t.check(writer.mutate(profile, writer.revision(), "preview-ready"), "preview eligibility persisted")
	var page = catalog.scene("promotion").instantiate()
	page.catalog = catalog
	page.payload = writer.payload.duplicate(true)
	page.revision = writer.revision()
	page.selected = "abyss_swordsman"
	page.confirmed.connect(func(hero, branch, revision): PromotionService.confirm(writer, hero, branch, revision, "preview-promote"))
	t.root.add_child(page)
	fault.stage = "readback"
	fault.remaining = 1
	page.submit()
	var frozen = writer.pending_bytes
	t.check(writer.state == "save-blocked" and frozen != "" and writer.payload.promotion_items == 1, "failed promotion retains original committed balance and frozen retry")
	var clock = [0]
	for visual in page.branch_previews.values():
		visual.set("now_usec", func(): return clock[0])
		visual.call("_process", 0.0)
	clock[0] = 60000000
	for visual in page.branch_previews.values():
		visual.call("_process", 0.0)
		t.check(visual.get("stopped") and visual.get("total_ticks") == 0, "submitted example cannot continue while save is blocked")
	page.submit()
	t.check(writer.pending_bytes == frozen and writer.payload.promotion_items == 1, "viewing/repeated submit cannot replace pending action or spend twice")
	t.check(writer.retry() and writer.payload.promotion_items == 0 and writer.payload.owned.aren.total_xp == 1400 and writer.payload.owned.aren.promotion_id == "abyss_swordsman", "same pending Retry commits one permanent choice with retained level")
	t.check(PromotionService.confirm(writer, "aren", "abyss_swordsman", page.revision, "preview-promote") and writer.payload.promotion_items == 0, "original operation receipt makes retry idempotent")
	page.free()
	catalog.free()
	writer.close()
	await t.process_frame
