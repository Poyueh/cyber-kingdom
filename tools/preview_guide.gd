extends SceneTree
func _initialize() -> void:
 ProjectSettings.set_setting("campaign/persistence_enabled",false)
 call_deferred("review")
func review() -> void:
 var scene=load("res://scenes/frontier.tscn").instantiate()
 root.add_child(scene)
 for i in range(8):await physics_frame
 scene.set_physics_process(false)
 scene.paused=false
 for stage in ["camp","recruit"]:
  scene._physics_process(1.0/60)
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/tmp/guide-"+stage+".png")
  scene.hud.interact_button.button_down.emit()
  scene._physics_process(1.0/60)
  scene._physics_process(0.6)
  scene.hud.interact_button.button_up.emit()
  scene._physics_process(1.0/60)
 scene.queue_free()
 await process_frame
 quit()
