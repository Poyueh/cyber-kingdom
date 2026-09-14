extends SceneTree
var scene
func _initialize():
 ProjectSettings.set_setting("campaign/persistence_enabled",false)
 ProjectSettings.set_setting("campaign/control_preview",1)
 call_deferred("run")
func capture(name: String):
 scene.view.present(scene.sim,scene.knight.position.x)
 scene.hud.present_world(scene.sim,false,scene.knight.position.x,true)
 scene.knight.get_node("Camera2D").reset_smoothing();scene.knight.get_node("Camera2D").force_update_scroll()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/world-"+name+".png")
func run():
 scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 for i in range(8):await physics_frame
 scene.set_physics_process(false);scene.knight.position.x=30
 scene._physics_process(0.016)
 var enemy=scene.sim._spawn_raider();enemy.x=280;scene.sim.raiders.append(enemy)
 await capture("people")
 scene.sim.frontier.drill_level=3;scene.sim.growth.capacitor_level=3
 scene._physics_process(0.016)
 await capture("mounted")
 for i in range(6):
  scene.knight.velocity.x=120;scene.knight.refresh_visual(0.10)
  await capture("ride-%02d"%i)
 scene.knight.position.x=scene.sim.frontier.regions[3].x-80
 scene.sim.advance(0.016,scene.knight.position.x)
 await capture("reveal-0")
 scene.sim.workforce.elapsed+=0.9
 await capture("reveal-1")
 scene.sim.workforce.elapsed+=0.9
 await capture("reveal-2")
 for side in ["left","right"]:
  scene.knight.position.x=scene.sim.frontier.left_boundary+40 if side=="left" else scene.sim.frontier.right_boundary-40
  await capture("edge-"+side)
 scene.queue_free();await process_frame;quit()
