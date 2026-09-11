extends "res://presentation/frontier_hud.gd"
const Icons=preload("res://presentation/ui_icons.gd")
const Dashboard=preload("res://presentation/icon_dashboard.gd")
signal throw_requested
var drop_button: Button
var interact_held := false
var focus_key := ""
var dashboard: Node2D
var fullscreen_button: Button

func _ready() -> void:
	super._ready()
	interact_button.action_mode=BaseButton.ACTION_MODE_BUTTON_PRESS
	interact_button.button_down.connect(func(): interact_held=true)
	interact_button.button_up.connect(func(): interact_held=false)
	$Top.hide()
	$Keys.hide()
	dashboard=Dashboard.new()
	add_child(dashboard)
	# Keep input actions on TouchScreenButton for simultaneous movement and attacks.
	for key in ["move_left","move_right","dash","jump","attack","pause","restart"]:
		var button: TouchScreenButton=get_node(key)
		button.get_node("Fill").hide()
		button.get_node("Label").hide()
		var shape:=CircleShape2D.new()
		shape.radius=29
		button.shape=shape
		button.texture_normal=_button_texture({"move_left":"left","move_right":"right","attack":"sword"}.get(key,key))
		button.texture_pressed=button.texture_normal
		# The native texture origin is top-left, while the touch shape is centered.
		button.shape_centered=true
		button.modulate=Color(1,1,1,0.88)
	for pair in [[interact_button,"hand"],[new_map_button,"map"],[$Refuge,"sword"]]:
		_skin(pair[0],pair[1])
	fullscreen_button=Button.new()
	fullscreen_button.name="Fullscreen"
	add_child(fullscreen_button)
	_skin(fullscreen_button,"fullscreen")
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	drop_button=Button.new()
	drop_button.name="DropCrystal"
	add_child(drop_button)
	_skin(drop_button,"drop")
	drop_button.pressed.connect(func(): throw_requested.emit())
	get_viewport().size_changed.connect(_layout)
	_layout()

func _button_texture(key: String) -> Texture2D:
	# SVG drawing remains editable and matches the resource and interaction symbols.
	var image:=Image.create(58,58,false,Image.FORMAT_RGBA8)
	image.fill(Color(0.04,0.09,0.12,0.72))
	var glyph:=Icons.get_icon(key).get_image()
	glyph.resize(30,30,Image.INTERPOLATE_LANCZOS)
	image.blend_rect(glyph,Rect2i(0,0,30,30),Vector2i(14,14))
	return ImageTexture.create_from_image(image)

func _skin(button: Button, key: String) -> void:
	button.text=""
	button.icon=Icons.get_icon(key)
	button.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon=true
	button.add_theme_constant_override("icon_max_width",30)
	button.focus_mode=Control.FOCUS_NONE
	var style:=StyleBoxFlat.new()
	style.bg_color=Color(0.04,0.09,0.12,0.82)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(12)
	button.add_theme_stylebox_override("normal",style)
	var pressed:=style.duplicate()
	pressed.bg_color=Color(0.18,0.36,0.36,0.94)
	button.add_theme_stylebox_override("pressed",pressed)
	button.add_theme_stylebox_override("hover",pressed)

func _layout() -> void:
	var size:=get_viewport().get_visible_rect().size
	var height:=size.y
	var width:=size.x
	for pair in [["move_left",24.0],["move_right",92.0],["dash",width-216],["jump",width-148],["attack",width-80]]:
		get_node(pair[0]).position=Vector2(pair[1],height-82)
	drop_button.position=Vector2(178,height-82)
	drop_button.size=Vector2(58,58)
	$pause.position=Vector2(width-80,14)
	$restart.position=Vector2(width-148,82)
	interact_button.position=Vector2(width-292,height-82)
	interact_button.size=Vector2(62,58)
	new_map_button.position=Vector2(width-216,82)
	new_map_button.size=Vector2(58,58)
	$Refuge.position=Vector2(width-80,82)
	$Refuge.size=Vector2(58,58)
	fullscreen_button.position=Vector2(width-148,14)
	fullscreen_button.size=Vector2(58,58)

func present_world(sim, is_paused: bool, at: float, grounded: bool) -> void:
	# No textual panel participates in the playable HUD.
	var choice: Dictionary=sim.context(at) if focus_key.is_empty() else sim.context_for_key(at,focus_key)
	interact_button.disabled=is_paused or not grounded or not choice.enabled or not sim.hero.is_alive()
	interact_button.icon=Icons.get_icon("chest" if choice.id=="chest" else "crystal" if choice.cost>0 else "hand")
	$restart.visible=is_paused or not sim.hero.is_alive()
	new_map_button.visible=is_paused or not sim.hero.is_alive()
	$Refuge.visible=is_paused
	drop_button.disabled=is_paused or not sim.hero.is_alive() or sim.pouch.amount<=0
	var map=sim.frontier
	dashboard.values={"hp":sim.hero.hp,"shield":sim.hero.shield,"crystal":"%d/%d" % [sim.pouch.amount,sim.pouch.capacity],"wood":map.wood,"food":map.food,"stone":map.stone,"herbs":map.herbs,"scrap":sim.world.scrap,"day":sim.clock.day,"survived":sim.clock.survived,"full":sim.pouch.amount>=sim.pouch.capacity}
	dashboard.health_ratio=clampf(float(sim.hero.hp)/sim.hero.stats.max_hp,0,1)
	dashboard.phase_ratio=clampf(sim.clock.remaining/(sim.clock.night_seconds if sim.clock.is_night else sim.clock.day_seconds),0,1)
	dashboard.is_night=sim.clock.is_night
	dashboard.is_paused=is_paused
	dashboard.dead=not sim.hero.is_alive()
	dashboard.victory=sim.kingdom_established()
	dashboard.queue_redraw()

func _toggle_fullscreen() -> void:
	var window:=get_window()
	window.mode=Window.MODE_WINDOWED if window.mode==Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
