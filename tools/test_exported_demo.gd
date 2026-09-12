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
	# Confirm the exported model also exposes the new left-side interaction.
	scene.knight.position.x=scene.sim.world.sites.wall_left
	scene._physics_process(1.0/60)
	for i in range(3):
		scene.hud.interact_button.button_down.emit()
		scene._physics_process(1.0/60)
		scene.hud.interact_button.button_up.emit()
		scene._physics_process(1.0/60)
	assert(scene.sim.world.walls.wall_left.pending and not scene.sim.world.wall.pending)
	assert(scene.sim.pouch.amount==6)
	scene.view.present(scene.sim,scene.knight.position.x)
	scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
	await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("/tmp/cyber-exported-mac-review.png")
	assert(scene.sim.mission.rifts.size()==2 and scene.sim.mission.core_hp==180)
	scene.sim.mission.damage_core(180)
	scene._physics_process(1.0/60)
	assert(scene.sim.hero.is_alive() and scene.hud.dashboard.dead)
	assert(scene.hud.get_node("restart").visible and scene.hud.drop_button.disabled)
	scene.restart()
	assert(scene.sim.is_running() and scene.sim.mission.core_hp==180)
	assert(scene.sim.mission.rifts.all(func(r):return not r.ordered and not r.discovered))
	scene.paused=true
	var time: float=scene.sim.clock.remaining
	scene._physics_process(1)
	assert(scene.sim.clock.remaining==time)
	scene.restart()
	assert(scene.sim.frontier.city_level==0 and scene.sim.pouch.amount==12)
	print("PASS: exported bundle entry, camp investment, recruitment, left-wall investment, core defeat, mission reset, pause, restart, and resource exclusions")
	scene.queue_free()
	await process_frame
	quit()
