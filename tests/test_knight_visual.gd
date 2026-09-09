extends RefCounted
const KnightVisual = preload("res://presentation/knight_visual.gd")

func test_idle_animation_advances_only_with_game_time(t) -> void:
	var view = KnightVisual.new()
	var pose := {"alive": true, "facing": 1, "moving": false, "invulnerable": false}
	view.present(pose, 0.26)
	t.equal(view.frame, 1, "idle advances to its next drawing")
	view.present(pose, 0.0)
	t.equal(view.frame, 1, "paused game time holds the drawing")
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

func test_grounded_motion_plays_run_then_returns_to_idle(t) -> void:
	var view = KnightVisual.new()
	var pose := {"alive": true, "facing": 1, "moving": true, "invulnerable": false, "grounded": true}
	view.present(pose, 0.1)
	t.equal(view.animation, &"run", "ground movement selects run artwork")
	t.equal(view.frame, 1, "run advances at its configured cadence")
	pose.moving = false
	view.present(pose, 0.0)
	t.equal(view.animation, &"idle", "stopping returns to idle")
	t.equal(view.frame, 0, "new clip begins from its first frame")
	view.free()

func test_attack_frames_follow_combat_progress_instead_of_render_time(t) -> void:
	var view = KnightVisual.new()
	var pose := {"alive": true, "facing": -1, "moving": true, "invulnerable": false, "attack_progress": 0.0}
	view.present(pose, 0.8)
	t.equal(view.animation, &"attack", "attack overrides running")
	t.equal(view.frame, 0, "windup stays tied to combat even after long render delta")
	pose.attack_progress = 0.2
	view.present(pose, 0.0)
	t.equal(view.frame, 1, "coiled anticipation precedes the cut")
	pose.attack_progress = 0.45
	view.present(pose, 0.0)
	t.equal(view.frame, 3, "downward drawing matches the damage window")
	pose.attack_progress = 0.95
	view.present(pose, 0.0)
	t.equal(view.frame, 5, "recovery uses the final drawing")
	pose.attack_progress = 1.0
	view.present(pose, 0.0)
	t.equal(view.animation, &"run", "completed swing releases movement animation")
	view.free()

func test_airborne_and_dash_do_not_play_ground_run_cycle(t) -> void:
	var view = KnightVisual.new()
	var pose := {"alive": true, "facing": 1, "moving": true, "invulnerable": false, "grounded": false}
	view.present(pose, 0.3)
	t.equal(view.animation, &"idle", "airborne movement holds a neutral pose until jump art exists")
	t.equal(view.frame, 0, "airborne pose does not breathe or run")
	pose.grounded = true
	pose.dashing = true
	view.present(pose, 0.3)
	t.equal(view.animation, &"idle", "dash holds a neutral pose until dash art exists")
	t.equal(view.frame, 0, "dash cannot run in place")
	view.free()

func test_attack_respects_authored_anticipation_and_recovery_durations(t) -> void:
	var view = KnightVisual.new()
	view.sprite_frames = view.sprite_frames.duplicate()
	var texture = view.sprite_frames.get_frame_texture(&"attack", 0)
	view.sprite_frames.clear(&"attack")
	for duration in [3.0, 1.0, 1.0, 1.0]:
		view.sprite_frames.add_frame(&"attack", texture, duration)
	var pose := {"alive": true, "facing": 1, "moving": false, "invulnerable": false, "attack_progress": 0.4}
	view.present(pose, 0.0)
	t.equal(view.frame, 0, "long anticipation remains visible until its authored duration ends")
	pose.attack_progress = 0.6
	view.present(pose, 0.0)
	t.equal(view.frame, 1, "strike begins when authored anticipation completes")
	view.free()

func test_enemy_telegraph_displays_raised_weapon_without_starting_swing(t) -> void:
	var view = KnightVisual.new()
	view.sprite_frames = view.sprite_frames.duplicate()
	view.sprite_frames.add_animation(&"windup")
	view.sprite_frames.add_frame(&"windup", view.sprite_frames.get_frame_texture(&"attack", 1))
	var pose := {"alive": true, "facing": -1, "moving": false, "invulnerable": false, "telegraph": true}
	view.present(pose, 0.2)
	t.equal(view.animation, &"windup", "guard raises its weapon throughout the warning")
	pose.telegraph = false
	view.present(pose, 0.0)
	t.equal(view.animation, &"idle", "cancelled warning returns to guard stance")
	view.free()
