extends RefCounted
const Pouch=preload("res://domain/crystal_pouch.gd")
const Campaign=preload("res://application/campaign_session.gd")
func test_throw_is_conserved_and_cannot_immediately_magnet_back(t) -> void:
	var pouch=Pouch.new(12,3)
	if not pouch.has_method("toss"):
		t.truth(false,"pouch supports deliberate crystal throwing")
		return
	t.truth(pouch.toss(100,430,1),"knight can throw one crystal")
	t.equal(pouch.amount,2,"throw debits exactly one")
	t.equal(pouch.ground_total(),1,"same crystal exists in the scene")
	pouch.advance(0.2,100,430)
	t.equal(pouch.amount,2,"freshly thrown crystal is not immediately sucked back")
	t.truth(pouch.drops[0].x>100,"throw travels in knight facing direction")
	for tick in range(40): pouch.advance(0.1,140,430)
	t.equal(pouch.amount,3,"crystal is eventually recoverable")
	t.equal(pouch.ground_total(),0,"recovery cannot duplicate the crystal")

func test_magnet_moves_visible_crystals_before_crediting_and_respects_capacity(t) -> void:
	var pouch=Pouch.new(2,1)
	if not pouch.has_method("advance"):
		t.truth(false,"crystals support time based attraction")
		return
	pouch.drop(3,180,430)
	pouch.advance(0.05,100,430)
	t.equal(pouch.amount,1,"entering radius begins travel instead of teleporting reward")
	t.truth(pouch.drops[0].x<180 and pouch.drops[0].x>100,"crystal visibly moves toward knight")
	for tick in range(20): pouch.advance(0.1,100,430)
	t.equal(pouch.amount,2,"magnet respects backpack capacity")
	t.equal(pouch.ground_total(),2,"overflow stays in world after one slot is filled")
	var position: float=pouch.drops[0].x
	pouch.advance(1,100,430)
	t.equal(pouch.drops[0].x,position,"full backpack does not drag remaining crystals around")

func test_chest_bursts_before_collecting_and_only_once(t) -> void:
	var sim=Campaign.new({"starting_crystals":0})
	var chest
	for node in sim.frontier.nodes:
		if node.kind=="cache" and node.y==430: chest=node;break
	sim.advance(0.01,chest.x,430)
	sim.interact(chest.x)
	t.equal(sim.pouch.amount,0,"opening chest first releases visible rewards")
	t.equal(sim.pouch.ground_total(),6,"all six crystals start in the world")
	t.equal(sim.pouch.drops.size(),6,"treasure erupts as separate crystals")
	sim.interact(chest.x)
	t.equal(sim.pouch.ground_total(),6,"chest cannot release a second reward")
	for tick in range(40): sim.advance(0.1,chest.x,430)
	t.equal(sim.pouch.amount,6,"nearby treasure is drawn into backpack after its burst")

func test_offerings_recruit_once_and_respect_the_configured_price(t) -> void:
	var sim=Campaign.new({"starting_crystals":4,"prices":{"recruit":2}})
	var person: Dictionary=sim.world.people[0]
	t.truth(sim.throw_crystal(100,430,1),"throw is accepted without an interaction target")
	for tick in range(16): sim.advance(0.1,100,430)
	t.equal(person.role,"wanderer","one offering does not bypass two-crystal recruitment price")
	t.equal(sim.context(person.x).paid,1,"offering fills the same persistent interaction slots")
	t.truth(sim.throw_crystal(100,430,1),"second offering can complete recruitment")
	for tick in range(16): sim.advance(0.1,100,430)
	t.equal(person.role,"citizen","wanderer accepts the second offered crystal")
	t.equal(sim.pouch.amount+sim.pouch.ground_total(),2,"recruitment consumes exactly its price")
	t.equal(sim.world.people[1].role,"wanderer","one offering cannot recruit a second person")

func test_treasure_is_not_an_offering_and_empty_or_dead_knight_cannot_throw(t) -> void:
	var sim=Campaign.new({"starting_crystals":0})
	sim.pouch.burst(3,180,430)
	for tick in range(20): sim.advance(0.1,-500,430)
	t.equal(sim.world.people[0].role,"wanderer","ordinary rewards do not silently recruit nearby wanderers")
	t.equal(sim.pouch.ground_total(),3,"treasure is preserved for the player")
	t.truth(not sim.throw_crystal(30,430,1),"empty wallet cannot create currency")
	sim.pouch.receive(1,30)
	sim.hero.hp=0
	t.truth(not sim.throw_crystal(30,430,1),"dead knight cannot spend currency")
	t.equal(sim.pouch.amount,1,"rejected throw preserves wallet")

func test_airborne_crystals_land_on_ledges_and_fall_off_their_edges(t) -> void:
	var pouch=Pouch.new(12,12)
	pouch.platforms.append({"left":0.0,"right":140.0,"y":366.0})
	pouch.drop(1,70,320)
	pouch.advance(1,-500,430)
	t.equal(pouch.drops[0].y,366.0,"falling crystal lands on actual platform surface")
	pouch.drops[0].x=130.0
	pouch.drops[0].vx=250.0
	pouch.advance(1,-500,430)
	t.equal(pouch.drops[0].y,430.0,"crystal leaving platform edge falls to ground")
	t.truth(pouch.toss(300,310,-1),"airborne knight can throw left")
	pouch.advance(2,-500,430)
	var tossed: Dictionary=pouch.drops[-1]
	t.truth(tossed.x<300 and tossed.y==430,"airborne throw keeps direction and lands safely")

func test_zero_invalid_time_and_boundaries_preserve_ground_rewards(t) -> void:
	var pouch=Pouch.new(12,2)
	pouch.left_boundary=0
	pouch.right_boundary=200
	pouch.toss(190,430,1)
	var before: Array=pouch.drops.duplicate(true)
	for seconds in [0.0,-1.0,INF,NAN]: pouch.advance(seconds,190,430)
	t.equal(pouch.drops,before,"invalid time cannot move or collect rewards")
	pouch.advance(3,-500,430)
	t.truth(pouch.drops[0].x<=192,"boundary prevents throwing beyond playable map")
	t.equal(pouch.amount+pouch.ground_total(),2,"wall collision never destroys currency")
