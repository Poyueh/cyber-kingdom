extends Control
## Displays snapshots and emits intentions; owns no allocation or combat rules.
signal allocation_requested(amount: int)
signal depart_requested
signal exit_requested
const Residents = preload("res://presentation/refuge_residents.gd")
const KnightFrames = preload("res://data/knight_animation_frames.tres")
var choices: Array[Button] = []
var depart_button: Button
var residents: Control
var _title: Label
var _forecast: Label
var _knight: Label
var _refuge: Label
var _summary: Label
var _caption: Label
var _choice_count := -1

func _ready() -> void:
	var font=preload("res://presentation/localized_font.gd").current()
	theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 18
	var background := ColorRect.new()
	background.color = Color("0b1520")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_title = _label(Vector2(32,18),Vector2(896,42),30,Color("e4cea0"))
	_label(Vector2(32,62),Vector2(896,26),15,Color("8da8b7")).text = tr("龍晶分配試驗  /  每輪重置，尚未保存出征進度")
	_forecast = _label(Vector2(32,99),Vector2(896,33),18,Color("e5ac7a"))
	_card(Rect2(32,145,432,163))
	_card(Rect2(488,145,440,163))
	_label(Vector2(56,158),Vector2(200,28),20,Color("90e4df")).text = tr("改造騎士")
	var portrait := TextureRect.new()
	portrait.texture = KnightFrames.get_frame_texture(&"idle",0)
	portrait.position = Vector2(38,169)
	portrait.size = Vector2(192,144)
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	_knight = _label(Vector2(212,195),Vector2(235,100),22,Color("dbe9e8"))
	_refuge = _label(Vector2(512,158),Vector2(392,36),20,Color("dbe9e8"))
	residents = Residents.new()
	residents.position = Vector2(522,201)
	residents.size = Vector2(372,80)
	residents.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(residents)
	_summary = _label(Vector2(32,390),Vector2(896,49),19,Color("d5e2e4"))
	_caption = _label(Vector2(32,512),Vector2(896,22),13,Color("8da8b7"))
	var back := _button(tr("返回訓練場"),Rect2(32,453,220,52))
	back.pressed.connect(func(): exit_requested.emit())
	depart_button = _button(tr("確認配置，出征"),Rect2(616,449,312,60))
	depart_button.pressed.connect(func(): depart_requested.emit())

func _label(at: Vector2, bounds: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.size = bounds
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.content_margin_left = 8
	style.content_margin_right = 8
	return style

func _card(rect: Rect2) -> void:
	var card := Panel.new()
	card.position = rect.position
	card.size = rect.size
	card.add_theme_stylebox_override("panel",_style(Color("152634"),Color("304855")))
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)

func _button(text: String, rect: Rect2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal",_style(Color("1b3442"),Color("41616c")))
	button.add_theme_stylebox_override("hover",_style(Color("294d59"),Color("8bd8d2")))
	button.add_theme_stylebox_override("pressed",_style(Color("346568"),Color("b2f0e8")))
	add_child(button)
	return button

func present_allocation(snapshot: Dictionary) -> void:
	_summary.position.y = 390
	_title.text = tr("最後的避難所  /  這次，能源留給誰？")
	_forecast.text = tr("魔潮預報：%d 名居民各承受一次衝擊。每顆龍晶可護住 1 人。") % snapshot.residents
	_knight.text = tr("護盾  %d\n分配 %d 顆龍晶") % [snapshot.knight_shield,snapshot.knight_crystals]
	_refuge.text = tr("居民防護  %d / %d 人") % [snapshot.protected,snapshot.residents]
	residents.present(snapshot,false)
	_summary.text = tr("共 %d 顆龍晶：騎士 %d ／ 避難所 %d。\n預計 %d 人受傷；騎士護盾承受傷害後不再恢復。") % [snapshot.total,snapshot.knight_crystals,snapshot.refuge_crystals,snapshot.wounded]
	_caption.text = tr("擊敗守衛帶回廢料；撤退或倒下也會結算魔潮。出征後配置鎖定。")
	depart_button.text = tr("確認配置，出征")
	if _choice_count != snapshot.total + 1:
		for button in choices:
			remove_child(button)
			button.queue_free()
		choices.clear()
		_choice_count = snapshot.total + 1
		var width: float = (896.0 - 8.0 * (_choice_count - 1)) / _choice_count
		for amount in range(_choice_count):
			var button := _button(tr("騎士 %d  /  避難所 %d") % [amount,snapshot.total-amount],Rect2(32+amount*(width+8),322,width,58))
			if _choice_count > 4:
				button.text = tr("騎士 %d\n避難所 %d") % [amount,snapshot.total-amount]
			button.pressed.connect(func(): allocation_requested.emit(amount))
			choices.append(button)
	for amount in range(choices.size()):
		choices[amount].show()
		var selected: bool = amount == snapshot.knight_crystals
		choices[amount].add_theme_stylebox_override("normal",_style(Color("285354") if selected else Color("1b3442"),Color("8bd8d2") if selected else Color("41616c")))

func present_result(report: Dictionary) -> void:
	var outcome: String = {"victory":tr("出征成功"), "retreat":tr("提前撤退"), "defeat":tr("騎士倒下")}[report.outcome]
	_title.text = tr("魔潮過後  /  ") + outcome
	_forecast.text = tr("魔潮已結算：%d 人安然無恙，%d 人受傷。") % [report.protected,report.wounded]
	_knight.text = tr("生命  %d\n護盾擋下 %d 傷害") % [report.hero_hp,report.absorbed]
	_refuge.text = tr("避難所  /  %d 名居民受傷") % report.wounded
	residents.present(report,true)
	for button in choices:
		button.hide()
	_summary.position.y = 333
	_summary.text = tr("帶回廢料 %d　剩餘護盾 %d\n本次配置：騎士 %d 顆 ／ 避難所 %d 顆") % [report.recovered,report.shield_remaining,report.knight_crystals,report.refuge_crystals]
	_caption.text = tr("重試會還原本輪龍晶與居民，供比較不同選擇；這不是永久死亡或完整經營系統。")
	depart_button.text = tr("重新分配，再試一次")
