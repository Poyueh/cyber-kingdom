extends "res://tools/preview_refuge.gd"
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
	for side in [1,-1]:
		var id: String="wall" if side>0 else "wall_left"
		sim.world.walls[id].merge({"level":1,"hp":40},true)
		sim.world.people.append({"role":"guard","x":sim.world.sites[id]-side*65,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	sim.clock.remaining=0.01
	for tick in range(160):sim.advance(1.0/60,30)
	var left_enemy=sim.raiders.filter(func(r):return r.get("side",1)<0)[0]
	left_enemy.x=sim.world.sites.wall_left-100
	scene.knight.position=Vector2(sim.world.sites.wall_left+80,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	for tick in range(60):
		await physics_frame
		scene.paused=false
		scene._physics_process(1.0/60)
		if tick%3==0:await picture("left-%03d" % (tick/3))
	var right_enemy=sim.raiders.filter(func(r):return r.get("side",1)>0)[0]
	right_enemy.x=sim.world.sites.wall+100
	scene.knight.position=Vector2(sim.world.sites.wall-210,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	for tick in range(60):
		await physics_frame
		scene.paused=false
		scene._physics_process(1.0/60)
		if tick%3==0:await picture("right-%03d" % (tick/3))
	print("PASS: native bilateral defense rendered with directional warnings")
	scene.queue_free()
	await process_frame
	quit()
