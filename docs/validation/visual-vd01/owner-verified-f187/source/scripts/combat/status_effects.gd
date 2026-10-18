class_name StatusEffects
extends RefCounted

const BURN_UPGRADE = preload("res://data/upgrades/ember_touch.tres")
const FROST_UPGRADE = preload("res://data/upgrades/frost_mark.tres")
var burn_until: int = -1
var next_burn: int = -1
var burn_damage: float = 0.0
var slow_until: int = -1
var burn_period: int = 60
var slow_fraction: float = 0.0

func apply(hit: Dictionary, tick: int, burn_definition: EffectDefinition = null, frost_definition: EffectDefinition = null) -> void:
	if hit.get("burn", false):
		var effect = burn_definition if burn_definition != null else BURN_UPGRADE.effects[0]
		burn_period = effect.period_ticks
		if burn_until < tick: next_burn = tick + burn_period
		burn_until = tick + effect.duration_ticks
		burn_damage = hit.damage * effect.amount / (effect.duration_ticks / float(burn_period))
	if hit.get("frost", false):
		var effect = frost_definition if frost_definition != null else FROST_UPGRADE.effects[0]
		slow_until = tick + effect.duration_ticks
		slow_fraction = effect.amount

func speed_multiplier(tick: int, resistant: bool) -> float:
	return 1.0 - slow_fraction if tick < slow_until and not resistant else 1.0

func simulate(actor, run, tick: int) -> void:
	if next_burn > 0 and tick >= next_burn and tick <= burn_until:
		run.queue_hit(actor, burn_damage, Vector2.ZERO, 0.0, false, false)
		next_burn += burn_period
