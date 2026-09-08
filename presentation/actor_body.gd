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
@onready var visual: AnimatedSprite2D = get_node_or_null("KnightVisual")

func configure(fighter: Fighter, parameters: Resource) -> void:
	model = fighter
	tuning = parameters
	velocity = Vector2.ZERO
	if visual != null:
		visual.reset_pose()
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

func refresh_visual(seconds: float) -> void:
	if visual != null:
		visual.present({"alive": model.is_alive(), "facing": action_facing(),
			"moving": absf(velocity.x) > 0.1, "grounded": is_on_floor(),
			"dashing": model.dash_remaining > 0.0, "attack_progress": model.attack_progress(),
			"invulnerable": model.invulnerability_remaining > 0.0}, seconds)
	queue_redraw()

func action_facing() -> int:
	return model.attack_facing if model.attack_remaining > 0.0 else model.facing

func _draw() -> void:
	if model == null or not model.is_alive():
		return
	var reach: float = model.stats.attack_range if model.is_attack_active() else 22.0
	var facing := action_facing()
	if visual == null:
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
				var x := column if facing > 0 else 15 - column
				draw_rect(Rect2(x * 2 - 16, row * 2 - 38, 2, 2), shade)
		draw_line(Vector2(facing * 12, -20), Vector2(facing * reach, -26), Color("d8d6b1"), 3.0)
	if model.is_attack_active():
		var center_angle := 0.0 if facing > 0 else PI
		draw_arc(Vector2(0, -24), reach, center_angle - 0.6, center_angle + 0.6, 12, Color("89d4d0"), 3.0)
	if telegraph:
		draw_rect(Rect2(-3, -62, 6, 13), Color("f4b26b"))
		draw_rect(Rect2(-3, -46, 6, 3), Color("f4b26b"))
	if is_enemy:
		draw_rect(Rect2(-24, -72, 48, 4), Color("342332"))
		draw_rect(Rect2(-24, -72, 48.0 * model.hp / model.stats.max_hp, 4), Color("d97884"))
