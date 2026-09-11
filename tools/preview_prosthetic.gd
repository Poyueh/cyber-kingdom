extends "res://tools/preview_refuge.gd"
## Art fixture: displays existing animation presentation with supplied poses.
## Does not claim live gameplay or change production state/rules.
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	scene.paused=false
	scene.sim.frontier.city_level=1
	scene.sim.built={"workshop":true}
	scene.sim.world.people.clear()
	for index in range(6):
		scene.sim.world.people.append({"x":150+index*95,"y":430,"role":["wanderer","citizen","engineer","farmer","hunter","guard"][index],"hurt":0.0,"cooldown":0.0,"region":-1,"direction":1.0,"moving":false,"work_state":"idle"})
	scene.knight.position=Vector2(50,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	var sprite=scene.knight.get_node("KnightVisual")
	for clip in sprite.sprite_frames.get_animation_names():
		for index in range(sprite.sprite_frames.get_frame_count(clip)):
			var texture: AtlasTexture=sprite.sprite_frames.get_frame_texture(clip,index)
			assert(Rect2(Vector2.ZERO,texture.atlas.get_size()).encloses(texture.region),"Frame outside new atlas")
	var sequence := [
		{"clip":"idle","count":12},{"clip":"run","count":12},
		{"clip":"dash","count":4},{"clip":"jump","count":4},
		{"clip":"attack","count":8},{"clip":"attack-left","count":8},
		{"clip":"idle","count":12}]
	var number:=0
	for segment in sequence:
		for index in range(segment.count):
			var pose: Dictionary={"alive":true,"facing":-1 if segment.clip=="attack-left" else 1,"invulnerable":false,"moving":segment.clip=="run","grounded":segment.clip!="jump","attack_progress":1.0}
			var fraction: float=float(index)/segment.count
			scene.knight.position.y=430
			if segment.clip.begins_with("attack"): pose.attack_progress=fraction
			elif segment.clip=="dash":
				pose.dashing=true
				pose.dash_progress=fraction
			elif segment.clip=="jump":
				pose.vertical_speed=[-500,-160,0,250][index]
				scene.knight.position.y=430-[18,35,42,15][index]
			scene.sim.workforce.elapsed+=1.0/12
			for person in scene.sim.world.people:
				person.moving=segment.clip=="run"
				if person.role=="engineer":
					person.work_state="work" if segment.clip.begins_with("attack") else ("haul" if segment.clip=="run" else "idle")
			sprite.present(pose,1.0/12)
			await picture("frame-%03d" % number)
			if index==0: await picture(segment.clip)
			number+=1
	print("PASS: native character fixture; all atlas regions in bounds; idle/run/dash/jump/attack and mirrored attack captured.")
	scene.queue_free()
	await process_frame
	quit()
