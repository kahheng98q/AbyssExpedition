extends CharacterBody2D

var actor_id: int = 0
var definition: Resource
var stats: StatBlock
var starting_stats: StatBlock
var profession: ProfessionDefinition
var passive: SkillDefinition
var is_companion: bool = false
var companion_slot: int = -1
var permanent_level: int = 1
var debug_ai_enabled: bool = true
var blocked_ticks: int = 0
var health: ActorHealth
var statuses: StatusEffects = StatusEffects.new()
var is_hero: bool = false
var is_boss: bool = false
var corrupted: bool = false
var contract_bonuses: Dictionary = {}
var resistant: bool = false
var resistance: float = 1.0
var knockback: Vector2 = Vector2.ZERO
var next_ready: int = 0
var activations: int = 0
var passive_activations: int = 0
var bastion_interval: int = -1
var last_passive_tick: int = -1
var attack_until: int = -1
var ai_state: String = "ready"
var deadline: int = 0
var aim: Vector2 = Vector2.RIGHT
var parent_id: int = -1
var dead_at: int = -1
var run

func setup(content: Resource, identity: int, expedition, hero_role: bool = false, boss_role: bool = false) -> void:
	definition = content
	actor_id = identity
	run = expedition
	is_hero = hero_role
	is_boss = boss_role
	var baseline = content.base_profession.starting_stats if hero_role else content.stats
	stats = baseline.duplicate(true)
	starting_stats = stats.duplicate(true)
	if hero_role: profession = content.base_profession
	health = ActorHealth.new(stats.max_health)
	if not hero_role and not boss_role:
		resistance = content.damage_reduction
		resistant = content.behavior_kind == "armored"
	if boss_role: resistant = true

func visual() -> VisualSet:
	return profession.visual_set if is_hero else definition.visual_set
