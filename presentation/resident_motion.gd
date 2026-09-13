extends RefCounted
## Presentation-only gait memory. Simulation distance plants feet; its clock freezes rest on pause.
const STRIDE:=32.0
const SETTLE_SECONDS:=0.12
var _people: Dictionary={}
func clear() -> void:
	_people.clear()

func sample(person: Dictionary, index: int, time: float) -> Dictionary:
	var moving: bool=person.get("moving",false)
	var phase:=fposmod(float(person.get("walk_distance",0.0))/STRIDE,1.0)
	if not _people.has(index):
		_people[index]={"moving":moving,"stop":time-SETTLE_SECONDS,"phase":phase,"role":person.role}
	var state: Dictionary=_people[index]
	if state.role!=person.role:
		state.role=person.role
		state.moving=moving
		state.stop=time-SETTLE_SECONDS
	if state.moving and not moving:
		state.stop=time
		state.phase=phase
	state.moving=moving
	if moving:return {"mode":"walk","frame":int(phase*8)%8}
	var progress:=clampf((time-float(state.stop))/SETTLE_SECONDS,0,1)
	if progress<1:
		# Finish at the next passing pose, with both feet close to the hips.
		var target: float=ceilf((float(state.phase)-0.25)*2.0)*0.5+0.25
		return {"mode":"settle","frame":int(fposmod(lerpf(state.phase,target,progress),1.0)*8)%8}
	return {"mode":"idle","frame":int(fposmod(time*0.45+index*0.173,1.0)*8)%8}
