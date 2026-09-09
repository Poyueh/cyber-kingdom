extends Control
## Prototype residents communicate protection and injury without combat rules.
var population: int = 3
var protected_count: int = 3
var wounded: int = 0
var settled: bool = false
const PERSON := ["..hhhh..", "..ssss..", "..ssss..", "...ss...", "..cccc..", ".cccccc.", ".sccccs.", "..cccc..", "..cccc..", "..b..b..", "..b..b..", ".bb..bb."]

func present(snapshot: Dictionary, result: bool) -> void:
	population = snapshot.residents
	protected_count = snapshot.protected
	wounded = snapshot.wounded if result else 0
	settled = result
	queue_redraw()

func _draw() -> void:
	for index in range(population):
		var x := (index + 0.5) * size.x / maxi(1, population)
		var safe := index < protected_count
		var injured := settled and not safe
		var coat := Color("ca985a") if index % 2 == 0 else Color("8b829e")
		if injured:
			coat = Color("785061")
		var colors := {"h": Color("43323a"), "s": Color("e2b69a"), "c": coat, "b": Color("3c5260")}
		var origin := Vector2(x - 12, 27 if injured else 18)
		for row in range(PERSON.size()):
			for column in range(PERSON[row].length()):
				var color_key: String = PERSON[row][column]
				if colors.has(color_key):
					draw_rect(Rect2(origin + Vector2(column * 3, row * 3), Vector2(3,3)), colors[color_key])
		draw_rect(Rect2(x-22, 66, 44, 3), Color("637474"))
		if safe:
			draw_arc(Vector2(x,42), 28, PI, TAU, 16, Color("75e4de"), 2)
			draw_line(Vector2(x-28,42),Vector2(x-28,63),Color("75e4de"),2)
			draw_line(Vector2(x+28,42),Vector2(x+28,63),Color("75e4de"),2)
		elif injured:
			draw_rect(Rect2(x-3,0,6,17),Color("f2a088"))
			draw_rect(Rect2(x-8,5,16,6),Color("f2a088"))
		else:
			draw_circle(Vector2(x,6),4,Color("de9a64"))
