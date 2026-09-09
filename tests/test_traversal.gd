extends SceneTree
## Verify actual jump trajectories against authored platform collision surfaces.
var failures := 0
var assertions := 0

func _initialize() -> void:
	call_deferred("run_traversal")

func check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		printerr("FAIL: " + message)
	else:
		print("PASS: " + message)

func key(code: int, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func frames(count: int) -> void:
	for tick in range(count):
		await physics_frame

func jump_to(scene, platform) -> bool:
	var top: float = platform.position.y - 7.0
	key(KEY_D, true)
	key(KEY_SPACE, true)
	await frames(2)
	key(KEY_SPACE, false)
	for tick in range(100):
		await physics_frame
		if scene.knight.position.x >= platform.position.x:
			key(KEY_D, false)
		if tick > 5 and scene.knight.is_on_floor():
			key(KEY_D, false)
			return absf(scene.knight.position.y - top) < 1.0
	key(KEY_D, false)
	return false

func walk_to(scene, destination: float) -> void:
	key(KEY_D, true)
	for tick in range(100):
		await physics_frame
		if scene.knight.position.x >= destination:
			break
	key(KEY_D, false)

func run_traversal() -> void:
	var scene = load("res://scenes/training.tscn").instantiate()
	var path := "user://test_traversal_%d.json" % Time.get_ticks_usec()
	scene.progress_path = path
	root.add_child(scene)
	await frames(12)
	for name in ["Platform", "Platform2"]:
		var platform = scene.get_node(name)
		var shape = platform.get_node("Shape").shape
		var top: float = platform.position.y - shape.size.y * platform.scale.y * 0.5
		scene.knight.position = Vector2(platform.position.x, 430)
		scene.knight.velocity = Vector2.ZERO
		await frames(2)
		key(KEY_SPACE, true)
		await frames(2)
		key(KEY_SPACE, false)
		var apex := 430.0
		for tick in range(70):
			await physics_frame
			apex = minf(apex, scene.knight.position.y)
		print(name, " reached height ", 430.0 - apex, "; platform height ", 430.0 - top)
		check(scene.knight.is_on_floor() and absf(scene.knight.position.y - top) < 1.0, "jump from floor lands on " + name)
	var route := ["Platform", "PlatformStep1", "PlatformStep2", "Platform2"]
	var complete_route := true
	for name in route:
		complete_route = complete_route and scene.has_node(name)
	check(complete_route, "four platforms form a continuous refuge approach")
	if complete_route:
		scene.knight.position = Vector2(335, 430)
		scene.knight.velocity = Vector2.ZERO
		await frames(3)
		for index in range(route.size()):
			if index > 0:
				var previous = scene.get_node(route[index - 1])
				var width: float = previous.get_node("Shape").shape.size.x
				await walk_to(scene, previous.position.x + width * 0.5 - 18.0)
			var landed: bool = await jump_to(scene, scene.get_node(route[index]))
			check(landed, "basic movement reaches " + route[index] + " without dash or energy")
			if not landed:
				break

	scene.queue_free()
	await process_frame
	DirAccess.remove_absolute(path)
	print("Traversal assertions: %d; failures: %d" % [assertions, failures])
	quit(0 if failures == 0 else 1)
