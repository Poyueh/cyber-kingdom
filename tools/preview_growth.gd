extends "res://tools/preview_refuge.gd"
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	scene.paused=false
	await invest();await invest()
	scene.sim.world.people.clear()
	scene.sim.world.scrap=20
	scene.sim.frontier.food=20
	scene.knight.position=Vector2(350,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	await picture("first-capacitor")
	await invest();await invest()
	await picture("locked-capacitor")
	scene.sim.hero.take_damage(15)
	await picture("refill")
	scene.sim.frontier.city_level=2
	await invest()
	await picture("second-capacitor")
	scene.knight.position=Vector2(1230,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	await invest();await invest()
	await picture("sword-training")
	print("PASS: native capacity, recharge, prerequisite and sword growth previews")
	scene.queue_free()
	await process_frame
	quit()
