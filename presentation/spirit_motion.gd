extends RefCounted
## A screen-space companion follows freely; advice remains a read-only world target.
var follow_distance:=68.0
var follow_height:=104.0
var _position:=Vector2.ZERO
var _last_time:=-1.0
var _direction:=1.0
func sample(hint: Dictionary, hero: Vector2, world_x: float, safe: Rect2, time: float) -> Dictionary:
 if hint.is_empty():
  _last_time=-1
  return {"visible":false}
 var distance: float=hint.x-world_x
 if absf(distance)>28:_direction=signf(distance)
 var goal:=hero+Vector2(-_direction*follow_distance,-follow_height)
 goal.x=clampf(goal.x,safe.position.x+45,safe.end.x-45)
 goal.y=clampf(goal.y,safe.position.y+140,safe.end.y-130)
 if _last_time<0 or time<_last_time:_position=goal
 elif time>_last_time:
  _position=_position.lerp(goal,1.0-exp(-10*(time-_last_time)))
  # Never strand the companion when the camera jumps or a distant checkpoint loads.
  _position=hero+(_position-hero).limit_length(165)
 _last_time=time
 return {"visible":true,"position":(_position+Vector2(0,sin(time*2.8)*3)).round(),
  "direction":(-1.0 if distance-(_position.x-hero.x)<0 else 1.0),"near":absf(distance)<=73,"phase":time}
