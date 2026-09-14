extends RefCounted
var fingers: Dictionary={}
var axis:=0.0
var move_finger:=-1
var offer_finger:=-1
func begin(id: int, at: Vector2, movement: bool) -> void:
 if (movement and move_finger>=0) or (not movement and offer_finger>=0):return
 fingers[id]={"origin":at,"point":at,"movement":movement,"offered":false}
 if movement:move_finger=id
 else:offer_finger=id
func drag(id: int, at: Vector2) -> bool:
 if not fingers.has(id):return false
 var finger: Dictionary=fingers[id];finger.point=at
 var delta: Vector2=at-finger.origin
 if finger.movement:
  axis=0.0 if absf(delta.x)<14 else clampf(delta.x/48,-1,1)
 elif not finger.offered and delta.y>=42 and delta.y>absf(delta.x)*1.25:
  finger.offered=true;return true
 return false
func finish(id: int) -> void:
 fingers.erase(id)
 if move_finger==id:move_finger=-1;axis=0
 if offer_finger==id:offer_finger=-1
func cancel() -> void:
 fingers.clear();axis=0;move_finger=-1;offer_finger=-1
