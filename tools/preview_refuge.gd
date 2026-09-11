extends SceneTree
## Native visual review; HUD interaction signals, repositioning and manual time steps keep this deterministic.
var scene
var output := "/tmp/refuge-review"
func _initialize() -> void:
	if not OS.get_cmdline_user_args().is_empty(): output=OS.get_cmdline_user_args()[0]
	call_deferred("capture")
func frames(count: int) -> void:
	for tick in range(count): await physics_frame
func key(code: int, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode=code
	event.keycode=code
	event.pressed=down
	Input.parse_input_event(event)
	Input.flush_buffered_events()
func invest() -> void:
	scene.paused=false
	scene.hud.interact_button.button_down.emit()
	scene._physics_process(1.0/60)
	scene.hud.interact_button.button_up.emit()
	scene._physics_process(1.0/60)
	await process_frame
func picture(name: String) -> Image:
	scene.view.present(scene.sim,scene.knight.position.x)
	scene.hud.present_world(scene.sim,scene.paused,scene.knight.position.x,true)
	await process_frame
	RenderingServer.force_draw(false)
	var result := root.get_texture().get_image()
	result.save_png(output+"/"+name+".png")
	return result
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	await frames(8)
	scene.set_physics_process(false)
	await picture("start")
	await invest()
	await invest()
	assert(scene.sim.frontier.city_level==1)
	scene.knight.position=Vector2(180,430)
	scene._physics_process(1.0/60)
	await process_frame
	await invest()
	scene.knight.position=Vector2(scene.sim.world.sites.workshop,430)
	scene._physics_process(1.0/60)
	await process_frame
	await invest()
	await invest()
	assert(scene.sim.built.get("workshop",false))
	for tick in range(100): scene.sim.advance(0.1,scene.knight.position.x)
	assert(scene.sim.world.people[0].role=="engineer")
	scene.knight.position=Vector2(60,430)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
	scene.set_physics_process(false)
	await picture("camp")
	for frame in range(30):
		scene._physics_process(0.1)
		await picture("motion-%03d" % frame)
	scene.paused=true
	var before: float=scene.sim.workforce.elapsed
	var frozen := await picture("pause-before")
	for tick in range(30): scene._physics_process(1.0/60)
	var after := await picture("pause-after")
	assert(scene.sim.workforce.elapsed==before)
	# The bottom strip contains the river; no HUD/pause dialog pixels.
	var strip := Rect2i(0,780,1440,30)
	assert(frozen.get_region(strip).get_data()==after.get_region(strip).get_data())
	print("PASS: HUD-signal investment/recruitment/workshop flow; native river image freezes on pause.")
	scene.queue_free()
	await process_frame
	quit()
