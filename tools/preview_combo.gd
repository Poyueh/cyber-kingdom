extends "res://tools/preview_refuge.gd"
## Fixed-step native capture. InputMap drives all attacks and actual locomotion.
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene = load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size = Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	# A durable raid opponent, away from villagers, permits all three visible hits.
	scene.sim.clock.remaining = 0.01
	scene.sim.advance(0.02,30,430)
	scene.sim.clock.is_night = false
	scene.sim.clock.remaining = 180.0
	var raider = scene.sim.raiders[0]
	raider.x = 62.0
	raider.fighter.hp = 200
	raider.fighter.stats.max_hp = 200
	raider.cooldown = 10.0
	var seen := {}
	var rooted := true
	var stepping := false
	for tick in range(210):
		await physics_frame
		scene.paused = false
		if tick in [8,16,31,88,96,111,158,166,181]: Input.action_press("attack")
		if tick==75: Input.action_press("move_right")
		if tick==135:
			Input.action_release("move_right")
			Input.action_press("move_left")
		if tick==205: Input.action_release("move_left")
		# Injected actions become just-pressed on the next engine physics frame.
		# Screenshots can skip intervening frames; consume before capturing.
		await physics_frame
		var before: float = scene.knight.position.x
		scene._physics_process(1.0/60)
		Input.action_release("attack")
		if scene.sim.hero.attack_remaining>0:
			seen[scene.sim.hero.combo_step]=true
			if scene.sim.hero.combo_step==1: rooted = rooted and absf(scene.knight.position.x-before)<0.01
			else: stepping = stepping or absf(scene.knight.position.x-before)>0.1
		if tick%2==0: await picture("frame-%03d" % (tick/2))
	if seen.size()!=3 or not rooted or not stepping:
		printerr("FAIL: native combo stages ",seen)
		quit(1)
		return
	print("PASS: native InputMap-driven three-cut combo, rooted first slash and followup steps with held direction")
	scene.controls.release_all()
	scene.queue_free()
	await process_frame
	quit()
