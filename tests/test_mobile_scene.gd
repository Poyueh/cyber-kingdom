extends "res://tests/test_scene.gd"
func touch(index: int, at: Vector2, down: bool):
 var event=InputEventScreenTouch.new();event.index=index;event.position=at;event.pressed=down
 root.push_input(event,true);Input.flush_buffered_events()
func drag(index: int, at: Vector2):
 var event=InputEventScreenDrag.new();event.index=index;event.position=at
 root.push_input(event,true);Input.flush_buffered_events()
func center(button) -> Vector2:
 return button.position+(button.size if button is Control else button.texture_normal.get_size())*0.5
func run_scene() -> void:
 var scene=load("res://scenes/frontier.tscn").instantiate();root.add_child(scene)
 await frames(8)
 check(scene.knight.position.x<scene.sim.world.sites.hall-800,"new journey begins in wilderness away from campfire")
 scene.set_physics_process(false);scene.knight.position.x=30;scene.paused=false
 var hud=scene.hud
 scene._physics_process(1.0/60)
 check(not hud.get_node("move_left").visible and not hud.get_node("move_right").visible,"movement buttons replaced with drag surface")
 touch(0,Vector2(100,300),true);drag(0,Vector2(160,300))
 check(hud.movement_axis()>0.9,"left thumb drags right to move")
 touch(1,Vector2(650,200),true);drag(1,Vector2(650,255))
 scene._physics_process(1.0/60)
 check(scene.sim.pouch.amount==11,"right downward drag invests one crystal near camp")
 check(hud.movement_axis()>0.9,"payment finger preserves movement finger")
 touch(1,Vector2(650,255),false)
 touch(0,Vector2(160,300),false)
 scene.knight.position.x=-600;scene._physics_process(1.0/60)
 touch(2,Vector2(650,200),true);drag(2,Vector2(650,255));scene._physics_process(1.0/60)
 check(scene.sim.pouch.ground_total()==1,"downward drag without target throws a crystal")
 touch(2,Vector2(650,255),false)
 touch(3,Vector2(100,300),true);drag(3,Vector2(160,300))
 scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(hud.movement_axis()==0 and not hud.interact_held,"focus loss cancels every gesture")
 scene.paused=false;scene._physics_process(1.0/60)
 touch(4,Vector2(100,300),true);drag(4,Vector2(160,300))
 check(hud.movement_axis()>0.9,"new finger works without old release after background")
 await process_frame
 touch(5,center(hud.get_node("attack")),true)
 var before: float=scene.knight.position.x
 scene.set_physics_process(true);await frames(3);scene.set_physics_process(false)
 check(scene.sim.hero.attack_remaining>0 and absf(scene.knight.position.x-before)<0.01,"attack button works while dragging and roots first cut")
 touch(5,center(hud.get_node("attack")),false);touch(4,Vector2(160,300),false)
 hud.preview_safe_margins=Vector4(90,18,30,32);hud._layout()
 for key in ["attack","jump","dash"]:
  var button=hud.get_node(key)
  check(hud.safe_rect().encloses(Rect2(button.position,Vector2(64,64))),"combat button stays within safe area")
 scene.queue_free();await process_frame
 print("Mobile scene assertions: %d; failures: %d"%[assertions,failures]);quit(0 if failures==0 else 1)
