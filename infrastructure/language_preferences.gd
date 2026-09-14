extends RefCounted
var path: String
func _init(file_path: String="user://language.cfg") -> void:path=file_path
func read_choice() -> String:
 var config=ConfigFile.new()
 if config.load(path)!=OK or config.get_value("language","version",0)!=1:return "auto"
 var value=config.get_value("language","choice","auto")
 return value if value in ["auto","zh_TW","zh_CN","en"] else "auto"
func write_choice(value: String) -> bool:
 if value not in ["auto","zh_TW","zh_CN","en"]:return false
 var config=ConfigFile.new()
 if FileAccess.file_exists(path):
  if config.load(path)!=OK or config.get_value("language","version",0)!=1:return false
 config.set_value("language","version",1);config.set_value("language","choice",value)
 if config.save(path+".tmp")!=OK:return false
 return DirAccess.rename_absolute(path+".tmp",path)==OK
