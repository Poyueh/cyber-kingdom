extends SceneTree
var assertions := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run_test")
func check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		printerr("FAIL: ",message)
	else: print("PASS: ",message)
func frames(count: int) -> void:
	for tick in range(count): await physics_frame
func key(code: int, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func click(button: Button) -> void:
	var at := root.get_final_transform()*button.get_global_rect().get_center()
	for down in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await frames(2)
func run_test() -> void:
	var scene = load("res://scenes/settlement.tscn").instantiate()
	root.add_child(scene)
	await frames(12)
	check(scene.knight.is_on_floor(),"knight stands in walkable refuge")
	key(KEY_E,true)
	await frames(2)
	key(KEY_E,false)
	await frames(10)
	check(scene.sim.world.people[0].role == "citizen","E throws supplies and nearby wanderer collects them")
	check(scene.sim.world.scrap == 13,"one press spends one supply")
	var before: float = scene.knight.position.x
	key(KEY_D,true)
	await frames(12)
	key(KEY_D,false)
	check(scene.knight.position.x>before+20,"existing movement controls walk through refuge")
	scene.knight.position = Vector2(scene.sim.world.sites.workshop,430)
	await frames(3)
	await click(scene.hud.interact_button)
	check(scene.sim.world.tools.hammer == 1,"pointer interaction stocks tool at nearby workshop")
	for tick in range(100): scene.sim.advance(0.1,scene.knight.position.x)
	await frames(2)
	check(scene.sim.world.people[0].role == "engineer","stocked tool autonomously becomes engineer profession")
	scene.knight.position = Vector2(scene.sim.world.sites.wall,430)
	await frames(2)
	key(KEY_E,true)
	await frames(2)
	key(KEY_E,false)
	check(scene.sim.world.wall.pending,"site interaction orders construction")
	for tick in range(160): scene.sim.advance(0.1,scene.knight.position.x)
	await frames(2)
	check(scene.sim.world.wall.level == 1,"engineer finishes physical site construction")
	key(KEY_ESCAPE,true)
	await frames(2)
	key(KEY_ESCAPE,false)
	var remaining: float = scene.sim.time_to_raid
	var resources: int = scene.sim.world.scrap
	key(KEY_E,true)
	await frames(12)
	key(KEY_E,false)
	check(scene.sim.time_to_raid == remaining and scene.sim.world.scrap == resources,"pause freezes wave clock and blocks spending")
	key(KEY_R,true)
	await frames(2)
	key(KEY_R,false)
	check(not scene.paused and scene.sim.world.scrap == 14 and scene.sim.world.people[0].role == "wanderer","retry resets complete disposable simulation")
	scene.sim.begin_raid()
	await frames(3)
	var raider: Dictionary = scene.sim.raiders[0]
	scene.knight.position = Vector2(raider.x-30,430)
	scene.sim.hero.facing = 1
	key(KEY_J,true)
	await frames(2)
	key(KEY_J,false)
	await frames(12)
	check(raider.fighter.hp == 35,"knight sword input damages an actual settlement raider")
	scene.queue_free()
	await process_frame
	print("Settlement scene assertions: %d; failures: %d" % [assertions,failures])
	quit(0 if failures == 0 else 1)
