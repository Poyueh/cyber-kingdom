extends RefCounted
func test_jump_pose_responds_to_vertical_motion_and_freezes_when_paused(t) -> void:
	var view=preload("res://presentation/knight_visual.gd").new()
	var pose={"alive":true,"facing":1,"moving":true,"invulnerable":false,"grounded":false,"vertical_speed":-400.0}
	view.present(pose,0.016)
	t.equal(view.animation,&"jump","takeoff uses dedicated airborne drawings")
	var rising: int=view.frame
	pose.vertical_speed=350.0
	view.present(pose,0.016)
	t.truth(view.frame!=rising,"falling silhouette differs from rising")
	var position: Vector2=view.offset
	view.present(pose,0.0)
	t.equal(view.offset,position,"paused jump does not drift")
	view.free()
