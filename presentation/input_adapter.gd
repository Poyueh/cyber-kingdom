extends Node
## Both keyboard and multi-touch buttons use the same named InputMap actions.
func read_frame() -> Dictionary:
	return {
		"direction": Input.get_axis("move_left", "move_right"),
		"jump": Input.is_action_just_pressed("jump"),
		"attack": Input.is_action_just_pressed("attack"),
		"dash": Input.is_action_just_pressed("dash"),
		"restart": Input.is_action_just_pressed("restart"),
		"pause": Input.is_action_just_pressed("pause"),
		"retry_save": Input.is_action_just_pressed("retry_save")
	}

func release_all() -> void:
	for action in ["move_left", "move_right", "jump", "attack", "dash"]:
		Input.action_release(action)
