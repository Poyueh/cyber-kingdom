extends RefCounted
## Only known journey filenames are admitted; never expose arbitrary file paths from saves.
var directory: String
var legacy: String
var last_error:=""
var _reserved: Dictionary={}
func _init(folder: String="user://campaigns", legacy_path: String="user://campaign_v1.json") -> void:
	directory=folder
	legacy=legacy_path

func entries() -> Array[Dictionary]:
	var result: Array[Dictionary]=[]
	if DirAccess.dir_exists_absolute(directory):
		var pattern:=RegEx.new()
		pattern.compile("^run-[0-9]+-[0-9]+\\.json(?:\\.manual)?$")
		for filename in DirAccess.get_files_at(directory):
			if pattern.search(filename)!=null:
				_append(result,directory.path_join(filename),false)
	if not legacy.is_empty():
		for path in [legacy,legacy+".manual"]:
			if FileAccess.file_exists(path):_append(result,path,true)
	result.sort_custom(func(a,b):return a.updated>b.updated if a.updated!=b.updated else a.path>b.path)
	return result

func _append(result: Array[Dictionary], path: String, old: bool) -> void:
	result.append({"path":path,"updated":FileAccess.get_modified_time(path),
		"manual":path.ends_with(".manual"),"legacy":old})

func allocate() -> String:
	last_error=""
	if DirAccess.make_dir_recursive_absolute(directory)!=OK:
		last_error="無法建立紀錄，請確認裝置有可用空間後再試一次。"
		return ""
	var path: String
	while true:
		path=directory.path_join("run-%d-%d.json" % [int(Time.get_unix_time_from_system()*1000),randi()])
		if not FileAccess.file_exists(path) and not _reserved.has(path):break
	_reserved[path]=true
	return path
