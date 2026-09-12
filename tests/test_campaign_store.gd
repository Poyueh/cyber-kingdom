extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
const Codec=preload("res://application/campaign_snapshot.gd")
func test_checkpoint_file_roundtrip_and_corruption_protection(t):
	var path="res://infrastructure/json_campaign_store.gd"
	t.truth(ResourceLoader.exists(path),"campaign has a durable file adapter")
	if not ResourceLoader.exists(path):return
	var location="user://test_campaign_%d.json" % Time.get_ticks_usec()
	var store=load(path).new(location)
	var codec=Codec.new()
	var packet=codec.capture(Campaign.new(),{},{"x":30.0,"y":430.0,"vx":0.0,"vy":0.0})
	t.equal(store.read().status,"missing","fresh location has no checkpoint")
	t.truth(store.write(packet),"writes full campaign")
	var another=load(path).new(location)
	var loaded=another.read()
	t.truth(not codec.restore(loaded.data).is_empty(),"real disk JSON resumes a campaign")
	var bytes=FileAccess.get_file_as_string(location)
	var competing=load(path).new(location)
	competing.read()
	packet.body.x=100.0
	t.truth(another.write(packet),"owner can replace snapshot atomically")
	t.truth(not competing.write(packet),"stale process cannot overwrite changed progress")
	t.truth(not FileAccess.file_exists(location+".tmp"),"successful replacement leaves no temporary snapshot")
	var progress_path="res://application/campaign_progress.gd"
	t.truth(ResourceLoader.exists(progress_path),"application protects undecodable progress")
	if not ResourceLoader.exists(progress_path):return
	for invalid in ["broken json",'{"version":99}',bytes.replace('"amount":12','"amount":-1')]:
		var file=FileAccess.open(location,FileAccess.WRITE)
		file.store_string(invalid);file.close()
		var progress=load(progress_path).new(load(path).new(location))
		t.truth(progress.open().is_empty(),"invalid save is not restored")
		t.equal(progress.status,"protected","unreadable progress is locked")
		t.truth(not progress.save(Campaign.new(),{},{"x":30.0,"y":430.0,"vx":0.0,"vy":0.0}),"new run cannot overwrite protected save")
		t.equal(FileAccess.get_file_as_string(location),invalid,"original bytes survive")
		t.truth(progress.archive(),"explicit fresh start preserves original in archive")
		t.equal(FileAccess.get_file_as_string(progress.last_archive),invalid,"archive is byte identical")
		DirAccess.remove_absolute(progress.last_archive)
	DirAccess.remove_absolute(location)

func test_failed_write_keeps_old_checkpoint_and_can_retry(t):
	var path="res://infrastructure/json_campaign_store.gd"
	if not ResourceLoader.exists(path):t.truth(false,"missing file adapter");return
	var location="user://test_retry_%d.json" % Time.get_ticks_usec()
	var store=load(path).new(location)
	store.read()
	var packet=Codec.new().capture(Campaign.new(),{},{"x":30.0,"y":430.0,"vx":0.0,"vy":0.0})
	t.truth(store.write(packet),"baseline snapshot saved")
	var original=FileAccess.get_file_as_string(location)
	DirAccess.make_dir_absolute(location+".tmp")
	t.truth(not store.write(packet),"unwritable temp destination is reported")
	t.equal(FileAccess.get_file_as_string(location),original,"failed write keeps last good snapshot")
	DirAccess.remove_absolute(location+".tmp")
	t.truth(store.write(packet),"retry succeeds when storage is available")
	DirAccess.remove_absolute(location)
