extends "res://tests/test_scene.gd"
func touch(index: int, at: Vector2, down: bool):
	var event:=InputEventScreenTouch.new()
	event.index=index
	event.position=at
	event.pressed=down
	root.push_input(event,true)
	Input.flush_buffered_events()
func center(button) -> Vector2:
	if button is Control:return button.position+button.size*0.5
	return button.position+button.texture_normal.get_size()*0.5
func run_scene() -> void:
	var scene=load("res://scenes/frontier.tscn").instantiate()
	root.add_child(scene)
	await frames(8)
	scene.set_physics_process(false)
	scene.paused=false
	var hud=scene.hud
	touch(0,center(hud.get_node("move_right")),true)
	touch(1,center(hud.interact_button),true)
	scene._physics_process(1.0/60)
	check(Input.is_action_pressed("move_right"),"movement remains held while another finger invests")
	check(scene.sim.pouch.amount==11,"second finger invests while first holds movement")
	touch(1,center(hud.interact_button),false)
	scene._physics_process(1.0/60)
	touch(2,center(hud.drop_button),true)
	touch(2,center(hud.drop_button),false)
	scene._physics_process(1.0/60)
	check(scene.sim.pouch.ground_total()==1,"another finger drops crystal while moving")
	touch(0,center(hud.get_node("move_right")),false)
	touch(3,center(hud.get_node("move_right")),true)
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not Input.is_action_pressed("move_right"),"focus loss releases active movement")
	scene.paused=false
	touch(4,center(hud.get_node("move_right")),true)
	check(Input.is_action_pressed("move_right"),"fresh finger can move after focus returns without old release event")
	touch(4,center(hud.get_node("move_right")),false)
	await process_frame
	touch(5,center(hud.get_node("move_right")),true)
	touch(6,center(hud.get_node("attack")),true)
	var before: float=scene.knight.position.x
	scene.set_physics_process(true)
	await frames(3)
	scene.set_physics_process(false)
	check(scene.sim.hero.attack_remaining>0 and absf(scene.knight.position.x-before)<0.01,"attack finger roots first cut while movement finger remains held")
	touch(6,center(hud.get_node("attack")),false)
	touch(5,center(hud.get_node("move_right")),false)
	scene.restart()
	scene._physics_process(1.0/60) # Release frame before a new gesture.
	touch(7,center(hud.interact_button),true)
	scene._physics_process(1.0/60)
	scene._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	scene.paused=false
	scene._physics_process(1.0/60) # Resuming clears the deliberate release guard.
	touch(8,center(hud.interact_button),true)
	scene._physics_process(1.0/60)
	check(scene.sim.frontier.city_level==1,"fresh investment finger works after background without old finger release")
	touch(8,center(hud.interact_button),false)
	check(hud.has_method("safe_rect"),"HUD exposes actual safe area layout")
	if hud.has_method("safe_rect"):
		hud.preview_safe_margins=Vector4(90,18,30,32)
		hud._layout()
		var safe: Rect2=hud.safe_rect()
		for button in [hud.get_node("move_left"),hud.get_node("move_right"),hud.get_node("attack"),hud.get_node("jump"),hud.get_node("dash"),hud.interact_button,hud.drop_button]:
			var size: Vector2=button.size if button is Control else button.texture_normal.get_size()
			check(safe.encloses(Rect2(button.position,size)),"touch control stays inside simulated cutout and gesture margins")
	scene.queue_free()
	await process_frame
	print("Mobile scene assertions: %d; failures: %d" % [assertions,failures])
	quit(0 if failures==0 else 1)
