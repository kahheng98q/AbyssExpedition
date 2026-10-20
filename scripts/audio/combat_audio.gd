class_name CombatAudio
extends Node

signal cue_started(cue: String, slot_index: int)

var run
var definition: CombatAudioDefinition
var generation: int = -1
var disposed: bool = true
var _enabled: bool = true
var allocator: VoiceAllocator = VoiceAllocator.new()
var players: Array[AudioStreamPlayer] = []
var last_level_offer_id: int = -1
var upgrade_fifo: Array[int] = []
var enabled: bool:
	get: return _enabled
	set(value): set_enabled(value)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in 8:
		var player = AudioStreamPlayer.new()
		player.name = "Voice%d" % index
		player.max_polyphony = 1
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.finished.connect(on_finished.bind(index))
		add_child(player)
		players.append(player)

func bind_run(owner) -> void:
	shutdown()
	run = owner
	generation = run.generation
	definition = run.catalog.combat_audio
	disposed = false
	run.attack_committed.connect(on_attack)
	run.damage_accepted.connect(on_damage)
	run.pause.changed.connect(sync_pause)
	sync_pause(run.pause.snapshot())

func live() -> bool:
	return not disposed and is_instance_valid(run) and run.phase == "active" and run.generation == generation

func set_enabled(value: bool) -> void:
	if _enabled == value: return
	_enabled = value
	if not value:
		stop_players()
		upgrade_fifo.clear()
	elif live(): sync_pause(run.pause.snapshot())

func level_allowed() -> bool:
	if not live() or not _enabled: return false
	for token in run.pause.snapshot().values():
		if token.reason != "level": return false
	return true

func sync_pause(_state: Dictionary) -> void:
	if not live(): return
	var blocked = run.pause.is_blocked()
	for index in range(1,8): players[index].stream_paused = blocked
	players[0].stream_paused = not level_allowed()
	if level_allowed(): drain_level()

func on_attack(fact: Dictionary) -> void:
	if not live() or not _enabled or run.pause.is_blocked() or fact.get("generation",-1) != generation: return
	if fact.get("weapon_mode",&"") not in [&"arc",&"straight",&"homing"]: return
	play_combat("attack_" + String(fact.weapon_mode), int(fact.tick), bool(fact.is_companion))

func on_damage(fact: Dictionary) -> void:
	if not live() or not _enabled or run.pause.is_blocked() or fact.get("generation",-1) != generation: return
	var role = fact.get("target_role",&"")
	if role == &"hero": play_combat("hero_hurt",int(fact.tick))
	elif role in [&"enemy",&"boss"]: play_combat("kill" if fact.fatal else "hit",int(fact.tick))

func play_combat(cue: String, tick: int, companion: bool = false) -> void:
	var index = allocator.request(cue,tick,generation,companion)
	if index < 0: return
	start_player(index,cue,companion)

func start_player(index: int, cue: String, companion: bool = false) -> void:
	# stop/stream replacement never sends finished; allocator already owns the new slot.
	var player = players[index]
	player.stop()
	player.stream_paused = false
	player.stream = definition.cues[cue].stream
	player.bus = definition.cues[cue].bus
	player.volume_db = definition.cues[cue].gain_db + (definition.companion_attack_offset_db if companion else 0.0)
	player.play()
	cue_started.emit(cue,index)

func present_level(expected_generation: int, offer_id: int) -> void:
	if not live() or expected_generation != generation or offer_id <= last_level_offer_id: return
	last_level_offer_id = offer_id
	# Disabled presentation is consumed, never accumulated for re-enable.
	if not _enabled: return
	upgrade_fifo.append(offer_id)
	drain_level()

func drain_level() -> void:
	if not level_allowed() or upgrade_fifo.is_empty(): return
	if allocator.claim_level(run.clock.tick,generation) < 0: return
	upgrade_fifo.pop_front()
	start_player(0,"level")

func on_finished(index: int) -> void:
	# A late completion from a stopped stream must not release a replacement voice.
	if disposed or players[index].playing: return
	allocator.release(index)
	if index == 0: drain_level()

func stop_players() -> void:
	for player in players:
		player.stop()
		player.stream_paused = false
		player.stream = null
	allocator.reset()

func shutdown() -> void:
	disposed = true
	if is_instance_valid(run):
		if run.attack_committed.is_connected(on_attack): run.attack_committed.disconnect(on_attack)
		if run.damage_accepted.is_connected(on_damage): run.damage_accepted.disconnect(on_damage)
		if run.pause.changed.is_connected(sync_pause): run.pause.changed.disconnect(sync_pause)
	stop_players()
	upgrade_fifo.clear()
	last_level_offer_id = -1
	generation = -1
	run = null

func _exit_tree() -> void:
	shutdown()
