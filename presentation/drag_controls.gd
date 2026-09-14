extends Node2D
signal offering_started
signal offering_ended
var state=preload("res://presentation/drag_state.gd").new()
var enabled:=false
var safe:=Rect2()
var exclusions: Array[Rect2]=[]
func cancel() -> void:
 state.cancel();offering_ended.emit();queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
 if not enabled:return
 if event is InputEventScreenTouch:
  if event.pressed:
   if not safe.has_point(event.position) or exclusions.any(func(r):return r.has_point(event.position)):return
   # Reserve the upper HUD; world gestures begin below it.
   if event.position.y<safe.position.y+110:return
   state.begin(event.index,event.position,event.position.x<safe.get_center().x)
  else:
   if event.index==state.offer_finger:offering_ended.emit()
   state.finish(event.index)
 elif event is InputEventScreenDrag:
  if state.drag(event.index,event.position):offering_started.emit()
 queue_redraw()
func _draw() -> void:
 if not enabled:return
 for finger in state.fingers.values():
  var at: Vector2=finger.origin
  if finger.movement:
   draw_circle(at,48,Color(0.2,0.6,0.62,0.10))
   draw_arc(at,48,0,TAU,32,Color(0.55,0.9,0.82,0.45),2)
   draw_circle(at+Vector2(state.axis*36,0),14,Color(0.65,0.94,0.82,0.6))
  else:
   draw_line(at,at+Vector2(0,42),Color(0.65,0.94,0.82,0.6),2)
   draw_line(at+Vector2(-6,34),at+Vector2(0,42),Color(0.65,0.94,0.82,0.6),2)
   draw_line(at+Vector2(6,34),at+Vector2(0,42),Color(0.65,0.94,0.82,0.6),2)
