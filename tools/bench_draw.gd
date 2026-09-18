extends SceneTree
## Draw-call probe for the campaign view. Not part of tools/check.sh:
##   godot --path . --script res://tools/bench_draw.gd -- --no-campaign-save
var scene
func _initialize():
	ProjectSettings.set_setting("campaign/persistence_enabled",false)
	ProjectSettings.set_setting("campaign/control_preview",1)
	call_deferred("run")

func measure(label: String) -> void:
	scene.view.present(scene.sim,scene.knight.position.x)
	scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
	scene.knight.get_node("Camera2D").reset_smoothing()
	scene.knight.get_node("Camera2D").force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var calls: int=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var items: int=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)
	print("DRAW %-22s calls=%5d objects=%5d" % [label,calls,items])

func run():
	scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	for i in range(8):await physics_frame
	scene.set_physics_process(false)
	scene.paused=false
	scene.knight.position=Vector2(30,430)
	scene._physics_process(0.016)
	await measure("start (undiscovered)")
	for region in scene.sim.frontier.regions:region.discovered=true
	scene.sim.workforce.elapsed+=5
	await measure("all regions discovered")
	for index in range(40):scene.sim.pouch.drop(1,float(index)*140.0-1500.0,430.0)
	await measure("+40 ground crystals")
	scene.sim.frontier.city_level=3
	scene.sim.barracks_level=3
	for site in ["armory","workshop","hunt_tools","farm_tools","forge"]:scene.sim.built[site]=true
	await measure("late game camp")
	quit()
