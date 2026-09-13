extends "res://tools/preview_refuge.gd"
## Controlled states for native visual inspection; not a normal-budget playthrough.
func capture() -> void:
 DirAccess.make_dir_recursive_absolute(output)
 scene=load("res://scenes/frontier.tscn").instantiate()
 root.add_child(scene)
 root.size=Vector2i(1440,810)
 await frames(8)
 scene.set_physics_process(false)
 scene.paused=false
 var sim=scene.sim
 sim.clock.survived=1
 sim.clock.day=2
 sim.frontier.city_level=1
 await picture("upgrade")
 sim.frontier.city_level=2
 var r: Dictionary=sim.mission.rifts[0]
 r.discovered=true;r.ordered=true;r.worker=0
 var worker: Dictionary=sim.world.people[0]
 worker.role="engineer";worker.x=r.x+160
 scene.knight.position=Vector2(r.x+80,430)
 sim._player_y=430
 scene.knight.get_node("Camera2D").reset_smoothing()
 await frames(3)
 await picture("escort")
 worker.x=r.x-r.side*28
 var enemy=sim._spawn_raider()
 enemy.x=r.x-50
 sim.raiders.append(enemy)
 r.wardens_spawned=true
 await picture("fight")
 enemy.fighter.hp=0
 sim.raiders.clear()
 r.progress=4
 await picture("seal")
 scene.queue_free()
 await process_frame
 print("PASS: expedition icon visual fixtures rendered")
 quit()
