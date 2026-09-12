extends RefCounted
const Campaign=preload("res://application/campaign_session.gd")
const Hold=preload("res://application/investment_hold.gd")
func camp(config: Dictionary={}):
	var sim=Campaign.new(config)
	sim.world.people.clear()
	sim.frontier.city_level=1
	sim.world.scrap=30
	sim.frontier.food=30
	return sim
func buy(sim,x: float) -> void:
	var choice: Dictionary=sim.context(x)
	for i in range(choice.cost):sim.interact(x,choice.key)

func test_full_shield_cannot_stack_before_city_upgrade(t):
	var sim=camp()
	buy(sim,350)
	t.equal(sim.hero.shield,20,"first capacitor provides twenty shield")
	var wallet: int=sim.pouch.amount
	t.truth(not sim.context(350).enabled,"second capacitor needs a larger settlement")
	t.truth(not sim.interact(350),"repeated forging cannot stack shield at first camp")
	t.equal(sim.pouch.amount,wallet,"locked upgrade never consumes a crystal")
	sim.frontier.city_level=3
	buy(sim,350);buy(sim,350)
	t.equal(sim.hero.shield,60,"third capacitor reaches a bounded sixty shield")
	t.truth(not sim.context(350).enabled,"maximum capacitor disables further stacking")
	t.equal(sim.context(350).cost,0,"full capacitor shows completion rather than another price")
	t.equal(sim.world.scrap,21,"three tiers cost two, three and four scrap")
	t.equal(sim.pouch.amount,3,"three tiers compete for nine crystals")

func test_damage_offers_bounded_refill_instead_of_another_upgrade(t):
	var sim=camp()
	buy(sim,350)
	sim.hero.take_damage(15)
	t.equal(sim.hero.hp,100,"real damage first drains capacitor energy")
	var choice: Dictionary=sim.context(350)
	t.equal(choice.id,"shield_charge","damaged capacitor offers repair action")
	t.equal(choice.cost,1,"one crystal recharges a capacitor")
	buy(sim,350)
	t.equal(sim.hero.shield,20,"refill clamps to installed capacity")
	t.equal(sim.world.scrap,27,"recharging uses one scrap in addition to initial two")
	t.truth(not sim.context(350).enabled,"refill cannot raise capacitor tier")

func test_training_tiers_cost_more_and_require_city_progress(t):
	var sim=camp()
	buy(sim,1230)
	t.equal(sim.hero.stats.damage,30,"first lesson increases real sword damage")
	t.truth(not sim.context(1230).enabled,"second lesson waits for tier-two settlement")
	sim.frontier.city_level=2
	t.equal(sim.context(1230).cost,3,"second lesson spends three crystals")
	t.equal(sim.context(1230).requirements.food,4,"second lesson competes with food trading")
	buy(sim,1230)
	sim.frontier.city_level=3
	buy(sim,1230)
	t.equal(sim.hero.stats.damage,40,"third lesson reaches bounded sword strength")
	t.equal(sim.frontier.food,18,"three lessons consume two, four, six food")
	t.equal(sim.pouch.amount,3,"sword route spends nine crystals")
	t.truth(not sim.interact(1230),"maximum training does not charge or add damage")
	t.equal(sim.context(1230).cost,0,"full training shows completion rather than another price")

func test_damage_interrupts_held_upgrade_without_spending_refill_or_losing_slots(t):
	var sim=camp()
	buy(sim,350)
	sim.frontier.city_level=2
	var hold=Hold.new()
	hold.step(0.02,true,true,sim,350)
	var key: String=hold.target_key
	t.equal(sim.context_for_key(350,key).paid,1,"first upgrade crystal is saved")
	sim.hero.take_damage(5)
	var wallet: int=sim.pouch.amount
	hold.step(1,true,true,sim,350)
	t.equal(sim.pouch.amount,wallet,"held upgrade cannot switch into a recharge")
	hold.step(0.02,false,true,sim,350)
	buy(sim,350)
	t.equal(sim.context_for_key(350,key).paid,1,"charging preserves partial upgrade")
	buy(sim,350)
	t.equal(sim.hero.shield,40,"fresh gesture completes preserved second capacitor")

func test_growth_configuration_changes_actual_cap_and_training(t):
	var sim=camp({"shield_value":15,"capacitor_limit":2,"growth_crystal_step":2,"growth_scrap_step":2,"shield_charge_cost":2,"shield_charge_scrap":3})
	buy(sim,350)
	sim.frontier.city_level=3
	t.equal(sim.context(350).cost,4,"configured cost slope reaches second upgrade")
	buy(sim,350)
	t.equal(sim.hero.shield,30,"configured capacitor stops at two fifteen-point cells")
	t.truth(not sim.context(350).enabled,"configured limit is enforced")
	sim.hero.take_damage(10)
	t.equal(sim.context(350).cost,2,"configured refill cost is used")
	buy(sim,350)
	t.equal(sim.hero.shield,30,"configured refill is bounded")
	t.equal(sim.world.scrap,21,"configured upgrade and refill scrap are conserved")
