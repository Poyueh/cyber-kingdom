extends CanvasLayer
signal refuge_requested
var _expedition: bool = false
@onready var status: Label = $Top/Status
@onready var message: Label = $Top/Message

func present(snapshot: Dictionary) -> void:
	status.text = tr("HP %d/%d   SHIELD %d   CHARGE %d   SCRAP %d") % [snapshot.hp, snapshot.max_hp, snapshot.get("shield", 0), snapshot.stamina, snapshot.scrap]
	if snapshot.paused:
		message.text = tr("PAUSED — Esc or PAUSE to resume")
	elif snapshot.dead:
		message.text = tr("OATH BROKEN — press R / RESTART")
	elif snapshot.victory:
		message.text = tr("SENTINEL DEFEATED — R / RESTART to train again")
	elif _expedition:
		message.text = tr("Defeat the sentinel for salvage. R / RETURN retreats to the refuge.")
	else:
		message.text = tr("Prosthesis trial: cross the platforms. Watch for amber warnings.")
	if not tr(str(snapshot.warning)).is_empty():
		message.text += "\n" + tr(str(snapshot.warning))

func _ready() -> void:
	var text_theme=Theme.new();text_theme.default_font=preload("res://presentation/localized_font.gd").current()
	for child in get_children():
		if child is Control:child.theme=text_theme
	$Refuge.pressed.connect(func(): refuge_requested.emit())

func configure_expedition(enabled: bool) -> void:
	_expedition = enabled
	$Refuge.text = tr("RETREAT / RETURN") if enabled else tr("REFUGE / 避難所")
	$restart.visible = not enabled
	if enabled:
		$Top/Title.text = tr("CYBER KINGDOM / EXPEDITION")
		$Keys.text = tr("A/D MOVE   SPACE JUMP   J HIT   L DASH   R RETURN")
