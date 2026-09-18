extends SceneTree
## Renders the campaign view at fixed positions so a rendering change can be
## proved pixel-identical. Run once per revision with a different --tag, then
## compare the two sets with cmp. Not part of tools/check.sh:
##   godot --path . --script res://tools/capture_view_parity.gd -- --no-campaign-save --tag=before
var scene
var tag: String="after"
func _initialize():
	ProjectSettings.set_setting("campaign/persistence_enabled",false)
	ProjectSettings.set_setting("campaign/control_preview",1)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--tag="):tag=argument.substr(6)
	call_deferred("run")

func shot(name: String) -> void:
	scene.view.present(scene.sim,scene.knight.position.x)
	scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
	scene.knight.get_node("Camera2D").reset_smoothing()
	scene.knight.get_node("Camera2D").force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("user://parity-%s-%s.png" % [tag,name])

func run():
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	for i in range(8):await physics_frame
	scene.set_physics_process(false)
	scene.paused=false
	scene.knight.position=Vector2(30,430)
	scene._physics_process(0.016)
	scene.sim.workforce.elapsed=7.0
	await shot("00-camp-undiscovered")
	for region in scene.sim.frontier.regions:region.discovered=true
	scene.sim.frontier.city_level=3
	scene.sim.barracks_level=3
	for site in ["armory","workshop","hunt_tools","farm_tools","forge"]:scene.sim.built[site]=true
	await shot("01-camp-discovered")
	# Scatter piles densely so some land exactly on the screen edges.
	for index in range(120):scene.sim.pouch.drop(1,float(index)*40.0-2400.0,430.0)
	await shot("02-camp-crystals")
	var index: int=0
	for region in scene.sim.frontier.regions:
		scene.knight.position.x=region.x+region.width*0.5
		scene._physics_process(0.016)
		await shot("03-region-%02d" % index)
		index+=1
	for x in [scene.sim.frontier.left_boundary+40.0,scene.sim.frontier.right_boundary-40.0,-1100.0,1230.0]:
		scene.knight.position.x=x
		scene._physics_process(0.016)
		await shot("04-edge-%d" % int(x))
	quit()
