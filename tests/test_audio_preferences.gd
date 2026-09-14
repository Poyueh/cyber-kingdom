extends RefCounted
const Preferences=preload("res://infrastructure/audio_preferences.gd")
func test_volume_preferences_round_trip_and_protect_corrupt_input(t):
	var path="user://test_preferences_%d.cfg" % Time.get_ticks_usec()
	var prefs=Preferences.new(path)
	t.equal(prefs.read(),{"music":0.4,"effects":0.8},"missing settings use audible defaults")
	t.truth(prefs.write(0.25,0),"volume preferences save independently of game progress")
	t.equal(Preferences.new(path).read(),{"music":0.25,"effects":0.0},"music and muted effects survive reopening")
	var corrupt='[audio]\nmusic="invalid"\n'
	var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(corrupt);file.close()
	prefs=Preferences.new(path);prefs.read()
	t.truth(not prefs.write(1,1),"malformed settings are protected")
	t.equal(FileAccess.get_file_as_string(path),corrupt,"invalid original is not silently replaced")
	DirAccess.remove_absolute(path)
