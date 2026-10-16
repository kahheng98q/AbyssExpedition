class_name RunSummary
extends RefCounted

static func freeze(run, outcome: String) -> Dictionary:
	var participants = [String(run.snapshot.hero_id)]
	for member in run.snapshot.members.slice(1): participants.append(member.id)
	var rescue = run.rescue.result()
	var successes = 0
	for result in run.rescue_results + [rescue]:
		if result.state == "succeeded" and result.owned_at_start: successes += 1
	rescue["repeat_successes"] = successes
	return {"outcome": outcome, "hero": run.snapshot.hero_id, "hero_name": run.hero.definition.display_name, "seed": run.snapshot.seed_value, "ticks": run.clock.tick, "time": run.clock.display_time(), "level": run.progression.level, "kills": run.kills, "upgrades": run.progression.stacks.duplicate(true), "trace": run.trace.snapshot(), "participants": participants, "rescue": rescue, "corruption": run.corruption.value, "chapter": "coast"}
