extends SceneTree
func _initialize() -> void:
	ProjectSettings.set_setting("campaign/persistence_enabled",false)
	call_deferred("review")
func review() -> void:
	var scene=load("res://scenes/frontier.tscn").instantiate()
	scene.tuning=scene.tuning.duplicate()
	scene.tuning.larger_desktop_window=false
	root.add_child(scene)
	scene.paused=true
	scene.sim.frontier.wood=24
	scene.sim.frontier.food=13
	scene.sim.frontier.stone=6
	scene.sim.frontier.herbs=3
	scene.sim.world.scrap=8
	scene.sim.clock.is_night=true
	scene.sim.clock.day=3
	scene.sim.clock.survived=2
	scene.sim.clock.remaining=30
	scene.sim._spawn_remaining=5
	var overlay=CanvasLayer.new()
	overlay.layer=50
	root.add_child(overlay)
	for item in [
		["left",Vector2i(1440,810),Vector4(80,12,20,26)],
		["right",Vector2i(1440,810),Vector4(20,12,80,26)],
		["tablet",Vector2i(1280,960),Vector4(0,16,0,24)]]:
		for child in overlay.get_children():child.queue_free()
		root.size=item[1]
		scene.hud.preview_safe_margins=item[2]
		for i in range(4):await physics_frame
		scene.hud._layout()
		scene.hud.present_world(scene.sim,true,scene.knight.position.x,true)
		var safe: Rect2=scene.hud.safe_rect()
		var view: Rect2=root.get_visible_rect()
		for rect in [Rect2(0,0,safe.position.x,view.size.y),Rect2(safe.end.x,0,view.size.x-safe.end.x,view.size.y),
			Rect2(safe.position.x,0,safe.size.x,safe.position.y),Rect2(safe.position.x,safe.end.y,safe.size.x,view.size.y-safe.end.y)]:
			var shade=ColorRect.new()
			shade.position=rect.position
			shade.size=rect.size
			shade.color=Color(0,0,0,0.65)
			shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
			overlay.add_child(shade)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/mobile-"+item[0]+".png")
		print(item[0]," viewport=",view," safe=",safe)
	scene.queue_free()
	overlay.queue_free()
	await process_frame
	quit()
