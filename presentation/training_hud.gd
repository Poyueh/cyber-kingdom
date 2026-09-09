extends CanvasLayer
@onready var status: Label = $Top/Status
@onready var message: Label = $Top/Message

func present(snapshot: Dictionary) -> void:
	status.text = "HP %d/%d    CHARGE %d    SCRAP %d" % [snapshot.hp, snapshot.max_hp, snapshot.stamina, snapshot.scrap]
	if snapshot.paused:
		message.text = "PAUSED — Esc or PAUSE to resume"
	elif snapshot.dead:
		message.text = "OATH BROKEN — press R / RESTART"
	elif snapshot.victory:
		message.text = "SENTINEL DEFEATED — R / RESTART to train again"
	else:
		message.text = "Prosthesis trial: cross the platforms. Watch for amber warnings."
	if not str(snapshot.warning).is_empty():
		message.text += "\n" + str(snapshot.warning)
