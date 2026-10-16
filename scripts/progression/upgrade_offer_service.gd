class_name UpgradeOfferService
extends RefCounted

static func eligible(catalog: Dictionary, stacks: Dictionary, capabilities: Array = []) -> Array[StringName]:
	var ids: Array[StringName] = []
	for id_value in catalog:
		var definition = catalog[id_value]
		if definition.required_capabilities.any(func(capability): return not capabilities.has(capability)): continue
		if definition.max_stacks == 0 or stacks.get(id_value, 0) < definition.max_stacks: ids.append(id_value)
	ids.sort_custom(func(a, b): return String(a) < String(b))
	return ids

static func sample(catalog: Dictionary, stacks: Dictionary, rng: RandomNumberGenerator, capabilities: Array = []) -> Array[StringName]:
	var pool = eligible(catalog, stacks, capabilities)
	var offer: Array[StringName] = []
	for i in range(3):
		var index = rng.randi_range(0, pool.size() - 1)
		offer.append(pool[index])
		pool.remove_at(index)
	return offer
