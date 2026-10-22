extends RefCounted
const Fault = preload("res://tests/fixtures/fault_file_store.gd")
const Controlled = preload("res://tests/unit/test_recruitment.gd").Controlled

func run(t) -> void:
	for stage in ["open", "short_write", "flush", "close", "temp_read", "read", "rename", "readback"]:
		var adapter = Fault.new()
		adapter.remaining = 0
		var location = "user://tests/m3-draw-%s-%d/" % [stage, Time.get_ticks_usec()]
		var writer = SaveCoordinator.new(location, adapter)
		t.check(writer.open(), "create draw fixture " + stage)
		var p = writer.payload.duplicate(true)
		p.tickets = 11
		t.check(writer.mutate(p, writer.revision(), "earn"), "persist earned ticket fixture")
		var rng_before = writer.payload.draw_rng.duplicate(true)
		var revision = writer.revision()
		var provider = Controlled.new()
		provider.values = [0, 1]
		adapter.stage = stage
		adapter.remaining = 1
		t.check(not RecruitmentService.confirm(writer, 10, revision, "draw-" + stage, provider), "draw failure blocks reveal " + stage)
		t.check(writer.state == "save-blocked" and writer.payload.tickets == 11 and writer.payload.draw_rng == rng_before and writer.payload.history.is_empty(), "failed draw leaves all committed balances/RNG/ownership unchanged")
		var bytes = writer.pending_bytes
		t.check(not RecruitmentService.confirm(writer, 10, revision, "draw-" + stage, provider) and provider.index == 10, "repeated blocked input cannot reroll")
		t.check(writer.retry() and writer.payload.tickets == 1 and writer.payload.tokens == 8, "same candidate retry deducts once " + stage + ": " + writer.error)
		t.check(writer.envelope.payload_json == JSON.parse_string(bytes).payload_json and provider.index == 10, "retry preserves exact candidate bytes and outcome order")
		t.check(RecruitmentService.confirm(writer, 10, revision, "draw-" + stage, provider) and writer.revision() == revision + 1, "repeated completed confirm idempotent")
		var receipt = RecruitmentHistory.awaiting(writer.payload)
		t.check(not receipt.is_empty() and RecruitmentService.candidate(writer.payload, 1, "blocked").is_empty(), "awaiting reveal blocks further spending")
		writer.close()
		writer = SaveCoordinator.new(location, adapter)
		t.check(writer.open() and RecruitmentHistory.awaiting(writer.payload) == receipt, "reopen restores exact committed reveal " + stage)
		adapter.stage = stage
		adapter.remaining = 1
		var saved_draw = writer.payload.draw_rng.duplicate(true)
		t.check(not RecruitmentHistory.acknowledge(writer, receipt.operation_id, writer.revision(), "ack-" + stage), "acknowledgment failure blocks continuation")
		t.check(writer.retry() and RecruitmentHistory.awaiting(writer.payload).is_empty(), "acknowledgment retries original mutation")
		t.check(writer.payload.draw_rng == saved_draw and writer.payload.tickets == 1 and writer.payload.tokens == 8 and writer.payload.history[0].results == receipt.results, "ack never charges, converts or advances RNG")
		writer.close()
		writer = SaveCoordinator.new(location)
		t.check(writer.open() and writer.payload.history[0].results == receipt.results and not writer.payload.history[0].awaiting_reveal, "ack persists with immutable historical results")
		writer.close()
	# Closing at each publish boundary yields the complete prior or committed draw.
	for stage in ["rename", "readback"]:
		var adapter = Fault.new()
		adapter.remaining = 0
		var location = "user://tests/m3-interrupt-%s-%d/" % [stage, Time.get_ticks_usec()]
		var writer = SaveCoordinator.new(location, adapter)
		writer.open()
		var p = writer.payload.duplicate(true)
		p.tickets = 10
		writer.mutate(p, writer.revision(), "tickets")
		adapter.stage = stage
		adapter.remaining = 1
		RecruitmentService.confirm(writer, 10, writer.revision(), "interrupted")
		var pending = ProfileValidator.decode(writer.pending_bytes).payload
		writer.close()
		writer = SaveCoordinator.new(location)
		t.check(writer.open(), "interrupted draw reopens")
		t.check(writer.payload == (p if stage == "rename" else pending) or (stage == "rename" and writer.payload.tickets == 10 and writer.payload.history.is_empty()), "interruption yields complete prior or complete committed state " + stage)
		writer.close()
	# Actual app routes to an unrevealed receipt before allowing selection or spending.
	var app = load("res://scenes/app/app.tscn").instantiate()
	app.writer = SaveCoordinator.new("user://tests/m3-app-draw-%d/" % Time.get_ticks_usec())
	t.root.add_child(app)
	var p = app.writer.payload.duplicate(true)
	p.tickets = 10
	app.writer.mutate(p, app.writer.revision(), "app-tickets")
	RecruitmentService.confirm(app.writer, 10, app.writer.revision(), "app-draw")
	var receipt = RecruitmentHistory.awaiting(app.writer.payload)
	app.show_selection()
	t.check(app.screen_host.get_child(0).has_signal("acknowledged") and app.run == null, "selection routes to saved reveal")
	app.mount_run(RunStartSnapshot.new(101, &"aren"))
	t.check(app.run == null and RecruitmentHistory.awaiting(app.writer.payload) == receipt, "cannot launch while original reveal awaits acknowledgment")
	RecruitmentHistory.acknowledge(app.writer, receipt.operation_id, app.writer.revision(), "app-ack")
	app.show_selection()
	t.check(app.screen_host.get_child(0).hero_buttons.size() >= 4, "recruited heroes selectable after reveal")
	var saved_rng = app.writer.payload.draw_rng.duplicate(true)
	app.mount_run(RunStartSnapshot.new(2147483647, &"aren"))
	app.run.set_physics_process(false)
	t.check(app.writer.payload.draw_rng == saved_rng, "expedition seed cannot reseed recruitment RNG")
	var wave_state = app.run.rng.stream("wave_types").state
	app.mount_run(RunStartSnapshot.new(2147483647, &"aren"))
	app.run.set_physics_process(false)
	t.check(app.run.rng.stream("wave_types").state == wave_state and app.writer.payload.draw_rng == saved_rng, "Retry repeats expedition stream without rewinding or selecting draw state")
	app.free()
	await t.process_frame
	# Exchange uses the same durable retry protocol, including post-publication interruption.
	var adapter = Fault.new()
	adapter.remaining = 0
	var writer = SaveCoordinator.new("user://tests/m3-exchange-%d/" % Time.get_ticks_usec(), adapter)
	writer.open()
	p = writer.payload.duplicate(true)
	p.tokens = 6
	writer.mutate(p, writer.revision(), "exchange-funding")
	var revision = writer.revision()
	adapter.stage = "readback"
	adapter.remaining = 1
	t.check(not TokenExchangeService.confirm(writer, "brann", revision, "exchange") and writer.payload.tokens == 6 and not writer.payload.owned.has("brann"), "failed exchange leaves complete prior ownership/balance")
	t.check(writer.retry() and writer.payload.tokens == 1 and writer.payload.owned.brann == {"character_id": "brann"}, "exchange Retry publishes cost and ownership together")
	t.check(TokenExchangeService.confirm(writer, "brann", revision, "exchange") and writer.payload.tokens == 1, "repeated exchange operation does not spend twice")
	t.check(not TokenExchangeService.confirm(writer, "nyra", revision, "stale-exchange"), "stale expected revision rejects exchange")
	var location = writer.store.root
	writer.close()
	# Reject malformed v2 state before it can enter the writer or loader.
	for field in ["tickets", "tokens"]:
		for value in [-1, 0.5, "5", INF, ProfileData.MAX_INTEGER + 1]:
			p = ProfileData.fresh()
			p[field] = value
			t.check(ProfileValidator.payload_error(p) != "", "invalid v2 balance " + field + "/" + str(value))
	for field in ["draw_rng", "history"]:
		p = ProfileData.fresh()
		p[field] = [] if field == "draw_rng" else {}
		t.check(ProfileValidator.payload_error(p) != "", "malformed nested v2 field " + field)
	p = ProfileData.fresh()
	p.tickets = 10
	var provider = Controlled.new()
	provider.values = [0, 1]
	var legal = RecruitmentService.candidate(p, 10, "validation", provider)
	for corrupt in ["hero", "tokens", "order", "cost", "index", "state", "duplicate", "count"]:
		var broken = legal.duplicate(true)
		match corrupt:
			"hero": broken.history[0].results[0].hero = "sera"
			"tokens": broken.history[0].results[2].tokens = 0
			"order": broken.history[0].sequence_start = 1
			"cost": broken.history[0].cost = 9
			"index": broken.draw_rng.index = 9
			"state": broken.draw_rng.state = "9223372036854775808"
			"duplicate": broken.history[0].results[2].duplicate = false
			"count": broken.history[0].results.pop_back()
		t.check(ProfileValidator.payload_error(broken) != "", "corrupted receipt rejected " + corrupt)
	var mixed_version = ProfileData.envelope(ProfileData.fresh(), 1, "mixed-version")
	mixed_version.schema_version = 1
	t.check(ProfileValidator.decode(JSON.stringify(mixed_version)).get("incompatible", false), "schema/game/content must form one explicitly supported version")
	writer = SaveCoordinator.new(location)
	t.check(writer.open() and writer.payload.tokens == 1 and writer.payload.owned.has("brann"), "exchanged hero and excess token persist")
	writer.close()
