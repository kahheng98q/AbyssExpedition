class_name EffectDefinition
extends Resource

@export var kind: StringName
@export var stat_category: StringName
@export var amount: float = 0.0
@export var duration_ticks: int = 0
@export var stack_policy: String = "add"
@export var target_scope: String = "living_party"
@export var period_ticks: int = 60
@export var secondary_scale: float = 0.5
@export var followup_ticks: int = 6

const STATS = [&"max_health", &"damage", &"frequency", &"speed", &"reach", &"defense", &"knockback", &"pickup_radius"]

func validate() -> String:
	if not is_finite(amount) or amount <= 0 or duration_ticks < 0: return "invalid effect amount/duration"
	if kind not in [&"percent", &"flat", &"heal", &"heal_added", &"echo", &"burn", &"frost"]: return "unknown effect capability"
	if kind in [&"burn", &"frost"] and duration_ticks <= 0: return "status duration must be positive"
	if stack_policy not in ["add", "refresh"]: return "unknown stack policy"
	if (kind in [&"burn", &"frost"]) != (stack_policy == "refresh"): return "stack policy does not match effect handler"
	if target_scope not in ["hero", "living_party"]: return "unknown target scope"
	if target_scope == "hero" and kind in [&"burn", &"frost", &"echo"]: return "unsupported individual status/extra-attack scope"
	if kind in [&"percent", &"flat", &"heal"] and stat_category not in STATS: return "unknown stat category"
	if kind == &"heal_added" and stat_category != &"max_health": return "added-health healing requires max_health"
	if kind in [&"echo", &"burn", &"frost"] and stat_category != kind: return "effect category/capability mismatch"
	if kind in [&"heal", &"frost"] and amount > 1: return "invalid healing/slow fraction"
	if kind == &"burn" and (period_ticks <= 0 or duration_ticks % period_ticks != 0): return "burn requires whole positive tick periods"
	if kind == &"echo" and (amount != floor(amount) or not is_finite(secondary_scale) or secondary_scale <= 0 or secondary_scale > 1 or followup_ticks < 1): return "invalid echo count/scale/delay"
	return ""
