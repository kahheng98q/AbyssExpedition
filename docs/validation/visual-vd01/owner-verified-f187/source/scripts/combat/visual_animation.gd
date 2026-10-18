class_name VisualAnimation
extends RefCounted

# Event origins always come from simulation. Observing a pose never starts an event.
static func sample(actor,tick: int,visual: VisualSet) -> Dictionary:
	var state="idle"
	var start=0
	var final_pose=false
	if actor.health.dead:
		state="death"
		start=actor.dead_at
		if start<0 and actor.is_hero and actor.health.hurt_until>=8:start=actor.health.hurt_until-8
		final_pose=start<0 or start>tick
	elif tick<actor.health.hurt_until:
		state="hurt"
	elif tick<actor.attack_until and visual.sprite_frames.has_animation(&"attack"):
		state="attack";start=actor.attack_until-12
	elif actor.ai_state=="warning" and tick<actor.deadline and visual.sprite_frames.has_animation(&"warning"):
		state="warning";start=actor.deadline-45
	elif actor.velocity.length_squared()>1:state="move"
	var frames=visual.sprite_frames
	var count=frames.get_frame_count(state)
	var index=maxi(0,floori((tick-start)*frames.get_animation_speed(state)/60.0))
	if final_pose:index=count-1
	elif frames.get_animation_loop(state):index=index%count
	else:index=mini(index,count-1)
	return {"state":state,"frame":index}
