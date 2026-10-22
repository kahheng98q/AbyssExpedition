class_name ChoiceCoordinator
extends RefCounted

var offer: Array[StringName] = []
var offer_id: int = 0
var pause_token: int = -1
var rescue_token: int = -1
var event_token: int = -1
var promotion_token: int = -1
var promotion_id: int = 0
var promotion_hero: String = ""
var promotion_deferred: bool = false


func present_rescue(run) -> void:
	if not offer.is_empty() or event_token >= 0 or rescue_token >= 0 or promotion_token >= 0: return
	var event = run.events.offer(run.clock.tick, run.snapshot.sera_owned, run.rng.stream("event_offers"))
	if event.is_empty(): return
	run.trace.events.append({"offer": event.duplicate(true)})
	if event.kind != "lost_adventurer":
		event_token = run.pause.acquire("event", "event-choice")
		run.event_presented.emit()
		return
	if run.rescue.state != "pending":
		run.rescue_results.append(run.rescue.result())
		if is_instance_valid(run.rescue_zone): run.rescue_zone.queue_free()
		run.rescue = RescueObjective.new()
		run.rescue.owned_at_start = run.snapshot.sera_owned
	# M4 owns scheduling; owned rescues can occur in any of the three slots.
	run.rescue.state = "offered"
	rescue_token = run.pause.acquire("rescue", "rescue-choice")
	run.rescue_presented.emit()

func resolve_event(run, identity: int, id: StringName) -> bool:
	if event_token < 0 or run.events.current.get("id", -1) != identity: return false
	if not EventEffects.apply(run, id): return false
	run.trace.events.append({"id": identity, "tick": run.clock.tick, "choice": id})
	run.events.resolve(identity)
	var prior_token = event_token
	event_token = -1
	present(run)
	run.pause.release(prior_token, "event-choice")
	run.state_changed.emit()
	run.choice_closed.emit()
	return true

func resolve_rescue(run, accepted: bool) -> bool:
	if run.phase != "active" or run.rescue.state != "offered": return false
	if accepted:
		run.rescue.accept(run.hero.position)
		run.rescue_zone = run.catalog.scene("rescue_zone").instantiate()
		run.rescue_zone.objective = run.rescue
		run.rescue_zone.position = run.rescue.center
		run.add_child(run.rescue_zone)
	else: run.rescue.decline()
	if not run.events.current.is_empty():
		run.trace.events.append({"id": run.events.current.id, "tick": run.clock.tick, "choice": "accept" if accepted else "decline"})
		run.events.resolve(run.events.current.id)
	var prior_rescue = rescue_token
	var prior_event = event_token
	rescue_token = -1
	event_token = -1
	run.events.current = {}
	present(run)
	run.pause.release(prior_rescue, "rescue-choice")
	if prior_event >= 0: run.pause.release(prior_event, "event-choice")
	run.choice_closed.emit()
	return true

func present(run) -> void:
	if run.phase != "active" or not offer.is_empty() or promotion_token >= 0 or event_token >= 0 or rescue_token >= 0: return
	if not promotion_deferred:
		var candidates = PromotionService.eligible(run)
		if not candidates.is_empty():
			promotion_id += 1
			promotion_hero = candidates[0]
			promotion_token = run.pause.acquire("promotion", "promotion-choice")
			run.trace.offers.append({"kind": "promotion", "id": promotion_id, "hero": promotion_hero, "tick": run.clock.tick, "options": run.catalog.characters[StringName(promotion_hero)].base_profession.promotion_ids.duplicate()})
			run.state_changed.emit()
			run.promotion_presented.emit(promotion_id, promotion_hero)
			return
	if run.progression.pending <= 0: return
	if pause_token < 0: pause_token = run.pause.acquire("level", "choice")
	offer_id += 1
	var mode = run.hero.profession.weapon.mode
	var capabilities = [&"melee"] if mode == "arc" else ([&"projectile", &"homing"] if mode == "homing" else [&"projectile"])
	offer = UpgradeOfferService.sample(run.catalog.upgrades, run.progression.stacks, run.rng.stream("upgrade_offers"), capabilities)
	run.trace.offers.append({"id": offer_id, "tick": run.clock.tick, "options": offer.duplicate()})
	run.state_changed.emit()
	run.choice_presented.emit(offer_id, offer.duplicate())

func confirm(run, identity: int, id_value: StringName) -> bool:
	if run.phase != "active" or identity != offer_id or not offer.has(id_value): return false
	UpgradeEffects.apply(run.catalog.upgrades[id_value], run.hero, run.progression)
	run.trace.decisions.append({"tick": run.clock.tick, "offer": identity, "upgrade": id_value})
	run.progression.pending -= 1
	offer.clear()
	var prior_token = pause_token
	pause_token = -1
	present(run)
	run.pause.release(prior_token, "choice")
	run.choice_closed.emit()
	return true

func cancel(run) -> void:
	if promotion_token >= 0: run.pause.release(promotion_token, "promotion-choice")
	promotion_token = -1
	promotion_hero = ""
	promotion_deferred = false
	if event_token >= 0: run.pause.release(event_token, "event-choice")
	event_token = -1
	run.events.current = {}
	offer.clear()
	run.progression.pending = 0
	if pause_token >= 0: run.pause.release(pause_token, "choice")
	pause_token = -1
	if rescue_token >= 0: run.pause.release(rescue_token, "rescue-choice")
	rescue_token = -1

func request_promotion(run) -> void:
	if run.phase != "active": return
	promotion_deferred = false
	run.trace.decisions.append({"tick": run.clock.tick, "kind": "promotion_reopen"})
	present(run)

func confirm_promotion(run, identity: int, hero_id: String, branch: String) -> bool:
	if run.phase != "active" or promotion_token < 0 or identity != promotion_id or hero_id != promotion_hero: return false
	if not PromotionService.apply(run, hero_id, branch): return false
	run.trace.decisions.append({"kind": "promotion", "tick": run.clock.tick, "offer": identity, "hero": hero_id, "branch": branch})
	close_promotion(run)
	run.choice_closed.emit()
	return true

func cancel_promotion(run, identity: int) -> bool:
	if run.phase != "active" or promotion_token < 0 or identity != promotion_id: return false
	run.trace.decisions.append({"kind": "promotion_cancel", "tick": run.clock.tick, "offer": identity})
	promotion_deferred = true
	close_promotion(run)
	run.choice_closed.emit()
	return true

func close_promotion(run) -> void:
	var prior_token = promotion_token
	promotion_token = -1
	promotion_hero = ""
	# Acquire the next choice before releasing this one: observers/audio never
	# see a false resume between adjacent party promotions or upgrade cards.
	present(run)
	run.pause.release(prior_token, "promotion-choice")
	run.state_changed.emit()
