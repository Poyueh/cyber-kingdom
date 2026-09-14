extends RefCounted
## Intent is chosen by the drag direction, not which half of the screen was touched.
var fingers: Dictionary={}
var axis:=0.0
var move_finger:=-1
var offer_finger:=-1
func begin(id: int, at: Vector2) -> void:
 if fingers.has(id):return
 fingers[id]={"origin":at,"point":at,"movement":false,"offered":false}
func drag(id: int, at: Vector2) -> bool:
 if not fingers.has(id):return false
 var finger: Dictionary=fingers[id];finger.point=at
 if finger.offered:return false
 var delta: Vector2=at-finger.origin
 if delta.y>=28 and delta.y>absf(delta.x)*1.25 and offer_finger<0:
  if move_finger==id:move_finger=-1;axis=0
  finger.movement=false;finger.offered=true;offer_finger=id
  return true
 if move_finger==id:
  axis=0.0 if absf(delta.x)<14 else clampf(delta.x/48,-1,1)
 elif move_finger<0 and absf(delta.x)>=14 and absf(delta.x)>absf(delta.y)*1.25:
  move_finger=id;finger.movement=true;axis=clampf(delta.x/48,-1,1)
 return false
func finish(id: int) -> void:
 fingers.erase(id)
 if move_finger==id:move_finger=-1;axis=0
 if offer_finger==id:offer_finger=-1
func cancel() -> void:
 fingers.clear();axis=0;move_finger=-1;offer_finger=-1
