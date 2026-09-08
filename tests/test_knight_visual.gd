extends RefCounted
const KnightVisual = preload("res://presentation/knight_visual.gd")

func test_idle_animation_advances_only_with_game_time(t) -> void:
	var view = KnightVisual.new()
	var pose := {"alive": true, "facing": 1, "moving": false, "invulnerable": false}
	view.present(pose, 0.26)
	t.equal(view.frame, 1, "idle advances to its next drawing")
	view.present(pose, 0.0)
	t.equal(view.frame, 1, "paused game time holds the drawing")
	pose.moving = true
	view.present(pose, 0.26)
	t.equal(view.frame, 0, "movement uses neutral pose until run art exists")
	view.free()

func test_death_facing_and_restart_are_visible(t) -> void:
	var view = KnightVisual.new()
	view.present({"alive": true, "facing": -1, "moving": false, "invulnerable": true}, 0.26)
	t.truth(view.flip_h, "left-facing knight mirrors its drawing")
	t.truth(view.modulate != Color.WHITE, "invulnerability has visual feedback")
	view.present({"alive": false, "facing": -1, "moving": false, "invulnerable": false}, 0.1)
	t.equal(view.visible, false, "defeated knight disappears with its model")
	view.reset_pose()
	t.truth(view.visible, "restart restores knight artwork")
	t.equal(view.frame, 0, "restart begins a fresh idle loop")
	t.equal(view.modulate, Color.WHITE, "restart clears damage tint")
	view.free()
