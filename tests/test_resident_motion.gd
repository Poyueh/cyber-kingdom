extends RefCounted
const Motion=preload("res://presentation/resident_motion.gd")
func test_walk_tracks_distance_instead_of_render_rate(t) -> void:
	var a=Motion.new()
	var b=Motion.new()
	var person={"role":"citizen","moving":true,"walk_distance":0.0}
	a.sample(person,0,0.0)
	b.sample(person,0,0.0)
	for step in range(1,9):
		person.walk_distance=step*2.0
		a.sample(person,0,step*0.04)
	var one=b.sample(person,0,0.32)
	t.equal(a.sample(person,0,0.32),one,"same travel gives the same pose regardless of render rate")
	person.walk_distance=4.0
	var early=a.sample(person,0,0.4)
	t.truth(early.frame!=one.frame,"advancing feet uses actual distance")

func test_stopping_settles_and_pause_freezes_the_transition(t) -> void:
	var motion=Motion.new()
	var person={"role":"citizen","moving":true,"walk_distance":12.0}
	motion.sample(person,0,1.0)
	person.moving=false
	var stop=motion.sample(person,0,1.01)
	t.equal(stop.mode,"settle","stopping finishes a foot placement before resting")
	t.equal(motion.sample(person,0,1.01),stop,"redraw without simulation time cannot animate through pause")
	var rest=motion.sample(person,0,1.3)
	t.equal(rest.mode,"idle","resident settles within a short recovery")
	var copy=person.duplicate(true)
	motion.sample(person,0,2.0)
	t.equal(person,copy,"animation never writes movement or save fields into a resident")
	motion.clear()
	t.equal(motion.sample(person,0,0.0).mode,"idle","new run cannot inherit an old stopping transition")
