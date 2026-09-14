extends SceneTree
var scene
func _initialize():
 ProjectSettings.set_setting("campaign/persistence_enabled",false)
 call_deferred("run")
func capture(name: String):
 scene.view.present(scene.sim,scene.knight.position.x)
 scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
 scene.knight.get_node("Camera2D").reset_smoothing()
 scene.knight.get_node("Camera2D").force_update_scroll()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/dragon-"+name+".png")
func run():
 scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 await process_frame;await process_frame
 scene.set_physics_process(false);scene.hud.control_mode=2
 await capture("arrival")
 scene.knight.position.x=scene.sim.frontier.regions[3].x-160
 scene.sim.advance(0.01,scene.knight.position.x)
 await capture("mist")
 scene.knight.position.x=30;scene.sim.frontier.city_level=2;scene.sim.clock.day=6;scene.sim.clock.survived=5
 for r in scene.sim.mission.rifts:r.sealed=true
 scene.sim.advance(0.01,30)
 var boss=scene.sim.raiders[0];boss.x=300;boss.direction=-1;boss.target={"kind":"hero","x":30.0};boss.windup=1.3
 await capture("boss")
 for i in range(12):
  scene.sim.workforce.elapsed+=0.1
  boss.windup=0 if i<8 else 1.3
  await capture("motion-%02d"%i)
 scene.hud.control_mode=1
 scene.knight.position.x=-1020
 await capture("touch")
 scene.queue_free();await process_frame;quit()
