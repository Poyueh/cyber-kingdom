extends SceneTree
## Run with the editor executable plus --main-pack pointing at the actual exported PCK.
## Release templates do not accept --script; this checks packaged resources, not OS input.
func _initialize() -> void:
	call_deferred("review")
func review() -> void:
	assert(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/frontier.tscn")
	assert(not ResourceLoader.exists("res://tests/test_scene.gd"))
	var scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	for i in range(8):await physics_frame
	scene.set_physics_process(false)
	for i in range(2):
		scene.hud.interact_button.button_down.emit()
		scene._physics_process(1.0/60)
		scene.hud.interact_button.button_up.emit()
		scene._physics_process(1.0/60)
	assert(scene.sim.frontier.city_level==1 and scene.sim.pouch.amount==10)
	scene.knight.position.x=scene.sim.world.people[0].x
	scene._physics_process(1.0/60)
	scene.hud.interact_button.button_down.emit()
	scene._physics_process(1.0/60)
	scene.hud.interact_button.button_up.emit()
	assert(scene.sim.world.people[0].role=="citizen" and scene.sim.pouch.amount==9)
	scene.view.present(scene.sim,scene.knight.position.x)
	scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
	await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("/tmp/cyber-exported-mac-review.png")
	scene.paused=true
	var time: float=scene.sim.clock.remaining
	scene._physics_process(1)
	assert(scene.sim.clock.remaining==time)
	scene.restart()
	assert(scene.sim.frontier.city_level==0 and scene.sim.pouch.amount==12)
	print("PASS: exported bundle entry, camp investment, recruitment, pause, restart, and resource exclusions")
	scene.queue_free()
	await process_frame
	quit()
