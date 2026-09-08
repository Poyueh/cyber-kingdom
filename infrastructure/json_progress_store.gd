extends "res://application/ports/progress_store.gd"
## Versioned progress snapshot. Failed validation protects the original file.
const SCHEMA_VERSION := 1
var last_error: String = ""
var _path: String
var _writable: bool = true

func _init(location: String = "user://progress_v1.json") -> void:
	_path = location

func load_scrap() -> int:
	last_error = ""
	_writable = true
	if not FileAccess.file_exists(_path):
		return 0
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(_path)) != OK:
		return _invalid("Progress is unreadable; original file retained.")
	var data = json.data
	if not data is Dictionary or data.get("version") != SCHEMA_VERSION:
		return _invalid("Unsupported save version; original file retained.")
	var amount = data.get("scrap")
	if not (amount is float or amount is int):
		return _invalid("Invalid progress value; original file retained.")
	if not is_finite(float(amount)) or amount < 0 or amount > 1000000000 or floorf(float(amount)) != float(amount):
		return _invalid("Invalid progress range; original file retained.")
	return int(amount)

func _invalid(reason: String) -> int:
	last_error = reason
	_writable = false
	return 0

func save_scrap(amount: int) -> bool:
	if not _writable or amount < 0 or amount > 1000000000:
		return false
	var temporary := _path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Unable to open progress file. Retry after checking storage."
		return false
	file.store_string(JSON.stringify({"version": SCHEMA_VERSION, "scrap": amount}))
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK or DirAccess.rename_absolute(temporary, _path) != OK:
		last_error = "Unable to replace progress snapshot. Retry is available."
		return false
	last_error = ""
	return true
