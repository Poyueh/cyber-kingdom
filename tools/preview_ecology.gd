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
	var forest: int=sim.frontier.regions.find(sim.frontier.regions.filter(func(r):return r.kind=="forest")[0])
	var at: float=sim.ecology.camp_x(forest)
	scene.knight.position=Vector2(at+110,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene._physics_process(1.0/60)
	await picture("camp-before")
	sim.clock.is_night=true
	sim.clock.remaining=0.01
	scene._physics_process(0.02)
	await picture("camp-after")
	var trees=sim.frontier.nodes.filter(func(n):return n.region==forest and n.kind=="tree")
	for node in trees.slice(0,3):
		node.collected=true
		node.delivered=true
	var last=trees.back()
	scene.knight.position=Vector2(last.x,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene.view.focus_key="node:%d" % sim.frontier.nodes.find(last)
	await picture("last-tree")
	last.collected=true
	last.delivered=true
	scene.view.focus_key=""
	scene.knight.position=Vector2(at+110,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene._physics_process(1.0/60)
	await picture("cleared-camp")
	print("PASS: native recruitment camp, dawn arrival and habitat loss visuals")
	scene.queue_free()
	await process_frame
	quit()
