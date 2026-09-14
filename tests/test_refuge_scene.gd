extends SceneTree
var assertions := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run_test")
func check(value: bool, message: String) -> void:
	assertions += 1
	if not value:
		failures += 1
		printerr("FAIL: ", message)
	else:
		print("PASS: ", message)
func frames(count: int) -> void:
	for tick in range(count):
		await physics_frame
func click(button: Button) -> void:
	# Input events use window coordinates, including headless stretch/letterbox.
	var at := root.get_final_transform() * button.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await frames(2)

func key(code: int, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func run_test() -> void:
	var packed = load("res://scenes/refuge.tscn")
	check(packed != null, "refuge prototype loads independently")
	if packed == null:
		quit(1)
		return
	var scene = packed.instantiate()
	root.add_child(scene)
	await frames(2)
	await click(scene.panel.choices[2])
	check(scene.run.preview().knight_shield == 40, "allocation button updates shield preview")
	scene.panel.depart_button.pressed.emit()
	await frames(3)
	check(scene.battle_view != null and not scene.panel.visible, "departure opens playable encounter")
	check(scene.battle_view.session.hero.shield == 40, "encounter uses allocated shield")
	check(scene.battle_view.store == null, "prototype never opens permanent progress file")
	check(not scene.battle_view.hud.get_node("restart").visible, "encounter cannot reset spent shield")
	scene.battle_view.session.hero.take_damage(50)
	check(scene.battle_view.session.hero.hp == 50, "shield overflow reaches prototype knight health")
	scene.battle_view.hud.get_node("Refuge").pressed.emit()
	await frames(3)
	check(scene.battle_view == null and scene.panel.visible, "retreat returns to refuge")
	check(scene.run.finish().wounded == 2, "retreat settles residents according to committed allocation")
	check(scene.panel.residents.wounded == 2, "resident display reflects injuries")
	scene.panel.depart_button.pressed.emit()
	await frames(2)
	check(scene.run.preview().knight_crystals == 0, "retry restores initial allocation")
	scene.panel.depart_button.pressed.emit()
	await frames(3)
	scene.battle_view.session.hero.take_damage(999)
	await frames(3)
	check(scene.run.finish().outcome == "defeat", "combat death automatically returns a result")
	check(scene.run.finish().wounded == 0, "full refuge protection survives knight defeat")
	# Retry and use keyboard retreat while paused: no free combat reset.
	scene.panel.depart_button.pressed.emit()
	scene.panel.choices[1].pressed.emit()
	scene.panel.depart_button.pressed.emit()
	await frames(3)
	key(KEY_ESCAPE, true)
	await frames(2)
	key(KEY_ESCAPE, false)
	check(scene.battle_view.paused, "expedition can pause normally")
	key(KEY_R, true)
	await frames(2)
	key(KEY_R, false)
	check(scene.battle_view == null and scene.run.finish().outcome == "retreat", "R while paused settles instead of refilling shield")
	# A real sword resolution triggers the automatic victory return.
	scene.panel.depart_button.pressed.emit()
	scene.panel.depart_button.pressed.emit()
	await frames(3)
	scene.battle_view.session.hero.stats.damage = 200
	scene.battle_view.session.hero.start_attack()
	scene.battle_view.session.advance(0.18)
	scene.battle_view.session.resolve_sword(20,0)
	await frames(3)
	check(scene.battle_view == null and scene.run.finish().outcome == "victory", "victory automatically returns to residents")
	check(scene.run.finish().recovered == 20, "victory result shows earned salvage")
	scene.panel.depart_button.pressed.emit()
	scene.panel.depart_button.pressed.emit()
	await frames(3)
	check(scene.battle_view.hud.status.text.ends_with(" 0"), "new expedition HUD shows this run's salvage only")
	scene.queue_free()
	await process_frame
	print("Refuge scene assertions: %d; failures: %d" % [assertions, failures])
	quit(0 if failures == 0 else 1)
