extends RefCounted

func run(t) -> void:
	var content = ContentCatalog.new()
	t.root.add_child(content)
	t.check(content.load_all(), "content contract baseline")
	check_sword_identities(t, content)
	var field = content.field.duplicate(true)
	field.hero_footprint = NAN
	t.check(field.validate() != "", "field rejects nonfinite hero footprint")
	var field_names = content.field.get_property_list().map(func(item): return item.name)
	t.check(field_names.has("opening_radius_min") and field_names.has("opening_radius_max") and field_names.has("opening_attempts"), "opening field contract exists")
	if field_names.has("opening_radius_min"):
		for entry in [["opening_radius_min", NAN], ["opening_radius_min", 127.0], ["opening_radius_max", INF], ["opening_radius_max", 161.0], ["opening_attempts", 15], ["opening_attempts", 0], ["spawn_warning_ticks", 46], ["separation", 97.0]]:
			field = content.field.duplicate(true)
			field.set(entry[0], entry[1])
			t.check(field.validate() != "", "opening rejects invalid " + str(entry))
		t.check(FieldDefinition.new().validate() != "", "missing required opening data fails without fallback")
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
	var wave_properties = content.waves.get_property_list().map(func(item): return item.name)
	t.check(wave_properties.has("opening_segments"), "opening segments are authored Resource data")
	if wave_properties.has("opening_segments"):
		for key in ["start", "end", "slots"]:
			wave = content.waves.duplicate(true)
			wave.opening_segments[0].erase(key)
			t.check(wave.validate() != "", "missing opening segment " + key)
		for entry in [["start", "bad"], ["start", 1], ["end", 1801], ["end", 1200], ["slots", "not-array"], ["slots", []], ["slots", ["missing_enemy", "saltbound_thrall", "saltbound_thrall", "saltbound_thrall"]]]:
			wave = content.waves.duplicate(true)
			wave.opening_segments[0][entry[0]] = entry[1]
			t.check(wave.validate() != "", "bad opening segment type/range/slots rejected " + str(entry))
		wave = content.waves.duplicate(true)
		wave.opening_segments[2].start = 3000
		t.check(wave.validate() != "", "opening overlap rejected")
		wave = content.waves.duplicate(true)
		wave.opening_segments.remove_at(4)
		t.check(wave.validate() != "", "opening gap rejected")
	var visited = {}
	content.errors.clear()
	content.validate_resource(content.upgrades[&"might"].duplicate(true), visited)
	content.validate_resource(content.upgrades[&"might"].duplicate(true), visited)
	t.check(content.errors.any(func(error): return error.contains("duplicate")), "distinct definitions cannot reuse an ID within type")
	content.free()

func check_sword_identities(t, content) -> void:
	var field = VisualSet.new().get_property_list().any(func(item): return item.name == "sword_identity")
	t.check(field, "VisualSet declares optional data-driven sword identity")
	if not field: return
	t.check(VisualSet.new().get("sword_identity") == &"", "non-sword identity defaults empty")
	var expected = {"swordsman": &"single", "swordmaster": &"dual", "abyss_swordsman": &"long"}
	for id in content.professions:
		var visual = content.professions[id].visual_set
		t.check(visual.get("sword_identity") == expected.get(String(id), &""), "profession owns visual identity " + String(id))
		var names = visual.get_property_list().map(func(item): return item.name)
		t.check(not names.has("health") and not names.has("activations"), "shared visual configuration owns no combat state")
	var invalid = content.professions[&"swordsman"].visual_set.duplicate(true)
	invalid.set("sword_identity", &"unknown")
	t.check(invalid.validate() != "", "VisualSet rejects unknown sword identity")
	t.check(content.has_method("validate_sword_identities"), "catalog validates profession/identity correspondence")
	if not content.has_method("validate_sword_identities"): return
	for id in expected:
		var probe = ContentCatalog.new()
		for key in content.professions: probe.professions[key] = content.professions[key].duplicate(true)
		probe.professions[StringName(id)].visual_set.set("sword_identity", &"dual" if id != "swordmaster" else &"single")
		probe.call("validate_sword_identities")
		t.check(not probe.errors.is_empty(), "catalog rejects mismatched identity " + id)
		probe.free()
