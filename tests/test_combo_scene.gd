extends "res://tests/test_scene.gd"
## Real keyboard and touch input through the campaign composition root.
func run_scene() -> void:
	var scene = load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	await frames(8)
	scene.set_physics_process(false)
	for direction in [KEY_D,KEY_A]:
		var before: float = scene.knight.position.x
		var seen := {}
		var walking := {}
		key(direction,true)
		for tick in range(80):
			await physics_frame
			scene.paused = false
			if tick in [0,8,23]: key(KEY_J,true)
			scene._physics_process(1.0/60)
			key(KEY_J,false)
			if scene.sim.hero.attack_remaining>0:
				seen[scene.sim.hero.combo_step] = true
				if scene.knight.get_node("KnightVisual/MovingAttack").visible:
					walking[scene.sim.hero.combo_step] = true
		key(direction,false)
		check(seen.size()==3,"keyboard presses reach all three cuts in each direction")
		check(walking.size()==3,"every moving combo stage retains running legs")
		check(absf(scene.knight.position.x-before)>100,"combo preserves actual locomotion")
	# Hold the touchscreen sword: one down event is one slash, never auto-chain.
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = scene.hud.get_node("attack").get_global_transform_with_canvas().origin+Vector2(28,28)
	touch.pressed = true
	var held_steps := {}
	for tick in range(70):
		await physics_frame
		if tick==0:
			root.push_input(touch,true)
			Input.flush_buffered_events()
		scene.paused = false
		scene._physics_process(1.0/60)
		if scene.sim.hero.attack_remaining>0: held_steps[scene.sim.hero.combo_step] = true
	touch.pressed = false
	root.push_input(touch,true)
	Input.flush_buffered_events()
	check(held_steps.size()==1 and held_steps.has(1),"holding touchscreen sword produces one cut")
	var tapped_steps := {}
	for tick in range(70):
		await physics_frame
		scene.paused = false
		if tick in [0,1,8,9,23,24]:
			touch.pressed = tick in [0,8,23]
			root.push_input(touch,true)
		scene._physics_process(1.0/60)
		if scene.sim.hero.attack_remaining>0: tapped_steps[scene.sim.hero.combo_step]=true
	check(tapped_steps.size()==3,"three touchscreen taps connect the full combo")
	# Focus loss after a buffered press must not release it on resume.
	for tick in range(10):
		await physics_frame
		scene.paused = false
		if tick in [0,8]: key(KEY_J,true)
		scene._physics_process(1.0/60)
		key(KEY_J,false)
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var frozen: float = scene.sim.hero.attack_progress()
	scene._physics_process(0.2)
	check(scene.sim.hero.attack_progress()==frozen,"focus pause freezes current attack pose")
	for tick in range(35):
		await physics_frame
		scene.paused = false
		scene._physics_process(1.0/60)
	check(scene.sim.hero.combo_step!=2,"resume discards buffered follow-up")
	scene.restart()
	check(scene.sim.hero.stats.combo_enabled and scene.sim.hero.combo_step==0,"restart keeps tuning and clears old combo")
	scene.controls.release_all()
	scene.queue_free()
	await process_frame
	print("Combo scene assertions: %d; failures: %d" % [assertions,failures])
	quit(0 if failures==0 else 1)
