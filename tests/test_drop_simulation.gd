extends RefCounted
## Pins the ground-crystal behaviour that the settled-pile fast path must preserve.
const Pouch=preload("res://domain/crystal_pouch.gd")

func _pouch() -> Pouch:
	var pouch=Pouch.new(12,0)
	pouch.left_boundary=-1000.0
	pouch.right_boundary=1000.0
	return pouch

func _run(pouch, seconds: float, hero_x: float) -> void:
	for step in range(int(seconds*60.0)):pouch.advance(1.0/60.0,hero_x,430.0)

func test_settled_pile_out_of_reach_only_ages(t) -> void:
	var pouch=_pouch()
	pouch.drop(3,500.0,430.0)
	var gem: Dictionary=pouch.drops[0]
	_run(pouch,1.0,-900.0)
	t.equal(gem.x,500.0,"a resting pile out of reach does not drift")
	t.equal(gem.y,430.0,"a resting pile stays on the ground")
	t.equal(gem.vx,0.0,"a resting pile keeps zero horizontal speed")
	t.equal(gem.vy,0.0,"a resting pile keeps zero fall speed")
	t.truth(absf(gem.age-1.0)<0.001,"a resting pile still ages")
	t.truth(not gem.attracted,"a distant pile is not attracted")

func test_grace_still_expires_while_resting(t) -> void:
	var pouch=_pouch()
	pouch.amount=5
	pouch.toss(0.0,430.0,1)
	var gem: Dictionary=pouch.drops[0]
	t.truth(gem.grace>0.0,"a thrown crystal starts with pickup grace")
	_run(pouch,0.5,-900.0)
	t.truth(gem.grace<pouch.throw_grace,"grace keeps draining out of reach")
	_run(pouch,3.0,-900.0)
	t.equal(gem.grace,0.0,"grace reaches zero even without the knight nearby")

func test_pile_outside_the_world_is_pulled_back(t) -> void:
	var pouch=_pouch()
	pouch.drop(1,0.0,430.0)
	pouch.drops[0].x=2000.0
	_run(pouch,1.0/60.0,-900.0)
	t.equal(pouch.drops[0].x,992.0,"an out-of-range pile is clamped inside the world")

func test_airborne_crystal_still_lands(t) -> void:
	var pouch=_pouch()
	pouch.burst(1,0.0,430.0)
	var gem: Dictionary=pouch.drops[0]
	t.truth(gem.y<430.0,"a burst crystal starts above the ground")
	_run(pouch,2.0,-900.0)
	t.equal(gem.y,430.0,"a burst crystal settles on the ground")
	t.equal(gem.vy,0.0,"a landed crystal stops falling")

func test_knight_still_collects_a_nearby_pile(t) -> void:
	var pouch=_pouch()
	pouch.drop(1,0.0,430.0)
	_run(pouch,0.5,0.0)
	t.truth(pouch.drops.is_empty(),"a reachable pile is collected")
	t.equal(pouch.amount,1,"collecting a pile fills the backpack")

func test_thrown_offering_resists_the_magnet_until_grace_ends(t) -> void:
	var pouch=_pouch()
	pouch.amount=5
	pouch.toss(0.0,430.0,1)
	_run(pouch,0.5,0.0)
	t.equal(pouch.drops.size(),1,"a fresh offering is not pulled back")
	_run(pouch,3.0,0.0)
	t.truth(pouch.drops.is_empty(),"the offering returns once its grace ends")

func test_resting_piles_do_not_change_an_active_crystal(t) -> void:
	var lonely=_pouch()
	var crowded=_pouch()
	for pouch in [lonely,crowded]:
		pouch.amount=5
		pouch.toss(-200.0,430.0,1)
	for index in range(200):crowded.drop(1,300.0+float(index),430.0)
	_run(lonely,1.5,-900.0)
	_run(crowded,1.5,-900.0)
	var a: Dictionary=lonely.drops[0]
	var b: Dictionary=crowded.drops[0]
	for key in ["x","y","vx","vy","age","grace"]:
		t.truth(absf(float(a[key])-float(b[key]))<0.000001,"resting piles leave the active crystal untouched: "+key)
