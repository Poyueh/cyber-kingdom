extends CanvasLayer
signal refuge_requested
var _expedition: bool = false
@onready var status: Label = $Top/Status
@onready var message: Label = $Top/Message

func present(snapshot: Dictionary) -> void:
	status.text = "HP %d/%d   SHIELD %d   CHARGE %d   SCRAP %d" % [snapshot.hp, snapshot.max_hp, snapshot.get("shield", 0), snapshot.stamina, snapshot.scrap]
	if snapshot.paused:
		message.text = "PAUSED — Esc or PAUSE to resume"
	elif snapshot.dead:
		message.text = "OATH BROKEN — press R / RESTART"
	elif snapshot.victory:
		message.text = "SENTINEL DEFEATED — R / RESTART to train again"
	elif _expedition:
		message.text = "Defeat the sentinel for salvage. R / RETURN retreats to the refuge."
	else:
		message.text = "Prosthesis trial: cross the platforms. Watch for amber warnings."
	if not str(snapshot.warning).is_empty():
		message.text += "\n" + str(snapshot.warning)

func _ready() -> void:
	$Refuge.pressed.connect(func(): refuge_requested.emit())

func configure_expedition(enabled: bool) -> void:
	_expedition = enabled
	$Refuge.text = "RETREAT / RETURN" if enabled else "REFUGE / 龍晶分配"
	$restart.visible = not enabled
	if enabled:
		$Top/Title.text = "CYBER KINGDOM / EXPEDITION"
		$Keys.text = "A/D MOVE   SPACE JUMP   J HIT   L DASH   R RETURN"
