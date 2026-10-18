extends Node2D

@warning_ignore("unused_signal") # Emitted by the run-owned ChoiceCoordinator.
signal choice_presented(offer_id: int, options: Array)
@warning_ignore("unused_signal")
signal choice_closed
signal state_changed
signal run_finished(summary: Dictionary)
signal rescue_presented
signal event_presented

var catalog: ContentCatalog
var snapshot: RunStartSnapshot
var clock: RunClock = RunClock.new()
var pause: PauseCoordinator = PauseCoordinator.new()
var progression: RunProgression = RunProgression.new()
var choices: ChoiceCoordinator = ChoiceCoordinator.new()
var simulation: SimulationCoordinator = SimulationCoordinator.new()
var damage: DamageService = DamageService.new()
var spawns: SpawnDirector = SpawnDirector.new()
var rng: SeedStreams
var trace: ReplayTrace
var phase: String = "preparation"
var hero
var party: Array = []
var boss_actor
var enemies: Array = []
var registry: Dictionary = {}
var dead_actors: Array = []
var deaths: Array = []
var followups: Array[Dictionary] = []
var activation_heals: Dictionary = {}
var delayed_impacts: Array[Dictionary] = []
var boss_hits: Array[Dictionary] = []
var sequence: int = 0
var request_id: int = 0
var kills: int = 0
var summary: Dictionary = {}
var manual_token: int = -1
var generation: int = 0
var rescue: RescueObjective = RescueObjective.new()
var rescue_zone
var corruption: CorruptionService = CorruptionService.new()
var coins: int = 0
var events: EventDirector = EventDirector.new()
var rescue_results: Array[Dictionary] = []
@onready var actors = $CombatWorld/Actors
@onready var projectiles = $CombatWorld/Projectiles
@onready var pickups = $CombatWorld/Pickups
@onready var telegraphs = $CombatWorld/Telegraphs
@onready var effects = $CombatWorld/Effects
@onready var camera: Camera2D = $Camera2D

func start(content: ContentCatalog, start_state: RunStartSnapshot, run_generation: int = 1) -> void:
	catalog = content
	snapshot = start_state
	rescue.owned_at_start = snapshot.sera_owned
	generation = run_generation
	damage.generation = generation
	rng = SeedStreams.new(snapshot.seed_value)
	trace = ReplayTrace.new(snapshot, catalog.digest)
	corruption.changed.connect(func():
		$CombatWorld/CoastField.set_corruption(corruption.value)
		state_changed.emit())
	hero = CharacterFactory.create(catalog.characters[snapshot.hero_id], self)
	party = [hero]
	actors.add_child(hero)
	registry[0] = hero
	for index in range(1, snapshot.members.size()):
		var member = snapshot.members[index]
		var companion = CharacterFactory.create(catalog.characters[StringName(member.id)], self, index)
		actors.add_child(companion)
		party.append(companion)
		registry[companion.actor_id] = companion
	phase = "active"
	$HUD/CombatHUD.bind_run(self)
	camera.position = hero.position
	state_changed.emit()

func _physics_process(_delta: float) -> void:
	if phase == "active":
		simulation.advance(self, PlayerController.read_movement_actions())
		camera.position = hero.position.round()

func actor_by_id(identity: int):
	return registry.get(identity)

func queue_hit(target, value: float, direction: Vector2, force: float, burn: bool, frost: bool) -> void:
	if phase != "active" or pause.is_blocked(): return
	# Hero contacts/hostile impacts resolve in the current tick. They cannot affect
	# an immune hero, so avoid allocating requests and permanent run dedup IDs.
	if target.is_hero and clock.tick < target.health.invulnerable_until: return
	request_id += 1
	damage.enqueue_hit({"id": request_id, "generation": generation, "target": target.actor_id, "damage": value, "direction": direction, "knockback": force, "burn": burn, "frost": frost})

func mark_dead(actor) -> void:
	registry.erase(actor.actor_id)
	if actor.is_companion: return # downed for this run; no XP drop, kill, or removal
	if actor != hero:
		enemies.erase(actor)
		actor.dead_at = clock.tick
		dead_actors.append(actor)
		deaths.append(actor)

func drop_rewards() -> void:
	for actor in deaths:
		if actor.is_boss: continue
		kills += 1
		var gem = catalog.scene("xp_gem").instantiate()
		gem.position = actor.position
		gem.value = roundi(actor.definition.xp_drop * corruption.modifiers().xp)
		gem.pickup_id = actor.actor_id
		pickups.add_child(gem)
	deaths.clear()

func spawn_enemy(id_value: StringName, point: Vector2, parent: int = -1, boss_role: bool = false, modifiers: Dictionary = {}):
	sequence += 1
	var actor = catalog.scene("boss" if boss_role else "enemy").instantiate()
	actor.setup(catalog.boss if boss_role else catalog.enemies[id_value], sequence, self, false, boss_role)
	if not boss_role:
		var spawn_modifiers = corruption.modifiers() if modifiers.is_empty() else modifiers
		actor.stats.damage *= spawn_modifiers.damage
		actor.corrupted = spawn_modifiers.damage > 1.0
	actor.position = point
	actor.parent_id = parent
	actor.deadline = clock.tick + (90 if boss_role else 0)
	actors.add_child(actor)
	enemies.append(actor)
	registry[actor.actor_id] = actor
	if boss_role: boss_actor = actor
	return actor

func create_warning(point: Vector2, shape: String, radius: float, direction: Vector2, angle: float, expires: int):
	var warning = catalog.scene("telegraph").instantiate()
	warning.position = point
	warning.geometry = shape
	warning.radius = radius
	warning.direction = direction
	warning.angle = angle
	warning.expires = expires
	telegraphs.add_child(warning)
	return warning

func create_arc(hit: Dictionary, tick: int) -> void:
	var arc = catalog.scene("melee_arc").instantiate()
	arc.run = self
	arc.position = hit.origin
	arc.direction = hit.direction
	arc.reach = hit.reach
	arc.angle = hit.angle
	arc.expires = tick + 10
	effects.add_child(arc)
	for actor in enemies:
		if arc.contains(hit.origin, hit.direction, hit.reach, hit.angle, actor.position):
			queue_hit(actor, hit.damage, hit.direction, hit.knockback, hit.burn, hit.frost)
			if hit.has("heal_source") and not damage.requests.is_empty():
				var request = damage.requests[-1]
				request["heal_source"] = hit.heal_source
				request["activation"] = hit.activation
				request["heal_fraction"] = hit.heal_fraction

func hostile_shot(point: Vector2, direction: Vector2, value: float, tick: int) -> void:
	var shot = catalog.scene("projectile").instantiate()
	shot.run = self
	shot.position = point
	shot.direction = direction
	shot.hostile = true
	shot.speed = 110.0
	shot.damage = value
	shot.knockback = 0
	shot.expires = tick + 180
	projectiles.add_child(shot)

func cleanup_effects(tick: int) -> void:
	for host in [telegraphs, effects]:
		for effect in host.get_children():
			if tick > effect.expires: effect.queue_free()
	for actor in dead_actors.duplicate():
		if tick >= actor.dead_at + 24:
			actor.queue_free()
			dead_actors.erase(actor)

func toggle_manual_pause() -> void:
	if phase != "active": return
	if manual_token < 0: manual_token = pause.acquire("manual", "menu")
	else:
		pause.release(manual_token, "menu")
		manual_token = -1

func finish(outcome: String) -> void:
	if phase != "active": return
	if outcome == "defeat" and rescue.state == "defending": rescue.advance(hero.position, false)
	phase = "results"
	choices.cancel(self)
	pause.cancel_all()
	spawns.reservations.clear()
	damage.requests.clear()
	followups.clear()
	delayed_impacts.clear()
	summary = RunSummary.freeze(self, outcome)
	run_finished.emit(summary.duplicate(true))
