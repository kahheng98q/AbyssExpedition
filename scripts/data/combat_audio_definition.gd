class_name CombatAudioDefinition
extends Resource

const BUDGETS = {"attack_arc": -26.0, "attack_straight": -26.0, "attack_homing": -26.0, "hit": -24.0, "kill": -20.0, "hero_hurt": -16.0, "level": -12.0}
const PRIORITIES = {"attack_arc": 20, "attack_straight": 20, "attack_homing": 20, "hit": 30, "kill": 40, "hero_hurt": 50, "level": 50}
@export var id: StringName = &"combat_audio"
@export var cues: Dictionary = {}
@export var companion_attack_offset_db: float = -6.0
@export var companion_attack_priority: int = 10
@export var hit_merge_ticks: int = 3
@export var kill_merge_ticks: int = 3
@export var attack_merge_ticks: int = 4
@export var voice_count: int = 8
@export var level_reserved: int = 1

func validate() -> String:
	if id != &"combat_audio": return "unregistered audio ID"
	if voice_count != 8 or level_reserved != 1 or companion_attack_priority != 10: return "invalid voice/priority budget"
	if not is_finite(companion_attack_offset_db) or companion_attack_offset_db != -6.0: return "invalid companion gain"
	if hit_merge_ticks != 3 or kill_merge_ticks != 3 or attack_merge_ticks != 4: return "invalid merge windows"
	if cues.size() != 7: return "exactly seven cues required"
	for key in BUDGETS:
		if not cues.has(key) or not cues[key] is Dictionary: return "missing cue " + key
		var cue = cues[key]
		for field in ["stream", "gain_db", "priority", "bus"]:
			if not cue.has(field): return "missing cue field " + field
		if (not cue.gain_db is float and not cue.gain_db is int) or not is_finite(cue.gain_db) or cue.gain_db > BUDGETS[key]: return "invalid cue gain"
		if not cue.priority is int or cue.priority != PRIORITIES[key]: return "invalid cue priority"
		var expected_bus = "ChoiceSFX" if key == "level" else "CombatSFX"
		if not cue.bus is String and not cue.bus is StringName: return "invalid bus type"
		if String(cue.bus) != expected_bus: return "wrong cue bus"
		var stream = cue.stream
		if not stream is AudioStreamWAV or not stream.resource_path.begins_with("res://assets/audio/") or not stream.resource_path.ends_with(".wav"): return "local WAV required"
		if stream.format != AudioStreamWAV.FORMAT_16_BITS or stream.stereo or stream.mix_rate != 44100 or stream.loop_mode != AudioStreamWAV.LOOP_DISABLED or stream.data.is_empty(): return "mono 44.1kHz16-bit nonloop PCM required"
		var duration = stream.get_length()
		var maximum = 0.12 if key.begins_with("attack_") else {"hit":0.08,"kill":0.14,"hero_hurt":0.12,"level":0.160}.get(key,0.0)
		if duration <= 0.0 or duration > maximum or (key.begins_with("attack_") and duration < 0.06): return "cue duration exceeds contract"
		var data = stream.data
		for offset in range(0, data.size(), 2):
			if absi(data.decode_s16(offset)) > 16384: return "source peak exceeds0.5"
	for bus_name in ["Master", "CombatSFX", "ChoiceSFX"]:
		var index = AudioServer.get_bus_index(bus_name)
		if index < 0: return "missing audio bus " + bus_name
		if AudioServer.is_bus_mute(index) or AudioServer.get_bus_volume_db(index) != 0.0 or AudioServer.get_bus_effect_count(index) != 0: return "audio bus must be unmuted0dB without effects"
		if bus_name != "Master" and AudioServer.get_bus_send(index) != &"Master": return "wrong audio bus route"
	return ""
