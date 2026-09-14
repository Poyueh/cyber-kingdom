extends RefCounted
const Store=preload("res://application/ports/campaign_store.gd")
const Codec=preload("res://application/campaign_snapshot.gd")
var store: Store
var codec:=Codec.new()
var status:="new"
var last_error:=""
var last_archive:=""
func _init(adapter: Store) -> void:
	store=adapter
func open() -> Dictionary:
	var result:=store.read()
	if result.status=="missing":
		status="new"
		return {}
	if result.status=="ready":
		var restored:=codec.restore(result.data)
		if not restored.is_empty():
			status="saved"
			last_error=""
			return restored
	status="protected"
	last_error=store.last_error if result.status!="ready" else codec.last_error
	return {}
func save(sim, config: Dictionary, body: Dictionary) -> bool:
	if status=="protected":return false
	var packet:=codec.capture(sim,config,body)
	if codec.restore(packet).is_empty():
		status="error"
		last_error=codec.last_error
		return false
	if not store.write(packet):
		status="error"
		last_error=store.last_error
		return false
	status="saved"
	last_error=""
	return true
## Only an explicit fresh-start action unlocks an incompatible save.
func archive() -> bool:
	if not store.archive():
		if status!="protected":status="error"
		last_error=store.last_error
		return false
	last_archive=store.last_archive
	status="new"
	last_error=""
	return true
