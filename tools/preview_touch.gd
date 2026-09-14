extends SceneTree
var scene
func _initialize():
 ProjectSettings.set_setting("campaign/persistence_enabled",false)
 ProjectSettings.set_setting("campaign/control_preview",1)
 call_deferred("run")
func touch(id: int, at: Vector2, pressed: bool):
 var event=InputEventScreenTouch.new();event.index=id;event.position=at;event.pressed=pressed
 root.push_input(event,true);Input.flush_buffered_events()
func drag(id: int, at: Vector2):
 var event=InputEventScreenDrag.new();event.index=id;event.position=at
 root.push_input(event,true);Input.flush_buffered_events()
func capture(name: String):
 scene.view.present(scene.sim,scene.knight.position.x)
 scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
 scene.knight.get_node("Camera2D").reset_smoothing()
 scene.knight.get_node("Camera2D").force_update_scroll()
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/touch-"+name+".png")
func run():
 scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 for i in range(8):await physics_frame
 scene.set_physics_process(false);scene.knight.position.x=30;scene._physics_process(0.016)
 touch(1,Vector2(150,320),true);drag(1,Vector2(200,320))
 await capture("movement")
 touch(1,Vector2(200,320),false)
 var before: int=scene.sim.pouch.amount
 touch(2,Vector2(200,230),true);drag(2,Vector2(200,265));touch(2,Vector2(200,265),false)
 scene._physics_process(0.016)
 print("Quick left down: ",before," -> ",scene.sim.pouch.amount)
 await capture("payment")
 scene.queue_free();await process_frame;quit()
