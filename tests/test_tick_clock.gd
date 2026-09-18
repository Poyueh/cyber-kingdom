extends RefCounted
const Clock=preload("res://domain/time/tick_clock.gd")

func test_clock_counts_ticks_not_seconds(t) -> void:
	var clock=Clock.new()
	t.equal(clock.tick,0,"a new clock starts at tick zero")
	for step in range(Clock.TICKS_PER_SECOND):clock.advance()
	t.equal(clock.tick,Clock.TICKS_PER_SECOND,"each advance is exactly one tick")
	t.truth(absf(clock.elapsed_seconds()-1.0)<0.000001,"a second of ticks reads back as one second")

func test_authored_seconds_become_whole_ticks(t) -> void:
	t.equal(Clock.ticks_for(1.0),Clock.TICKS_PER_SECOND,"one second converts to the tick rate")
	t.equal(Clock.ticks_for(0.5),15,"half a second converts to half the tick rate")
	t.equal(Clock.ticks_for(0.0),0,"no duration means no ticks")
	t.equal(Clock.ticks_for(-4.0),0,"a negative duration cannot become ticks")
	t.equal(Clock.ticks_for(INF),0,"a broken duration cannot become ticks")

func test_a_short_duration_never_collapses_to_nothing(t) -> void:
	t.equal(Clock.ticks_for(0.001),1,"a positive duration is at least one tick")

func test_restore_rejects_impossible_values(t) -> void:
	var clock=Clock.new()
	clock.tick=9
	t.truth(not clock.restore(-1),"a negative tick count is refused")
	t.equal(clock.tick,9,"a refused restore leaves the clock alone")
	t.truth(clock.restore(120),"a plain tick count is accepted")
	t.equal(clock.capture(),120,"a restored clock reports what it was given")
