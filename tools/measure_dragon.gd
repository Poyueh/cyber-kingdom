extends SceneTree
const Campaign=preload("res://application/campaign_session.gd")
func _initialize():call_deferred("run")
func battle(count: int) -> Dictionary:
 var sim=Campaign.new({"seed":7});sim.world.people.clear();sim.frontier.city_level=2
 for r in sim.mission.rifts:r.sealed=true
 sim.advance(0.01,30)
 var dragon=sim.raiders[0];dragon.x=1210;dragon.side=1
 sim.world.walls.wall.level=2;sim.world.walls.wall.hp=80
 for i in range(count):sim.world.people.append({"x":1035.0-i*10,"role":"guard","hurt":0.0,"cooldown":0.0,"region":-1,"defense_post":"wall"})
 var elapsed:=0.0
 while sim.is_running() and elapsed<180:
  sim.advance(0.05,-700);elapsed+=0.05
 return {"guards":count,"outcome":sim.mission.outcome,"seconds":snappedf(elapsed,0.1),"core":sim.mission.core_hp,"dragon_hp":dragon.fighter.hp}
func run():
 print(JSON.stringify([battle(0),battle(8)]));quit()
