extends "res://tools/preview_refuge.gd"
## Native day/night review using real scene updates and presentation.
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
	sim.frontier.farm_active=true
	sim.world.people.append({"role":"farmer","x":-200.0,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	sim.world.people.append({"role":"citizen","x":240.0,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	sim.clock.remaining=2.0
	scene.knight.position=Vector2(30,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	for tick in range(180):
		await physics_frame
		scene.paused=false
		scene._physics_process(1.0/60)
		if tick%6==0: await picture("return-%03d" % (tick/6))
	assert(sim.clock.is_night and absf(sim.world.people[0].x-30)<100)
	sim.world.people.clear()
	sim.world.wall.merge({"level":1,"hp":40},true)
	sim.world.people.append({"role":"hunter","x":1010.0,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	scene.knight.position=Vector2(850,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	sim.raiders.clear()
	var enemy=sim._spawn_raider()
	enemy.x=1140.0
	sim.raiders.append(enemy)
	for tick in range(30):
		await physics_frame
		scene.paused=false
		scene._physics_process(1.0/60)
		if tick%2==0: await picture("defense-%03d" % (tick/2))
	assert(enemy.fighter.hp<60)
	print("PASS: native residents return across dusk and hunter fires behind built wall")
	scene.queue_free()
	await process_frame
	quit()
