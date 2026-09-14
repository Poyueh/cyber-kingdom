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
 root.get_texture().get_image().save_png("/tmp/fort-"+name+".png")
func run():
 scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 for i in range(8):await physics_frame
 scene.set_physics_process(false);scene.paused=false;scene.knight.position=Vector2(890,430)
 scene.sim.frontier.city_level=3
 for region in scene.sim.frontier.regions:region.discovered=true
 scene.view.present(scene.sim,890);scene.sim.workforce.elapsed+=3
 for tier in range(1,4):
  scene.sim.buildings.beacon.level=tier
  scene.sim.world.wall.merge({"level":tier,"hp":scene.sim.world.wall_max_hp(tier)},true)
  scene.sim.raiders.clear();scene.sim.effects.clear()
  var enemy=scene.sim._spawn_raider();enemy.x=1220;scene.sim.raiders.append(enemy)
  scene.sim.buildings.beacon.cooldown=0;scene.sim._advance_towers(0.01)
  await capture("tier-%d"%tier)
  scene.knight.position.x=1100
  await capture("wall-%d"%tier)
  scene.knight.position.x=890
 scene.sim.raiders.clear();scene.sim.effects.clear()
 for kind in ["wall","tower","farm"]:
  for id in scene.sim.buildings:
   var site: Dictionary=scene.sim.buildings[id]
   if site.kind!=kind or site.node<0:continue
   for resource in scene.sim.frontier.nodes:
    if absf(resource.x-site.x)<90:resource.collected=true
   scene.knight.position.x=site.x
   await capture("plot-"+kind)
   if kind=="wall":scene.sim.world.walls[id].merge({"level":1,"hp":40},true)
   else:site.level=1
   await capture("built-"+kind)
   break
 scene.sim.clock.is_night=true;scene.sim.clock.remaining=100
 scene.knight.position.x=890;scene.sim.buildings.beacon.level=1;scene.sim.buildings.beacon.pending=true
 scene.sim.world.people.clear();scene.sim.world.people.append({"role":"engineer","x":890.0,"y":430.0,"hurt":0.0,"cooldown":0.0,"region":-1})
 scene.sim.advance(1.0,890)
 await capture("night-work")
 scene.queue_free();await process_frame;quit()
