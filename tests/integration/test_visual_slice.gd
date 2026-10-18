extends RefCounted
const Fixture=preload("res://tests/fixtures/run_fixture.gd")

func observation(run) -> Dictionary:
	var actors=[]
	for actor in run.actors.get_children():actors.append([actor.actor_id,actor.position,actor.health.current,actor.health.dead,actor.next_ready,actor.attack_until,actor.aim,actor.ai_state,actor.deadline])
	var shots=[]
	for shot in run.projectiles.get_children():shots.append([shot.position,shot.direction,shot.target_id,shot.expires,shot.hit_ids.duplicate()])
	return {"tick":run.clock.tick,"actors":actors,"shots":shots,"hits":run.damage.requests.duplicate(true),"spawns":run.trace.spawns.duplicate(true),"kills":run.kills}

func capture(t,fallback: bool) -> Array:
	var f=Fixture.create(t,&"milo",101)
	var run=f.run
	run.hero.health.invulnerable_until=99999
	run.spawn_enemy(&"saltbound_thrall",run.hero.position+Vector2(100,0))
	run.spawn_enemy(&"skittering_brinejaw",run.hero.position+Vector2(-100,0))
	var rows=[]
	for i in range(120):
		run.simulation.advance(run,[Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP][i/30])
		for actor in run.actors.get_children():
			var p=actor.get_node("Presentation");p.force_fallback=fallback;p.sync_sprite()
		for shot in run.projectiles.get_children():shot.force_fallback=fallback;shot._process(0)
		rows.append(observation(run))
		await t.physics_frame
	Fixture.dispose(f)
	await t.process_frame
	return rows

func run(t) -> void:
	print("FIXTURE test_visual_slice")
	var a=await capture(t,true)
	var b=await capture(t,false)
	t.check(a==b,"120 paired ticks: HP/hits/targets/cooldowns/spawn order/projectile paths unchanged by sprite/fallback")
	var f=Fixture.create(t)
	var run=f.run
	var hero=run.hero
	var visual=run.catalog.actor_visuals.resolve("hero",&"aren",&"swordsman")
	hero.attack_until=112
	t.check(VisualAnimation.sample(hero,104,visual)=={"state":"attack","frame":1},"first observation samples authoritative mid-attack")
	hero.health.hurt_until=108
	t.check(VisualAnimation.sample(hero,105,visual).state=="hurt","hurt interrupts attack")
	t.check(VisualAnimation.sample(hero,108,visual)=={"state":"attack","frame":2},"same attack resumes without restarting")
	t.check(VisualAnimation.sample(hero,120,visual).state=="idle","skipped expiry never replays attack")
	hero.health.dead=true;hero.dead_at=-1;hero.health.hurt_until=108
	t.check(VisualAnimation.sample(hero,108,visual).state=="death" and VisualAnimation.sample(hero,108,visual).frame==1,"hero lethal receive origin is hurt_until minus8")
	hero.health.hurt_until=-1
	t.check(VisualAnimation.sample(hero,108,visual).frame==3,"synthetic death without origin uses final pose")
	hero.health.dead=false;hero.health.hurt_until=102;hero.attack_until=-1
	t.check(VisualAnimation.sample(hero,101,visual).state=="hurt" and VisualAnimation.sample(hero,102,visual).state=="idle","two-tick feedback obeys actual deadline")
	var enemy=run.spawn_enemy(&"skittering_brinejaw",Vector2(500,270))
	var thrall=run.spawn_enemy(&"saltbound_thrall",Vector2(600,270))
	thrall.velocity=Vector2.LEFT*30
	thrall.get_node("Presentation").sync_sprite()
	t.check(thrall.get_node("Presentation").sprite.scale.x==-1,"moving contact enemy mirrors from velocity without changing AI aim")
	var crab=run.catalog.actor_visuals.resolve("enemy",&"skittering_brinejaw",&"")
	BrinejawBehavior.decide(enemy,run,100)
	t.check(enemy.ai_state=="warning" and enemy.deadline==145,"warning remains45 simulation ticks")
	enemy.health.hurt_until=141
	t.check(VisualAnimation.sample(enemy,140,crab).state=="hurt" and enemy.ai_state=="warning" and run.telegraphs.get_child_count()>0,"hurt cannot remove independent warning geometry")
	t.check(VisualAnimation.sample(enemy,141,crab).state=="warning","warning resumes at original deadline")
	BrinejawBehavior.decide(enemy,run,145)
	t.check(enemy.ai_state=="rush" and VisualAnimation.sample(enemy,145,crab).state!="warning","no late warning replay")
	enemy.health.dead=true;enemy.dead_at=100
	t.check(VisualAnimation.sample(enemy,123,crab).frame==2,"enemy death samples existing24tick lifetime")
	run.clock.tick=104;hero.health.hurt_until=-1;hero.attack_until=112
	var presentation=hero.get_node("Presentation")
	hero.position=Vector2(480.25,270.75)
	for aim in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		hero.aim=aim;presentation.sync_sprite()
		t.check(presentation.using_sprite and (presentation.sprite.transform*Vector2(visual.anchor_px)).is_zero_approx(),"mirrored fixed foot anchor; body never rotates")
	var token=run.pause.acquire("manual","visual-test")
	var pose=VisualAnimation.sample(hero,run.clock.tick,visual)
	for i in range(5):run.simulation.advance(run,Vector2.ONE);presentation.sync_sprite()
	t.check(run.clock.tick==104 and VisualAnimation.sample(hero,run.clock.tick,visual)==pose,"paused presentation frozen on run ticks")
	run.pause.release(token,"visual-test")
	run.clock.tick=110;presentation.sync_sprite()
	t.check(presentation.sprite.frame==2,"debug-speed/skipped tick samples current frame without catch-up")
	presentation.force_fallback=true;presentation.sync_sprite()
	t.check(not presentation.using_sprite and not presentation.sprite.visible,"explicit fault injection restores full procedural body")
	var arc=run.catalog.scene("melee_arc").instantiate();arc.run=run;run.effects.add_child(arc)
	t.check(arc.using_sprite,"base48/100 arc selects delivered art")
	arc.reach=60;arc._process(0)
	t.check(not arc.using_sprite,"upgraded reach keeps exact full procedural arc")
	var shot=run.catalog.scene("projectile").instantiate();shot.run=run;shot.homing=true;run.projectiles.add_child(shot)
	t.check(shot.using_sprite,"existing friendly base homing star selects delivered art")
	shot.profession=run.catalog.professions[&"void_caster"];shot._process(0)
	t.check(not shot.using_sprite,"promoted magic remains procedural")
	shot.profession=null;shot.hostile=true;shot._process(0)
	t.check(not shot.using_sprite,"hostile projectile never uses friendly art")
	hero.profession=run.catalog.professions[&"swordmaster"];presentation.force_fallback=false;presentation.sync_sprite()
	t.check(not presentation.using_sprite,"live promotion switches fully to legacy presentation")
	Fixture.dispose(f)
