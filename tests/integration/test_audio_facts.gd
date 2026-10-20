extends RefCounted
const Fixture = preload("res://tests/fixtures/run_fixture.gd")

func run(t) -> void:
	check_branches_and_roles(t)
	for hero in [&"aren", &"lia", &"milo"]:
		var f = Fixture.create(t, hero)
		var r = f.run
		var present = r.has_signal("attack_committed") and r.has_signal("damage_accepted")
		t.check(present, "run publishes committed attack and accepted damage facts")
		if not present: Fixture.dispose(f); continue
		var attacks: Array = []
		var damages: Array = []
		r.attack_committed.connect(func(fact): attacks.append(fact))
		r.damage_accepted.connect(func(fact): damages.append(fact))
		t.check(not AttackExecutor.try_activate(r.hero,r,0) and attacks.is_empty(), "no target never commitsattack")
		var target = r.spawn_enemy(&"shellbound_husk",r.hero.position+Vector2(30,0))
		r.progression.stacks[&"echo_strike"] = 2
		t.check(AttackExecutor.try_activate(r.hero,r,0) and attacks.size()==1, "multi-shot/echo commits once peractivation")
		var fact = attacks[0]
		t.check(fact.size()==6 and fact.generation is int and fact.tick is int and fact.source_id is int and fact.is_companion is bool and fact.weapon_mode is StringName and fact.activation_id is int, "AttackCommitted fixed typed schema")
		t.check(fact.source_id == r.hero.actor_id and fact.weapon_mode == r.hero.profession.weapon.mode, "stable source and committed weaponmode")
		r.damage.requests.clear()
		r.queue_hit(target,1,Vector2.RIGHT,0,false,false)
		r.damage.resolve_tick_hits(r,0)
		t.check(damages.size()==1 and not damages[0].fatal and damages[0].target_role==&"enemy", "accepted surviving enemy produces hitfact")
		r.queue_hit(target,9999,Vector2.RIGHT,0,false,false)
		r.queue_hit(target,9999,Vector2.RIGHT,0,false,false)
		r.damage.resolve_tick_hits(r,1)
		t.check(damages.size()==2 and damages[1].fatal, "overkill emits one fatal, dead duplicate nofact")
		r.hero.health.invulnerable_until=100
		r.queue_hit(r.hero,10,Vector2.ZERO,0,false,false)
		r.damage.resolve_tick_hits(r,2)
		t.check(damages.size()==2, "invulnerable request produces nofact")
		# Real DoT, duplicate ID, multi-kill and boss paths use accepted facts too.
		var dotted=r.spawn_enemy(&"shellbound_husk",r.hero.position+Vector2(40,0))
		dotted.statuses.apply({"damage":20.0,"burn":true},0)
		r.clock.tick=60
		dotted.statuses.simulate(dotted,r,60)
		var before=damages.size()
		r.damage.resolve_tick_hits(r,60)
		t.check(damages.size()==before+1 and damages[-1].actual_damage>0,"DoT emits actual accepted damage")
		var last_id=r.request_id
		r.damage.enqueue_hit({"id":last_id,"generation":r.generation,"target":dotted.actor_id,"damage":999,"direction":Vector2.ZERO})
		r.damage.resolve_tick_hits(r,61)
		t.check(damages.size()==before+1,"late duplicate request emits no extra fact")
		for i in 3: r.spawn_enemy(&"saltbound_thrall",r.hero.position+Vector2(20,i*2))
		before=damages.size()
		r.create_arc({"origin":r.hero.position,"direction":Vector2.RIGHT,"reach":48.0,"angle":100.0,"damage":999.0,"knockback":0.0,"burn":false,"frost":false},62)
		r.damage.resolve_tick_hits(r,62)
		t.check(damages.slice(before).filter(func(entry): return entry.fatal).size()>=3,"range multikill emits one fatal per victim")
		var boss=r.spawn_enemy(&"tidebound_hierophant",Vector2(40,40),-1,true)
		r.queue_hit(boss,1,Vector2.ZERO,0,false,false)
		r.damage.resolve_tick_hits(r,63)
		t.check(damages[-1].target_role==&"boss" and not damages[-1].fatal,"boss role explicit")
		Fixture.dispose(f)

func check_branches_and_roles(t) -> void:
	for profession in [&"swordsman",&"archer",&"mage",&"swordmaster",&"abyss_swordsman",&"sharpshooter",&"star_hunter",&"elemental_sage",&"void_caster"]:
		var payload = ProfileData.fresh()
		payload.companions = ["lia","milo"]
		var f = Fixture.create_party(t,payload)
		var r = f.run
		r.hero.profession = r.catalog.professions[profession]
		var attacks: Array=[]
		var damages: Array=[]
		var visuals: Array=[]
		r.attack_committed.connect(func(fact): attacks.append(fact))
		r.damage_accepted.connect(func(fact): damages.append(fact))
		r.hit_confirmed.connect(func(point,direction,value,fatal,friendly): visuals.append([point,direction,value,fatal,friendly]))
		var enemy=r.spawn_enemy(&"saltbound_thrall",r.hero.position+Vector2(20,0))
		t.check(AttackExecutor.try_activate(r.hero,r,0) and attacks.size()==1 and attacks[0].weapon_mode==StringName(r.hero.profession.weapon.mode), "every branch one committed base-mode fact " + String(profession))
		r.damage.requests.clear()
		var companion=r.party[1]
		companion.debug_ai_enabled=false
		t.check(not AttackExecutor.try_activate(companion,r,0) and attacks.size()==1,"disabled companion noattackfact")
		companion.debug_ai_enabled=true
		companion.position=r.hero.position
		AttackExecutor.try_activate(companion,r,0)
		t.check(attacks.size()==2 and attacks[1].is_companion and attacks[1].source_id==companion.actor_id,"companion stable identity inattackfact")
		r.damage.requests.clear()
		r.queue_hit(companion,5,Vector2.ZERO,0,false,false)
		r.queue_hit(r.hero,5,Vector2.ZERO,0,false,false)
		r.queue_hit(enemy,9999,Vector2.RIGHT,0,false,false)
		r.damage.resolve_tick_hits(r,0)
		t.check(damages.size()==3 and damages[0].target_role==&"companion" and damages[1].target_role==&"hero" and damages[2].fatal,"roles explicit; fatal only one fact")
		t.check(visuals.size()==3 and visuals[0].size()==5 and visuals[0][4],"legacy hit_confirmed five-field visual contract retained")
		Fixture.dispose(f)
