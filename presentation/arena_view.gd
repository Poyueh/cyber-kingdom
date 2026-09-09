extends Node2D
## Generated foundry backdrop; foreground ledges match scene collision exactly.
const BACKDROP = preload("res://art/environments/foundry/processed/foundry-v001.png")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1800, 540), Color("0a1421"))
	draw_texture_rect(BACKDROP, Rect2(0, -85, 1800, 600), false)
	# Low contrast masonry under a bright, unambiguous walkable edge.
	draw_rect(Rect2(0, 430, 1800, 110), Color("151f2b"))
	for row in range(4):
		for column in range(24):
			var x := column * 80 - (40 if row % 2 else 0)
			var block := Rect2(x + 2, 441 + row * 25, 76, 22)
			var shade := Color("263342") if (column + row) % 3 else Color("2d3a48")
			draw_rect(block, shade)
			draw_line(block.position, block.position + Vector2(75, 0), Color("38444e"), 1.0)
	draw_rect(Rect2(0, 430, 1800, 4), Color("aaa086"))
	draw_rect(Rect2(0, 434, 1800, 6), Color("4d4b42"))
	for index in range(30):
		var x := index * 60.0
		draw_rect(Rect2(x, 432, 2, 7), Color("232b34"))
		draw_rect(Rect2(x + 12, 436, 2, 2), Color("c99e62"))
	for platform in [Rect2(370, 348, 130, 14), Rect2(990, 332, 180, 14)]:
		draw_rect(platform.grow(2), Color("101a26"))
		draw_rect(platform, Color("3e4b56"))
		draw_rect(Rect2(platform.position, Vector2(platform.size.x, 3)), Color("91b9b4"))
		for x in range(8, int(platform.size.x) - 4, 24):
			draw_rect(Rect2(platform.position + Vector2(x, 8), Vector2(10, 2)), Color("897450"))
