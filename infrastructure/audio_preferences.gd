extends RefCounted
## Independent user preferences; never stored inside a campaign checkpoint.
var writable:=true
var path: String
func _init(location: String) -> void:path=location
func read() -> Dictionary:
	var result={"music":0.4,"effects":0.8}
	var file:=ConfigFile.new()
	var error:=file.load(path)
	writable=error in [OK,ERR_FILE_NOT_FOUND]
	if error!=OK:return result
	for key in result:
		var value=file.get_value("audio",key,result[key])
		if not (value is float or value is int) or not is_finite(float(value)) or value<0 or value>1:
			writable=false
			return {"music":0.4,"effects":0.8}
		result[key]=float(value)
	return result
func write(music: float,effects: float) -> bool:
	if not writable or not is_finite(music) or not is_finite(effects):return false
	var file:=ConfigFile.new()
	file.set_value("audio","music",clampf(music,0,1))
	file.set_value("audio","effects",clampf(effects,0,1))
	return file.save(path)==OK
