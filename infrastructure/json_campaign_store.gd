extends "res://application/ports/campaign_store.gd"
## Flush to a sibling file, then atomically rename. Never recover by deleting the original.
const MAX_BYTES:=4*1024*1024
var _path: String
var _observed:=false
var _exists:=false
var _digest:=""
func _init(location: String="user://campaign_v1.json") -> void:
	_path=location
func read() -> Dictionary:
	last_error=""
	_observed=false
	_exists=FileAccess.file_exists(_path)
	if not _exists:
		# A directory at the save path is an error, not a new game.
		if DirAccess.dir_exists_absolute(_path):return _read_error()
		_observed=true
		return {"status":"missing"}
	var file=FileAccess.open(_path,FileAccess.READ)
	if file==null or file.get_length()>MAX_BYTES:
		if file!=null:file.close()
		return _read_error()
	var bytes=file.get_buffer(file.get_length())
	file.close()
	_digest=bytes.hex_encode().sha256_text()
	_observed=true
	var json:=JSON.new()
	if json.parse(bytes.get_string_from_utf8())!=OK:return _read_error()
	return {"status":"ready","data":json.data}
func _read_error() -> Dictionary:
	last_error="Checkpoint could not be read; original retained."
	return {"status":"error"}
func _unchanged() -> bool:
	if not _observed or FileAccess.file_exists(_path)!=_exists:return false
	if not _exists:return not DirAccess.dir_exists_absolute(_path)
	var file=FileAccess.open(_path,FileAccess.READ)
	if file==null or file.get_length()>MAX_BYTES:
		if file!=null:file.close()
		return false
	var bytes=file.get_buffer(file.get_length())
	file.close()
	return bytes.hex_encode().sha256_text()==_digest
func write(packet: Dictionary) -> bool:
	if not _unchanged():
		last_error="Checkpoint changed or was not read; original retained."
		return false
	var bytes:=JSON.stringify(packet).to_utf8_buffer()
	if bytes.size()>MAX_BYTES:
		last_error="Checkpoint exceeds supported size; original retained."
		return false
	var temporary:=_path+".tmp"
	var file=FileAccess.open(temporary,FileAccess.WRITE)
	if file==null:
		last_error="Cannot write checkpoint; retry when storage is available."
		return false
	file.store_buffer(bytes)
	file.flush()
	var result:=file.get_error()
	file.close()
	if result!=OK or not _unchanged() or DirAccess.rename_absolute(temporary,_path)!=OK:
		last_error="Could not replace checkpoint; previous progress retained."
		return false
	_exists=true
	_digest=bytes.hex_encode().sha256_text()
	last_error=""
	return true
func archive() -> bool:
	if not _unchanged():
		last_error="Checkpoint cannot be archived safely; original retained."
		return false
	last_archive=""
	if _exists:
		last_archive=_path+".archive-%d-%d" % [int(Time.get_unix_time_from_system()),Time.get_ticks_usec()]
		if FileAccess.file_exists(last_archive) or DirAccess.rename_absolute(_path,last_archive)!=OK:
			last_error="Could not archive checkpoint; original retained."
			return false
	_exists=false
	_digest=""
	last_error=""
	return true
