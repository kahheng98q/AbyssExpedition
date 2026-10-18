extends SceneTree
var rows=[]
var output=""
func _initialize():call_deferred("run_capture")
func run_capture():
	var args=OS.get_cmdline_user_args()
	output=args[args.find("--output")+1]
	var catalog=ContentCatalog.new();root.add_child(catalog)
	if not catalog.load_all():quit(2);return
	var run=catalog.scene("expedition").instantiate();root.add_child(run);run.set_physics_process(false)
	run.start(catalog,RunStartSnapshot.new(101,&"milo"))
	run.hero.health.invulnerable_until=99999
	run.spawn_enemy(&"saltbound_thrall",run.hero.position+Vector2(100,0))
	run.spawn_enemy(&"skittering_brinejaw",run.hero.position+Vector2(-100,0))
	for i in range(120):
		run.simulation.advance(run,[Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP][i/30])
		var actors=[];var shots=[]
		for actor in run.actors.get_children():actors.append([actor.actor_id,[actor.position.x,actor.position.y],actor.health.current,actor.health.dead,actor.next_ready,actor.attack_until,[actor.aim.x,actor.aim.y],actor.ai_state,actor.deadline])
		for shot in run.projectiles.get_children():shots.append([[shot.position.x,shot.position.y],[shot.direction.x,shot.direction.y],shot.target_id,shot.expires,shot.hit_ids.duplicate()])
		rows.append({"tick":run.clock.tick,"actors":actors,"shots":shots,"hits":run.damage.requests.duplicate(true),"spawns":run.trace.spawns.duplicate(true),"kills":run.kills})
		await physics_frame
	var f=FileAccess.open(output,FileAccess.WRITE)
	f.store_string(JSON.stringify({"seed":101,"hero":"milo","ticks":120,"catalog_digest":catalog.digest,"simulation_version":ReplayTrace.SIMULATION_VERSION,"observations":rows},"  "));f.close()
	run.free();catalog.free();quit()
