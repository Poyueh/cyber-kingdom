extends SceneTree
## Headless cost probe. Not part of tools/check.sh; run it by hand before and after
## a performance change:
##   godot --headless --path . --script res://tools/bench_sim.gd -- --no-campaign-save
const Campaign=preload("res://application/campaign_session.gd")
const Guide=preload("res://application/campaign_guide.gd")
const Progress=preload("res://application/campaign_progress.gd")
const Store=preload("res://application/ports/campaign_store.gd")
const SEED:=742601
const STEP:=1.0/60.0
const ROUNDS:=200
const MARKS: Array[int]=[1800,5400,10800,21600,36000]

class NullStore:
	extends Store
	func write(_packet: Dictionary) -> bool:
		return true

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var config: Dictionary={"seed":SEED}
	var sim=Campaign.new(config)
	var next: int=0
	print("%6s %4s %8s %8s %9s %8s %7s %7s %7s" % ["t","day","adv_us","ctx_us","guide_us","save_us","people","raiders","drops"])
	for frame in range(MARKS[MARKS.size()-1]+1):
		if next<MARKS.size() and frame==MARKS[next]:
			_sample(sim,config,frame)
			next+=1
		_drive(sim,frame)
	quit()

## Keeps the probe alive and pushes the campaign forward; not a model of real play.
func _drive(sim, frame: int) -> void:
	var span: float=sim.frontier.right_boundary-sim.frontier.left_boundary
	var hero_x: float=sim.frontier.left_boundary+fposmod(float(frame)*4.0,span)
	sim.advance(STEP,hero_x,430.0)
	sim.hero.hp=sim.hero.stats.max_hp
	sim.hero.stamina=sim.hero.stats.max_stamina
	sim.mission.core_hp=sim.mission.core_max_hp
	for enemy in sim.raiders:
		if enemy.get("kind","")!="dragon":enemy.fighter.hp=0
	if frame%30==0:
		sim.pouch.amount=sim.pouch.capacity
		sim.interact(hero_x)
	if frame%240==0:sim.pouch.drop(1,hero_x,430.0)

func _sample(sim, config: Dictionary, frame: int) -> void:
	var hero_x: float=sim._hero_x
	var body: Dictionary={"x":hero_x,"y":430.0,"vx":0.0,"vy":0.0}
	var context_us: int=_time(func():sim.context(hero_x))
	var guide_us: int=_time(func():Guide.next(sim,hero_x))
	var advance_us: int=_time(func():sim.advance(0.0001,hero_x,430.0))
	var progress=Progress.new(NullStore.new())
	var start: int=Time.get_ticks_usec()
	progress.save(sim,config,body)
	var save_us: int=Time.get_ticks_usec()-start
	print("%6d %4d %8d %8d %9d %8d %7d %7d %7d" % [frame/60,sim.clock.day,advance_us,context_us,guide_us,save_us,
		sim.world.people.size(),sim.raiders.size(),sim.pouch.drops.size()])

func _time(body: Callable) -> int:
	var start: int=Time.get_ticks_usec()
	for i in range(ROUNDS):body.call()
	return (Time.get_ticks_usec()-start)/ROUNDS
