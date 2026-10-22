class_name PromotionService
extends RefCounted

static func actor_for(run, hero_id: String):
	if run == null: return null
	for actor in run.party:
		if String(actor.definition.id) == hero_id: return actor
	return null

static func reason(run, hero_id: String, branch: String = "") -> String:
	if run == null or run.phase != "active": return "Promote during an expedition at RUN Lv15."
	var actor = actor_for(run, hero_id)
	if actor == null: return "Character is not deployed."
	if actor.health.dead: return "Downed members cannot promote."
	if run.progression.branches.has(hero_id) or actor.profession.id != actor.definition.base_profession.id: return "Already promoted this run."
	if run.progression.level < 15: return "Requires RUN Lv15."
	if branch != "" and not actor.definition.base_profession.promotion_ids.has(StringName(branch)): return "Branch belongs to another base class."
	return ""

static func eligible(run) -> Array[String]:
	var ids: Array[String] = []
	if run == null: return ids
	for actor in run.party:
		var id = String(actor.definition.id)
		if reason(run, id) == "": ids.append(id)
	return ids

static func apply(run, hero_id: String, branch: String) -> bool:
	if branch.is_empty() or reason(run, hero_id, branch) != "": return false
	var actor = actor_for(run, hero_id)
	run.progression.branches[hero_id] = branch
	CharacterFactory.apply_run_profession(actor, branch)
	run.state_changed.emit()
	return true
