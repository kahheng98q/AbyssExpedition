class_name ProfileStore
extends RefCounted

static var test_mode: bool = false
var root: String
var fault # Test-only I/O boundary; shipping uses native FileAccess/DirAccess.
var diagnostic: String = ""
var scan_error: String = ""
var scan_unreadable: bool = false
var invalid_paths: Array[String] = []
var duplicate_revisions: Dictionary = {}
var highest_seen_revision: int = 0
var has_artifacts: bool = false

func permitted_root() -> bool:
	return not test_mode or root.simplify_path().begins_with("user://tests/")

func _init(location: String = "user://profiles/default/", adapter = null) -> void:
	root = location
	fault = adapter
	if fault != null: assert(root.begins_with("user://tests/"), "Fault adapters cannot access the live profile.")

func fail(stage: String) -> bool:
	return fault != null and fault.fail(stage)

func read(path: String) -> String:
	if fail("read"): return ""
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1048576: return ""
	var value = file.get_as_text()
	file.close()
	return value

func generations() -> Array:
	var result: Array = []
	scan_error = ""
	scan_unreadable = false
	invalid_paths.clear()
	duplicate_revisions.clear()
	highest_seen_revision = 0
	has_artifacts = false
	var directory = DirAccess.open(root)
	if directory == null or fail("enumerate"):
		scan_error = "Cannot read profile directory. Retry loading; no new profile was created."
		scan_unreadable = true
		return result
	directory.include_hidden = true
	if directory.list_dir_begin() != OK:
		scan_error = "Cannot enumerate profile directory. Retry loading; no new profile was created."
		scan_unreadable = true
		return result
	var files: Array[String] = []
	var name = directory.get_next()
	while name != "":
		if directory.current_is_dir():
			if name not in ["writer.lock", ".", ".."]: has_artifacts = true
		else: files.append(name)
		name = directory.get_next()
	directory.list_dir_end()
	var seen = {}
	for filename in files:
		has_artifacts = true
		if filename.begins_with("pending-"): continue
		var number = filename.trim_prefix("profile-").trim_suffix(".json")
		var numeric = number.is_valid_int() and number.to_int() >= 1 and number.to_int() <= ProfileData.MAX_INTEGER
		if numeric:
			highest_seen_revision = maxi(highest_seen_revision, number.to_int())
			if seen.has(number.to_int()): duplicate_revisions[number.to_int()] = true
			seen[number.to_int()] = true
		if not filename.begins_with("profile-") or not filename.ends_with(".json") or not numeric or filename != "profile-%d.json" % number.to_int():
			invalid_paths.append(root.path_join(filename))
			scan_error = "Unrecognized profile filename or duplicate revision. Review recovery; files preserved."
			continue
		result.append({"revision": int(number), "path": root.path_join(filename)})
	if not duplicate_revisions.is_empty(): scan_error = "Duplicate profile revisions require explicit recovery review."
	result.sort_custom(func(a, b): return a.revision > b.revision)
	return result

func archive_reviewed(operation: String) -> String:
	if invalid_paths.is_empty(): return ""
	var archive = root.path_join("recovery-evidence-" + operation)
	if DirAccess.make_dir_recursive_absolute(archive) != OK: return "Cannot preserve reviewed save artifacts."
	for path in invalid_paths:
		if DirAccess.rename_absolute(path, archive.path_join(path.get_file())) != OK: return "Cannot archive reviewed artifact: " + path.get_file()
	invalid_paths.clear()
	return ""

func inspect(path: String) -> Dictionary:
	return ProfileValidator.decode(read(path))

func publish(bytes: String) -> String:
	if not permitted_root(): return "Tests may write only under unique user://tests/ roots."
	var parsed = ProfileValidator.decode(bytes)
	if parsed.error != "": return parsed.error
	var e = parsed.envelope
	var destination = root.path_join("profile-%d.json" % e.revision)
	# Retry after publication checks the destination before any new write.
	if FileAccess.file_exists(destination):
		if fail("readback"): return "Published readback failed."
		if read(destination) == bytes and inspect(destination).error == "": return ""
		return "Destination conflict or invalid readback; generation preserved."
	var temporary = root.path_join("pending-%s.tmp" % e.operation_id)
	if fail("open"): return "Cannot open pending save."
	var file = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return "Cannot open pending save (%s)." % FileAccess.get_open_error()
	file.store_string(bytes if not fail("short_write") else bytes.substr(0, bytes.length() / 2))
	file.flush()
	var write_error = file.get_error()
	file.close()
	if write_error != OK or fail("flush") or fail("close"): return "Pending save flush/close failed."
	if fail("temp_read") or read(temporary) != bytes or inspect(temporary).error != "": return "Pending save verification failed."
	if fail("rename") or DirAccess.rename_absolute(temporary, destination) != OK: return "Save publication failed."
	if fail("readback") or read(destination) != bytes or inspect(destination).error != "": return "Published readback failed."
	cleanup()
	return ""

func cleanup() -> void:
	if fail("cleanup"):
		diagnostic = "Cleanup failed; committed and recovery generations retained."
		return
	var healthy = 0
	var entries = generations()
	if scan_error != "":
		diagnostic = "Cleanup skipped: " + scan_error
		return
	for entry in entries:
		var parsed = inspect(entry.path)
		if parsed.error != "" or int(parsed.envelope.revision) != entry.revision: continue
		if int(parsed.envelope.schema_version) < ProfileData.SCHEMA: continue # Preserve migration sources.
		healthy += 1
		if healthy > 2 and DirAccess.remove_absolute(entry.path) != OK:
			diagnostic = "Cleanup failed; committed and recovery generations retained."
