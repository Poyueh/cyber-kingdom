extends RefCounted
## Pixel-grid energy animation driven by simulation time, so pause and outcome freeze it.
static func draw_gate(view: Node2D, rift: Dictionary, elapsed: float, duration: float, alpha: float=1.0) -> void:
	var x: float=rift.x
	var active: bool=not rift.sealed
	var frame:=int(elapsed*8)
	var pulse:=0.72+0.18*sin(elapsed*2.2)
	# Reuse the original world stone; stepped pylons carry the same cyan circuitry.
	view._prop("stone",Vector2(x,432),0.75,_fade(Color("83909e"),alpha))
	for side in [-1,1]:
		var at:=Vector2(x+side*34,430)
		var shape:=PackedVector2Array([at+Vector2(-9,0),at+Vector2(-9,-68),at+Vector2(-5,-68),at+Vector2(-5,-88),at+Vector2(5,-88),at+Vector2(5,-76),at+Vector2(9,-76),at+Vector2(9,0)])
		view.draw_colored_polygon(shape,_fade(Color("27313e"),alpha))
		view.draw_rect(Rect2(at+Vector2(-5,-74),Vector2(3,65)),_fade(Color("657080"),alpha))
		for y in [-66,-44,-22]:
			view.draw_rect(Rect2(at+Vector2(0,y),Vector2(5,8)),_fade(Color("bb93db"),alpha) if active else _fade(Color("6fbdae"),alpha))
	if active:
		view.draw_rect(Rect2(x-25,350,50,76),_fade(Color(0.31,0.16,0.43,0.24*pulse),alpha))
		for row in range(18):
			var y:=352.0+row*4
			var width:=8.0+absf(sin(row*0.5+elapsed*1.8))*12
			var offset:=float((row+frame)%3-1)*4
			view.draw_rect(Rect2(x-width*0.5+offset,y,width,4),_fade(Color(0.52,0.35,0.68,0.6*pulse),alpha))
			if (row+frame)%5==0:view.draw_rect(Rect2(x+offset-2,y,4,4),_fade(Color("bce9df"),alpha))
		for i in range(6):
			var y:=424.0-fposmod(elapsed*24+i*17,86)
			var dx:=float((i*13)%48)-24
			view.draw_rect(Rect2(Vector2(x+dx,y).snapped(Vector2.ONE*2),Vector2.ONE*2),_fade(Color("d3acdf"),alpha))
	view._icon("check" if rift.sealed else "rift",Vector2(x,330),23,_fade(Color("9ddcba"),alpha) if rift.sealed else _fade(Color("c5a3de"),alpha))
	if rift.ordered and not rift.sealed:
		view.draw_rect(Rect2(x-32,337,64,4),_fade(Color("273940"),alpha))
		view.draw_rect(Rect2(x-32,337,64*rift.progress/duration,4),_fade(Color("a2ecd1"),alpha))
		view._icon("hammer",Vector2(x+54,405),17,_fade(Color("edc98e"),alpha))

static func _fade(color: Color, alpha: float) -> Color:
	color.a*=alpha
	return color
