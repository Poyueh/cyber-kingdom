extends SceneTree
## Deterministic visual review of the real campaign; no user records are opened.
var scene
var frame_index:=0
var enemy: Dictionary
var output:="/tmp/cyber-spirit-frames-final"
func _initialize() -> void:
 call_deferred("begin")
func begin() -> void:
 DirAccess.make_dir_recursive_absolute(output)
 scene=load("res://scenes/frontier.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.set_physics_process(false)
 scene.paused=false
 scene.hud.control_mode=2
 scene.sim.clock.remaining=10000
 scene.sim.world.people.clear()
 scene.sim.world.people.append({"role":"guard","x":-90.0,"y":430.0,"hurt":0.0,"cooldown":999.0,"direction":1.0})
 enemy=scene.sim._spawn_raider();enemy.x=180.0;enemy.cooldown=999.0
 scene.sim.raiders.append(enemy)
 scene._physics_process(0.01)
 scene.knight.get_node("Camera2D").force_update_scroll()
 for index in range(96):
  frame_index=index
  if index==12:scene.sim.hero.take_damage(12)
  if index==32:scene.sim.world.hit_person(0)
  if index==52:enemy.fighter.take_damage(8)
  if index==74:
   enemy.fighter.invulnerability_remaining=0
   enemy.fighter.take_damage(999)
  scene._physics_process(1.0/30)
  if scene.sim.raiders.has(enemy):enemy.x=180.0
  scene.sim.world.people[0].x=-90.0
  scene.view.present(scene.sim,scene.knight.position.x)
  scene.knight.refresh_visual(0)
  await process_frame
  await RenderingServer.frame_post_draw
  if index%2==0:
   root.get_texture().get_image().save_png(output.path_join("frame-%03d.png"%index))
 print("Visual frames: ",output)
 scene.queue_free()
 await process_frame
 quit()
