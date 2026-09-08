extends CharacterBody2D
## Engine adapter: movement/collision/rendering only. Combat rules live in model.
const Fighter = preload("res://domain/combatant.gd")
const PIXELS := [
	".....rrr........", "....ssssss......", "...sHHHHHHs.....", "...sHhhhhHs.....",
	"...sHddddds.....", "...sHhggggs.....", "....sHHHHs......", "..rrssssss......",
	".rrsHHHHHHss....", ".rrsHhHHhHsGs...", ".rrsHHHHHHsGs...", ".rrsHHGGHHss....",
	".rr.sHHHHs......", "..r.sGGGGs......", "....sHHHHs......", "....sGssGs......",
	"....sGs.Gs......", "....sGs.Gs......", "...sGGs.GGs....."]
const PALETTE := {"s": Color("101523"), "H": Color("829eab"), "h": Color("d5e3dd"),
	"d": Color("171e2c"), "g": Color("88e4df"), "r": Color("78445a"), "G": Color("c49b66")}
@export var is_enemy: bool = false
var model: Fighter
var tuning: Resource
var telegraph: bool = false

func configure(fighter: Fighter, parameters: Resource) -> void:
	model = fighter
	tuning = parameters
	velocity = Vector2.ZERO
	queue_redraw()

func advance_motion(direction: float, jump_requested: bool, seconds: float) -> void:
	if model == null:
		return
	if model.is_alive():
		velocity.x = direction * tuning.move_speed
		if model.dash_remaining > 0.0:
			velocity.x = model.facing * tuning.dash_speed
		if jump_requested and is_on_floor():
			velocity.y = -tuning.jump_speed
	else:
		velocity.x = 0.0
	velocity.y += tuning.gravity * seconds
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	if model == null or not model.is_alive():
		return
	for row in range(PIXELS.size()):
		for column in range(PIXELS[row].length()):
			var key: String = PIXELS[row][column]
			if not PALETTE.has(key):
				continue
			var shade: Color = PALETTE[key]
			if is_enemy and key == "H":
				shade = Color("826875")
			if model.invulnerability_remaining > 0.0:
				shade = shade.lightened(0.35)
			var x := column if model.facing > 0 else 15 - column
			draw_rect(Rect2(x * 2 - 16, row * 2 - 38, 2, 2), shade)
	var reach: float = model.stats.attack_range if model.attack_remaining > 0.0 else 22.0
	draw_line(Vector2(model.facing * 12, -20), Vector2(model.facing * reach, -26), Color("d8d6b1"), 3.0)
	if model.attack_remaining > 0.0:
		draw_arc(Vector2.ZERO, reach, -1.1 if model.facing > 0 else -3.1, -0.1 if model.facing > 0 else -2.1, 12, Color("89d4d0"), 3.0)
	if telegraph:
		draw_rect(Rect2(-3, -62, 6, 13), Color("f4b26b"))
		draw_rect(Rect2(-3, -46, 6, 3), Color("f4b26b"))
	if is_enemy:
		draw_rect(Rect2(-24, -72, 48, 4), Color("342332"))
		draw_rect(Rect2(-24, -72, 48.0 * model.hp / model.stats.max_hp, 4), Color("d97884"))
