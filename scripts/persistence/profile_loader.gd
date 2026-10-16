class_name ProfileLoader
extends RefCounted

static func load_profile(writer: SaveCoordinator) -> bool:
	writer.state = "loading"
	writer.error = ""
	writer.recovery = {}
	var generations = writer.store.generations()
	writer.highest_revision = maxi(writer.highest_revision, writer.store.highest_seen_revision)
	if writer.store.scan_error != "":
		writer.state = "load-blocked" if writer.store.scan_unreadable else "recovery-required"
		writer.error = writer.store.scan_error
		if writer.store.scan_unreadable: return false
		var candidates = {}
		# Even a badly named future-version save must never be reset as fresh.
		for path in writer.store.invalid_paths:
			var parsed = writer.store.inspect(path)
			if parsed.get("incompatible", false):
				writer.state = "incompatible"
				writer.error = parsed.error
				return false
			if parsed.error == "":
				var revision = int(parsed.envelope.revision)
				writer.highest_revision = maxi(writer.highest_revision, revision)
				candidates[revision] = {} if candidates.has(revision) else parsed
		for entry in generations:
			var parsed = writer.store.inspect(entry.path)
			if parsed.get("incompatible", false):
				writer.state = "incompatible"
				writer.error = parsed.error
				return false
			if parsed.error == "" and int(parsed.envelope.revision) == entry.revision:
				candidates[entry.revision] = {} if candidates.has(entry.revision) else parsed
		var revisions = candidates.keys()
		revisions.sort()
		revisions.reverse()
		for revision in revisions:
			if not candidates[revision].is_empty() and not writer.store.duplicate_revisions.has(revision):
				writer.recovery = candidates[revision]
				break
		return false
	if generations.is_empty():
		if writer.store.has_artifacts:
			writer.state = "recovery-required"
			writer.error = "Uncommitted or archived save evidence exists. Retry loading or explicitly create a new profile."
			return false
		writer.state = "ready"
		return writer.mutate(ProfileData.fresh(), 0, writer.operation_id(), {"kind": "creation"})
	writer.highest_revision = generations[0].revision
	var newest = writer.store.inspect(generations[0].path)
	if newest.error == "" and int(newest.envelope.revision) == generations[0].revision:
		writer.payload = newest.payload
		writer.envelope = newest.envelope
		writer.receipts[newest.envelope.operation_id] = newest.payload.receipt.get("result", {})
		writer.state = "ready"
		if int(newest.envelope.schema_version) < ProfileData.SCHEMA:
			var candidate = writer.payload.duplicate(true)
			if int(newest.envelope.schema_version) == 1: candidate = ProfileMigrations.v1_to_v2(candidate, DrawRng.initial().seed)
			candidate = ProfileMigrations.v2_to_v3(candidate)
			return writer.mutate(candidate, writer.revision(), writer.operation_id(), {"kind": "migration", "from": newest.envelope.schema_version, "to": 3})
		return true
	writer.error = newest.error if newest.error != "" else "Filename/revision mismatch."
	if newest.get("incompatible", false):
		writer.state = "incompatible"
		return false
	writer.state = "recovery-required"
	for entry in generations.slice(1):
		var parsed = writer.store.inspect(entry.path)
		if parsed.get("incompatible", false):
			writer.state = "incompatible"
			writer.error = parsed.error
			return false
		if parsed.error == "" and int(parsed.envelope.revision) == entry.revision:
			writer.recovery = parsed
			break
	return false

static func recover(writer: SaveCoordinator, confirmed: bool, fresh: bool = false) -> bool:
	if not confirmed or writer.state != "recovery-required": return false
	if writer.store.scan_unreadable: return false
	if not fresh and writer.recovery.is_empty(): return false
	var candidate = ProfileData.fresh() if fresh else writer.recovery.payload.duplicate(true)
	if not fresh and int(writer.recovery.envelope.schema_version) == 1:
		candidate = ProfileMigrations.v1_to_v2(candidate, DrawRng.initial().seed)
	if not fresh and int(writer.recovery.envelope.schema_version) < 3: candidate = ProfileMigrations.v2_to_v3(candidate)
	# Explicit consent precedes moving anomalous names into a preserved evidence folder.
	# A crash here leaves the prior generation, or evidence requiring confirmation again.
	writer.error = writer.store.archive_reviewed(writer.operation_id())
	if writer.error != "": return false
	writer.state = "ready"
	return writer.mutate(candidate, writer.revision(), writer.operation_id(), {"kind": "recovery", "fresh": fresh})
