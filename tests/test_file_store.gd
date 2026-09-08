extends RefCounted
const FileStore = preload("res://infrastructure/json_progress_store.gd")

func test_round_trip_and_schema_guard(t) -> void:
	var location := "user://test_progress_%d.json" % Time.get_ticks_usec()
	var store = FileStore.new(location)
	t.equal(store.load_scrap(), 0, "missing progress starts empty")
	t.truth(store.save_scrap(40), "first snapshot saved")
	t.equal(FileStore.new(location).load_scrap(), 40, "new adapter restores progress")
	var file := FileAccess.open(location, FileAccess.WRITE)
	file.store_string('{"version":99,"scrap":900}')
	file.close()
	var future = FileStore.new(location)
	t.equal(future.load_scrap(), 0, "unknown future save not interpreted")
	t.equal(future.save_scrap(0), false, "unreadable progress cannot be overwritten")
	t.truth(not future.last_error.is_empty(), "recovery warning available")
	DirAccess.remove_absolute(location)

func test_invalid_values_preserve_original_save(t) -> void:
	for invalid in ['{"version":1,"scrap":-1}', '{"version":1,"scrap":2.5}', 'broken json']:
		var location := "user://test_invalid_%d.json" % Time.get_ticks_usec()
		var file := FileAccess.open(location, FileAccess.WRITE)
		file.store_string(invalid)
		file.close()
		var store = FileStore.new(location)
		store.load_scrap()
		t.equal(store.save_scrap(20), false, "invalid file protected")
		t.equal(FileAccess.get_file_as_string(location), invalid, "original bytes preserved")
		DirAccess.remove_absolute(location)
