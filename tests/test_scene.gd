extends SceneTree
## Exercise actual physics, InputMap, scene wiring and persistence together.
var failures: int = 0
var assertions: int = 0

func _initialize() -> void:
	call_deferred("run_scene")

func check(value: bool, description: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		printerr("FAIL: " + description)
	else:
		print("PASS: " + description)

func key(code: int, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func frames(count: int) -> void:
	for unused in range(count):
		await physics_frame

func run_scene() -> void:
	var scene = load("res://scenes/training.tscn").instantiate()
	var location := "user://test_scene_%d.json" % Time.get_ticks_usec()
	scene.progress_path = location
	root.add_child(scene)
	await frames(12)
	check(scene.knight.is_on_floor(), "knight lands on actual collision floor")
	var start_x: float = scene.knight.position.x
	key(KEY_D, true)
	await frames(12)
	key(KEY_D, false)
	check(scene.knight.position.x > start_x + 10.0, "D key moves knight through input adapter")
	key(KEY_SPACE, true)
	await frames(2)
	key(KEY_SPACE, false)
	check(scene.knight.velocity.y < 0.0, "Space starts physical jump")
	key(KEY_L, true)
	await frames(2)
	key(KEY_L, false)
	check(scene.session.hero.stamina < 100.0, "L dash consumes model stamina")
	key(KEY_ESCAPE, true)
	await frames(2)
	key(KEY_ESCAPE, false)
	check(scene.paused, "Escape pauses encounter")
	var paused_position: Vector2 = scene.knight.position
	await frames(4)
	check(scene.knight.position == paused_position, "pause freezes physical motion")
	key(KEY_R, true)
	await frames(2)
	key(KEY_R, false)
	check(not scene.paused and scene.session.hero.hp == 100, "R restarts and resumes")
	await frames(12)
	scene.knight.position = Vector2(620, 430)
	scene.sentinel.position = Vector2(660, 430)
	scene.session.hero.stats.damage = 200
	key(KEY_J, true)
	await frames(2)
	key(KEY_J, false)
	check(not scene.session.enemy.is_alive(), "J attack hits nearby sentinel")
	check(scene.session.scrap == 20, "scene grants one defeat reward")
	check(scene.store.load_scrap() == 20, "scene writes isolated progress save")
	scene.queue_free()
	await process_frame
	DirAccess.remove_absolute(location)
	print("Scene assertions: %d; failures: %d" % [assertions, failures])
	quit(0 if failures == 0 else 1)
