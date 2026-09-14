extends RefCounted
## Transient visual memory; none of this is serialized or changes combat/occupations.
const Reaction=preload("res://presentation/hit_reaction.gd")
var fallen: Array[Dictionary]=[]
var _sim
var _clock:=0.0
var _enemies: Dictionary={}
var _residents: Dictionary={}
func present(sim) -> void:
 if not is_same(_sim,sim):
  _sim=sim;_clock=sim.workforce.elapsed
  _enemies.clear();_residents.clear();fallen.clear()
 var delta:=maxf(0,sim.workforce.elapsed-_clock)
 _clock=sim.workforce.elapsed
 for body in fallen:body.age+=delta
 fallen=fallen.filter(func(body):return body.age<0.42)
 var living: Dictionary={}
 for enemy in sim.raiders:
  var id: int=enemy.fighter.get_instance_id()
  living[id]=true
  if not _enemies.has(id):
   var reaction=Reaction.new()
   reaction.observe(enemy.fighter.hp,enemy.fighter.shield,0,1)
   _enemies[id]={"reaction":reaction,"enemy":enemy,"fallen":false}
  var state: Dictionary=_enemies[id]
  state.reaction.observe(enemy.fighter.hp,enemy.fighter.shield,delta,-enemy.get("direction",-1.0))
  if not enemy.fighter.is_alive():_fall(state)
 for id in _enemies.keys():
  if not living.has(id):
   if not _enemies[id].enemy.fighter.is_alive():_fall(_enemies[id])
   _enemies.erase(id)
 for index in range(sim.world.people.size()):
  var person: Dictionary=sim.world.people[index]
  if not _residents.has(index):_residents[index]={"reaction":Reaction.new(),"hurt":person.hurt,"role":person.role}
  var state: Dictionary=_residents[index]
  state.reaction.advance(delta)
  if person.hurt>state.hurt:state.reaction.trigger(_away(person,sim.raiders))
  state.hurt=person.hurt
  if not state.reaction.pose().active:state.role=person.role
func _away(person: Dictionary, enemies: Array) -> float:
 var direction: float=-person.get("direction",1.0)
 var nearest:=INF
 for enemy in enemies:
  if absf(enemy.x-person.x)<nearest:
   nearest=absf(enemy.x-person.x)
   direction=1.0 if person.x>=enemy.x else -1.0
 return direction
func _fall(state: Dictionary) -> void:
 if state.fallen:return
 state.fallen=true
 fallen.append({"x":state.enemy.x,"direction":state.enemy.get("direction",-1.0),"age":0.0})
func enemy_pose(enemy: Dictionary) -> Dictionary:
 var state: Dictionary=_enemies.get(enemy.fighter.get_instance_id(),{})
 return state.reaction.pose() if not state.is_empty() else Reaction.new().pose()
func resident_pose(index: int) -> Dictionary:
 var state: Dictionary=_residents.get(index,{})
 var result: Dictionary=state.reaction.pose() if not state.is_empty() else Reaction.new().pose()
 result.role=state.get("role","wanderer")
 return result
