extends RefCounted
const Fault = preload("res://tests/fixtures/fault_file_store.gd")

func run(t) -> void:
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
	t.check(writer.retry() and writer.envelope.schema_version == 4 and writer.payload.chapters.coast == false, "same migration candidate retries")
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
			t.check(writer.state == "save-blocked" and writer.payload == old, "failed settlement exposes no partial chapter/rewards: " + writer.error + " stage=" + stages[i % stages.size()])
			if writer.pending_bytes.is_empty():
				writer.close()
				continue
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
