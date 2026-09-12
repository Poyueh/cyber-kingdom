extends RefCounted
## Pixel-grid energy animation driven by simulation time, so pause and outcome freeze it.
static func draw_gate(view: Node2D, rift: Dictionary, elapsed: float, duration: float) -> void:
	var x: float=rift.x
	var active: bool=not rift.sealed
	var frame:=int(elapsed*8)
	var pulse:=0.72+0.18*sin(elapsed*2.2)
	# Reuse the original world stone; stepped pylons carry the same cyan circuitry.
	view._prop("stone",Vector2(x,432),0.75,Color("83909e"))
	for side in [-1,1]:
		var at:=Vector2(x+side*34,430)
		var shape:=PackedVector2Array([at+Vector2(-9,0),at+Vector2(-9,-68),at+Vector2(-5,-68),at+Vector2(-5,-88),at+Vector2(5,-88),at+Vector2(5,-76),at+Vector2(9,-76),at+Vector2(9,0)])
		view.draw_colored_polygon(shape,Color("27313e"))
		view.draw_rect(Rect2(at+Vector2(-5,-74),Vector2(3,65)),Color("657080"))
		for y in [-66,-44,-22]:
			view.draw_rect(Rect2(at+Vector2(0,y),Vector2(5,8)),Color("bb93db") if active else Color("6fbdae"))
	if active:
		view.draw_rect(Rect2(x-25,350,50,76),Color(0.31,0.16,0.43,0.24*pulse))
		for row in range(18):
			var y:=352.0+row*4
			var width:=8.0+absf(sin(row*0.5+elapsed*1.8))*12
			var offset:=float((row+frame)%3-1)*4
			view.draw_rect(Rect2(x-width*0.5+offset,y,width,4),Color(0.52,0.35,0.68,0.6*pulse))
			if (row+frame)%5==0:view.draw_rect(Rect2(x+offset-2,y,4,4),Color("bce9df"))
		for i in range(6):
			var y:=424.0-fposmod(elapsed*24+i*17,86)
			var dx:=float((i*13)%48)-24
			view.draw_rect(Rect2(Vector2(x+dx,y).snapped(Vector2.ONE*2),Vector2.ONE*2),Color("d3acdf"))
	view._icon("check" if rift.sealed else "rift",Vector2(x,330),23,Color("9ddcba") if rift.sealed else Color("c5a3de"))
	if rift.ordered and not rift.sealed:
		view.draw_rect(Rect2(x-32,337,64,4),Color("273940"))
		view.draw_rect(Rect2(x-32,337,64*rift.progress/duration,4),Color("a2ecd1"))
		view._icon("hammer",Vector2(x+54,405),17,Color("edc98e"))
