extends "res://tools/preview_refuge.gd"
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	# Compact visual fixture; subsequent movement/attack goes through real InputMap.
	scene.sim.frontier.city_level=1
	scene.sim.built={"workshop":true}
	scene.sim.world.people[0].role="citizen"
	scene.sim.world.people[0].x=30
	var moving_strikes:=0
	var origins: Array=[]
	for person in scene.sim.world.people: origins.append(float(person.x))
	for tick in range(300):
		await physics_frame
		scene.paused=false
		if tick==0: Input.action_press("move_right")
		if tick==100:
			Input.action_release("move_right")
			Input.action_press("move_left")
		if tick==200: Input.action_release("move_left")
		if tick in [28,72,128,172,230,270]: Input.action_press("attack")
		scene._physics_process(1.0/60)
		Input.action_release("attack")
		if scene.knight.get_node("KnightVisual/MovingAttack").visible: moving_strikes+=1
		if tick%3==0: await picture("frame-%03d" % (tick/3))
	assert(moving_strikes>8,"actual movement and attack must use continuous legs")
	var moved:=false
	for index in range(scene.sim.world.people.size()):
		moved=moved or absf(scene.sim.world.people[index].x-origins[index])>8
	assert(moved,"residents must change world positions")
	scene.paused=true
	var time: float=scene.sim.workforce.elapsed
	var before: Array=[]
	for person in scene.sim.world.people: before.append(person.x)
	for tick in range(30): scene._physics_process(1.0/60)
	assert(scene.sim.workforce.elapsed==time)
	for index in range(before.size()): assert(scene.sim.world.people[index].x==before[index])
	print("PASS: InputMap left/right movement, moving and planted attacks, actual strolling, pause; moving strike ticks=",moving_strikes)
	scene.controls.release_all()
	scene.queue_free()
	await process_frame
	quit()
