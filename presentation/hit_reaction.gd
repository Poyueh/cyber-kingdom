extends RefCounted
## Observes damage, never inflicts it. All timing advances with the caller's game clock.
var duration:=0.34
var distance:=7.0
var _hp:=-1
var _shield:=0
var _remaining:=0.0
var _direction:=1.0
var _kind:="hurt"
func clear() -> void:
 _hp=-1;_shield=0;_remaining=0
func trigger(direction: float, shielded:=false) -> void:
 _remaining=duration
 _direction=-1.0 if direction<0 else 1.0
 _kind="shield" if shielded else "hurt"
func advance(seconds: float) -> void:
 if seconds>0 and is_finite(seconds):_remaining=maxf(0,_remaining-seconds)
func observe(hp: int, shield: int, seconds: float, direction: float) -> Dictionary:
 advance(seconds)
 if _hp>=0:
  if hp<_hp:trigger(direction)
  elif shield<_shield:trigger(direction,true)
 _hp=hp;_shield=shield
 return pose()
func pose() -> Dictionary:
 var progress:=1.0-clampf(_remaining/maxf(0.01,duration),0,1)
 var force:=1.0 if progress<0.16 else pow((1.0-progress)/0.84,2)
 if _kind=="shield":force*=0.4
 return {"active":_remaining>0,"kind":_kind,"progress":progress,
  "offset":Vector2(_direction*distance*force,force*2),
  "rotation":_direction*0.18*force,"scale":Vector2(1+force*0.05,1-force*0.09),
  "flash":maxf(0,1-progress/0.24)}
