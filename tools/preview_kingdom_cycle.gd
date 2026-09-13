extends "res://tools/preview_refuge.gd"
## Explicit visual fixtures: resource clearing and tier changes here are staged, not earned.
func move_to(x: float) -> void:
	scene.knight.position=Vector2(x,430)
	scene.sim.frontier.reveal(x)
	scene.knight.get_node("Camera2D").reset_smoothing()
	await frames(3)
func capture() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	ProjectSettings.set_setting("campaign/persistence_enabled",true)
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=output+"/preview.json"
	scene.audio_preferences_path=output+"/audio.cfg"
	root.add_child(scene);root.size=Vector2i(1440,810)
	await frames(8);scene.set_physics_process(false);scene.paused=false
	scene.hud.first_day_guidance=false;scene.hud.expedition_guidance=false
	scene.hud.control_mode=2;scene.view.keyboard_hint=true
	await picture("desktop-start")
	for kind in ["forest","quarry","ruins"]:
		var region=scene.sim.frontier.regions.filter(func(r):return r.kind==kind)[0]
		await move_to(region.x+region.width*0.5)
		await picture(kind)
	var region=scene.sim.frontier.regions[0]
	var x:float=region.x+region.width*0.5
	await move_to(x)
	await picture("uncleared")
	for node in scene.sim.frontier.nodes:
		if node.region==0:node.collected=true;node.delivered=true
	region.outpost_ready=true;region.outpost_x=x
	scene.sim.frontier.city_level=2
	await picture("cleared")
	await invest()
	await picture("crystal-slot")
	for tier in range(4):
		scene.sim.frontier.drill_level=tier;scene.sim.growth.capacitor_level=tier
		scene.knight.visual.set_equipment(tier,tier)
		scene.knight.refresh_visual(0)
		await picture("equipment-%d"%tier)
	scene.paused=true;scene.view.interactions_visible=false
	await picture("desktop-menu")
	scene.hud.control_mode=1;scene.view.keyboard_hint=false
	scene.hud.preview_safe_margins=Vector4(35,0,35,18)
	root.size=Vector2i(1280,720);await frames(3);scene.hud._layout()
	await picture("mobile-menu")
	scene.paused=false;scene.view.interactions_visible=true
	await picture("mobile-play")
	await move_to(scene.sim.mission.rifts[1].x-80)
	scene.sim.clock.remaining=0.01
	scene._physics_process(0.02)
	await picture("gate-spawn")
	print("PASS: native cycle, scenery, equipment, platform HUD and menu captures")
	scene.queue_free();await process_frame
	for suffix in ["/preview.json","/preview.json.manual","/audio.cfg"]:DirAccess.remove_absolute(output+suffix)
	quit()
