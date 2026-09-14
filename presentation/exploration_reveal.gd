extends RefCounted
var _started: Dictionary={}
var _amount: Dictionary={}
var _initialized:=false
func observe(regions: Array, time: float) -> void:
 for i in range(regions.size()):
  if regions[i].discovered:
   if not _started.has(i):_started[i]=time-2.0 if not _initialized else time
   _amount[i]=smoothstep(0,1,clampf((time-float(_started[i]))/1.8,0,1))
  else:_amount[i]=0.0
 _initialized=true
func amount(index: int) -> float:
 return _amount.get(index,1.0 if index<0 else 0.0)
