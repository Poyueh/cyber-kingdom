extends RefCounted
const Streams=preload("res://domain/rng/rng_streams.gd")

func _draw(streams, stream, count: int) -> Array[float]:
	var values: Array[float]=[]
	for index in range(count):values.append(streams.of(stream).randf())
	return values

func test_same_seed_replays_the_same_sequence(t) -> void:
	var first=_draw(Streams.new(7),Streams.Stream.WORLD,8)
	var second=_draw(Streams.new(7),Streams.Stream.WORLD,8)
	t.equal(first,second,"one seed always produces one world sequence")

func test_streams_do_not_share_a_sequence(t) -> void:
	var streams=Streams.new(7)
	var world=_draw(streams,Streams.Stream.WORLD,8)
	var loot=_draw(streams,Streams.Stream.LOOT,8)
	t.truth(world!=loot,"two purposes do not draw the same numbers")

func test_draining_one_stream_does_not_shift_another(t) -> void:
	var quiet=Streams.new(742601)
	var busy=Streams.new(742601)
	_draw(busy,Streams.Stream.LOOT,100)
	_draw(busy,Streams.Stream.COMBAT,100)
	t.equal(_draw(busy,Streams.Stream.WORLD,8),_draw(quiet,Streams.Stream.WORLD,8),
		"spending loot and combat dice leaves world generation untouched")

func test_neighbouring_seeds_do_not_produce_neighbouring_streams(t) -> void:
	t.truth(_draw(Streams.new(1),Streams.Stream.WORLD,4)!=_draw(Streams.new(2),Streams.Stream.WORLD,4),
		"adjacent run seeds give unrelated worlds")

func test_capture_survives_a_checkpoint_round_trip(t) -> void:
	var streams=Streams.new(99)
	_draw(streams,Streams.Stream.EVENT,17)
	var expected=_draw(streams,Streams.Stream.EVENT,5)
	var replay=Streams.new(99)
	_draw(replay,Streams.Stream.EVENT,17)
	var saved: Dictionary=replay.capture()
	_draw(replay,Streams.Stream.EVENT,40)
	t.truth(replay.restore(JSON.parse_string(JSON.stringify(saved))),"a stored position is accepted back")
	t.equal(_draw(replay,Streams.Stream.EVENT,5),expected,"dice resume where the checkpoint left them")

func test_stored_state_stays_inside_the_checkpoint_number_range(t) -> void:
	var streams=Streams.new(5)
	_draw(streams,Streams.Stream.WORLD,3)
	for key in streams.capture().states:
		t.truth(streams.capture().states[key] is String,"generator positions are stored as text, not huge numbers")

func test_restore_refuses_a_damaged_position(t) -> void:
	var streams=Streams.new(5)
	t.truth(not streams.restore({}),"an empty payload is refused")
	t.truth(not streams.restore({"seed":5,"states":{"0":"12"}}),"a payload missing streams is refused")
	t.truth(not streams.restore({"seed":5,"states":{"0":"x","1":"1","2":"2","3":"3"}}),"a non-numeric position is refused")

func test_helpers_follow_their_own_stream(t) -> void:
	var streams=Streams.new(3)
	t.truth(not streams.roll(Streams.Stream.LOOT,0.0),"an impossible chance never fires")
	t.truth(streams.roll(Streams.Stream.LOOT,1.0),"a certain chance always fires")
	t.equal(streams.pick(Streams.Stream.EVENT,[]),null,"picking from nothing yields nothing")
	t.equal(streams.pick(Streams.Stream.EVENT,["only"]),"only","picking from one option yields it")
