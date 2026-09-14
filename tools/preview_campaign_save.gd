extends SceneTree
## Native preview from a real saved/reopened scene, using an isolated checkpoint.
var location: String
func _initialize() -> void:
	call_deferred("review")
func review() -> void:
	location="user://preview_campaign_%d.json" % Time.get_ticks_usec()
	var scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=location
	root.add_child(scene)
	root.size=Vector2i(1440,810)
	for i in range(8):await physics_frame
	scene.hud.interact_button.button_down.emit()
	await physics_frame
	scene.hud.interact_button.button_up.emit()
	scene.hud.drop_button.pressed.emit()
	await physics_frame
	scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	assert(scene.progress.status=="saved",scene.progress.last_error)
	scene.queue_free()
	await process_frame
	scene=load("res://scenes/frontier.tscn").instantiate()
	scene.campaign_save_path=location
	root.add_child(scene)
	for i in range(4):await physics_frame
	assert(scene.paused and scene.sim.context(30).paid==1 and scene.sim.pouch.ground_total()==1)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/campaign-resumed.png")
	DirAccess.make_dir_absolute(location+".tmp")
	assert(not scene.save_campaign())
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/campaign-save-retry.png")
	DirAccess.remove_absolute(location+".tmp")
	scene.hud.save_button.pressed.emit()
	assert(scene.progress.status=="saved")
	scene.queue_free()
	await process_frame
	DirAccess.remove_absolute(location)
	print("PASS: saved campaign reopened paused; retry icon recovered storage.")
	quit()
