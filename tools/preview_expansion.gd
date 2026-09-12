extends "res://tools/preview_refuge.gd"
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	scene.paused=false
	var sim=scene.sim
	sim.world.people.clear()
	var id: String="frontier_wall:3"
	var x: float=sim.world.sites[id]
	sim.frontier.regions[3].discovered=true
	sim.frontier.city_level=1
	scene.knight.position=Vector2(x,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene.view.focus_key=id+":0:false"
	await picture("locked")
	scene.view.focus_key=""
	sim.frontier.city_level=2
	sim.frontier.regions[3].outpost_built=true
	sim.frontier.regions[3].outpost_x=x-200
	sim.world.wall.merge({"level":1,"hp":40},true)
	for node in sim.frontier.nodes:
		if node.kind=="tree" and absf(node.x-x)<80:node.collected=true
	await invest();await invest();await invest()
	sim.world.people.append({"role":"engineer","x":x-12,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	sim.world.people.append({"role":"guard","x":x-150,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	for frame in range(70):
		scene._physics_process(0.1)
		await picture("build-%03d" % frame)
	assert(sim.world.walls[id].hp==40)
	await picture("built")
	sim.world.walls[id].hp=0
	for frame in range(24):
		scene._physics_process(0.1)
		await picture("fallback-%03d" % frame)
	await picture("broken")
	print("PASS: native outward construction, completed wall, guard advance and fallback")
	scene.queue_free()
	await process_frame
	quit()
