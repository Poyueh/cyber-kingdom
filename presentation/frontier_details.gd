extends RefCounted
## Cosmetic placement uses a separate seed stream, so art never changes resources or saves.
const TEXTURES={"fir":preload("res://art/frontier/variety-v001/fir.png"),"oak":preload("res://art/frontier/variety-v001/oak.png"),"dead_tree":preload("res://art/frontier/variety-v001/dead_tree.png"),"cedar":preload("res://art/frontier/variety-v001/cedar.png"),"log":preload("res://art/frontier/variety-v001/log.png"),"mushrooms":preload("res://art/frontier/variety-v001/mushrooms.png"),"arch":preload("res://art/frontier/variety-v001/arch.png"),"dragon_statue":preload("res://art/frontier/variety-v001/dragon_statue.png"),"basalt":preload("res://art/frontier/variety-v001/basalt.png"),"quartz":preload("res://art/frontier/variety-v001/quartz.png"),"gear":preload("res://art/frontier/variety-v001/gear.png"),"ferns":preload("res://art/frontier/variety-v001/ferns.png")}
static func layout(seed: int,regions: Array) -> Array[Dictionary]:
	var rng:=RandomNumberGenerator.new()
	rng.seed=seed^0x31a89f
	var result: Array[Dictionary]=[]
	for index in range(regions.size()):
		var region: Dictionary=regions[index]
		var palette: Array={"forest":["log","mushrooms","ferns"],"quarry":["gear","mushrooms","ferns"],"ruins":["arch","dragon_statue","gear","ferns"]}[region.kind]
		for i in range(rng.randi_range(3,5)):
			result.append({"region":index,"x":region.x+rng.randf_range(40,region.width-40),"kind":palette[rng.randi_range(0,palette.size()-1)],"scale":rng.randf_range(0.7,1.0),"flip":rng.randf()<0.5})
	return result
static func harvest_texture(kind: String,x: float,seed: int) -> Texture2D:
	var pick:=posmod(int(x)*31+seed,4)
	if kind in ["tree","tree-plain"]:return TEXTURES[["fir","oak","dead_tree","cedar"][pick]]
	if kind=="crystal":return TEXTURES["basalt" if pick<2 else "quartz"]
	return null
static func draw_background(view: Node2D,details: Array,regions: Array) -> void:
	for detail in details:
		var texture: Texture2D=TEXTURES[detail.kind]
		var size: Vector2=texture.get_size()*detail.scale
		var tint:=Color("a3b2bc")
		tint.a=view._region_reveal(detail.region)
		view.draw_set_transform(Vector2(detail.x,430),0,Vector2(-1 if detail.flip else 1,1))
		view.draw_texture_rect(texture,Rect2(Vector2(-size.x/2,-size.y),size),false,tint)
	view.draw_set_transform(Vector2.ZERO)
