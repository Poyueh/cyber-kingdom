extends RefCounted
static func start(viewport: Viewport, id: int=19) -> void:
 var touch=InputEventScreenTouch.new();touch.index=id;touch.position=Vector2(650,200);touch.pressed=true
 viewport.push_input(touch,true)
 var drag=InputEventScreenDrag.new();drag.index=id;drag.position=Vector2(650,255)
 viewport.push_input(drag,true);Input.flush_buffered_events()
static func finish(viewport: Viewport, id: int=19) -> void:
 var event=InputEventScreenTouch.new();event.index=id;event.position=Vector2(650,255);event.pressed=false
 viewport.push_input(event,true);Input.flush_buffered_events()
