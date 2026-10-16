class_name ProfileLock
extends RefCounted

var path: String
var token: String
var owned: bool = false

func acquire(root: String) -> String:
	path = root.path_join("writer.lock")
	if DirAccess.make_dir_recursive_absolute(root) != OK: return "Cannot create profile directory."
	# A single native directory creation acquires ownership atomically.
	if DirAccess.make_dir_absolute(path) != OK: return "Profile is locked. Close other game instances before recovering a stale lock."
	token = str(OS.get_process_id()) + "-" + str(Time.get_ticks_usec())
	var f = FileAccess.open(path.path_join("owner"), FileAccess.WRITE)
	if f == null:
		DirAccess.remove_absolute(path)
		return "Cannot record lock ownership."
	f.store_string(token)
	f.close()
	owned = true
	return ""

func release() -> void:
	if not owned: return
	if FileAccess.get_file_as_string(path.path_join("owner")) == token:
		DirAccess.remove_absolute(path.path_join("owner"))
		DirAccess.remove_absolute(path)
	owned = false

func recover_stale(root: String, confirmed: bool) -> String:
	if not confirmed: return "Confirm that all other game instances are closed."
	var stale = root.path_join("writer.lock")
	if FileAccess.file_exists(stale.path_join("owner")): DirAccess.remove_absolute(stale.path_join("owner"))
	if DirAccess.dir_exists_absolute(stale) and DirAccess.remove_absolute(stale) != OK: return "Cannot remove stale lock."
	return acquire(root)
