extends RefCounted

func run(t) -> void:
	var content = ContentCatalog.new()
	t.root.add_child(content)
	t.check(content.load_all(), "content contract baseline")
	var field = content.field.duplicate(true)
	field.hero_footprint = NAN
	t.check(field.validate() != "", "field rejects nonfinite hero footprint")
	var weapon = content.weapons[&"straight"].duplicate(true)
	weapon.ricochet_limit = -1
	t.check(weapon.validate() != "", "weapon rejects negative ricochet count")
	var visual = content.professions[&"mage"].visual_set.duplicate(true)
	visual.palette = Color(NAN, 1, 1)
	t.check(visual.validate() != "", "visual palette rejects nonfinite components")
	var burn = content.upgrades[&"ember_touch"].effects[0].duplicate(true)
	burn.target_scope = "hero"
	t.check(burn.validate() != "", "status handler rejects unsupported individual scope")
	for field_name in ["stat_category", "stack_policy", "target_scope"]:
		var effect = content.upgrades[&"might"].effects[0].duplicate(true)
		effect.set(field_name, "unknown_capability")
		t.check(effect.validate() != "", "effect rejects unknown " + field_name)
	var upgrade = content.upgrades[&"might"].duplicate(true)
	upgrade.required_capabilities.assign([&"unsupported"])
	t.check(upgrade.validate() != "", "upgrade rejects unknown required capability")
	t.check(UpgradeOfferService.eligible({upgrade.id: upgrade}, {}).is_empty(), "incompatible upgrade is excluded")
	var wave = content.waves.duplicate(true)
	wave.phases[1].introduce = ["missing_enemy"]
	t.check(wave.validate() != "", "unknown introduction cannot pass validation")
	wave = content.waves.duplicate(true)
	wave.phases[1].ids = "not an array"
	t.check(wave.validate() != "", "malformed wave fields fail without runtime errors")
	var visited = {}
	content.errors.clear()
	content.validate_resource(content.upgrades[&"might"].duplicate(true), visited)
	content.validate_resource(content.upgrades[&"might"].duplicate(true), visited)
	t.check(content.errors.any(func(error): return error.contains("duplicate")), "distinct definitions cannot reuse an ID within type")
	content.free()
