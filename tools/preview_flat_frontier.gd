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
 root.get_texture().get_image().save_png("/tmp/flat-"+name+".png")
func run():
 scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 for i in range(8):await physics_frame
 scene.set_physics_process(false);scene.paused=false
 scene.knight.position=Vector2(30,430);scene._physics_process(0.016)
 for region in scene.sim.frontier.regions:region.discovered=true
 scene.view.present(scene.sim,30);scene.sim.workforce.elapsed+=3
 scene.sim.frontier.city_level=3;scene.sim.barracks_level=3
 for site in ["armory","workshop","hunt_tools","farm_tools","forge"]:scene.sim.built[site]=true
 await capture("camp")
 scene.knight.position.x=scene.sim.world.sites.armory
 await capture("barracks")
 for kind in ["forest","quarry","ruins"]:
  for region in scene.sim.frontier.regions:
   if region.kind==kind:
    scene.knight.position.x=region.x+region.width/2
    await capture(kind);break
 scene.knight.position.x=30
 for i in range(8):
  scene.knight.velocity.x=300;scene.knight.refresh_visual(0.09)
  await capture("run-%02d"%i)
 for mounted in [false,true]:
  scene.knight.set_mounted(mounted)
  for step in range(1,4):
   scene.sim.hero.cooldown_remaining=0;scene.sim.hero.stamina=100;scene.sim.hero._begin_attack(step)
   for i in range(8):
    scene.sim.hero.attack_remaining=scene.sim.hero._swing_duration*(1.0-i/8.0)
    scene.knight.velocity.x=0;scene.knight.refresh_visual(0.016)
    await capture(("mounted" if mounted else "slash")+"-%d-%02d"%[step,i])
 scene.sim.hero.attack_remaining=0
 scene.sim.clock.is_night=true;scene.sim.clock.remaining=1000
 scene.sim.world.people.clear()
 for i in range(6):scene.sim.world.people.append({"role":"hunter" if i<2 else "citizen","x":30.0,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
 for id in ["wall","wall_left"]:scene.sim.world.walls[id].merge({"hp":80,"level":2},true)
 for i in range(400):scene.sim._advance_people(0.1)
 await capture("night")
 scene.queue_free();await process_frame;quit()
