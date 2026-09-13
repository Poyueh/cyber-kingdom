extends "res://tools/preview_refuge.gd"
## Visual fixture: positions/roles are staged for inspection, not a normal-budget playthrough.
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	var sim=scene.sim
	sim.frontier.city_level=1
	sim.world.people.clear()
	var roles=["wanderer","citizen","farmer","hunter","guard","engineer"]
	for i in range(roles.size()):
		sim.world.people.append({"role":roles[i],"x":-150.0+i*82,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	scene.knight.position=Vector2(30,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	for tick in range(360):
		await physics_frame
		scene.paused=false
		scene._physics_process(1.0/60)
		if tick%6==0: await picture("residents-%03d" % (tick/6))
	scene.paused=true
	var time: float=sim.workforce.elapsed
	var frozen:=await picture("paused")
	for tick in range(12):
		await physics_frame
		scene._physics_process(1.0/60)
	var after:=await picture("paused-after")
	assert(sim.workforce.elapsed==time)
	assert(frozen.get_region(Rect2i(0,420,1440,230)).get_data()==after.get_region(Rect2i(0,420,1440,230)).get_data())
	var region: Dictionary=sim.frontier.regions.back()
	scene.knight.position=Vector2(region.x+region.width*0.5,430)
	sim.frontier.reveal(scene.knight.position.x)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene.paused=false
	await picture("outer-frontier")
	print("PASS: native resident movement rendered, resident pixels freeze on pause, outer map rendered")
	scene.queue_free()
	await process_frame
	quit()
