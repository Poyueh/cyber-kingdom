extends RefCounted
## A checkpoint store reports absence separately from failed reads.
var last_error:=""
var last_archive:=""
func read() -> Dictionary:
	return {"status":"missing"}
func write(_packet: Dictionary) -> bool:
	return false
func archive() -> bool:
	return false
