extends SceneTree
var assertions := 0
var failures := 0
func _initialize() -> void: call_deferred("run_test")
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
	if not ResourceLoader.exists("res://scenes/frontier.tscn"):
		check(false,"playable frontier scene exists")
		quit(1)
		return
	var training = load("res://scenes/training.tscn").instantiate()
	training.progress_path = "user://frontier_entry_test.json"
	root.add_child(training)
	current_scene = training
	await frames(4)
	await click(training.hud.get_node("Refuge"))
	await frames(12)
	var scene = current_scene
	check(scene.scene_file_path == "res://scenes/frontier.tscn","training entry opens the new playable frontier")
	check(scene.knight.is_on_floor(),"frontier has a grounded playable knight")
	var signature: String = scene.sim.frontier.layout_signature()
	key(KEY_R,true)
	await frames(2)
	key(KEY_R,false)
	check(scene.sim.frontier.layout_signature() == signature,"R replays the same map")
	await click(scene.hud.new_map_button)
	check(scene.sim.frontier.layout_signature() != signature,"new-map touch button generates a different frontier")
	var seed_before: int = scene.sim.map_seed
	key(KEY_N,true)
	await frames(2)
	key(KEY_N,false)
	check(scene.sim.map_seed != seed_before,"N is another route to a new map")
	scene.sim.clock.remaining = 10000
	check(scene.sim.frontier.city_level==0,"playable campaign starts at the campfire")
	await click(scene.hud.interact_button)
	check(scene.sim.context(30).paid==1,"touch interaction fills one crystal slot")
	await click(scene.hud.interact_button)
	scene.knight.position = Vector2(180,430)
	await frames(4)
	key(KEY_E,true)
	await frames(2)
	key(KEY_E,false)
	await frames(6)
	scene.knight.position = Vector2(scene.sim.world.sites.workshop,430)
	await frames(4)
	await click(scene.hud.interact_button)
	await click(scene.hud.interact_button)
	for tick in range(100): scene.sim.advance(0.1,520)
	check(scene.sim.world.people[0].role=="engineer","actual recruitment and workshop button equip a working resident")
	var resource
	for node in scene.sim.frontier.nodes:
		if node.kind == "tree":
			resource = node
			break
	scene.knight.position = Vector2(resource.x-20,430)
	scene.sim.hero.facing = 1
	await frames(4)
	key(KEY_E,true)
	await frames(2)
	key(KEY_E,false)
	await frames(4)
	check(resource.marked and scene.sim.hero.attack_remaining<=0,"E marks work without a knight chopping animation")
	key(KEY_J,true)
	await frames(2)
	key(KEY_J,false)
	await frames(24)
	check(resource.remaining_work==75,"knight sword leaves resource intact")
	for tick in range(2000):
		scene.sim.advance(0.1,resource.x)
		if resource.delivered: break
	await frames(3)
	check(resource.delivered and scene.sim.frontier.wood>=3,"resident harvest and physical delivery bank the resource")
	for slot in range(3): await click(scene.hud.interact_button)
	for tick in range(2000):
		scene.sim.advance(0.1,resource.x)
		if scene.sim.frontier.regions[resource.region].outpost_built: break
	await frames(3)
	check(scene.sim.frontier.regions[resource.region].outpost_built,"cleared-site button orders a resident-built frontier depot")
	check(scene.sim.frontier.discovered_count()>0,"walking outside reveals a region")
	check(scene.hud.calendar_label.text.contains("已熬過 0 晚"),"HUD displays survival calendar")
	check(scene.hud.status.text.contains("木材") and scene.hud.status.text.contains("食物"),"HUD displays both new resources")
	var cache
	for node in scene.sim.frontier.nodes:
		if node.y == 366:
			cache = node
			break
	scene.knight.position = Vector2(cache.x,430)
	scene.knight.velocity = Vector2.ZERO
	await frames(5)
	key(KEY_SPACE,true)
	await frames(2)
	key(KEY_SPACE,false)
	await frames(60)
	check(absf(scene.knight.position.y-366)<2 and scene.knight.is_on_floor(),"basic jump reaches generated ruin resource ledge")
	await click(scene.hud.interact_button)
	check(cache.delivered,"knight directly opens elevated treasure using the actual button")
	scene.knight.position = Vector2(scene.sim.frontier.left_boundary+30,430)
	await frames(6)
	check(scene.knight.is_on_floor(),"far left generated route has actual collision")
	scene.knight.position = Vector2(scene.sim.frontier.right_boundary-30,430)
	await frames(6)
	check(scene.knight.is_on_floor(),"far right generated route has actual collision")
	key(KEY_ESCAPE,true)
	await frames(2)
	key(KEY_ESCAPE,false)
	var clock_before: float = scene.sim.time_to_raid
	await frames(6)
	check(scene.paused and scene.sim.time_to_raid == clock_before,"pause freezes frontier simulation")
	scene.queue_free()
	await process_frame
	print("Frontier scene assertions: %d; failures: %d" % [assertions,failures])
	quit(0 if failures == 0 else 1)
