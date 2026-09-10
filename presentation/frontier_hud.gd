extends "res://presentation/settlement_hud.gd"
signal new_map_requested
var new_map_button: Button
func _ready() -> void:
	super._ready()
	new_map_button = Button.new()
	new_map_button.position = Vector2(225,459)
	new_map_button.size = Vector2(125,54)
	new_map_button.text = "新地圖 [N]"
	new_map_button.focus_mode = Control.FOCUS_NONE
	new_map_button.add_theme_font_override("font",$Keys.get_theme_font("font"))
	new_map_button.pressed.connect(func(): new_map_requested.emit())
	add_child(new_map_button)
	status.add_theme_font_size_override("font_size",15)
	$Keys.text = "A/D 移動　E 就地互動　J 採集／戰鬥　L 衝刺　Space 跳躍　R 重玩此圖"

func present_world(sim, is_paused: bool, at: float, grounded: bool) -> void:
	super.present_world(sim,is_paused,at,grounded)
	var map = sim.frontier
	$Top/Title.text = "龍晶邊境 / 地圖 %d · 探索 %d/6" % [sim.map_seed,map.discovered_count()]
	status.text = "生命 %d  盾 %d  廢料 %d  龍晶 %d  木材 %d  食物 %d" % [sim.hero.hp,sim.hero.shield,sim.world.scrap,sim.world.crystals,map.wood,map.food]
	if is_paused or not sim.hero.is_alive(): return
	if sim.kingdom_established():
		message.text = "王國建立！三波守成、王城與居民都保住了。N 開始另一片邊境。"
	elif sim.finished():
		message.text = "夜襲已退 / 目標：王城 3 級、防線 2 級存活、至少 3 位居民。"
	elif sim.raiders.is_empty():
		message.text = "夜襲 %d 秒 / 城鎮 %d/3 · 探索兩側 → 採集／生產 → 擴建守城" % [ceili(sim.time_to_raid),map.city_level]
	var choice: Dictionary = sim.context(at)
	if choice.id == "harvest": interact_button.text = "採集 / 揮劍 [E]"
