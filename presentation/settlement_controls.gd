extends "res://presentation/input_adapter.gd"
var _interact_held: bool = false
func read_frame() -> Dictionary:
	var frame := super.read_frame()
	var down := Input.is_physical_key_pressed(KEY_E)
	frame["interact"] = down and not _interact_held
	_interact_held = down
	return frame
