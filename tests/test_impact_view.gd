extends RefCounted
const ImpactView = preload("res://presentation/impact_view.gd")

func test_impact_feedback_freezes_expires_and_resets_with_game_time(t) -> void:
	var view = ImpactView.new()
	view.trigger(Vector2(50, 20), 1, Color.CYAN)
	t.truth(view.has_impacts(), "a confirmed hit produces visible feedback")
	var held_offset: Vector2 = view.camera_offset(2.0)
	view.advance(0.0)
	t.equal(view.camera_offset(2.0), held_offset, "pause freezes camera feedback")
	view.advance(0.3)
	t.equal(view.has_impacts(), false, "short impact burst expires")
	t.equal(view.camera_offset(2.0), Vector2.ZERO, "camera returns to its exact origin")
	view.trigger(Vector2.ZERO, -1, Color.ORANGE)
	view.clear()
	t.equal(view.has_impacts(), false, "restart clears old sparks")
	view.free()
