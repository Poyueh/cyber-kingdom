extends "res://presentation/training_hud.gd"
signal interact_requested
var interact_button: Button
func _ready() -> void:
	super._ready()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["PingFang TC","Microsoft JhengHei","Noto Sans CJK TC"])
	for node in [$Top/Title,$Top/Status,$Top/Message,$Refuge,$Keys]:
		node.add_theme_font_override("font",font)
	$Refuge.position = Vector2(595,12)
	$Refuge.size = Vector2(120,52)
	$Refuge.text = tr("訓練場")
	$Top/Title.text = tr("最後的避難所 / 現場建設")
	$Keys.text = tr("A/D 移動　E 投入　J 劈砍　L 衝刺　Space 跳躍　R 重試")
	interact_button = Button.new()
	interact_button.position = Vector2(365,459)
	interact_button.size = Vector2(225,54)
	interact_button.focus_mode = Control.FOCUS_NONE
	interact_button.add_theme_font_override("font",font)
	interact_button.add_theme_font_size_override("font_size",18)
	interact_button.pressed.connect(func(): interact_requested.emit())
	add_child(interact_button)

func present_world(sim, paused: bool, at: float, grounded: bool) -> void:
	status.text = tr("生命 %d  護盾 %d  廢料 %d  龍晶 %d") % [sim.hero.hp,sim.hero.shield,sim.world.scrap,sim.world.crystals]
	var choice: Dictionary = sim.context(at)
	interact_button.text = tr("投入 %d %s  [E]") % [choice.cost,tr(choice.currency)] if choice.cost>0 else tr("互動 [E]")
	interact_button.disabled = paused or not grounded or not choice.enabled or not sim.hero.is_alive()
	if paused:
		message.text = tr("已暫停 / Esc 或 PAUSE 繼續")
	elif not sim.hero.is_alive():
		message.text = tr("騎士倒下 / R 重試整段避難所")
	elif sim.finished():
		message.text = tr("三波試煉結束。留下的居民與防線，就是本輪的結果。")
	elif not sim.raiders.is_empty():
		message.text = tr("第 %d 波來襲！保護居民；敵人倒下的廢料要靠近回收。") % sim.wave
	else:
		message.text = tr("夜襲約 %d 秒後 / 招攬居民 → 供應器具 → 建造防線") % ceili(sim.time_to_raid)
