class_name SaveCoordinator
extends RefCounted

var store: ProfileStore
var lock: ProfileLock = ProfileLock.new()
var payload: Dictionary = {}
var envelope: Dictionary = {}
var state: String = "unloaded"
var error: String = ""
var pending_bytes: String = ""
var pending_result: Dictionary = {}
var receipts: Dictionary = {}
var recovery: Dictionary = {}
var highest_revision: int = 0

func _init(location: String = "user://profiles/default/", adapter = null) -> void:
	store = ProfileStore.new(location, adapter)

func open() -> bool:
	if not store.permitted_root():
		state = "test-root-rejected"
		error = "Tests may open only unique user://tests/ profiles."
		return false
	if not lock.owned:
		error = lock.acquire(store.root)
		if error != "":
			state = "locked"
			return false
	return ProfileLoader.load_profile(self)

func mutate(candidate: Dictionary, expected_revision: int, operation: String, result: Dictionary = {}) -> bool:
	if not lock.owned:
		error = "Writer lock is not owned."
		return false
	if receipts.has(operation): return true
	if state != "ready" or not pending_bytes.is_empty():
		error = "Another action is pending; Retry it first."
		return false
	if expected_revision != revision():
		error = "Profile changed; refresh and confirm again."
		return false
	if highest_revision >= ProfileData.MAX_INTEGER:
		error = "Profile revision limit reached."
		return false
	var next = candidate.duplicate(true)
	var new_revision = maxi(highest_revision, revision()) + 1
	next.receipt = {"operation_id": operation, "base_revision": new_revision - 1, "result_revision": new_revision, "result": result.duplicate(true)}
	var reason = ProfileValidator.payload_error(next)
	if reason != "":
		error = reason
		return false
	pending_bytes = JSON.stringify(ProfileData.envelope(next, new_revision, operation))
	pending_result = result.duplicate(true)
	return retry()

func retry() -> bool:
	if not lock.owned:
		error = "Writer lock is not owned."
		return false
	if pending_bytes.is_empty(): return false
	state = "writing"
	error = store.publish(pending_bytes)
	if error != "":
		state = "save-blocked"
		return false
	var parsed = ProfileValidator.decode(pending_bytes)
	payload = parsed.payload
	envelope = parsed.envelope
	highest_revision = int(envelope.revision)
	receipts[envelope.operation_id] = pending_result.duplicate(true)
	pending_bytes = ""
	pending_result = {}
	state = "ready"
	return true

func revision() -> int:
	return int(envelope.get("revision", 0))

func operation_id() -> String:
	return "%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]

func close() -> void:
	lock.release()
