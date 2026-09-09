@tool
extends StaticBody2D
## One width drives the visible ledge and its collision surface.
@export_range(32.0, 320.0, 1.0) var width: float = 130.0:
	set(value):
		width = value
		if is_node_ready():
			_update_shape()

func _ready() -> void:
	_update_shape()

func _update_shape() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 14)
	$Shape.shape = shape
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(-width * 0.5, -7, width, 14)
	draw_rect(rect.grow(2), Color("101a26"))
	draw_rect(rect, Color("3e4b56"))
	draw_rect(Rect2(rect.position, Vector2(width, 3)), Color("91b9b4"))
	for x in range(8, int(width) - 4, 24):
		draw_rect(Rect2(rect.position + Vector2(x, 8), Vector2(10, 2)), Color("897450"))
