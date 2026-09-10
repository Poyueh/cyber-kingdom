extends "res://presentation/settlement_controls.gd"
signal new_map_requested
signal throw_requested
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_Q:
		throw_requested.emit()
		get_viewport().set_input_as_handled()
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_N:
		new_map_requested.emit()
		get_viewport().set_input_as_handled()
