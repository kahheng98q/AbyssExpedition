class_name VoiceAllocator
extends RefCounted

var _slots: Array = []
var _merge: Dictionary = {}
var _serial: int = 0
var _accepted: int = 0
var _dropped: int = 0
var _stolen: int = 0
var _started: Array = []
var accepted: int:
	get: return _accepted
var dropped: int:
	get: return _dropped
var stolen: int:
	get: return _stolen
var cue_started: Array:
	get:
		var result = _started.duplicate(true)
		for entry in result: entry.make_read_only()
		result.make_read_only()
		return result

func _init() -> void: reset()

func reset() -> void:
	_slots.clear()
	for index in 8: _slots.append({"slot_index":index,"busy":false,"cue":"","priority":0,"start_serial":0,"generation":-1})
	_merge.clear()
	_started.clear()
	_serial=0
	_accepted=0
	_dropped=0
	_stolen=0

func snapshot() -> Array:
	var result = _slots.duplicate(true)
	for slot in result: slot.make_read_only()
	result.make_read_only()
	return result

func active_count() -> int:
	return _slots.filter(func(slot): return slot.busy).size()

func release(index: int) -> void:
	if index < 0 or index >= 8: return
	_slots[index].merge({"busy":false,"cue":"","priority":0,"generation":-1},true)

func begin(index: int, cue: String, priority: int, tick: int, generation: int) -> int:
	_serial += 1
	_accepted += 1
	_slots[index].merge({"busy":true,"cue":cue,"priority":priority,"start_serial":_serial,"generation":generation},true)
	_started.append({"slot_index":index,"cue":cue,"tick":tick,"generation":generation,"serial":_serial})
	if _started.size()>2048: _started.pop_front()
	return index

func claim_level(tick: int, generation: int) -> int:
	if _slots[0].busy: return -1
	return begin(0,"level",50,tick,generation)

func request(cue: String, tick: int, generation: int, companion: bool = false) -> int:
	if not CombatAudioDefinition.PRIORITIES.has(cue) or cue == "level":
		_dropped += 1
		return -1
	var attack = cue.begins_with("attack_")
	var key = cue + (":companion" if companion else ":hero") if attack else cue
	var window = 4 if attack else (3 if cue in ["hit","kill"] else 0)
	if window>0 and _merge.has(key) and tick - _merge[key] < window:
		_dropped += 1
		return -1
	var priority = 10 if attack and companion else int(CombatAudioDefinition.PRIORITIES[cue])
	var chosen = -1
	for index in range(1,8):
		if not _slots[index].busy:
			chosen=index
			break
	if chosen<0:
		var candidates = _slots.slice(1).filter(func(slot): return slot.priority < priority)
		if candidates.is_empty() and cue == "hero_hurt": candidates = _slots.slice(1).filter(func(slot): return slot.cue == "hero_hurt")
		candidates.sort_custom(func(a,b): return a.start_serial < b.start_serial if a.start_serial != b.start_serial else a.slot_index < b.slot_index)
		if not candidates.is_empty():
			chosen=candidates[0].slot_index
			_stolen += 1
	if chosen<0:
		_dropped += 1
		return -1
	if window>0: _merge[key]=tick
	return begin(chosen,cue,priority,tick,generation)
