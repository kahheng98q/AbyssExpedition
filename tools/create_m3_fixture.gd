extends SceneTree

func _initialize() -> void:
	var old = ProfileValidator.decode(FileAccess.get_file_as_string("res://tests/fixtures/profiles/v1.json"))
	var p = ProfileMigrations.v1_to_v2(old.payload, "12345")
	var envelope = ProfileData.envelope(p, 1, "golden-v2")
	envelope.saved_at_utc = "2026-10-15T00:00:00"
	var file = FileAccess.open("res://tests/fixtures/profiles/v2.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(envelope, "  "))
	file.close()
	quit()
