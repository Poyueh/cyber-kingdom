extends Node2D
## Temporary original code-drawn scenery; collision shapes stay in the scene.
func _draw() -> void:
	draw_rect(Rect2(0, 0, 1800, 540), Color("0d1522"))
	draw_circle(Vector2(710, 100), 37, Color("8ba7ad"))
	for index in range(15):
		var x := index * 140.0
		var height := 90.0 + (index % 4) * 35.0
		draw_rect(Rect2(x, 330 - height, 92, height), Color("1d2a3b"))
		draw_rect(Rect2(x + 32, 306 - height, 28, 24), Color("1d2a3b"))
	for index in range(10):
		var x := 70.0 + index * 185.0
		draw_rect(Rect2(x, 150, 16, 280), Color("35414d"))
		draw_rect(Rect2(x - 8, 145, 32, 10), Color("607078"))
		draw_rect(Rect2(x + 40, 185, 36, 84), Color("56374a"))
		draw_line(Vector2(x + 58, 197), Vector2(x + 58, 252), Color("bc9465"), 3)
		draw_rect(Rect2(x + 6, 180, 3, 210), Color("43777d"))
		draw_rect(Rect2(x + 115, 340, 8, 20), Color("e6aa68"))
	draw_rect(Rect2(0, 430, 1800, 110), Color("27313c"))
	draw_rect(Rect2(0, 430, 1800, 5), Color("788886"))
	for index in range(45):
		draw_line(Vector2(index * 40, 438), Vector2(index * 40, 462), Color("131f2c"), 2)
	for platform in [Rect2(370, 348, 130, 14), Rect2(990, 332, 180, 14)]:
		draw_rect(platform, Color("4b5d67"))
		draw_line(platform.position, platform.position + Vector2(platform.size.x, 0), Color("81b8b1"), 3)
