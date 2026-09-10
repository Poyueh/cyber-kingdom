extends "res://presentation/frontier_hud.gd"
var calendar_label: Label
func _ready() -> void:
	super._ready()
	calendar_label=Label.new()
	calendar_label.position=Vector2(18,94)
	calendar_label.add_theme_font_override("font",$Keys.get_theme_font("font"))
	calendar_label.add_theme_font_size_override("font_size",18)
	calendar_label.add_theme_color_override("font_color",Color("f4d8a5"))
	add_child(calendar_label)
	$Keys.text="A/D 移動　E 每次投入一顆／開箱　J 戰鬥　L 衝刺　Space 跳躍　R 重玩"
func present_world(sim, is_paused: bool, at: float, grounded: bool) -> void:
	super.present_world(sim,is_paused,at,grounded)
	var map=sim.frontier
	$Top/Title.text="營火王國 · 探索 %d/6 · 拓荒站 %d" % [map.discovered_count(),map.outpost_count()]
	status.text="龍晶背包 %d/%d　木材 %d　食物 %d　石材 %d　藥草 %d　廢料 %d" % [sim.pouch.amount,sim.pouch.capacity,map.wood,map.food,map.stone,map.herbs,sim.world.scrap]
	status.add_theme_font_size_override("font_size",14)
	calendar_label.text="第 %d 天 · %s　已熬過 %d 晚　%s　生命 %d / 盾 %d" % [sim.clock.day,"夜晚" if sim.clock.is_night else "白天",sim.clock.survived,"等待敵軍退去" if sim.clock.remaining<=0 else "%d 秒" % ceili(sim.clock.remaining),sim.hero.hp,sim.hero.shield]
	if is_paused or not sim.hero.is_alive(): return
	if sim.kingdom_established(): message.text="王國建立！仍可繼續守城與探索；N 開始新地圖。"
	elif sim.clock.is_night: message.text="第 %d 夜 · 敵人逐日增強。保護居民，活到下一個黎明。" % sim.clock.day
	elif map.city_level==0: message.text="在營火投入 2 龍晶 → 招攬流浪者 → 準備工匠器具。"
	else: message.text="居民採集搬運 · 龍晶留在收貨點 · 食物可交易龍晶 · 寶箱親自開。"
	if sim.pouch.amount==sim.pouch.capacity and not sim.clock.is_night:
		for pile in sim.pouch.drops:
			if absf(pile.x-at)<28:
				message.text="背包已滿！多出的龍晶留在地面，投入龍晶後可回來撿取。"
	var choice: Dictionary=sim.context(at)
	interact_button.text="投入 1 龍晶 [E]" if choice.cost>0 else ("開啟寶箱 [E]" if choice.id=="chest" else "互動 [E]")
