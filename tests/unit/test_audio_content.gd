extends RefCounted

func run(t) -> void:
	var empty = CombatAudioDefinition.new()
	t.check(empty.validate()!= "", "missing combat audio configuration rejected")
	var exists = ResourceLoader.exists("res://data/audio/combat_audio.tres")
	t.check(exists, "seven original localaudio cues authored")
	if not exists: return
	var audio = load("res://data/audio/combat_audio.tres")
	t.check(audio.validate()=="" and audio.cues.size()==7, "all7 PCM cues /budget /bus validate")
	for cue in audio.cues:
		var invalid = audio.duplicate(true)
		invalid.cues[cue].gain_db = NAN
		t.check(invalid.validate()!= "", "nonfinite gain rejected")
		invalid = audio.duplicate(true)
		invalid.cues[cue].priority = 99
		t.check(invalid.validate()!= "", "priority contract enforced")
	for entry in [["voice_count",9],["level_reserved",0],["companion_attack_offset_db",0.0],["hit_merge_ticks",4],["attack_merge_ticks",3]]:
		var invalid = audio.duplicate(true)
		invalid.set(entry[0],entry[1])
		t.check(invalid.validate()!= "", "invalid configuration rejected " + str(entry))

	var missing=audio.duplicate(true)
	missing.cues.erase("level")
	t.check(missing.validate()!= "", "missing cue key rejected")
	var bad_bus=audio.duplicate(true)
	bad_bus.cues.level.bus=&"MissingBus"
	t.check(bad_bus.validate()!= "", "wrong bus route never silently falls back")
	var bad_stream=audio.duplicate(true)
	bad_stream.cues.level.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
	t.check(bad_stream.validate()!= "", "looping cue rejected")
	var choice_bus=AudioServer.get_bus_index("ChoiceSFX")
	AudioServer.set_bus_mute(choice_bus,true)
	t.check(audio.validate()!= "", "muted bus rejected")
	AudioServer.set_bus_mute(choice_bus,false)
