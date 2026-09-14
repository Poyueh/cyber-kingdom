extends SceneTree
var scene
func _initialize():
 ProjectSettings.set_setting("campaign/persistence_enabled",false)
 ProjectSettings.set_setting("campaign/control_preview",1)
 call_deferred("run")
func capture(name: String):
 scene.view.present(scene.sim,scene.knight.position.x)
 scene.hud.present_world(scene.sim,scene.paused,scene.knight.position.x,true)
 scene.knight.get_node("Camera2D").reset_smoothing();scene.knight.get_node("Camera2D").force_update_scroll()
 await process_frame;await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/tmp/feedback-"+name+".png")
func run():
 scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 for i in range(8):await physics_frame
 scene.set_physics_process(false);scene.paused=false
 scene.knight.position.x=30;scene._physics_process(0.016)
 scene.sim.workforce.elapsed+=0.1
 await capture("guide")
 for region in scene.sim.frontier.regions:region.discovered=true
 scene.view.present(scene.sim,30);scene.sim.workforce.elapsed+=2
 for kind in ["forest","quarry","ruins"]:
  for region in scene.sim.frontier.regions:
   if region.kind==kind:
    scene.knight.position.x=region.x+region.width/2
    await capture(kind);break
 scene.knight.position.x=30
 scene.sim.world.people[0].x=90;scene.sim.world.people[0].role="guard"
 scene.view.present(scene.sim,30);scene.sim.world.barrier=0;scene.sim.world.hit_person(0)
 for i in range(8):
  scene.sim.workforce.elapsed+=0.18
  await capture("demotion-%02d"%i)
 scene.sim.hero.invulnerability_remaining=0;scene.sim.hero.take_damage(99999)
 for i in range(10):
  scene._physics_process(0.1)
  scene.hud.dashboard.outcome_age=i*0.13
  await capture("defeat-%02d"%i)
 scene.restart();scene.knight.position.x=30;scene._physics_process(0.016)
 scene.sim.mission.outcome="victory";scene._physics_process(0.016)
 scene.hud.dashboard._process(0)
 scene.hud.dashboard.outcome_age=2
 await capture("victory")
 scene.restart();scene.sim.mission.core_hp=0;scene._physics_process(0.01)
 scene.hud.dashboard._process(0)
 scene.hud.dashboard.outcome_age=2
 await capture("core-defeat")
 scene.queue_free();await process_frame;quit()
