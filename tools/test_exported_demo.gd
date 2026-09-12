extends SceneTree
## Run from outside any project (for example --path /tmp) with the editor executable
## plus --main-pack pointing at the actual exported PCK. Local res:// files must not overlay it.
## Release templates do not accept --script; this checks packaged resources, not OS input.
func _initialize() -> void:
	if DisplayServer.get_name()=="headless":
		printerr("This review captures a native screenshot; run without --headless.")
		quit(1)
		return
	ProjectSettings.set_setting("campaign/persistence_enabled",false)
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
	scene.sim.world.people.clear()
	scene.sim.frontier.city_level=1
	scene.sim.world.scrap=3
	scene.knight.position.x=350
	scene._physics_process(1.0/60)
	for i in range(2):
		scene.hud.interact_button.button_down.emit()
		scene._physics_process(1.0/60)
		scene.hud.interact_button.button_up.emit()
		scene._physics_process(1.0/60)
	assert(scene.sim.hero.shield==20 and scene.sim.growth.capacity()==20)
	assert(scene.hud.dashboard.values.shield_capacity==20 and scene.hud.interact_button.disabled)
	scene.sim.hero.take_damage(15)
	scene.hud.interact_button.button_down.emit()
	scene._physics_process(1.0/60)
	scene.hud.interact_button.button_up.emit()
	assert(scene.sim.hero.shield==20 and scene.sim.world.scrap==0)
	scene.restart()
	scene.sim.clock.is_night=true
	scene.sim.clock.remaining=0.01
	scene._physics_process(0.02)
	assert(scene.sim.clock.day==2 and scene.sim.world.people.size()==14)
	scene._physics_process(0.02)
	assert(scene.sim.world.people.size()==14)
	var arrival: Dictionary=scene.sim.world.people.back()
	scene.knight.position=Vector2(arrival.x,430)
	for i in range(2):await physics_frame
	scene._physics_process(1.0/60)
	var before_recruit: int=scene.sim.pouch.amount
	scene.hud.interact_button.button_down.emit()
	scene._physics_process(1.0/60)
	scene.hud.interact_button.button_up.emit()
	assert(arrival.role=="citizen" and scene.sim.pouch.amount==before_recruit-1)
	scene.paused=true
	scene.sim.clock.is_night=true
	scene.sim.clock.remaining=0.01
	scene._physics_process(0.02)
	assert(scene.sim.clock.day==2 and scene.sim.world.people.size()==14)
	scene.restart()
	assert(scene.sim.world.people.size()==8 and scene.sim.ecology.last_dawn==1)
	scene.sim.frontier.city_level=2
	scene.sim.world.people.clear()
	var wall_id: String="frontier_wall:3"
	var wall_x: float=scene.sim.world.sites[wall_id]
	scene.sim.frontier.regions[3].discovered=true
	scene.sim.frontier.regions[3].outpost_built=true
	scene.sim.world.wall.merge({"level":1,"hp":40},true)
	for node in scene.sim.frontier.nodes:
		if node.kind=="tree" and absf(node.x-wall_x)<80:node.collected=true
	scene.knight.position=Vector2(wall_x,430)
	for i in range(2):await physics_frame
	scene._physics_process(1.0/60)
	assert(scene.view._context.id=="wall" and scene.view._context.x==wall_x)
	for i in range(3):
		scene.hud.interact_button.button_down.emit()
		scene._physics_process(1.0/60)
		scene.hud.interact_button.button_up.emit()
		scene._physics_process(1.0/60)
	assert(scene.sim.world.walls[wall_id].pending and scene.sim.pouch.amount==9)
	scene.sim.world.people.append({"role":"engineer","x":wall_x-12,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
	for i in range(200):scene._physics_process(1.0/60)
	assert(scene.sim.world.walls[wall_id].hp==40 and scene.sim.defenses.active_post(1)==wall_id)
	scene.sim.clock.remaining=0.01
	scene._physics_process(0.02)
	assert(scene.sim.raiders[0].x>wall_x)
	print("PASS: outward wall touch payment, resident construction and outside spawn in exported bundle")
	print("PASS: dawn recruitment, payment, no duplicate renewal, pause and reset in exported bundle")
	print("PASS: bounded capacitor install, recharge and HUD in exported bundle")
	print("PASS: exported bundle entry, camp investment, recruitment, left-wall investment, core defeat, mission reset, pause, restart, and resource exclusions")
	scene.queue_free()
	await process_frame
	ProjectSettings.set_setting("campaign/persistence_enabled",true)
	var location="user://test_packaged_campaign_%d.json" % Time.get_ticks_usec()
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=location
	root.add_child(scene)
	for i in range(3):await physics_frame
	scene.sim.interact(30)
	scene.sim.throw_crystal(30,430,-1)
	scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert(scene.progress.status=="saved")
	var wallet: int=scene.sim.pouch.amount
	scene.queue_free()
	await process_frame
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=location
	root.add_child(scene)
	for i in range(3):await physics_frame
	assert(scene.paused and scene.sim.context(30).paid==1)
	assert(scene.sim.pouch.amount==wallet and scene.sim.pouch.ground_total()==1)
	assert(scene.hud.save_button.visible)
	scene.queue_free()
	await process_frame
	DirAccess.remove_absolute(location)
	print("PASS: actual packaged campaign saves, reopens paused and preserves payment and thrown crystal")
	quit()
