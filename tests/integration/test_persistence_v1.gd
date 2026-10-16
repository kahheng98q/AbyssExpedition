extends RefCounted

const Fault = preload("res://tests/fixtures/fault_file_store.gd")

func location(label: String) -> String:
	return "user://tests/m2-%s-%d-%d/" % [label, OS.get_process_id(), Time.get_ticks_usec()]

func run(t) -> void:
	for forbidden_root in ["user://profiles/default/", "user://tests/../profiles/default/"]:
		var unsafe_writer = SaveCoordinator.new(forbidden_root)
		t.check(not unsafe_writer.open() and unsafe_writer.state == "test-root-rejected", "test runner rejects live or escaping profile roots before I/O")
		unsafe_writer.close()
	for filename in ["profile-bad.json", "profile-01.json", "profile-1.JSON", "profile-0.json", "profile-9007199254740992.json"]:
		var anomaly_root = location("filename")
		DirAccess.make_dir_recursive_absolute(anomaly_root)
		var artifact = anomaly_root.path_join(filename)
		var original = FileAccess.get_file_as_string("res://tests/fixtures/profiles/v3.json")
		var output = FileAccess.open(artifact, FileAccess.WRITE)
		output.store_string(original)
		output.close()
		var anomaly = SaveCoordinator.new(anomaly_root)
		t.check(not anomaly.open() and anomaly.state == "recovery-required", "anomalous save name requires review: " + filename)
		t.check(not DirAccess.open(anomaly_root).get_files().has("profile-1.json"), "no silent profile creation for " + filename)
		t.check(not ProfileLoader.recover(anomaly, false, true), "anomaly recovery requires consent")
		t.check(ProfileLoader.recover(anomaly, true, true), "explicit new profile can preserve anomalous evidence")
		t.check(anomaly.revision() > 1, "reviewed valid envelope advances revision even when its name is invalid")
		var preserved = false
		for folder in DirAccess.open(anomaly_root).get_directories():
			if folder.begins_with("recovery-evidence-") and FileAccess.get_file_as_string(anomaly_root.path_join(folder).path_join(filename)) == original: preserved = true
		t.check(preserved, "anomalous evidence retains exact bytes after explicit recovery")
		anomaly.close()
		anomaly = SaveCoordinator.new(anomaly_root)
		t.check(anomaly.open(), "confirmed anomaly recovery survives reopen")
		anomaly.close()
	# A numeric alias and canonical name must not choose an arbitrary same revision.
	var duplicate_root = location("duplicate-revision")
	DirAccess.make_dir_recursive_absolute(duplicate_root)
	for filename in ["profile-1.json", "profile-01.json"]:
		var file = FileAccess.open(duplicate_root.path_join(filename), FileAccess.WRITE)
		file.store_string(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v3.json"))
		file.close()
	var duplicated = SaveCoordinator.new(duplicate_root)
	t.check(not duplicated.open() and duplicated.recovery.is_empty(), "duplicate revisions cannot pick an arbitrary recovery")
	duplicated.close()
	var read_fault = Fault.new()
	read_fault.stage = "enumerate"
	var blocked = SaveCoordinator.new(location("enumeration"), read_fault)
	t.check(not blocked.open() and blocked.state != "ready" and blocked.store.generations().is_empty(), "unreadable directory never creates a profile")
	blocked.close()
	t.check(ProfileValidator.decode(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v1.json")).error == "", "golden schema-v1 fixture validates")
	for stage in ["open", "short_write", "flush", "close", "temp_read", "read", "rename", "readback", "cleanup"]:
		var adapter = Fault.new()
		adapter.remaining = 0
		var writer = SaveCoordinator.new(location(stage), adapter)
		t.check(writer.open(), "profile creation " + stage)
		var prior = writer.revision()
		var candidate = writer.payload.duplicate(true)
		candidate.promotion_items = 1
		adapter.stage = stage
		adapter.remaining = 1
		var ok = writer.mutate(candidate, prior, "fault-" + stage, {"kind": "test"})
		if stage == "cleanup":
			t.check(ok and writer.store.diagnostic != "", "cleanup failure does not roll back commit")
		else:
			t.check(not ok and writer.state == "save-blocked" and writer.payload.promotion_items == 0, "failed action blocks and preserves prior: " + stage)
			var bytes = writer.pending_bytes
			t.check(not writer.mutate(candidate, prior, "second"), "pending action prevents another mutation")
			t.check(writer.retry() and writer.payload.promotion_items == 1 and writer.revision() == prior + 1, "Retry commits same action once: " + stage)
			t.check(JSON.parse_string(bytes).operation_id == writer.envelope.operation_id, "Retry retains candidate identity")
		t.check(writer.mutate(candidate, prior, "fault-" + stage) and writer.revision() == prior + 1, "repeated committed operation is idempotent")
		var root = writer.store.root
		writer.close()
		var reopened = SaveCoordinator.new(root)
		t.check(reopened.open() and reopened.payload.promotion_items == 1, "committed save survives reopen " + stage)
		reopened.close()
	# Twenty controlled close/reopen comparisons, including XP cap and party selection.
	var root = location("twenty")
	var writer = SaveCoordinator.new(root)
	t.check(writer.open(), "twenty reopen profile created")
	for i in range(20):
		var p = writer.payload.duplicate(true)
		p.owned.aren = OwnedHero.record("aren", mini(2900, i * 170), "swordmaster" if i >= 9 else "")
		p.companions = ["lia", "milo"] if i % 2 else []
		p.seed = i
		p.promotion_items = 20 - i
		t.check(writer.mutate(p, writer.revision(), "reopen-" + str(i)), "controlled commit " + str(i))
		var expected = writer.payload.duplicate(true)
		writer.close()
		writer = SaveCoordinator.new(root)
		t.check(writer.open() and writer.payload == expected, "exact close/reopen state comparison " + str(i))
	# Native lock acquisition and owned-only release.
	var competing = SaveCoordinator.new(root)
	t.check(not competing.open() and competing.state == "locked", "second writer refused by native directory acquisition")
	competing.close()
	t.check(DirAccess.dir_exists_absolute(root.path_join("writer.lock")), "foreign release leaves owner lock")
	writer.close()
	var generations = writer.store.generations()
	t.check(not writer.mutate(ProfileData.fresh(), writer.revision(), "after-close"), "closed writer cannot mutate without owning lock")
	var f = FileAccess.open(generations[0].path, FileAccess.WRITE)
	f.store_string("{damaged")
	f.close()
	writer = SaveCoordinator.new(root)
	t.check(not writer.open() and writer.state == "recovery-required" and not writer.recovery.is_empty(), "corrupt current requires explicit recovery")
	t.check(not ProfileLoader.recover(writer, false), "unconfirmed recovery changes nothing")
	t.check(ProfileLoader.recover(writer, true) and writer.revision() > generations[0].revision, "recovery publishes higher generation preserving evidence")
	writer.close()
	# Highest unsupported version blocks fallback.
	var latest = writer.store.generations()[0]
	var e = JSON.parse_string(writer.store.read(latest.path))
	e.schema_version = ProfileData.SCHEMA + 1
	f = FileAccess.open(latest.path, FileAccess.WRITE)
	f.store_string(JSON.stringify(e))
	f.close()
	writer = SaveCoordinator.new(root)
	t.check(not writer.open() and writer.state == "incompatible", "unsupported newest save is preserved; no rollback/reset")
	writer.close()
	# Validation treats JSON numbers carefully and checks exact payload bytes.
	var p = ProfileData.fresh()
	for value in [-1, 0.5, INF, ProfileData.MAX_INTEGER + 1]:
		p.promotion_items = value
		t.check(ProfileValidator.payload_error(p) != "", "invalid balance rejected " + str(value))
	p = ProfileData.fresh()
	var encoded = ProfileData.envelope(p, 1, "validation")
	encoded.payload_json += " "
	t.check(ProfileValidator.decode(JSON.stringify(encoded)).error != "", "checksum hashes exact UTF-8 payload")
	encoded = ProfileData.envelope(p, 1, "validation")
	encoded.revision = 1.5
	t.check(ProfileValidator.decode(JSON.stringify(encoded)).error != "", "fractional revision rejected")
	# No usable recovery: explicit creation only, preserving damaged file.
	root = location("empty-recovery")
	DirAccess.make_dir_recursive_absolute(root)
	f = FileAccess.open(root.path_join("profile-1.json"), FileAccess.WRITE)
	f.store_string("{}")
	f.close()
	writer = SaveCoordinator.new(root)
	t.check(not writer.open() and writer.recovery.is_empty(), "no valid generation blocks normal play")
	t.check(ProfileLoader.recover(writer, true, true) and FileAccess.file_exists(root.path_join("profile-1.json")), "explicit fresh profile preserves corrupt evidence")
	writer.close()
	var lock = ProfileLock.new()
	t.check(lock.acquire(root) == "", "stale-lock fixture acquired")
	lock.owned = false # simulate process termination without a normal release
	var recovery_lock = ProfileLock.new()
	t.check(recovery_lock.recover_stale(root, false) != "" and recovery_lock.recover_stale(root, true) == "", "stale lock requires other-instance confirmation")
	recovery_lock.release()
	# Closing before/after the publish boundary yields a complete prior/new action.
	for stage in ["rename", "readback"]:
		var adapter = Fault.new()
		adapter.remaining = 0
		root = location("interrupt-" + stage)
		writer = SaveCoordinator.new(root, adapter)
		t.check(writer.open(), "interruption fixture created " + stage)
		p = writer.payload.duplicate(true)
		p.promotion_items = 7
		adapter.stage = stage
		adapter.remaining = 1
		t.check(not writer.mutate(p, writer.revision(), "interrupted-" + stage), "interrupted pending action " + stage)
		writer.close()
		writer = SaveCoordinator.new(root)
		t.check(writer.open() and writer.payload.promotion_items == (0 if stage == "rename" else 7), "reopen returns complete prior or published state " + stage)
		t.check(writer.store.generations().size() <= 2, "retains current/prior validated generations")
		writer.close()
	root = location("interrupted-creation")
	var adapter = Fault.new()
	adapter.stage = "rename"
	writer = SaveCoordinator.new(root, adapter)
	t.check(not writer.open() and writer.state == "save-blocked", "creation failure blocks launch")
	writer.close()
	writer = SaveCoordinator.new(root)
	t.check(not writer.open() and writer.state == "recovery-required", "orphaned temp never automatically creates or commits profile")
	writer.close()
	for mutate in ["xp", "level", "branch", "ownership", "party", "seed"]:
		p = ProfileData.fresh()
		match mutate:
			"xp": p.owned.aren.total_xp = 2901
			"level": p.owned.aren.level = 30
			"branch": p.owned.aren.promotion_id = "void_caster"
			"ownership": p.owned.erase("milo")
			"party": p.companions = ["aren"]
			"seed": p.seed = 2147483648
		t.check(ProfileValidator.payload_error(p) != "", "invalid persisted record rejected " + mutate)
	t.check(ProfileValidator.decode(" ".repeat(1048577)).error != "", "bounded input enforced before JSON parsing")
